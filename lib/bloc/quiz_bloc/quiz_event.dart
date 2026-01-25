import 'package:equatable/equatable.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object> get props => [];
}

class LoadQuiz extends QuizEvent {}

class AnswerQuestion extends QuizEvent {
  final dynamic answer;

  const AnswerQuestion(this.answer);

  @override
  List<Object> get props => [answer];
}

class NextQuestion extends QuizEvent {}

class CompleteQuiz extends QuizEvent {}
