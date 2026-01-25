import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../pages/navigation/quiz/quiz_repository.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizRepository _quizRepository;
  Timer? _timer;

  QuizBloc({required QuizRepository quizRepository})
      : _quizRepository = quizRepository,
        super(QuizInitial()) {
    on<LoadQuiz>(_onLoadQuiz);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<NextQuestion>(_onNextQuestion);
    on<CompleteQuiz>(_onCompleteQuiz);
  }

  Future<void> _onLoadQuiz(LoadQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    try {
      final questions = await _quizRepository.fetchQuestions();
      emit(QuizLoaded(
        questions: questions,
        currentQuestionIndex: 0,
        score: 0,
        isAnswered: false,
        isCorrect: false,
        timeLeft: 10,
      ));
      _startTimer();
    } catch (e) {
      emit(QuizError(e.toString()));
    }
  }

  void _onAnswerQuestion(AnswerQuestion event, Emitter<QuizState> emit) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final currentQuestion =
          currentState.questions[currentState.currentQuestionIndex];

      currentQuestion.selectedAnswer = event.answer;
      bool isCorrect = currentQuestion.isCorrect();

      emit(currentState.copyWith(
        isAnswered: true,
        isCorrect: isCorrect,
        score: isCorrect ? currentState.score + 1 : currentState.score,
      ));

      _timer?.cancel();
      Future.delayed(const Duration(seconds: 2), () => add(NextQuestion()));
    }
  }

  void _onNextQuestion(NextQuestion event, Emitter<QuizState> emit) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      if (currentState.currentQuestionIndex <
          currentState.questions.length - 1) {
        emit(currentState.copyWith(
          currentQuestionIndex: currentState.currentQuestionIndex + 1,
          isAnswered: false,
          timeLeft: 10,
        ));
        _startTimer();
      } else {
        add(CompleteQuiz());
      }
    }
  }

  Future<void> _onCompleteQuiz(
      CompleteQuiz event, Emitter<QuizState> emit) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      await _quizRepository.sendResults(
          currentState.score, currentState.questions.length);
      emit(QuizCompleted(
          score: currentState.score,
          totalQuestions: currentState.questions.length));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is QuizLoaded) {
        final currentState = state as QuizLoaded;
        if (currentState.timeLeft > 0) {
          emit(currentState.copyWith(timeLeft: currentState.timeLeft - 1));
        } else {
          add(const AnswerQuestion(null));
        }
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
