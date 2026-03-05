import 'package:equatable/equatable.dart';
import 'package:blogapp/features/navigation/pages/quiz/quiz_model.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final int score;
  final bool isAnswered;
  final bool isCorrect;
  final int timeLeft;

  const QuizLoaded({
    required this.questions,
    required this.currentQuestionIndex,
    required this.score,
    required this.isAnswered,
    required this.isCorrect,
    required this.timeLeft,
  });

  @override
  List<Object> get props =>
      [questions, currentQuestionIndex, score, isAnswered, isCorrect, timeLeft];

  QuizLoaded copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    int? score,
    bool? isAnswered,
    bool? isCorrect,
    int? timeLeft,
  }) {
    return QuizLoaded(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }
}

class QuizCompleted extends QuizState {
  final int score;
  final int totalQuestions;

  const QuizCompleted({required this.score, required this.totalQuestions});

  @override
  List<Object> get props => [score, totalQuestions];
}

class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object> get props => [message];
}
