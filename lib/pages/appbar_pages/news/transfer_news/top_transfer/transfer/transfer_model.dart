import '../../../../../../domain/player/playerName.dart';
import '../../../../../../localization/demo_localization.dart';
import '../../../../../../models/teamName.dart';

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
    final teamName = json['fromClubName'] as Map<String, dynamic>? ?? {};
    final toClubName = json['toClubName'] as Map<String, dynamic>? ?? {};

    String amharicTeamName = teamName['AmharicName'] ?? '';
    String oromoTeamName = teamName['OromoName'] ?? '';
    String englishTeamName = teamName['EnglishName'] ?? '';
    String somaliTeamName = teamName['SomaliName'] ?? '';

    String amharicToClubName = toClubName['AmharicName'] ?? '';
    String oromoToClubName = toClubName['OromoName'] ?? '';
    String englishToClubName = toClubName['EnglishName'] ?? '';
    String somaliToClubName = toClubName['SomaliName'] ?? '';

    String fromClubLogo =
        json['fromClubPhoto'] ?? 'assets/placeholder_logo.png';
    String toClubLogo = json['toClubPhoto'] ?? 'assets/placeholder_logo.png';

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
        amharicName: json['playerName']['AmharicName'] ?? '',
        englishName: json['playerName']['EnglishName'] ?? '',
        oromoName: json['playerName']['OromoName'] ?? '',
        somaliName: json['playerName']['SomaliName'] ?? '',
        photo: json['playerProfile'] ?? '',
        id: 0,
      ),
      transferAmount: json['transferAmount'] ?? '0',
      age: json['age'] ?? '',
      nationalitylogo: json['nationalitylogo'] ?? '',
      position: mapPositionToLocalized(json['position'] ?? ''),
      playerProfile: json['playerProfile'] ?? '',
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
