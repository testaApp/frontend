import '../domain/player/playerName.dart';
import 'teamName.dart';

class PlayerWithTeam {
  final PlayerName playerName;
  final TeamName teamName;
  PlayerWithTeam({
    required this.playerName,
    required this.teamName,
  });

  factory PlayerWithTeam.fromJson(Map<String, dynamic> json) {
    return PlayerWithTeam(
      playerName: PlayerName.fromJson(json['playerName'] ?? {}),
      teamName: TeamName.fromJson(json['teamName'] ?? {}),
    );
  }
}
