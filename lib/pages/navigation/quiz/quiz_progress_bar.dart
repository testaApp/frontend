import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class QuizProgressBar extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;

  const QuizProgressBar({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: currentQuestion / totalQuestions,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.white70, Colors.white]
                      : [
                          Colorscontainer.greenColor.withOpacity(0.7),
                          Colorscontainer.greenColor
                        ],
                ),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colorscontainer.greenColor.withOpacity(0.3),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
