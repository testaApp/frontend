import '../../domain/player/player.model.dart';
import '../../domain/player/playerName.dart';
import 'coach.dart';

class Lineup {
  final int teamId;
  final String teamName;
  final String teamLogo;
  final Map<String, dynamic>? colors;
  final String formation;
  final List<Player> players;
  final Coach coach;
  final List<PlayerName> substitutes;
  final List<PlayerName> playerNames;

  Lineup({
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.colors,
    required this.formation,
    required this.players,
    required this.coach,
    required this.substitutes,
    this.playerNames = const [],
  });

  factory Lineup.fromJson(Map<String, dynamic> json) {
    int teamId = json['team']['id'] ?? 0;
    String teamName = json['team']['name'] ?? '';
    String teamLogo = json['team']['logo'] ?? '';
    Map<String, dynamic>? colors = json['team']['colors'];
    String formation = json['formation'] ?? '';

    List<dynamic> substitutesData = json['substitutes'] ?? [];
    List<dynamic> playersData = json['startXI'] ?? [];

    Coach coach = Coach.fromJson(json['coach'] ?? {});

    // Starting XI players (unchanged)
    List<Player> players = playersData
        .map((playerJson) => Player.fromJson(playerJson['player'] ?? {}))
        .toList();

    // FIXED substitutes with safe fallback to default 'name'
    List<PlayerName> substitutes = substitutesData.map((subJson) {
      final playerMap = subJson['player'] ?? subJson;
      final String defaultName =
          (playerMap['name'] ?? 'Unknown').toString().trim();

      // Get localized map safely
      final Map<String, dynamic>? localized = playerMap['localized'];

      return PlayerName(
        id: playerMap['id'] ?? 0,
        // Use localized when available, fallback to default name otherwise
        englishName: localized?['english']?.toString().trim().isNotEmpty == true
            ? localized!['english'].toString().trim()
            : defaultName,
        amharicName: localized?['amharic']?.toString().trim().isNotEmpty == true
            ? localized!['amharic'].toString().trim()
            : defaultName,
        oromoName: localized?['oromo']?.toString().trim().isNotEmpty == true
            ? localized!['oromo'].toString().trim()
            : defaultName,
        somaliName: localized?['somali']?.toString().trim().isNotEmpty == true
            ? localized!['somali'].toString().trim()
            : defaultName,
        // Other fields
        number: playerMap['number'],
        position: playerMap['pos'] ?? playerMap['position'] ?? '',
        photo: playerMap['photo']?.toString().trim(),
        age: playerMap['age'],
      );
    }).toList();

    // Also apply same safe fallback logic to playerNames (optional but recommended)
    List<PlayerName> playerNames = [];
    for (var player in playersData) {
      if (player['player'] != null) {
        final playerMap = player['player'];
        final String defaultName =
            (playerMap['name'] ?? 'Unknown').toString().trim();
        final Map<String, dynamic>? localized = playerMap['localized'];

        playerNames.add(PlayerName(
          id: playerMap['id'] ?? 0,
          englishName:
              localized?['english']?.toString().trim().isNotEmpty == true
                  ? localized!['english'].toString().trim()
                  : defaultName,
          amharicName:
              localized?['amharic']?.toString().trim().isNotEmpty == true
                  ? localized!['amharic'].toString().trim()
                  : defaultName,
          oromoName: localized?['oromo']?.toString().trim().isNotEmpty == true
              ? localized!['oromo'].toString().trim()
              : defaultName,
          somaliName: localized?['somali']?.toString().trim().isNotEmpty == true
              ? localized!['somali'].toString().trim()
              : defaultName,
          number: playerMap['number'],
          position: playerMap['pos'] ?? '',
          photo: playerMap['photo']?.toString().trim(),
          age: playerMap['age'],
        ));
      } else {
        playerNames.add(PlayerName(
          amharicName: '',
          englishName: '',
          oromoName: '',
          somaliName: '',
          id: -1,
        ));
      }
    }

    return Lineup(
      teamId: teamId,
      teamName: teamName,
      teamLogo: teamLogo,
      colors: colors,
      formation: formation,
      players: players,
      coach: coach,
      substitutes: substitutes,
      playerNames: playerNames,
    );
  }
}

List<Lineup> parseLineupsData(Map<String, dynamic> data) {
  List<Lineup> lineups = [];

  List<dynamic> lineupData = data['response'] ?? [];

  for (var lineupJson in lineupData) {
    Lineup lineup = Lineup.fromJson(lineupJson);
    lineups.add(lineup);
  }

  return lineups;
}
