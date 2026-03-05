import 'package:flutter/material.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/shared/constants/text_utils.dart';

class QuizResult extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const QuizResult(
      {super.key, required this.score, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 100, color: Colors.white),
          const SizedBox(height: 20),
          Text(
            DemoLocalizations.daily_quiz_completed,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            '${DemoLocalizations.result}: $score / $totalQuestions',
            style: TextUtils.setTextStyle(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Implement leaderboard viewing logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: Text(DemoLocalizations.viewLeaderboard),
          ),
        ],
      ),
    );
  }
}
