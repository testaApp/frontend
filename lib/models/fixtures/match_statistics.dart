class TeamsMatchStat {
  int fixtureID;
  MatchStatistics teamOneMatchStatistics;
  MatchStatistics teamTwoMatchStatistics;
  TeamsMatchStat(
      {required this.fixtureID,
      required this.teamOneMatchStatistics,
      required this.teamTwoMatchStatistics});
  factory TeamsMatchStat.fromMap(Map<String, dynamic> map) {
    return TeamsMatchStat(
        fixtureID: map['fixtureId'] as int,
        teamOneMatchStatistics: MatchStatistics.fromJson(map['teamOneStat']),
        teamTwoMatchStatistics: MatchStatistics.fromJson(map['teamTwoStat']));
  }
}

class MatchStatistics {
  final int id;
  final int? shotsOfGoal;
  final int? shotsOnGoal;
  final int? totalShots;
  final int? blockedShots;
  final int? shotsInsideBox;
  final int? shotsOutsideBox;
  final int? fouls;
  final int? cornerKicks;
  final int? offsides;
  final int? ballPossession;
  final int? yellowCards;
  final int? redCards;
  final int? goalKeeperSaves;
  final int? totalPasses;
  final int? passesAccurate;
  final int? passesInPercent;
  MatchStatistics(
      {required this.id,
      required this.shotsOfGoal,
      required this.totalShots,
      required this.blockedShots,
      required this.shotsInsideBox,
      required this.shotsOutsideBox,
      required this.fouls,
      required this.cornerKicks,
      required this.offsides,
      required this.ballPossession,
      required this.yellowCards,
      required this.redCards,
      required this.goalKeeperSaves,
      required this.totalPasses,
      required this.passesAccurate,
      required this.passesInPercent,
      required this.shotsOnGoal});

  factory MatchStatistics.fromJson(Map<String, dynamic> json) {
    print('inside here == = =  - -- ');
    print(json);
    return MatchStatistics(
        id: json['teamId'] as int,
        shotsOfGoal: json['shotsOfGoal'] as int?,
        totalShots: json['totalShots'] as int?,
        blockedShots: json['blockedShots'] as int?,
        shotsInsideBox: json['shotsInsideBox'] as int?,
        shotsOutsideBox: json['shotsOutsideBox'] as int?,
        fouls: json['fouls'] as int?,
        cornerKicks: json['cornerKicks'] as int?,
        offsides: json['offsides'] as int?,
        ballPossession: json['ballPossession'] as int?,
        yellowCards: json['yellowCards'] as int?,
        redCards: json['redCards'] as int?,
        goalKeeperSaves: json['goalKeeperSaves'] as int?,
        totalPasses: json['totalPasses'] as int?,
        passesAccurate: json['passesAccurate'] as int?,
        passesInPercent: json['passesInPercent'] as int?,
        shotsOnGoal: json['shotsOnGoal'] as int?);
  }
}
