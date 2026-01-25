import 'package:flutter/material.dart';
import '../../main.dart';

class TextUtils {
  static TextStyle setTextStyle({
    ThemeData? themeData,
    double? fontSize,
    Color? color,
    double? engFont,
    FontWeight fontWeight = FontWeight.normal,
    double? height,
    TextDecoration? decoration = TextDecoration.none,
    TextOverflow? overflow,
    double? letterSpacing,
    double? wordSpacing,
    Color? backgroundColor,
    String? fontFamily,
    TextStyle? textStyle,
    List<Shadow>? shadows, // 1. Added shadows parameter
  }) {
    // Determine font family based on language
    String family = (localLanguageNotifier.value == 'am' ||
            localLanguageNotifier.value == 'tr')
        ? 'AbyssinicaSIL-Regular'
        : 'klavika-medium';

    return TextStyle(
      fontFamily: fontFamily ?? family,
      fontSize: fontSize,
      color:
          color ?? textStyle?.color ?? themeData?.textTheme.titleLarge?.color,
      fontWeight: fontWeight,
      height: height,
      decoration: decoration,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      backgroundColor: backgroundColor,
      shadows: shadows, // 2. Applied shadows here
      overflow: overflow,
    );
  }
}
