import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:blogapp/domain/PlayerPreference/PlayerPreference.dart';
import 'package:blogapp/domain/PlayerPreference/PlayerPreferenceFailure.dart';
import 'package:blogapp/domain/core/failure.dart';
import 'package:blogapp/core/network/baseUrl.dart';

class PlayersDataProvider {
  static String apiUrl = '${BaseUrl().url}/api/player-preferences';

  // Get all PlayerPreference preferences
  Future<List<PlayerPreference>> getAllPlayers() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      ////print(response.body);
      if (response.statusCode == 200) {
        // ////print(response.body);
        final List<dynamic> responseData = json.decode(response.body);
        final List<PlayerPreference> playerPreferences =
            responseData.map((item) {
          return PlayerPreference.fromJson(item);
        }).toList();
        return playerPreferences;
      } else {
        throw ServerErrorFailure();
      }
    } catch (e) {
      ////print(e);
      throw NetworkErrorFailure();
    }
  }

  // Get PlayerPreference preference by ID
  Future<PlayerPreference> getPlayerById(String id) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PlayerPreference.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw PlayerPreferenceNotFoundFailure();
      } else {
        throw ServerErrorsFailure();
      }
    } catch (e) {
      throw NetworkErrorFailure();
    }
  }

  // Create a new PlayerPreference preference
  Future<PlayerPreference> createPlayer(PlayerPreference preference) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(preference.toJson()),
      );
      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return PlayerPreference.fromJson(jsonData);
      } else {
        throw PlayerPreferenceCreationFailure();
      }
    } catch (e) {
      throw NetworkErrorFailure();
    }
  }

  Future<PlayerPreference> updatePlayer(
      String id, PlayerPreference preference) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(preference.toJson()),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PlayerPreference.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw PlayerPreferenceNotFoundFailure();
      } else {
        throw PlayerPreferenceUpdateFailure();
      }
    } catch (e) {
      throw NetworkErrorFailure();
    }
  }

  Future<void> deletePlayer(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 404) {
        throw PlayerPreferenceNotFoundFailure();
      } else {
        throw PlayerPreferenceDeletionFailure();
      }
    } catch (e) {
      throw NetworkErrorFailure();
    }
  }
}
