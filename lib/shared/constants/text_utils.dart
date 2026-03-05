import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final isAmOrTr = localLanguageNotifier.value == 'am' ||
        localLanguageNotifier.value == 'tr';
    final useReadableEnglishWeight =
        !isAmOrTr && fontFamily == null && fontWeight == FontWeight.normal;
    final effectiveWeight =
        useReadableEnglishWeight ? FontWeight.w600 : fontWeight;

    final baseStyle = TextStyle(
      fontFamily: fontFamily ?? (isAmOrTr ? 'AbyssinicaSIL-Regular' : null),
      fontSize: fontSize,
      color:
          color ?? textStyle?.color ?? themeData?.textTheme.titleLarge?.color,
      fontWeight: effectiveWeight,
      height: height,
      decoration: decoration,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      backgroundColor: backgroundColor,
      shadows: shadows, // 2. Applied shadows here
      overflow: overflow,
    );

    if (fontFamily != null || isAmOrTr) {
      return baseStyle;
    }

    return GoogleFonts.notoSans(textStyle: baseStyle);
  }
}
