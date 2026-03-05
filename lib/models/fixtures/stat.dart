// First, update the Stat model to include season field

import '../../components/timeFormatter.dart';
import '../../functions/date_conversion.dart';
import '../../main.dart';
import 'package:blogapp/data/repositories/matches_repository.dart';
import '../teamName.dart';
import 'team.dart';

class Stat {
  Stat(
      {required this.homeTeam,
      required this.dateString,
      required this.dateOnly,
      required this.status,
      required this.venue,
      required this.leaguelogo,
      required this.referee,
      required this.city,
      required this.awayTeam,
      required this.date,
      required this.time,
      required this.fixtureId,
      required this.round,
      this.season, // Added season field
      this.VideoTitle,
      this.VideoId,
      this.Thumbnail,
      required this.leagueId,
      required this.leagueName,
      required this.homeTeamName,
      required this.awayTeamName,
      this.kickOfTime,
      this.sortingTime,
      required this.elapsed,
      this.channelLogo,
      this.secondHalfTime});
  Team homeTeam;
  TeamName homeTeamName;
  TeamName awayTeamName;
  Team awayTeam;
  String? date;
  String? time;
  int? fixtureId;
  String? venue;
  String? leaguelogo;
  String? referee;
  String? city;
  String? channelLogo;
  String? VideoTitle;
  String? VideoId;
  String? Thumbnail;

  String? dateString;
  String? dateOnly;
  String? round;
  int? season; // Added season field
  int? leagueId;
  String? status;
  String? leagueName;
  String? kickOfTime;
  String? sortingTime;
  String? secondHalfTime;
  int? elapsed;

  factory Stat.fromMap(match) {
    String languageName = '';

    switch (localLanguageNotifier.value) {
      case 'am':
        languageName = 'AmharicName';
        break;
      case 'or':
        languageName = 'OromoName';
        break;
      case 'so':
        languageName = 'SomaliName';
        break;
      default:
        languageName = 'EnglishName';
    }

    // Safe access to goals object
    final goals = match['goals'] as Map<String, dynamic>?;

    Team homeTeam = Team(
      id: match['homeTeam']['id'] as int,
      name: match['homeTeam'][languageName] as String,
      logo: match['homeTeam']['logo'] as String,
      winner: match['homeTeamWinner'] as bool?,
      goal: goals?['home'] as int?,
    );

    Team awayTeam = Team(
      id: match['awayTeam']['id'] as int,
      name: match['awayTeam'][languageName] as String,
      logo: match['awayTeam']['logo'] as String,
      winner: match['awayTeamWinner'] as bool?,
      goal: goals?['away'] as int?,
    );

    final venueData = match['venue'] as Map<String, dynamic>?;
    String? venueName = venueData?['name']?.toString().trim();
    String? cityName = venueData?['city']?.toString().trim();

    String leaguelogo = match['league']?['logo'] ?? '';
    String? referee = match['referee']?.toString();
    String? dateString = match['date']?.toString();
    String? channelLogo = match['channelLogo']?.toString();

    String? date = dateString != null ? extractDate(dateString) : null;
    String? time = dateString != null ? extractTime(dateString) : null;

    int? fixtureId = match['id'] as int?;
    String? dateOnly = match['dateOnly']?.toString();
    int? leagueId = match['league']?['id'] as int?;
    String? status = match['status']?['short']?.toString();
    int? elapsed = match['status']?['elapsed'] as int?;
    String? leagueName = match['league']?['name']?.toString();
    int? season = match['league']?['season'] as int?; // Extract season

    // Safe extraction of highlights
    final highlights = match['youtubeHighlight'] as Map<String, dynamic>?;
    String? videoId = highlights?['VideoId']?.toString();
    String? videoTitle = highlights?['VideoTitle']?.toString();
    String? thumbnail = highlights?['Thumbnail']?.toString();

    return Stat(
      secondHalfTime: match['secondHalfTime'],
      leagueId: leagueId,
      homeTeam: homeTeam,
      leagueName: leagueName,
      status: status,
      round: match['league'] != null
          ? replaceText(match['league']['round'])
          : null,
      season: season, // Pass season
      dateOnly: dateOnly,
      awayTeam: awayTeam,
      dateString: dateString,
      date: date,
      channelLogo: channelLogo,
      time: time,
      fixtureId: fixtureId,
      homeTeamName: TeamName.fromJson(match['homeTeam']),
      awayTeamName: TeamName.fromJson(match['awayTeam']),
      venue: venueName,
      leaguelogo: leaguelogo,
      referee: referee,
      city: cityName,
      kickOfTime: match['kickOfTime'],
      elapsed: elapsed,
      VideoTitle: videoTitle,
      VideoId: videoId,
      Thumbnail: thumbnail,
    );
  }

  factory Stat.fromJson(match) {
    String? language = localLanguageNotifier.value;

    // Determine team name based on current language
    String? homeTeamDisplayName;
    String? awayTeamDisplayName;

    if (language == 'or' || language == 'so') {
      homeTeamDisplayName = match['homeTeamData']['OromoName'];
      awayTeamDisplayName = match['awayTeamData']['OromoName'];
    } else if (language == 'am' || language == 'tr') {
      homeTeamDisplayName = match['homeTeamData']['AmharicName'];
      awayTeamDisplayName = match['awayTeamData']['AmharicName'];
    } else {
      homeTeamDisplayName = match['homeTeamData']['EnglishName'];
      awayTeamDisplayName = match['awayTeamData']['EnglishName'];
    }

    // Create Team objects with localized names
    Team homeTeam = Team(
      id: match['homeTeamData']['id'],
      name: homeTeamDisplayName ?? match['homeTeamData']['EnglishName'] ?? '',
      logo: match['homeTeamData']['logo'] ?? '',
      winner: match['homeTeamData']['winner'],
      goal: match['goals'] != null ? match['goals']['home'] : null,
    );

    Team awayTeam = Team(
      id: match['awayTeamData']['id'],
      name: awayTeamDisplayName ?? match['awayTeamData']['EnglishName'] ?? '',
      logo: match['awayTeamData']['logo'] ?? '',
      winner: match['awayTeamData']['winner'],
      goal: match['goals'] != null ? match['goals']['away'] : null,
    );

    // Extract venue data safely
    final venueData = match['venue'] as Map<String, dynamic>?;
    String? venueName = venueData?['name']?.toString().trim();
    String? cityName = venueData?['city']?.toString().trim();

    String dateString = match['date']?.toString() ?? '';
    String? date = dateString.isNotEmpty ? extractDate(dateString) : null;
    String? time =
        dateString.isNotEmpty ? extractTimeFromIso(dateString) : null;

    int fixtureId = match['id'] as int;

    String? referee = match['referee']?.toString();
    String? channelLogo = match['channelLogo']?.toString();
    String? dateOnly = match['dateOnly']?.toString();

    // Safe round and season extraction
    String? round =
        match['league'] != null ? replaceText(match['league']['round']) : null;
    int? season = match['league']?['season'] as int?; // Extract season
    int? leagueId =
        match['league'] != null ? match['league']['id'] as int? : null;
    String? leagueName =
        match['league'] != null ? match['league']['name']?.toString() : null;
    String leaguelogo =
        match['league'] != null ? (match['league']['logo'] ?? '') : '';

    String? status =
        match['status'] != null ? match['status']['short']?.toString() : null;
    int? elapsed =
        match['status'] != null ? match['status']['elapsed'] as int? : null;

    // Safe access to highlights
    final highlights = match['youtubeHighlight'] as Map<String, dynamic>?;
    String? videoId = highlights?['VideoId']?.toString();
    String? videoTitle = highlights?['VideoTitle']?.toString();
    String? thumbnail = highlights?['Thumbnail']?.toString();

    return Stat(
      secondHalfTime: match['secondHalfTime'],
      elapsed: elapsed,
      kickOfTime: match['kickOfTime'],
      leagueId: leagueId,
      status: status,
      leagueName: leagueName,
      dateString: dateString,
      sortingTime: dateString,
      homeTeamName: TeamName.fromJson(match['homeTeamData']),
      awayTeamName: TeamName.fromJson(match['awayTeamData']),
      round: round,
      season: season, // Pass season
      dateOnly: dateOnly,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      date: date,
      channelLogo: channelLogo,
      time: time,
      fixtureId: fixtureId,
      venue: venueName,
      leaguelogo: leaguelogo,
      referee: referee,
      city: cityName,
      VideoTitle: videoTitle,
      VideoId: videoId,
      Thumbnail: thumbnail,
    );
  }
}
