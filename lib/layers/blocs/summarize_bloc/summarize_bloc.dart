import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:voice_summary/layers/services/speech_to_text_service.dart';
import 'package:voice_summary/layers/services/summarizer_service.dart';

part 'summarize_event.dart';
part 'summarize_state.dart';

class SummarizeBloc extends Bloc<SummarizeEvent, SummarizeState> {
  final speechToTextService = SpeechToTextService();
  final summarizeService = SummarizerService();
  final logger = Logger();

  /// here we will use the [SpeechToTextService] to get the text from the audio file
  /// then we will use the [SummarizerService] to summarize the text
  /// then we will emit the summarized text
  /// the summarizer service uses the [gemini] api to summarize the text
  /// the [SpeechToTextService] uses the [google] api to transcribe the audio
  SummarizeBloc() : super(SummarizeInitial()) {
    on<ConvertAudioToTextEvent>((event, emit) async {
      try {
        emit(ConvertingAudioToText());
        final text = await speechToTextService.transcribeAudio(event.audioPath);
        if (text == null) {
          throw Exception('Failed to convert audio to text');
        }
        Logger().i('text: $text');
        emit(ConvertedAudioToTexxt(text: text));
        Logger().i('Converted audio to text');
      } on DioException catch (e) {
        Logger().e('Error in ConvertAudioToTextEvent: $e');
        emit(
          ConvertTextError(
            error: e.response?.data['error']['message'] ?? e.message,
          ),
        );
      } catch (e, st) {
        Logger().w(st);
        Logger().e('Error in ConvertAudioToTextEvent: $e');
        emit(ConvertTextError(error: e.toString()));
      }
    });
    on<SummarizeTextEvent>((event, emit) async {
      emit(SummarizingText());
      try {
        final text = """
        Artificial Intelligence (AI) has revolutionized numerous aspects of our daily lives, from virtual assistants 
        to autonomous vehicles. The field of AI encompasses machine learning, natural language processing,
         and computer vision, among other disciplines. Machine learning algorithms enable computers 
         to learn from data and improve their performance over time without explicit programming.
          Deep learning, a subset of machine learning, uses neural networks with multiple layers to 
          process complex patterns in data. Natural language processing allows computers to understand, 
          interpret, and generate human language, powering applications like chatbots and translation services. 
          Computer vision enables machines to interpret and make decisions based on visual data, driving innovations 
          in facial recognition and medical imaging. The ethical implications of AI development, including 
          privacy concerns and algorithmic bias, have become increasingly important topics of discussion.
           As AI technology continues to advance, it presents both opportunities for innovation and challenges 
           that require careful consideration and responsible development practices.
        """;
        final summary = await summarizeService.summarizeText(event.text);
        //  final summary = await summarizeService.summarizeText(text);
        Logger().i("summary: $summary");
        emit(SummarizedText(summary: summary ?? ""));
      } on DioException catch (e) {
        Logger().e('Error in ConvertAudioToTextEvent: $e');
        emit(
          SummarizeError(
            error: e.response?.data['error']['message'] ?? e.message,
          ),
        );
      } catch (e, st) {
        Logger().w(st);
        Logger().e('Error in ConvertAudioToTextEvent: $e');
        emit(SummarizeError(error: e.toString()));
      }
    });
  }
}
