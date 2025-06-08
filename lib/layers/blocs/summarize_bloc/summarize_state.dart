part of 'summarize_bloc.dart';

 class SummarizeState extends Equatable {
  const SummarizeState();
  
  @override
  List<Object> get props => [];
}

 class SummarizeInitial extends SummarizeState {}

class ConvertingAudioToText extends SummarizeState{}
class ConvertedAudioToTexxt extends SummarizeState{
  final String text;
 const  ConvertedAudioToTexxt({required this.text});
   @override
  List<Object> get props => [text];
}

class ConvertTextError extends SummarizeState{
  final String error;
  const ConvertTextError({required this.error});
   @override
  List<Object> get props => [error];
}
class SummarizingText extends SummarizeState{}

class SummarizedText extends SummarizeState{
  final String summary;
  const SummarizedText({required this.summary});
   @override
  List<Object> get props => [summary];
}

class SummarizeError extends SummarizeState{
  final String error;
  const SummarizeError({required this.error});
   @override
  List<Object> get props => [error];
}
