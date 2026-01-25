// team_leaders_model.dart

import 'playerName.dart';

// Simple statistics class just for team leaders
class PlayerStatisticsSimple {
  final int totalGoals;
  final int assists;
  final int yellowCards;
  final int redCards;

  PlayerStatisticsSimple({
    required this.totalGoals,
    required this.assists,
    required this.yellowCards,
    required this.redCards,
  });
}

// Simplified TeamLeader class
class TeamLeader {
  final PlayerName player;
  final int totalGoals;
  final int assists;
  final int yellowCards;
  final int redCards;

  TeamLeader({
    required this.player,
    required this.totalGoals,
    required this.assists,
    required this.yellowCards,
    required this.redCards,
  });

  factory TeamLeader.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] ?? {};
    final playerJson = profile['player'] ?? {};

    final playerName = PlayerName(
      id: playerJson['id'] ?? 0,
      englishName: playerJson['englishName'] ?? '',
      amharicName: playerJson['amharicName'] ?? '',
      oromoName: playerJson['oromoName'] ?? '',
      somaliName: playerJson['somaliName'] ?? '',
      photo: playerJson['photo'] ?? '',
    );

    return TeamLeader(
      player: playerName,
      totalGoals: json['totalGoals'] ?? 0,
      assists: json['assists'] ?? 0,
      yellowCards: json['yellowCards'] ?? 0,
      redCards: json['redCards'] ?? 0,
    );
  }

  // Getter to work with your existing UI code that expects stats
  PlayerStatisticsSimple get stats => PlayerStatisticsSimple(
        totalGoals: totalGoals,
        assists: assists,
        yellowCards: yellowCards,
        redCards: redCards,
      );
}
