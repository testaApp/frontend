import '../../../leagueNames.dart';
import 'profile_fixtures.dart';

class TeamStats {
  final int id;
  final String name;
  final int season;
  final int? leagueId;
  final LeagueName? league; // Changed from leagueId to league

  final String? form;
  final ProfileFixtures? fixtures;
  final Goals? goalsFor;
  final Goals? goalsAgainst;
  final Biggest? biggest;
  final int? cleanSheetHome;
  final int? cleanSheetAway;
  final int? cleanSheetTotal;
  final int? failedToScoreHome;
  final int? failedToScoreAway;
  final int? failedToScoreTotal;
  final Penalty? penalty;
  final List<Lineup>? lineups;
  final Cards? cards;

  TeamStats({
    required this.id,
    required this.name,
    required this.season,
    this.leagueId,
    this.league,
    this.form,
    this.fixtures,
    this.goalsFor,
    this.goalsAgainst,
    this.biggest,
    this.cleanSheetHome,
    this.cleanSheetAway,
    this.cleanSheetTotal,
    this.failedToScoreHome,
    this.failedToScoreAway,
    this.failedToScoreTotal,
    this.penalty,
    this.lineups,
    this.cards,
  });

  factory TeamStats.fromJson(Map<String, dynamic> json) {
    return TeamStats(
      id: json['id'],
      name: json['name'],
      season: json['season'],
      leagueId: json['leagueId'],
      league: json['league'] != null
          ? LeagueName(
              leagueId: json['league']['id']?.toString() ?? '',
              amharicName: json['league']['amharicName'],
              englishName: json['league']['englishName'],
              somaliName: json['league']['somaliName'],
              oromoName: json['league']['oromoName'],
              logo: json['league']['photo'],
            )
          : null,
      form: json['form'],
      fixtures: json['fixtures'] != null
          ? ProfileFixtures.fromJson(json['fixtures'])
          : null,
      goalsFor: json['goals']?['for'] != null
          ? Goals.fromJson(json['goals']['for'])
          : null,
      goalsAgainst: json['goals']?['against'] != null
          ? Goals.fromJson(json['goals']['against'])
          : null,
      biggest:
          json['biggest'] != null ? Biggest.fromJson(json['biggest']) : null,
      cleanSheetHome: json['clean_sheet']?['home'],
      cleanSheetAway: json['clean_sheet']?['away'],
      cleanSheetTotal: json['clean_sheet']?['total'],
      failedToScoreHome: json['failed_to_score']?['home'],
      failedToScoreAway: json['failed_to_score']?['away'],
      failedToScoreTotal: json['failed_to_score']?['total'],
      penalty:
          json['penalty'] != null ? Penalty.fromJson(json['penalty']) : null,
      lineups: json['lineups'] != null
          ? (json['lineups'] as List).map((e) => Lineup.fromJson(e)).toList()
          : null,
      cards: json['cards'] != null ? Cards.fromJson(json['cards']) : null,
    );
  }
}

class Goals {
  final TotalData? total;
  final AverageData? average;
  final MinuteData? minute;

  Goals({this.total, this.average, this.minute});

  factory Goals.fromJson(Map<String, dynamic> json) {
    return Goals(
      total: json['total'] != null ? TotalData.fromJson(json['total']) : null,
      average: json['average'] != null
          ? AverageData.fromJson(json['average'])
          : null,
      minute:
          json['minute'] != null ? MinuteData.fromJson(json['minute']) : null,
    );
  }
}

class TotalData {
  final int? home;
  final int? away;
  final int? total;

  TotalData({this.home, this.away, this.total});

  factory TotalData.fromJson(Map<String, dynamic> json) {
    return TotalData(
      home: json['home'],
      away: json['away'],
      total: json['total'],
    );
  }
}

class AverageData {
  final String? home;
  final String? away;
  final String? total;

  AverageData({this.home, this.away, this.total});

  factory AverageData.fromJson(Map<String, dynamic> json) {
    return AverageData(
      home: json['home'],
      away: json['away'],
      total: json['total'],
    );
  }
}

class MinuteData {
  final DataInterval? interval0To15;
  final DataInterval? interval16To30;
  final DataInterval? interval31To45;
  final DataInterval? interval46To60;
  final DataInterval? interval61To75;
  final DataInterval? interval76To90;
  final DataInterval? interval91To105;
  final DataInterval? interval106To120;

  MinuteData({
    this.interval0To15,
    this.interval16To30,
    this.interval31To45,
    this.interval46To60,
    this.interval61To75,
    this.interval76To90,
    this.interval91To105,
    this.interval106To120,
  });

  factory MinuteData.fromJson(Map<String, dynamic> json) {
    return MinuteData(
      interval0To15:
          json['0-15'] != null ? DataInterval.fromJson(json['0-15']) : null,
      interval16To30:
          json['16-30'] != null ? DataInterval.fromJson(json['16-30']) : null,
      interval31To45:
          json['31-45'] != null ? DataInterval.fromJson(json['31-45']) : null,
      interval46To60:
          json['46-60'] != null ? DataInterval.fromJson(json['46-60']) : null,
      interval61To75:
          json['61-75'] != null ? DataInterval.fromJson(json['61-75']) : null,
      interval76To90:
          json['76-90'] != null ? DataInterval.fromJson(json['76-90']) : null,
      interval91To105:
          json['91-105'] != null ? DataInterval.fromJson(json['91-105']) : null,
      interval106To120: json['106-120'] != null
          ? DataInterval.fromJson(json['106-120'])
          : null,
    );
  }
}

class DataInterval {
  final int? total;
  final String? percentage;

  DataInterval({this.total, this.percentage});

  factory DataInterval.fromJson(Map<String, dynamic> json) {
    return DataInterval(
      total: json['total'],
      percentage: json['percentage'],
    );
  }
}

class Biggest {
  final Streak? streak;
  final WinsOrLoses? wins;
  final WinsOrLoses? loses;
  final GoalsForOrAgainst? goalsFor;
  final GoalsForOrAgainst? goalsAgainst;

  Biggest(
      {this.streak, this.wins, this.loses, this.goalsFor, this.goalsAgainst});

  factory Biggest.fromJson(Map<String, dynamic> json) {
    return Biggest(
      streak: json['streak'] != null ? Streak.fromJson(json['streak']) : null,
      wins: json['wins'] != null ? WinsOrLoses.fromJson(json['wins']) : null,
      loses: json['loses'] != null ? WinsOrLoses.fromJson(json['loses']) : null,
      goalsFor: json['goals']?['for'] != null
          ? GoalsForOrAgainst.fromJson(json['goals']['for'])
          : null,
      goalsAgainst: json['goals']?['against'] != null
          ? GoalsForOrAgainst.fromJson(json['goals']['against'])
          : null,
    );
  }
}

class Streak {
  final int? wins;
  final int? draws;
  final int? loses;

  Streak({this.wins, this.draws, this.loses});

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      wins: json['wins'],
      draws: json['draws'],
      loses: json['loses'],
    );
  }
}

class WinsOrLoses {
  final String? home;
  final String? away;

  WinsOrLoses({this.home, this.away});

  factory WinsOrLoses.fromJson(Map<String, dynamic> json) {
    return WinsOrLoses(
      home: json['home'],
      away: json['away'],
    );
  }
}

class GoalsForOrAgainst {
  final int? home;
  final int? away;

  GoalsForOrAgainst({this.home, this.away});

  factory GoalsForOrAgainst.fromJson(Map<String, dynamic> json) {
    return GoalsForOrAgainst(
      home: json['home'],
      away: json['away'],
    );
  }
}

class Penalty {
  final ScoredOrMissed? scored;
  final ScoredOrMissed? missed;
  final int? total;

  Penalty({this.scored, this.missed, this.total});

  factory Penalty.fromJson(Map<String, dynamic> json) {
    return Penalty(
      scored: json['scored'] != null
          ? ScoredOrMissed.fromJson(json['scored'])
          : null,
      missed: json['missed'] != null
          ? ScoredOrMissed.fromJson(json['missed'])
          : null,
      total: json['total'],
    );
  }
}

class ScoredOrMissed {
  final int? total;
  final String? percentage;

  ScoredOrMissed({this.total, this.percentage});

  factory ScoredOrMissed.fromJson(Map<String, dynamic> json) {
    return ScoredOrMissed(
      total: json['total'],
      percentage: json['percentage'],
    );
  }
}

class Lineup {
  final String? formation;
  final int? played;

  Lineup({this.formation, this.played});

  factory Lineup.fromJson(Map<String, dynamic> json) {
    return Lineup(
      formation: json['formation'],
      played: json['played'],
    );
  }
}

class Cards {
  final MinuteData? yellow;
  final MinuteData? red;

  Cards({this.yellow, this.red});

  factory Cards.fromJson(Map<String, dynamic> json) {
    return Cards(
      yellow:
          json['yellow'] != null ? MinuteData.fromJson(json['yellow']) : null,
      red: json['red'] != null ? MinuteData.fromJson(json['red']) : null,
    );
  }
}
