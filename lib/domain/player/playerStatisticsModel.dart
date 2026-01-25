import '../../main.dart';

class PlayerStatistics {
  int id;

  int? gameAppearances;

  int? gameLineups;

  int? gameMinutes;

  int? gameNumber;

  String? gamePosition;

  String? gameRating;

  bool? gameCaptain;

  int? substitutedIn;

  int? substitutedOut;

  int? substitutedBench;

  int? totalShot;

  int? onShot;

  int? totalGoals;

  int? goalsConceded;

  int? assists;

  int? totalSaves;

  int? totalPasses;

  int? keyPasses;

  int? passesAccuracy;

  int? totalTackles;

  int? totalBlocks;

  int? totalInterceptions;

  int? duelsTotal;

  int? duelsWon;

  int? dribbleAttempts;

  int? dribbleSuccess;

  int? dribblePast;

  int? foulsDrawn;

  int? foulsCommitted;

  int? yellowCards;

  int? yellowRedCards;

  int? redCards;

  int? penalityWon;

  int? penalityCommitted;

  int? penalityScored;

  int? penalityMissed;

  int? penalitySaved;

  String? amharicTeamName;

  String? somaliTeamName;

  String? englishTeamName;

  String? oromoTeamName;

  String? amharicLeagueName;

  String? somaliLeagueName;

  String? oromoLeagueName;

  String? englishLeagueName;

  String? teamPhoto;

  String? leaguePhoto;

  PlayerStatistics({
    required this.id,
    this.gameAppearances,
    this.gameLineups,
    this.gameMinutes,
    this.gameNumber,
    this.gamePosition,
    this.gameRating,
    this.gameCaptain,
    this.substitutedIn,
    this.substitutedOut,
    this.substitutedBench,
    this.totalShot,
    this.onShot,
    this.totalGoals,
    this.goalsConceded,
    this.assists,
    this.totalSaves,
    this.totalPasses,
    this.keyPasses,
    this.passesAccuracy,
    this.totalTackles,
    this.totalBlocks,
    this.totalInterceptions,
    this.duelsTotal,
    this.duelsWon,
    this.dribbleAttempts,
    this.dribbleSuccess,
    this.dribblePast,
    this.foulsDrawn,
    this.foulsCommitted,
    this.yellowCards,
    this.yellowRedCards,
    this.redCards,
    this.penalityWon,
    this.penalityCommitted,
    this.penalityScored,
    this.penalityMissed,
    this.penalitySaved,
    this.somaliTeamName,
    this.englishTeamName,
    this.oromoTeamName,
    this.amharicTeamName,
    this.teamPhoto,
    this.leaguePhoto,
    this.amharicLeagueName,
    this.englishLeagueName,
    this.oromoLeagueName,
    this.somaliLeagueName,
  });

  factory PlayerStatistics.fromJson(Map<String, dynamic> json) {
    return PlayerStatistics(
      id: json['id'] ?? 0,
      gameAppearances: json['gameAppearances'] ?? 0,
      gameLineups: json['gameLineups'] ?? 0,
      gameMinutes: json['gameMinutes'] ?? 0,
      gameNumber: json['gameNumber'] ?? 0,
      gamePosition: json['gamePosition'] ?? '',
      gameRating: json['gameRating']?.toString() ?? '',
      gameCaptain: json['gameCaptain'] ?? false,
      substitutedIn: json['substitutedIn'] ?? 0,
      substitutedOut: json['substitutedOut'] ?? 0,
      substitutedBench: json['substitutedBench'] ?? 0,
      totalShot: json['totalShot'] ?? 0,
      onShot: json['onShot'] ?? 0,
      totalGoals: json['totalGoals'] ?? 0,
      goalsConceded: json['goalsConceded'] ?? 0,
      assists: json['assists'] ?? 0,
      totalSaves: json['totalSaves'] ?? 0,
      totalPasses: json['totalPasses'] ?? 0,
      keyPasses: json['keyPasses'] ?? 0,
      passesAccuracy: json['passesAccuracy'] ?? 0,
      totalTackles: json['totalTackles'] ?? 0,
      totalBlocks: json['totalBlocks'] ?? 0,
      totalInterceptions: json['totalInterceptions'] ?? 0,
      duelsTotal: json['duelsTotal'] ?? 0,
      duelsWon: json['duelsWon'] ?? 0,
      dribbleAttempts: json['dribbleAttempts'] ?? 0,
      dribbleSuccess: json['dribbleSuccess'] ?? 0,
      dribblePast: json['dribblePast'] ?? 0,
      foulsDrawn: json['foulsDrawn'] ?? 0,
      foulsCommitted: json['foulsCommitted'] ?? 0,
      yellowCards: json['yellowCards'] ?? 0,
      yellowRedCards: json['yellowRedCards'] ?? 0,
      redCards: json['redCards'] ?? 0,
      penalityWon: json['penalityWon'] ?? 0,
      penalityCommitted: json['penalityCommitted'] ?? 0,
      penalityScored: json['penalityScored'] ?? 0,
      penalityMissed: json['penalityMissed'] ?? 0,
      penalitySaved: json['penalitySaved'] ?? 0,
      somaliTeamName: json['team']?['SomaliName'] ?? '',
      englishTeamName: json['team']?['EnglishName'] ?? '',
      oromoTeamName: json['team']?['OromoName'] ?? '',
      amharicTeamName: json['team']?['AmharicName'] ?? '',
      teamPhoto: json['team']?['logo'] ?? '',
      leaguePhoto: json['league']?['photo'] ?? '',
      englishLeagueName: json['league']?['englishName'] ?? '',
      amharicLeagueName: json['league']?['amharicName'] ?? '',
      oromoLeagueName: json['league']?['oromoName'] ?? '',
      somaliLeagueName: json['league']?['somaliName'] ?? '',
    );
  }

  String get leagueName {
    final lang = localLanguageNotifier.value;
    switch (lang) {
      case 'am':
        return amharicLeagueName ?? englishLeagueName ?? 'Unknown League';
      case 'or':
        return oromoLeagueName ?? englishLeagueName ?? 'Unknown League';
      case 'si':
        return somaliLeagueName ?? englishLeagueName ?? 'Unknown League';
      default:
        return englishLeagueName ?? 'Unknown League';
    }
  }
}
