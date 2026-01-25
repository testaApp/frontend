import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../models/standings/standings.dart';
import '../models/standings/standings_failure.dart';
import '../util/baseUrl.dart';

Future<Either<StandingsFailure, Map<String, List<List<TableItem>>>>>
    getNewerStanding({
  required int leagueId,
  required String? season,
}) async {
  final String url = BaseUrl().url;
  try {
    final response = await http.get(Uri.parse(
        '$url/api/leagues/standingsbyseason/?leagueId=$leagueId&season=$season'));
    if (response.statusCode == 200) {
      final nestedParsed = jsonDecode(response.body);

      final List<dynamic>? overallStanding = nestedParsed['overall'];
      final List<dynamic>? homeStanding = nestedParsed['home'];
      final List<dynamic>? awayStanding = nestedParsed['away'];
      final String seasonn = nestedParsed['season'].toString();

      List<List<TableItem>> overallStandingList = overallStanding != null
          ? overallStanding.map<List<TableItem>>((list) {
              List<TableItem> listOfTables = list
                  .map<TableItem>((item) => TableItem.Overall(item, seasonn))
                  .toList();
              return listOfTables;
            }).toList()
          : [];

      List<List<TableItem>> homeStandingList = [];
      if (homeStanding != null) {
        for (int i = 0; i < homeStanding.length; i++) {
          List<TableItem> listOfTables = [];

          for (int j = 0; j < homeStanding[i].length; j++) {
            try {
              listOfTables.add(TableItem.homeStat(homeStanding[i][j], j));
            } catch (e) {}
          }

          homeStandingList.add(listOfTables);
        }
      }

      List<List<TableItem>> awayStandingList = [];
      if (awayStanding != null) {
        for (int i = 0; i < awayStanding.length; i++) {
          List<TableItem> listOfTables = [];

          for (int j = 0; j < awayStanding[i].length; j++) {
            try {
              listOfTables.add(TableItem.awayStat(awayStanding[i][j], j));
            } catch (e) {}
          }

          awayStandingList.add(listOfTables);
        }
      }

      return Right({
        'overall': overallStandingList,
        'home': homeStandingList,
        'away': awayStandingList,
      });
    } else if (response.statusCode == 400) {
      return Left(NetworkFailure());
    }
    return Left(NetworkFailure());
  } catch (e) {
    return Left(NetworkFailure());
  }
}

Future<Either<StandingsFailure, List<List<List<TableItem>>>>> getLeagueWinners(
    {required int leagueId}) async {
  final String url = BaseUrl().url;

  try {
    final response = await http
        .get(Uri.parse('$url/api/leagues/champions?leagueId=$leagueId'));
    print('Champions response for league $leagueId: ${response.body}');

    if (response.statusCode == 200) {
      final nestedParsed = jsonDecode(response.body);

      if (nestedParsed == null) {
        return Left(NetworkFailure(message: 'Invalid response'));
      }

      List<List<List<TableItem>>> standings = [];
      List<dynamic> seasonsData =
          nestedParsed is List ? nestedParsed : [nestedParsed];

      for (var seasonData in seasonsData) {
        if (seasonData['standings'] == null) continue;

        List<List<TableItem>> seasonStandings = [];
        List<dynamic> standingsGroups = seasonData['standings'] is List
            ? seasonData['standings']
            : [seasonData['standings']];

        for (var group in standingsGroups) {
          List<TableItem> groupStandings = [];
          List<dynamic> teamStandings = group is List ? group : [group];

          for (var standing in teamStandings) {
            if (standing != null && standing['teamData'] != null) {
              groupStandings.add(TableItem.Overall(
                  standing, seasonData['season']?.toString() ?? ''));
            }
          }

          if (groupStandings.isNotEmpty) {
            seasonStandings.add(groupStandings);
          }
        }

        if (seasonStandings.isNotEmpty) {
          standings.add(seasonStandings);
        }
      }

      return Right(standings);
    }

    return Left(NetworkFailure(message: 'Failed to fetch data'));
  } catch (e, stackTrace) {
    print('Error fetching league winners: $e\n$stackTrace');
    return Left(NetworkFailure(message: e.toString()));
  }
}
