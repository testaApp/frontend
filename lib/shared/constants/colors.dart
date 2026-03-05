import 'package:flutter/material.dart';

class Colorscontainer {
  static String hexColor = '#29A96F';

  // Primary Green Color from Hex
  static Color greenColor =
      Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000);

  // Dark Background Colors (Adjust these for the specific dark theme)
  static Color blueShade =
      Colors.blueGrey.shade800; // Used for Manager Card background
  static Color greyShade =
      Colors.grey.shade900; // Used for Tab Selector track background
  static Color greenShade =
      const Color.fromARGB(255, 45, 45, 45); // Darker shade
  static Color greyShade2 =
      const Color.fromARGB(111, 97, 96, 96); // Semi-transparent grey

  static Color veryLightGreen = greenColor.withAlpha(0xCC);
}
