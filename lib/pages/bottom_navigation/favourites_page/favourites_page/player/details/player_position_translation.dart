import '../../../../../../localization/demo_localization.dart';

class PlayerPositionTranslation {
  static String translatePosition(String position) {
    if (position == null || position.isEmpty) {
      return '';
    }

    // Normalize the position string: lowercase and trim
    final normalizedPosition = position.toLowerCase().trim();

    switch (normalizedPosition) {
      // === Short single-letter codes (common in lineup/substitutes APIs) ===
      case 'g':
        return DemoLocalizations.goalkeeper;

      case 'd':
        return DemoLocalizations.defender;

      case 'm':
        return DemoLocalizations.midfielder;

      case 'f':
        return DemoLocalizations
            .centerForward; // or .attacker if you prefer broader term

      // === Goalkeeper ===
      case 'goalkeeper':
      case 'gk':
      case 'goalie':
        return DemoLocalizations.goalkeeper;

      // === Defenders ===
      case 'defense':
      case 'defender':
      case 'defenders':
      case 'defensive':
        return DemoLocalizations.defender;

      case 'centre-back':
      case 'center-back':
      case 'cb':
        return DemoLocalizations.centerBack;

      case 'right-back':
      case 'rb':
        return DemoLocalizations.rightBack;

      case 'left-back':
      case 'lb':
        return DemoLocalizations.leftBack;

      case 'sweeper':
        return DemoLocalizations.sweeper;

      case 'wing-back':
      case 'wb':
        return DemoLocalizations.wingBack;

      case 'libero':
        return DemoLocalizations.libero;

      // === Midfielders ===
      case 'midfielder':
        return DemoLocalizations.midfielder;

      case 'defensive midfielder':
      case 'defensive midfield':
      case 'dm':
      case 'cdm':
        return DemoLocalizations.defensiveMidfielder;

      case 'central midfielder':
      case 'central midfield':
      case 'cm':
        return DemoLocalizations.centralMidfielder;

      case 'right midfielder':
      case 'right midfield':
      case 'rm':
        return DemoLocalizations.rightMidfielder;

      case 'left midfielder':
      case 'left midfield':
      case 'lm':
        return DemoLocalizations.leftMidfielder;

      case 'attacking midfielder':
      case 'attacking midfield':
      case 'am':
      case 'cam':
        return DemoLocalizations.attackingMidfielder;

      case 'box-to-box midfielder':
      case 'b2b':
        return DemoLocalizations.boxToBoxMidfielder;

      case 'playmaker':
        return DemoLocalizations.playmaker;

      case 'trequartista':
        return DemoLocalizations.trequartista;

      // === Forwards / Attackers ===
      case 'attacker':
      case 'forward':
        return DemoLocalizations.attacker;

      case 'striker':
      case 'centre-forward':
      case 'center-forward':
      case 'st':
        return DemoLocalizations.centerForward;

      case 'right winger':
      case 'right wing':
      case 'rw':
      case 'left winger':
      case 'left wing':
      case 'lw':
        return DemoLocalizations.wingerForward;

      case 'second striker':
      case 'supporting striker':
      case 'ss':
      case 'cf':
        return DemoLocalizations.secondStriker;

      case 'false nine':
        return DemoLocalizations.falseNine;

      case 'target man':
        return DemoLocalizations.targetMan;

      // === Fallback ===
      default:
        // If no match, return the original (useful for rare or new positions)
        return position;
    }
  }
}
