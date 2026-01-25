import '../../main.dart';

class TableItem {
  final int id;
  final int position;
  final String avatar;
  final String name;
  final int point;
  final int gamePlayed;
  final String? group;
  final int goalDifference;
  final int scored;
  final int conceded;
  final int won;
  final int draw;
  final int lost;
  final String? season;
  final List<String> form;
  TableItem(
      {required this.id,
      required this.position,
      required this.avatar,
      required this.name,
      required this.point,
      required this.gamePlayed,
      required this.group,
      required this.goalDifference,
      required this.draw,
      required this.won,
      required this.lost,
      required this.conceded,
      required this.scored,
      required this.form,
      this.season});

  factory TableItem.Overall(Map<String, dynamic> map, String season) {
    String language = localLanguageNotifier.value;

    String teamName;
    if (language == 'or' || language == 'so') {
      teamName = map['teamData']['OromoName'];
    } else if (language == 'am' || language == 'tr') {
      teamName = map['teamData']['AmharicName'];
    } else {
      teamName = map['teamData']['EnglishName'];
    }
    // //print(map);
    TableItem value = TableItem(
        id: map['teamData']['id'] as int,
        position: map['rank'] as int,
        avatar: map['teamData']['logo'],
        name: teamName,
        point: map['point'] as int,
        gamePlayed: map['played'] as int,
        goalDifference: map['goalDifference'] as int,
        scored: map['scored'] as int,
        lost: map['loss'] as int,
        won: map['win'] as int,
        draw: map['draw'] as int,
        conceded: map['conceded'] as int,
        group: map['group'],
        form: map['form'] != null ? map['form'].split('') as List<String> : [],
        season: season);

    return value;
  }

  factory TableItem.homeStat(Map<String, dynamic> map, int index) {
    String language = localLanguageNotifier.value;
    String teamName;
    if (language == 'or' || language == 'so') {
      teamName = map['teamData']['OromoName'];
    } else if (language == 'am' || language == 'tr') {
      teamName = map['teamData']['AmharicName'];
    } else {
      teamName = map['teamData']['EnglishName'];
    }
    // //print(map);
    return TableItem(
      id: map['teamData']['id'] as int,
      position: index + 1,
      avatar: map['teamData']['logo'],
      name: teamName,
      point: map['homePoint'],
      gamePlayed: map['homePlayed'] as int,
      goalDifference: map['homeGoalDifference'] as int,
      scored: map['homeScored'] as int,
      lost: map['homeLoose'] as int,
      won: map['homeWon'] as int,
      draw: map['homeDraw'] as int,
      group: map['group'],
      conceded: map['homeConceded'] as int,
      form: map['form'] != null ? map['form'].split('') as List<String> : [],
    );
  }

  factory TableItem.awayStat(Map<String, dynamic> map, int index) {
    String language = localLanguageNotifier.value;
    String teamName;
    //print(map['teamData']);
    if (language == 'or' || language == 'so') {
      teamName = map['teamData']['OromoName'];
    } else if (language == 'am' || language == 'tr') {
      teamName = map['teamData']['AmharicName'];
    } else {
      teamName = map['teamData']['EnglishName'];
    }
    //  //print(map);
    return TableItem(
      id: map['teamData']['id'] as int,
      position: index + 1,
      avatar: map['teamData']['logo'] ?? '',
      name: teamName,
      point: map['awayPoint'],
      gamePlayed: map['awayPlayed'] as int,
      goalDifference: map['awayGoalDifference'] as int,
      scored: map['homeScored'] as int,
      lost: map['awayLoose'] as int,
      won: map['awayWon'] as int,
      group: map['group'],
      draw: map['awayDraw'] as int,
      conceded: map['awayConceded'] as int,
      form: map['form'] != null ? map['form'].split('') as List<String> : [],
    );
  }
}
