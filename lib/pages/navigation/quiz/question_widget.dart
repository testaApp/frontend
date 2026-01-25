import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../../../main.dart';
import 'quiz_model.dart';
import '../../constants/text_utils.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final Function(String) onAnswer;
  final bool isAnswered;
  final bool? isCorrect;
  final bool isDark;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.isAnswered,
    this.isCorrect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = localLanguageNotifier.value;
    final questionText = question.getQuestionText(languageCode);
    final options = question.getOptions(languageCode);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionText,
            style: TextUtils.setTextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (question.imageUrl != null) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                question.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return _buildOptionButton(context, option, index.toString());
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, String option, String index) {
    final bool isSelected = isAnswered && option == question.selectedAnswer;
    final bool isCorrectAnswer = option == question.correctAnswer;

    Color getButtonColor() {
      if (!isAnswered) {
        return isDark ? Colors.white.withOpacity(0.1) : Colors.white;
      }
      if (isSelected) {
        return isCorrect ?? false
            ? Colors.green.withOpacity(isDark ? 0.3 : 0.1)
            : Colors.red.withOpacity(isDark ? 0.3 : 0.1);
      }
      if (isCorrectAnswer) {
        return Colors.green.withOpacity(isDark ? 0.3 : 0.1);
      }
      return isDark ? Colors.white.withOpacity(0.1) : Colors.white;
    }

    Future<void> handleAnswer() async {
      if (option != question.correctAnswer) {
        try {
          if (await Vibration.hasVibrator() ?? false) {
            await Vibration.vibrate(duration: 300);
          }
        } catch (e) {
          // Silently handle the error if vibration is not available
          print('Vibration not available: $e');
        }
      }
      onAnswer(option);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAnswered ? null : handleAnswer,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: getButtonColor(),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                width: 1,
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
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: TextUtils.setTextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: isSelected || isCorrectAnswer
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isAnswered && (isSelected || isCorrectAnswer))
                  Icon(
                    isCorrect ?? false ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ?? false ? Colors.green : Colors.red,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
