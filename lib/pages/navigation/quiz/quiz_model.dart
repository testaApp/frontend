import '../../../main.dart';

enum QuestionType { multipleChoice, trueFalse }

class Question {
  final String id;
  final String question_en;
  final String question_am;
  final String question_or;
  final String question_tr;
  final String question_so;
  final QuestionType type;
  final List<String> options_en;
  final List<String> options_am;
  final List<String> options_or;
  final List<String> options_tr;
  final List<String> options_so;
  final dynamic correctAnswer;
  final String category;
  final String difficulty;
  final String? imageUrl;
  String? selectedAnswer;

  Question({
    required this.id,
    required this.question_en,
    required this.question_am,
    required this.question_or,
    required this.question_tr,
    required this.question_so,
    required this.type,
    required this.options_en,
    required this.options_am,
    required this.options_or,
    required this.options_tr,
    required this.options_so,
    required this.correctAnswer,
    required this.category,
    required this.difficulty,
    this.imageUrl,
    this.selectedAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    String currentLanguage =
        json['currentLanguage'] ?? localLanguageNotifier.value;

    return Question(
      id: json['id']?.toString() ?? '',
      question_en: currentLanguage == 'en' ? json['question'] ?? '' : '',
      question_am: currentLanguage == 'am' ? json['question'] ?? '' : '',
      question_or: currentLanguage == 'or' ? json['question'] ?? '' : '',
      question_tr: currentLanguage == 'tr' ? json['question'] ?? '' : '',
      question_so: currentLanguage == 'so' ? json['question'] ?? '' : '',
      type: json['options'] != null && (json['options'] as List).length == 2
          ? QuestionType.trueFalse
          : QuestionType.multipleChoice,
      options_en: currentLanguage == 'en'
          ? List<String>.from(json['options'] ?? [])
          : [],
      options_am: currentLanguage == 'am'
          ? List<String>.from(json['options'] ?? [])
          : [],
      options_or: currentLanguage == 'or'
          ? List<String>.from(json['options'] ?? [])
          : [],
      options_tr: currentLanguage == 'tr'
          ? List<String>.from(json['options'] ?? [])
          : [],
      options_so: currentLanguage == 'so'
          ? List<String>.from(json['options'] ?? [])
          : [],
      correctAnswer: json['correctAnswer'],
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 'easy',
      imageUrl: json['imageUrl'],
    );
  }

  String getQuestionText(String languageCode) {
    switch (languageCode) {
      case 'am':
        return question_am;
      case 'or':
        return question_or;
      case 'tr':
        return question_tr;
      case 'so':
        return question_so;
      default:
        return question_en;
    }
  }

  List<String> getOptions(String languageCode) {
    switch (languageCode) {
      case 'am':
        return options_am;
      case 'or':
        return options_or;
      case 'tr':
        return options_tr;
      case 'so':
        return options_so;
      default:
        return options_en;
    }
  }

  bool isCorrect() {
    if (selectedAnswer == null) return false;

    if (type == QuestionType.trueFalse) {
      return selectedAnswer?.toLowerCase() ==
          correctAnswer.toString().toLowerCase();
    }

    if (type == QuestionType.multipleChoice) {
      if (correctAnswer is int) {
        try {
          return int.parse(selectedAnswer!) == correctAnswer;
        } catch (e) {
          return false;
        }
      } else {
        return selectedAnswer?.toLowerCase() ==
            correctAnswer.toString().toLowerCase();
      }
    }

    return false;
  }
}
