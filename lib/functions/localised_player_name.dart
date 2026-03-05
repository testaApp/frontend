// File: functions/localised_player_name.dart

import 'package:flutter/material.dart';
import 'package:blogapp/domain/player/playerName.dart';
import 'package:blogapp/main.dart'; // Make sure this imports the file where localLanguageNotifier is defined

/// Returns the player's name in the current app language.
/// Automatically updates when language changes because it reads from localLanguageNotifier.value
String getLocalPlayerName(PlayerName player) {
  final String language = localLanguageNotifier.value;

  switch (language) {
    case 'am':
    case 'tr': // you treat Turkish same as Amharic
      if (player.amharicName.trim().isNotEmpty) {
        return player.amharicName.trim();
      }
      break;

    case 'or':
      if (player.oromoName.trim().isNotEmpty) {
        return player.oromoName.trim();
      }
      break;

    case 'so':
      if (player.somaliName.trim().isNotEmpty) {
        return player.somaliName.trim();
      }
      break;

    default:
      // English or any unknown language
      if (player.englishName.trim().isNotEmpty) {
        return player.englishName.trim();
      }
  }

  // Final fallback: use whatever is in englishName (which already contains API name)
  return player.englishName.trim().isNotEmpty
      ? player.englishName.trim()
      : 'Unknown Player';
}
