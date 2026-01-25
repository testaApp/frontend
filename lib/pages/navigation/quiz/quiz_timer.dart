import 'package:flutter/material.dart';

import '../../../localization/demo_localization.dart';
import '../../constants/text_utils.dart';

class QuizTimer extends StatelessWidget {
  final int timeLeft;
  final int totalTime;

  const QuizTimer({
    super.key,
    required this.timeLeft,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getTimerColor(isDark).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            color: _getTimerColor(isDark),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$timeLeft ${DemoLocalizations.seconds}',
            style: TextUtils.setTextStyle(
              fontSize: 18,
              color: _getTimerColor(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimerColor(bool isDark) {
    if (timeLeft <= 5) return Colors.red;
    if (timeLeft <= 10) return Colors.orange;
    return isDark ? Colors.white : Colors.black87;
  }
}
