class LeagueName {
  String amharicName;
  String englishName;
  String somaliName;
  String oromoName;
  String? leagueId;
  String logo;
  int? id;
  int? homepoint;
  int? awaypoint;
  int? point;

  int? homeScored;
  int? homeDraw;
  int? homePlayed;
  int? homeWon;
  int? homeLoose;

  int? awayScored;
  int? awayDraw;
  int? awayPlayed;
  int? awayWon;
  int? awayLoose;
  int? scored;
  int? homeConceded;
  int? awayConceded;
  int? averagescored;

  LeagueName(
      {required this.amharicName,
      required this.englishName,
      required this.somaliName,
      required this.oromoName,
      this.leagueId,
      this.homepoint,
      this.awaypoint,
      this.point,
      this.homeScored,
      this.homeDraw,
      this.homePlayed,
      this.homeWon,
      this.homeLoose,
      this.awayScored,
      this.awayDraw,
      this.awayPlayed,
      this.awayWon,
      this.awayLoose,
      this.averagescored,
      required this.logo,
      this.id,
      this.scored,
      this.homeConceded,
      this.awayConceded});
}
