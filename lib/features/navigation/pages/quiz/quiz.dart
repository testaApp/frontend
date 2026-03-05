import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blogapp/state/bloc/quiz_bloc/quiz_bloc.dart';
import 'package:blogapp/state/bloc/quiz_bloc/quiz_event.dart';
import 'package:blogapp/state/bloc/quiz_bloc/quiz_state.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/shared/constants/colors.dart';
import 'package:blogapp/shared/constants/text_utils.dart';
import 'package:blogapp/features/auth/pages/login.dart';
import 'package:blogapp/features/auth/services/firebase_auth_helpers.dart';
import 'package:blogapp/features/navigation/pages/quiz/question_widget.dart';
import 'package:blogapp/features/navigation/pages/quiz/quiz_progress_bar.dart';
import 'package:blogapp/features/navigation/pages/quiz/quiz_repository.dart';
import 'package:blogapp/features/navigation/pages/quiz/quiz_result.dart';
import 'package:blogapp/features/navigation/pages/quiz/quiz_timer.dart';

class DailyQuizPage extends StatefulWidget {
  const DailyQuizPage({super.key});

  @override
  State<DailyQuizPage> createState() => _DailyQuizPageState();
}

class _DailyQuizPageState extends State<DailyQuizPage> {
  bool _loginDialogShown = false;

  @override
  void initState() {
    super.initState();
    _guardLogin();
  }

  Future<void> _guardLogin() async {
    final user = await ensureFirebaseUser();
    if (!mounted) return;
    if (user == null || user.isAnonymous) {
      if (_loginDialogShown) return;
      _loginDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showLoginRequiredDialog(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => QuizBloc(
        quizRepository: QuizRepository(),
      )..add(LoadQuiz()),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(
                Icons.close,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () => _showExitConfirmationDialog(context, isDark),
            ),
          ],
          title: Text(
            DemoLocalizations.dailyQuizChallenge,
            style: TextUtils.setTextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocBuilder<QuizBloc, QuizState>(
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1A1A1A),
                          const Color(0xFF2D2D2D),
                        ]
                      : [
                          Colors.white,
                          const Color(0xFFF8F9FA),
                        ],
                ),
              ),
              child: _buildStateWidget(context, state, isDark),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStateWidget(BuildContext context, QuizState state, bool isDark) {
    if (state is QuizLoading) {
      return _buildLoadingState(isDark);
    } else if (state is QuizLoaded) {
      return _buildQuizContent(context, state, isDark);
    } else if (state is QuizCompleted) {
      return QuizResult(
        score: state.score,
        totalQuestions: state.totalQuestions,
      );
    } else if (state is QuizError) {
      return _buildErrorState(context, state, isDark);
    }
    return Container();
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.black12,
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.white : Colorscontainer.greenColor,
              ),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Preparing your challenge...',
            style: TextUtils.setTextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent(
      BuildContext context, QuizLoaded state, bool isDark) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                QuizTimer(
                  timeLeft: state.timeLeft,
                  totalTime: 10,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuizProgressBar(
                    currentQuestion: state.currentQuestionIndex + 1,
                    totalQuestions: state.questions.length,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark ? Colors.black26 : Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: QuestionWidget(
                      question: state.questions[state.currentQuestionIndex],
                      onAnswer: (answer) =>
                          context.read<QuizBloc>().add(AnswerQuestion(answer)),
                      isAnswered: state.isAnswered,
                      isCorrect: state.isCorrect,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildScoreIndicator(state, isDark),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator(QuizLoaded state, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colorscontainer.greenColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colorscontainer.greenColor.withOpacity(0.1),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.stars_rounded,
            color: isDark ? Colors.amber : Colorscontainer.greenColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            '${state.score} / ${state.currentQuestionIndex + 1}',
            style: TextUtils.setTextStyle(
              fontSize: 20,
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, QuizError state, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              state.message,
              style: TextUtils.setTextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => context.read<QuizBloc>().add(LoadQuiz()),
            icon: const Icon(Icons.refresh),
            label: Text(DemoLocalizations.tryAgain),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colorscontainer.greenColor,
              foregroundColor:
                  isDark ? Colorscontainer.greenColor : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login required'),
          content:
              const Text('Please sign in to access the quiz and track results.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Login()),
                );
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ],
        );
      },
    );
  }

  void _showExitConfirmationDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colorscontainer.greenColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.exit_to_app_rounded,
                    size: 40,
                    color: isDark ? Colors.white : Colorscontainer.greenColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  DemoLocalizations.exitQuiz,
                  style: TextUtils.setTextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  DemoLocalizations.exitQuizConfirmation,
                  textAlign: TextAlign.center,
                  style: TextUtils.setTextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Text(
                          DemoLocalizations.cancel,
                          style: TextUtils.setTextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colorscontainer.greenColor,
                          foregroundColor: isDark
                              ? Colorscontainer.greenColor
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          DemoLocalizations.exit,
                          style: TextUtils.setTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
