import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../main.dart';
import 'quiz_model.dart';
import '../../../util/baseUrl.dart';

class QuizRepository {
  final String baseUrl = BaseUrl().url;
  final FlutterSecureStorage secureStorage;

  QuizRepository({required this.secureStorage});

  Future<List<Question>> fetchQuestions() async {
    try {
      final String languageCode = localLanguageNotifier.value;
      final response = await http
          .get(Uri.parse('$baseUrl/daily-questions?lang=$languageCode'));

      developer.log('Quiz API Response: ${response.body}',
          name: 'QuizRepository');

      if (response.statusCode == 200) {
        List<dynamic> questionsJson = json.decode(response.body);
        if (questionsJson.isEmpty) {
          throw Exception('No questions available');
        }

        return questionsJson.map((json) {
          try {
            json['currentLanguage'] = languageCode;
            return Question.fromJson(json);
          } catch (e) {
            developer.log('Error parsing question: $e',
                name: 'QuizRepository', error: e);
            throw Exception('Invalid question format');
          }
        }).toList();
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Failed to load questions',
          name: 'QuizRepository', error: e);
      throw Exception('Failed to load questions: $e');
    }
  }

  Future<void> sendResults(int score, int totalQuestions) async {
    try {
      final String? accessToken = await secureStorage.read(key: 'access_token');

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/results'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // Add auth header
        },
        body: json.encode({
          'score': score,
          'totalQuestions': totalQuestions,
          'date': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        developer.log('Failed to send results: ${response.statusCode}',
            name: 'QuizRepository', error: response.body);
        throw Exception('Failed to send results');
      }

      developer.log('Quiz results sent successfully', name: 'QuizRepository');
    } catch (e) {
      developer.log('Error sending quiz results',
          name: 'QuizRepository', error: e);
      throw Exception('Failed to send results: $e');
    }
  }
}
