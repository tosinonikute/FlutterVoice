part of 'summarize_bloc.dart';

class SummarizeEvent extends Equatable {
  const SummarizeEvent();
  @override
  List<Object> get props => [];
}

class SummarizeTextEvent extends SummarizeEvent {
  const SummarizeTextEvent({required this.text});
  final String text;
  @override
  List<Object> get props => [text];
}
class ConvertAudioToTextEvent extends SummarizeEvent {
  const ConvertAudioToTextEvent({required this.audioPath});
  final String audioPath;
  @override
  List<Object> get props => [audioPath];
}




