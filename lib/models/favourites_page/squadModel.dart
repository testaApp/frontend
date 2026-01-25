import '../../domain/player/playerName.dart';
import '../../domain/player/playerStatisticsModel.dart';
import '../teamName.dart';

class SquadModel {
  List<PlayerName> goalKeepers;
  List<PlayerName> defenders;
  List<PlayerName> midfielders;
  List<PlayerName> attackers;

  // Optional lists for statistics
  List<PlayerStatistics>? goalKeeperStats;
  List<PlayerStatistics>? defenderStats;
  List<PlayerStatistics>? midfielderStats;
  List<PlayerStatistics>? attackerStats;
  String? coach;
  String? coachimage;
  String? coachStartdate;
  String? coachEnddate;

  TeamName team;
  int? playerId;

  SquadModel(
      {required this.goalKeepers,
      required this.defenders,
      required this.midfielders,
      required this.attackers,
      this.coach,
      this.coachimage,
      this.coachStartdate,
      this.coachEnddate,
      this.goalKeeperStats,
      this.defenderStats,
      this.midfielderStats,
      this.attackerStats,
      required this.team,
      this.playerId});
}
