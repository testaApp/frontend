import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/following_storage_service.dart';
import 'package:blogapp/features/auth/services/firebase_auth_helpers.dart';
import 'package:blogapp/core/network/baseUrl.dart';

class FollowingSyncResult {
  final List<int> matchIds;
  final List<int> teamIds;
  final List<int> playerIds;
  final List<String> podcastIds;

  const FollowingSyncResult({
    this.matchIds = const [],
    this.teamIds = const [],
    this.playerIds = const [],
    this.podcastIds = const [],
  });
}

Future<FollowingSyncResult> syncFollowingDataAfterLogin({
  required FollowingStorageService storageService,
}) async {
  var matchIds = <int>[];
  var teamIds = <int>[];
  var playerIds = <int>[];
  var podcastIds = <String>[];

  try {
    final url = BaseUrl().url;
    final headers = await buildAuthHeaders();

    // Fetch followed matches
    try {
      final matchesResponse = await http.get(
        Uri.parse('$url/api/user/favoriteMatches'),
        headers: headers,
      );

      if (matchesResponse.statusCode == 200) {
        final matchesData = jsonDecode(matchesResponse.body);
        matchIds = (matchesData['matches'] as List)
            .map((m) => int.parse(m['id'].toString()))
            .toList();
        await storageService.syncFromServer(matches: matchIds);
      }
    } catch (_) {}

    // Fetch followed teams
    try {
      final teamsResponse = await http.get(
        Uri.parse('$url/api/user/favoriteTeams'),
        headers: headers,
      );

      if (teamsResponse.statusCode == 200) {
        final teamsData = jsonDecode(teamsResponse.body);
        final teamsList = teamsData['teams'] as List;
        teamIds = teamsList
            .map((t) => int.parse(t['id'].toString()))
            .toList();
        await storageService.syncFromServer(teams: teamIds);
        for (final team in teamsList) {
          final id = int.tryParse(team['id'].toString());
          final name = team['name']?.toString();
          if (id != null && name != null && name.isNotEmpty) {
            await storageService.setFollowedTeamName(id, name);
          }
        }
      }
    } catch (_) {}

    // Fetch followed players
    try {
      final playersResponse = await http.get(
        Uri.parse('$url/api/user/favoritePlayers'),
        headers: headers,
      );

      if (playersResponse.statusCode == 200) {
        final playersData = jsonDecode(playersResponse.body);
        final playersList = playersData['players'] as List;
        playerIds = playersList
            .map((p) => int.parse(p['id'].toString()))
            .toList();
        await storageService.syncFromServer(players: playerIds);
        for (final player in playersList) {
          final id = int.tryParse(player['id'].toString());
          final name = player['name']?.toString();
          if (id != null && name != null && name.isNotEmpty) {
            await storageService.setFollowedPlayerName(id, name);
          }
        }
      }
    } catch (_) {}

    // Fetch followed podcasts
    try {
      final podcastsResponse = await http.get(
        Uri.parse('$url/api/user/FavoritePodcasts'),
        headers: headers,
      );

      if (podcastsResponse.statusCode == 200) {
        final podcastsData = jsonDecode(podcastsResponse.body);
        podcastIds = (podcastsData['favoritePodcasts'] as List)
            .map((p) => p['id'].toString())
            .toList();
        await storageService.syncFromServer(podcasts: podcastIds);
      }
    } catch (_) {}
  } catch (_) {}

  return FollowingSyncResult(
    matchIds: matchIds,
    teamIds: teamIds,
    playerIds: playerIds,
    podcastIds: podcastIds,
  );
}
