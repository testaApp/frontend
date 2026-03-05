import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import 'package:blogapp/components/timeFormatter.dart';
import 'package:blogapp/functions/date_conversion.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/main.dart';
import 'package:blogapp/models/fixtureByLeague.dart';
import 'package:blogapp/models/fixtures/stat.dart';
import 'package:blogapp/models/fixtures/team.dart';
import 'package:blogapp/models/standings/standings_failure.dart';
import 'package:blogapp/models/teamName.dart';
import 'package:blogapp/core/network/baseUrl.dart';

class MatchApiDataSource {
  final url = BaseUrl().url;

  Future<Either<NetworkFailure, List<Stat>>> getFixturesByLeagueId(
      {required int leagueId}) async {
    try {
      final response = await http.get(Uri.parse('$url/fixtures/$leagueId'));
      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body);

        List<Stat> statList = result.map((match) {
          String language = localLanguageNotifier.value;
          String homeTeamName;
          String awayTeamName;
          if (language == 'or' || language == 'so') {
            homeTeamName = match['homeTeam']['OromoName'];
            awayTeamName = match['awayTeam']['OromoName'];
          } else if (language == 'am' || language == 'tr') {
            homeTeamName = match['homeTeam']['AmharicName'];
            awayTeamName = match['awayTeam']['AmharicName'];
          } else {
            homeTeamName = match['homeTeam']['EnglishName'];
            awayTeamName = match['awayTeam']['EnglishName'];
          }
          Team homeTeam = Team(
              id: match['homeTeam']['id'],
              name: homeTeamName,
              logo: match['homeTeam']['logo'],
              winner: match['homeTeam']['winner'],
              goal: match['goals']['home']);
          Team awayTeam = Team(
              id: match['awayTeam']['id'],
              name: awayTeamName,
              logo: match['awayTeam']['logo'],
              winner: match['awayTeam']['winner'],
              goal: match['goals']['away']);

          String venue = match['venue']['name'] ?? '';
          String leaguelogo = match['league']['logo'] ?? '';
          String referee = match['referee'] ?? '';
          String city = match['venue']?['city'] ?? '';
          String dateString = match['date'];
          String date = extractDate(dateString);
          String time = extractTimeFromIso(dateString);
          int id = match['id'];
          String? VideoId = match['youtubeHighlight']['VideoId'] ?? '';
          String? VideoTitle = match['youtubeHighlight']['VideoTitle'] ?? '';
          String? Thumbnail = match['youtubeHighlight']['Thumbnail'] ?? '';
          String dateOnly = match['dateOnly'];
          int? leagueId = match['league']['id'];
          String status = match['status']['short'] ?? '';
          int? elapsed = match['status']['elapsed'] as int?;
          String leagueName = match['league']['name'] ?? '';

          return Stat(
              secondHalfTime: match['secondHalfTime'],
              elapsed: elapsed,
              kickOfTime: match['kickOfTime'],
              leagueId: leagueId,
              homeTeam: homeTeam,
              leagueName: leagueName,
              status: status,
              homeTeamName: TeamName.fromJson(match['homeTeam']),
              awayTeamName: TeamName.fromJson(match['awayTeam']),
              round: replaceText(match['league']['round']),
              dateOnly: dateOnly,
              awayTeam: awayTeam,
              dateString: dateString,
              date: date,
              time: time,
              fixtureId: id,
              venue: venue,
              leaguelogo: leaguelogo,
              referee: referee,
              city: city,
              VideoTitle: VideoTitle,
              VideoId: VideoId,
              Thumbnail: Thumbnail);
        }).toList();
        return Right(statList);
      }
    } catch (e) {
      return left(NetworkFailure(message: e.toString()));
    }
    return left(NetworkFailure());
  }

  Future<Either<NetworkFailure, List<Stat>>> getFixturesByDate(
      {required int leagueId, required String date}) async {
    try {
      var url = Uri.parse('${BaseUrl().url}/api/fixtures/date').replace(
          queryParameters: {'leagueId': leagueId.toString(), 'date': date});

      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> result = jsonDecode(response.body)['matches'];

        List<Stat> statList = result.map((match) {
          String language = localLanguageNotifier.value;
          String homeTeamName;
          String awayTeamName;
          if (language == 'or' || language == 'so') {
            homeTeamName = match['homeTeam']['OromoName'];
            awayTeamName = match['awayTeam']['OromoName'];
          } else if (language == 'am' || language == 'tr') {
            homeTeamName = match['homeTeam']['AmharicName'];
            awayTeamName = match['awayTeam']['AmharicName'];
          } else {
            homeTeamName = match['homeTeam']['EnglishName'];
            awayTeamName = match['awayTeam']['EnglishName'];
          }
          Team homeTeam = Team(
              id: match['homeTeam']['id'],
              name: homeTeamName,
              logo: match['homeTeam']['logo'] ?? '',
              winner: match['homeTeam']['winner'],
              goal: match['goals']['home']);
          Team awayTeam = Team(
              id: match['awayTeam']['id'],
              name: awayTeamName,
              logo: match['awayTeam']['logo'] ?? '',
              winner: match['awayTeam']['winner'],
              goal: match['goals']['away']);
          String dateString = match['date'];
          String date = extractDate(dateString);
          String time = extractTimeFromIso(dateString);
          int id = match['id'];
          String venue = match['venue']['name'] ?? '';
          String leaguelogo = match['league']['logo'] ?? '';
          String? VideoId = match['youtubeHighlight']['VideoId'] ?? '';
          String? VideoTitle = match['youtubeHighlight']['VideoTitle'] ?? '';
          String? Thumbnail = match['youtubeHighlight']['Thumbnail'] ?? '';
          String referee = match['referee'] ?? '';
          String city = match['venue']?['city'] ?? '';
          String dateOnly = match['dateOnly'];
          String round = replaceText(match['league']['round']);
          int? leagueId = match['league']['id'];
          String status = match['status']['short'] ?? '';
          String leagueName = match['league']['name'] ?? '';

          int? elapsed = match['status']['elapsed'] as int?;

          return Stat(
              secondHalfTime: match['secondHalfTime'],
              elapsed: elapsed,
              kickOfTime: match['kickOfTime'],
              leagueId: leagueId,
              status: status,
              leagueName: leagueName,
              dateString: dateString,
              sortingTime: dateString,
              homeTeamName: TeamName.fromJson(match['homeTeam']),
              awayTeamName: TeamName.fromJson(match['awayTeam']),
              round: round,
              dateOnly: dateOnly,
              homeTeam: homeTeam,
              leaguelogo: leaguelogo,
              awayTeam: awayTeam,
              date: date,
              time: time,
              fixtureId: id,
              venue: venue,
              referee: referee,
              city: city,
              VideoTitle: VideoTitle,
              VideoId: VideoId,
              Thumbnail: Thumbnail);
        }).toList();

        statList.sort((a, b) {
          bool aMissing = a.sortingTime == null;
          bool bMissing = b.sortingTime == null;

          if (aMissing && bMissing) {
            return 0;
          } else if (aMissing) {
            return 1;
          } else if (bMissing) {
            return -1;
          }

          DateTime dateA = DateTime.parse(a.sortingTime!);
          DateTime dateB = DateTime.parse(b.sortingTime!);
          return dateA.compareTo(dateB);
        });

        return Right(statList);
      }
    } catch (e) {
      return left(NetworkFailure());
    }
    return left(NetworkFailure());
  }

  Future<Either<NetworkFailure, LeagueFixtures>> getFixtureListByLeague({
    required int leagueId,
    required int season, // Add season as a required parameter
  }) async {
    print('🔍 Fetching fixtures for league $leagueId and season $season');
    var url =
        Uri.parse('${BaseUrl().url}/api/fixtures/leaguefixtures/$leagueId')
            .replace(queryParameters: {'season': season.toString()});

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        String currentDate = decodedData['currentDate'];
        List<dynamic> fixtureContainer = decodedData['fixtures'];

        if (fixtureContainer.isEmpty) {
          print('⚠️ No fixtures found for league $leagueId');
          return right(
              const LeagueFixtures(previousMatches: [], upcomingMatches: []));
        }

        List<LeagueFixtures> leagueFixtures = [];
        List<FixtureListsByLeague> fixtureListByLeague = [];

        for (int i = 0; i < fixtureContainer.length; i++) {
          final element = fixtureContainer[i]['fixtures'];

          String dateOnly = fixtureContainer[i]['dateOnly'];

          List<Stat> leagueMatches = [];
          for (int i = 0; i < element.length; i++) {
            final match = element[i];

            String language = localLanguageNotifier.value;
            String homeTeamName;
            String awayTeamName;
            if (language == 'or' || language == 'so') {
              homeTeamName = match['homeTeamData']['OromoName'];
              awayTeamName = match['awayTeamData']['OromoName'];
            } else if (language == 'am' || language == 'tr') {
              homeTeamName = match['homeTeamData']['AmharicName'];
              awayTeamName = match['awayTeamData']['AmharicName'];
            } else {
              homeTeamName = match['homeTeamData']['EnglishName'];
              awayTeamName = match['awayTeamData']['EnglishName'];
            }

            Team homeTeam = Team(
                id: match['homeTeamData']['id'],
                name: homeTeamName,
                logo: match['homeTeamData']['logo'] ?? '',
                winner: match['teams']?['home']?['winner'],
                goal: match['goals']['home']);

            Team awayTeam = Team(
                id: match['awayTeamData']['id'],
                name: awayTeamName,
                logo: match['awayTeamData']['logo'] ?? '',
                winner: match['teams']?['away']?['winner'],
                goal: match['goals']['away']);

            String dateString = match['date'];
            String date = extractDate(dateString);
            String time = extractTimeFromIso(dateString);
            int id = match['id'];
            String venue = match['venue']['name'] ?? '';

            String leaguelogo = match['league']['logo'] ?? '';

            String? referee = match['referee'] ?? '';
            String? dateOnly = match['dateOnly'];
            String round = replaceText(match['league']['round']);
            int? leagueId = match['league']['id'];
            String status = match['status']['short'] ?? '';
            String leagueName = match['league']['name'] ?? '';
            int? elapsed = match['status']['elapsed'] as int?;
            final matchObject = Stat(
              secondHalfTime: match['secondHalfTime'],
              elapsed: elapsed,
              kickOfTime: match['kickOfTime'],
              leagueId: leagueId,
              status: status,
              leagueName: leagueName,
              dateString: dateString,
              homeTeamName: TeamName.fromJson(match['homeTeamData']),
              awayTeamName: TeamName.fromJson(match['awayTeamData']),
              round: round,
              dateOnly: dateOnly,
              homeTeam: homeTeam,
              awayTeam: awayTeam,
              date: date,
              time: time,
              sortingTime: dateString,
              fixtureId: id,
              venue: venue,
              leaguelogo: leaguelogo,
              referee: referee,
              city: match['venue']?['city'] ?? '',
            );

            leagueMatches.add(matchObject);
          }

          leagueMatches.sort((a, b) {
            bool aMissing = a.sortingTime == null;
            bool bMissing = b.sortingTime == null;

            if (aMissing && bMissing) {
              return 0;
            } else if (aMissing) {
              return 1;
            } else if (bMissing) {
              return -1;
            }

            DateTime dateA = DateTime.parse(a.sortingTime!);
            DateTime dateB = DateTime.parse(b.sortingTime!);
            return dateA.compareTo(dateB);
          });

          FixtureListsByLeague fixByLeague = FixtureListsByLeague(
              dateOnly: dateOnly, leagueMatches: leagueMatches);

          fixtureListByLeague.add(fixByLeague);
        }

        List<FixtureListsByLeague> previousMatches = [];
        List<FixtureListsByLeague> upcomingMatches = [];

        for (var i = 0; i < fixtureListByLeague.length; i++) {
          final fixture = fixtureListByLeague[i];

          if (isDateInPast(fixture.dateOnly, DateTime.parse(currentDate))) {
            previousMatches.add(fixture);
          } else {
            upcomingMatches.add(fixture);
          }
        }

        return Right(LeagueFixtures(
            previousMatches: previousMatches,
            upcomingMatches: upcomingMatches));
      }
    } catch (e) {
      return left(NetworkFailure());
    }
    return left(NetworkFailure());
  }

  Future<Either<NetworkFailure, Stat>> getFixtureById(
      {required int? fixtureId}) async {
    try {
      var url = Uri.parse('${BaseUrl().url}/api/fixtures/fixture')
          .replace(queryParameters: {'fixtureId': fixtureId.toString()});

      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);

        Stat stat = returnMatchfromMap(result);

        return Right(stat);
      }
    } catch (e) {
      return left(NetworkFailure());
    }
    return left(NetworkFailure());
  }

  Future<Either<NetworkFailure, List<Stat>>> getTodaysLeagueMatches() async {
    try {
      final response =
          await http.get(Uri.parse('${BaseUrl().url}/todaysLeagueMatches'));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        List<dynamic> result = decodedData['matches'];

        List<Stat> statList = result.map((match) {
          String language = localLanguageNotifier.value;
          String homeTeamName;
          String awayTeamName;
          String leagueName;

          if (language == 'or' || language == 'so') {
            homeTeamName = match['homeTeam']['OromoName'] ?? '';
            awayTeamName = match['awayTeam']['OromoName'] ?? '';
            leagueName =
                match['league']['OromoName'] ?? match['league']['name'] ?? '';
          } else if (language == 'am' || language == 'tr') {
            homeTeamName = match['homeTeam']['AmharicName'] ?? '';
            awayTeamName = match['awayTeam']['AmharicName'] ?? '';
            leagueName =
                match['league']['AmharicName'] ?? match['league']['name'] ?? '';
          } else {
            homeTeamName = match['homeTeam']['EnglishName'] ?? '';
            awayTeamName = match['awayTeam']['EnglishName'] ?? '';
            leagueName =
                match['league']['EnglishName'] ?? match['league']['name'] ?? '';
          }

          int homeTeamId =
              int.tryParse(match['homeTeam']['_id']?.toString() ?? '') ?? 0;
          int awayTeamId =
              int.tryParse(match['awayTeam']['_id']?.toString() ?? '') ?? 0;
          int fixtureId = int.tryParse(match['id']?.toString() ?? '') ?? 0;

          Team homeTeam = Team(
              id: homeTeamId,
              name: homeTeamName,
              logo: match['homeTeam']['logo'] ?? '',
              winner: match['homeTeamWinner'] ?? false,
              goal: match['goals']?['home'] ?? 0);

          Team awayTeam = Team(
              id: awayTeamId,
              name: awayTeamName,
              logo: match['awayTeam']['logo'] ?? '',
              winner: match['awayTeamWinner'] ?? false,
              goal: match['goals']?['away'] ?? 0);

          return Stat(
              secondHalfTime: match['secondHalfTime'] ?? '',
              elapsed: int.tryParse(
                      match['status']?['elapsed']?.toString() ?? '0') ??
                  0,
              kickOfTime: match['kickOfTime'] ?? '',
              leagueId:
                  int.tryParse(match['league']?['id']?.toString() ?? '0') ?? 0,
              status: match['status']?['short'] ?? '',
              leagueName: leagueName,
              dateString: match['date'] ?? '',
              sortingTime: match['date'] ?? '',
              homeTeamName: TeamName.fromJson(match['homeTeam']),
              awayTeamName: TeamName.fromJson(match['awayTeam']),
              round: replaceText(match['league']?['round'] ?? ''),
              dateOnly: match['dateOnly'] ?? '',
              homeTeam: homeTeam,
              awayTeam: awayTeam,
              date: extractDate(match['date'] ?? ''),
              time: extractTimeFromIso(match['date'] ?? ''),
              fixtureId: fixtureId,
              venue: match['venue']?['name'] ?? '',
              leaguelogo: match['league']?['logo'] ?? '',
              referee: match['referee'] ?? '',
              city: match['venue']?['city'] ?? '',
              VideoTitle: match['youtubeHighlight']?['VideoTitle'] ?? '',
              VideoId: match['youtubeHighlight']?['VideoId'] ?? '',
              Thumbnail: match['youtubeHighlight']?['Thumbnail'] ?? '');
        }).toList();

        return Right(statList);
      }
    } catch (e) {
      return left(NetworkFailure(message: e.toString()));
    }
    return left(NetworkFailure());
  }
}

String replaceText(String input) {
  String lowerInput = input.toLowerCase();
  
  // Extract number (e.g., "17" or "1")
  final RegExp numRegex = RegExp(r'(\d+)');
  final match = numRegex.firstMatch(input);
  String n = match != null ? match.group(1)! : "";

  // 1. Regular Season / Week / Matchday
  if (lowerInput.contains('regular season') || 
      lowerInput.contains('matchday') || 
      lowerInput.contains('week')) {
    // Result: "መደበኛ ወቅት 17 ሳምንት"
    return '${DemoLocalizations.regularSeason} $n ${DemoLocalizations.week}';
  }

  // 2. Group Stage
  if (lowerInput.contains('group stage')) {
    // Some APIs give "Group Stage - 3", we attach the number if it exists
    return n.isEmpty 
        ? DemoLocalizations.groupStage 
        : '${DemoLocalizations.groupStage} $n';
  }

  // 3. Round of (e.g., Round of 16)
  if (lowerInput.contains('round of')) {
    return '${DemoLocalizations.roundOf} $n';
  }

  // 4. Simple Rounds (e.g., Round 5)
  if (lowerInput.contains('round') && !lowerInput.contains('round of')) {
    return '$n ${DemoLocalizations.round}';
  }

  // 5. Legs (Home/Away aggregate matches)
  if (lowerInput.contains('1st leg') || lowerInput.contains('2nd leg')) {
    // Result: "1ኛው ጨዋታ" or "2ኛው ጨዋታ"
    return '$n ${DemoLocalizations.leg}';
  }

  // 6. Knockout Phases (Static)
  if (lowerInput.contains('quarter-final')) return DemoLocalizations.quarterFinals;
  if (lowerInput.contains('semi-final')) return DemoLocalizations.semiFinals;
  if (lowerInput.contains('final')) return DemoLocalizations.finalmatch;

  // 7. Play-offs / Qualifiers
  if (lowerInput.contains('play-off')) return DemoLocalizations.playOff;
  if (lowerInput.contains('qualifying')) return DemoLocalizations.qualifying;

  return input; 
}
bool isDateInPast(String dateStr, DateTime today) {
  final DateTime inputDate = DateTime.parse(dateStr);
  return inputDate.isBefore(today);
}

Stat returnMatchfromMap(Map<String, dynamic> match) {
  String language = localLanguageNotifier.value;
  String homeTeamName;
  String awayTeamName;
  String leagueName;

  if (language == 'or' || language == 'so') {
    homeTeamName = match['homeTeam']['OromoName'];
    awayTeamName = match['awayTeam']['OromoName'];
    leagueName = match['league']['OromoName'] ?? match['league']['name'];
  } else if (language == 'am' || language == 'tr') {
    homeTeamName = match['homeTeam']['AmharicName'];
    awayTeamName = match['awayTeam']['AmharicName'];
    leagueName = match['league']['AmharicName'] ?? match['league']['name'];
  } else {
    homeTeamName = match['homeTeam']['EnglishName'];
    awayTeamName = match['awayTeam']['EnglishName'];
    leagueName = match['league']['EnglishName'] ?? match['league']['name'];
  }

  Team homeTeam = Team(
      id: match['homeTeam']['id'],
      name: homeTeamName,
      logo: match['homeTeam']['logo'] ?? '',
      winner: match['homeTeam']['winner'],
      goal: match['goals']['home']);
  Team awayTeam = Team(
      id: match['awayTeam']['id'],
      name: awayTeamName,
      logo: match['awayTeam']['logo'] ?? '',
      winner: match['awayTeam']['winner'],
      goal: match['goals']['away']);
  String dateString = match['date'];
  String date = extractDate(dateString);
  String time = extractTimeFromIso(dateString);
  int id = match['id'];
  String venue = match['venue']['name'] ?? '';
  String leaguelogo = match['league']['logo'] ?? '';
  String? VideoId = match['youtubeHighlight']['VideoId'] ?? '';
  String? VideoTitle = match['youtubeHighlight']['VideoTitle'] ?? '';
  String? Thumbnail = match['youtubeHighlight']['Thumbnail'] ?? '';
  String referee = match['referee'] ?? '';
  String city = match['venue']?['city'] ?? '';
  String dateOnly = match['dateOnly'];
  String round = replaceText(match['league']['round']);
  int? leagueId = match['league']['id'];
  String status = match['status']['short'] ?? '';

  int? elapsed = match['status']['elapsed'] as int?;

  return Stat(
      secondHalfTime: match['secondHalfTime'],
      elapsed: elapsed,
      kickOfTime: match['kickOfTime'],
      leagueId: leagueId,
      status: status,
      leagueName: leagueName,
      dateString: dateString,
      sortingTime: dateString,
      homeTeamName: TeamName.fromJson(match['homeTeam']),
      awayTeamName: TeamName.fromJson(match['awayTeam']),
      round: round,
      dateOnly: dateOnly,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      date: date,
      time: time,
      fixtureId: id,
      venue: venue,
      leaguelogo: leaguelogo,
      referee: referee,
      city: city,
      VideoTitle: VideoTitle,
      VideoId: VideoId,
      Thumbnail: Thumbnail);
}
