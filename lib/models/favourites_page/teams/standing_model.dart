import '../../leagueNames.dart';
import '../../standings/standings.dart';

class TeamProfileStandingModel {
  LeagueName leagueName;
  List<TableItem> tableItems;
  TeamProfileStandingModel(
      {required this.leagueName, required this.tableItems});
}
