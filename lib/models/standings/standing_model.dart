import 'standings.dart';

class StandingModel {
  int leagueId;
  List<List<TableItem>> overallStanding;
  List<List<TableItem>> homeStanding;
  List<List<TableItem>> awayStanding;
  StandingModel(
      {required this.overallStanding,
      required this.homeStanding,
      required this.awayStanding,
      required this.leagueId});

  // factory StandingModel.fromJson(Map<String, dynamic> map) =>
  // StandingModel(overallStanding: json["overallStanding"],
  //  homeStanding: homeStanding,
  //   awayStanding: awayStanding,
  //    leagueId: leagueId)
}
