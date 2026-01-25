import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../domain/core/failure.dart';
import '../domain/team/team.dart';
import '../util/baseUrl.dart';

class TeamDataProvider {
  static String baseUrl = '${BaseUrl().url}/api';
  late Box<int> bestPlayerBox;

  TeamDataProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    bestPlayerBox = await Hive.openBox<int>('team');
  }

  Future<void> addToHive(int teamId) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    bestPlayerBox = await Hive.openBox<int>('team');
    await bestPlayerBox.add(teamId);
  }

  Future<void> removeFromHive(int teamId) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    bestPlayerBox = await Hive.openBox<int>('team');
    final keys = bestPlayerBox.keys
        .where((key) => bestPlayerBox.get(key) == teamId)
        .toList();
    for (final key in keys) {
      await bestPlayerBox.delete(key);
    }
  }

  Future<List<TeamInfo>> getTeams() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/teams'));
      // //print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // //print(data);
        return data
            .map((json) => TeamInfo.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Failure('Failed to load teams');
      }
    } catch (e) {
      throw Failure('Failed to connect to the server');
    }
  }

  Future<TeamInfo> getTeamById(int teamId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/teams/$teamId'));
      // //print(response.body);
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return TeamInfo.fromJson(data as Map<String, dynamic>);
      } else {
        throw Failure('Failed to load team');
      }
    } catch (e) {
      throw Failure('Failed to connect to the server');
    }
  }

  Future<List<int>> getBestPlayerChoose() async {
    return bestPlayerBox.values.toList();
  }
}
