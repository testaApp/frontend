import 'package:flutter/material.dart';

Color getOppositeColor(Color color) {
  int oppositeRed = 255 - color.red;
  int oppositeGreen = 255 - color.green;
  int oppositeBlue = 255 - color.blue;

  return Color.fromARGB(
    color.alpha,
    oppositeRed,
    oppositeGreen,
    oppositeBlue,
  );
}
