import 'package:blogapp/domain/player/playerName.dart';
import 'package:blogapp/localization/demo_localization.dart';
import 'package:blogapp/models/teamName.dart';

class TransferModel {
  TransferModel({
    required this.fromClubName,
    required this.toClubName,
    required this.playerName,
    required this.transferAmount,
    required this.age,
    required this.nationalitylogo,
    required this.position,
    required this.playerProfile,
  });

  final TeamName fromClubName;
  final TeamName toClubName;
  final PlayerName playerName;
  final String transferAmount;
  final String age;
  final String nationalitylogo;
  final String position;
  final String playerProfile;

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> mapOrEmpty(dynamic value) {
      if (value is Map<String, dynamic>) {
        return value;
      }
      return {};
    }

    String stringOrEmpty(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    String stringOrDefault(dynamic value, String fallback) {
      final text = stringOrEmpty(value).trim();
      if (text.isEmpty || text.toLowerCase() == 'null') {
        return fallback;
      }
      return text;
    }

    final teamName = mapOrEmpty(json['fromClubName']);
    final toClubName = mapOrEmpty(json['toClubName']);
    final primaryPlayerMap = mapOrEmpty(json['playerName']);
    final playerMap =
        primaryPlayerMap.isNotEmpty ? primaryPlayerMap : mapOrEmpty(json['player']);

    final fromClubNameRaw = json['fromClubName'] is String
        ? stringOrEmpty(json['fromClubName'])
        : '';
    final toClubNameRaw = json['toClubName'] is String
        ? stringOrEmpty(json['toClubName'])
        : '';
    final playerNameRaw = json['playerName'] is String
        ? stringOrEmpty(json['playerName'])
        : '';

    String amharicTeamName =
        stringOrEmpty(teamName['AmharicName'] ?? teamName['amharicName']);
    String oromoTeamName =
        stringOrEmpty(teamName['OromoName'] ?? teamName['oromoName']);
    String englishTeamName =
        stringOrEmpty(teamName['EnglishName'] ?? teamName['englishName']);
    String somaliTeamName =
        stringOrEmpty(teamName['SomaliName'] ?? teamName['somaliName']);

    if (englishTeamName.isEmpty && fromClubNameRaw.isNotEmpty) {
      englishTeamName = fromClubNameRaw;
    }
    if (amharicTeamName.isEmpty && fromClubNameRaw.isNotEmpty) {
      amharicTeamName = fromClubNameRaw;
    }
    if (oromoTeamName.isEmpty && fromClubNameRaw.isNotEmpty) {
      oromoTeamName = fromClubNameRaw;
    }
    if (somaliTeamName.isEmpty && fromClubNameRaw.isNotEmpty) {
      somaliTeamName = fromClubNameRaw;
    }

    String amharicToClubName =
        stringOrEmpty(toClubName['AmharicName'] ?? toClubName['amharicName']);
    String oromoToClubName =
        stringOrEmpty(toClubName['OromoName'] ?? toClubName['oromoName']);
    String englishToClubName =
        stringOrEmpty(toClubName['EnglishName'] ?? toClubName['englishName']);
    String somaliToClubName =
        stringOrEmpty(toClubName['SomaliName'] ?? toClubName['somaliName']);

    if (englishToClubName.isEmpty && toClubNameRaw.isNotEmpty) {
      englishToClubName = toClubNameRaw;
    }
    if (amharicToClubName.isEmpty && toClubNameRaw.isNotEmpty) {
      amharicToClubName = toClubNameRaw;
    }
    if (oromoToClubName.isEmpty && toClubNameRaw.isNotEmpty) {
      oromoToClubName = toClubNameRaw;
    }
    if (somaliToClubName.isEmpty && toClubNameRaw.isNotEmpty) {
      somaliToClubName = toClubNameRaw;
    }

    String fromClubLogo = stringOrDefault(
        json['fromClubPhoto'] ?? teamName['Logo'], 'assets/club.png');
    String toClubLogo = stringOrDefault(
        json['toClubPhoto'] ?? toClubName['Logo'], 'assets/club.png');

    final playerProfile = stringOrEmpty(json['playerProfile'] ??
        json['playerPhoto'] ??
        json['playerImage'] ??
        playerMap['photo']);
    final transferAmount = stringOrEmpty(
        json['transferAmount'] ?? json['transferFee'] ?? json['transfer_fee']);
    final age = stringOrEmpty(json['age'] ?? json['playerAge']);
    final nationalityLogo = stringOrEmpty(json['nationalitylogo'] ??
        json['nationalityLogo'] ??
        json['nationality_flag'] ??
        json['nationalityFlag'] ??
        json['nationalityLogoUrl']);
    final positionRaw =
        stringOrEmpty(json['position'] ?? json['playerPosition']);

    final playerEnglishName = stringOrEmpty(
        playerMap['EnglishName'] ?? playerMap['englishName'] ?? playerNameRaw);
    final playerAmharicName =
        stringOrEmpty(playerMap['AmharicName'] ?? playerMap['amharicName']);
    final playerOromoName =
        stringOrEmpty(playerMap['OromoName'] ?? playerMap['oromoName']);
    final playerSomaliName =
        stringOrEmpty(playerMap['SomaliName'] ?? playerMap['somaliName']);

    return TransferModel(
      fromClubName: TeamName(
        amharicName: amharicTeamName.isNotEmpty ? amharicTeamName : 'Club',
        englishName: englishTeamName.isNotEmpty ? englishTeamName : 'Club',
        oromoName: oromoTeamName.isNotEmpty ? oromoTeamName : 'Club',
        somaliName: somaliTeamName.isNotEmpty ? somaliTeamName : 'Club',
        logo: fromClubLogo,
        id: 0,
      ),
      toClubName: TeamName(
        amharicName: amharicToClubName.isNotEmpty ? amharicToClubName : 'Club',
        englishName: englishToClubName.isNotEmpty ? englishToClubName : 'Club',
        oromoName: oromoToClubName.isNotEmpty ? oromoToClubName : 'Club',
        somaliName: somaliToClubName.isNotEmpty ? somaliToClubName : 'Club',
        logo: toClubLogo,
        id: 0,
      ),
      playerName: PlayerName(
        amharicName: playerAmharicName,
        englishName:
            playerEnglishName.isNotEmpty ? playerEnglishName : playerNameRaw,
        oromoName: playerOromoName,
        somaliName: playerSomaliName,
        photo: playerProfile,
        id: 0,
      ),
      transferAmount: transferAmount.isNotEmpty ? transferAmount : '0',
      age: age,
      nationalitylogo: nationalityLogo,
      position: mapPositionToLocalized(positionRaw),
      playerProfile: playerProfile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromClubName': {
        'AmharicName': fromClubName.amharicName,
        'EnglishName': fromClubName.englishName,
        'OromoName': fromClubName.oromoName,
        'SomaliName': fromClubName.somaliName,
        'Logo': fromClubName.logo,
        'Id': fromClubName.id,
      },
      'toClubName': {
        'AmharicName': toClubName.amharicName,
        'EnglishName': toClubName.englishName,
        'OromoName': toClubName.oromoName,
        'SomaliName': toClubName.somaliName,
        'Logo': toClubName.logo,
        'Id': toClubName.id,
      },
      'playerName': {
        'AmharicName': playerName.amharicName,
        'EnglishName': playerName.englishName,
        'OromoName': playerName.oromoName,
        'SomaliName': playerName.somaliName,
        'Photo': playerName.photo,
        'Id': playerName.id,
      },
      'transferAmount': transferAmount,
      'age': age,
      'nationalitylogo': nationalitylogo,
      'position': position,
      'playerProfile': playerProfile,
    };
  }
}

extension TransferModelView on TransferModel {
  String localizedPlayerName(String lang) {
    if (lang == 'am' && playerName.amharicName.isNotEmpty) {
      return playerName.amharicName;
    }
    if (lang == 'or' && playerName.oromoName.isNotEmpty) {
      return playerName.oromoName;
    }
    if (lang == 'so' && playerName.somaliName.isNotEmpty) {
      return playerName.somaliName;
    }
    return playerName.englishName.isNotEmpty
        ? playerName.englishName
        : 'Unknown';
  }

  String localizedClubName(TeamName club, String lang) {
    if (lang == 'am' && club.amharicName.isNotEmpty) return club.amharicName;
    if (lang == 'or' && club.oromoName.isNotEmpty) return club.oromoName;
    if (lang == 'so' && club.somaliName.isNotEmpty) return club.somaliName;
    return club.englishName.isNotEmpty ? club.englishName : 'N/A';
  }

  String normalizedTransferAmount(String lang) {
    final cleaned = transferAmount.trim();
    if (cleaned.isEmpty || cleaned.toLowerCase() == 'null' || cleaned == '0') {
      return 'N/A';
    }
    if (cleaned.toLowerCase().contains('free')) {
      switch (lang) {
        case 'am':
          return 'ነጻ ዝውውር';
        case 'or':
          return 'Bilisa';
        case 'so':
          return 'Bilaash';
        default:
          return 'Free';
      }
    }
    return cleaned;
  }

  String resolvedPlayerImage() {
    if (playerProfile.trim().isNotEmpty &&
        playerProfile.toLowerCase() != 'null') {
      return playerProfile;
    }
    return playerName.photo ?? '';
  }
}

String mapPositionToLocalized(String transfermarktPosition) {
  switch (transfermarktPosition.toLowerCase()) {
    case 'goalkeeper':
    case 'gk':
      return DemoLocalizations.goalkeeper;
    case 'centre-back':
    case 'cb':
      return DemoLocalizations.centerBack;
    case 'right-back':
    case 'rb':
      return DemoLocalizations.rightBack;
    case 'left-back':
    case 'lb':
      return DemoLocalizations.leftBack;
    case 'defensive midfield':
    case 'dm':
      return DemoLocalizations.defensiveMidfielder;
    case 'central midfield':
    case 'cm':
      return DemoLocalizations.centralMidfielder;
    case 'right midfield':
    case 'rm':
      return DemoLocalizations.rightMidfielder;
    case 'left midfield':
    case 'lm':
      return DemoLocalizations.leftMidfielder;
    case 'attacking midfield':
    case 'am':
      return DemoLocalizations.attackingMidfielder;
    case 'right winger':
    case 'rw':
    case 'left winger':
    case 'lw':
      return DemoLocalizations.wingerForward;
    case 'second striker':
    case 'ss':
      return DemoLocalizations.secondStriker;
    case 'centre-forward':
    case 'cf':
    case 'striker':
    case 'st':
      return DemoLocalizations.centerForward;
    default:
      return transfermarktPosition;
  }
}
