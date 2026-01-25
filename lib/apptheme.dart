import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/constants/colors.dart';
import 'pages/constants/text_utils.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  primaryColor: Colorscontainer.greenColor,
  primaryColorLight: Colorscontainer.greenColor,
  primaryColorDark: Colorscontainer.greenColor,
  canvasColor: const Color(0xFF121212),
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  dividerColor: const Color(0x1FFFFFFF),
  highlightColor: const Color(0x40CCCCCC),
  splashColor: const Color(0x40CCCCCC),
  unselectedWidgetColor: const Color(0xB3FFFFFF),
  disabledColor: const Color(0x62FFFFFF),
  secondaryHeaderColor: const Color(0xFF616161),
  dialogBackgroundColor: const Color(0xFF1E1E1E),
  indicatorColor: Colorscontainer.greenColor,
  hintColor: const Color(0x80FFFFFF),
  primarySwatch: MaterialColor(Colorscontainer.greenColor.value, <int, Color>{
    50: Colorscontainer.greenColor.withOpacity(0.1),
    100: Colorscontainer.greenColor.withOpacity(0.2),
    200: Colorscontainer.greenColor.withOpacity(0.3),
    300: Colorscontainer.greenColor.withOpacity(0.4),
    400: Colorscontainer.greenColor.withOpacity(0.5),
    500: Colorscontainer.greenColor,
    600: Colorscontainer.greenColor.withOpacity(0.7),
    700: Colorscontainer.greenColor.withOpacity(0.8),
    800: Colorscontainer.greenColor.withOpacity(0.9),
    900: Colorscontainer.greenColor.withOpacity(1.0),
  }),
  colorScheme: ColorScheme.dark(
    brightness: Brightness.dark,
    primary: Colorscontainer.greenColor,
    onPrimary: Colors.white,
    primaryContainer: Colorscontainer.greenColor.withOpacity(0.7),
    onPrimaryContainer: Colors.white,
    secondary: Colorscontainer.greenColor,
    onSecondary: Colors.white,
    secondaryContainer: Colorscontainer.greenColor.withOpacity(0.7),
    onSecondaryContainer: Colors.white,
    tertiary: Colorscontainer.greenColor,
    onTertiary: Colors.white,
    tertiaryContainer: Colorscontainer.greenColor.withOpacity(0.7),
    onTertiaryContainer: Colors.white,
    error: const Color(0xFFF2B8B5),
    onError: const Color(0xFF601410),
    errorContainer: const Color(0xFF8C1D18),
    onErrorContainer: const Color(0xFFF9DEDC),
    surface: const Color(0xFF141218),
    onSurface: const Color(0xFFE6E0E9),
    surfaceContainerHighest: const Color(0xFF49454F),
    onSurfaceVariant: const Color(0xFFCAC4D0),
    outline: const Color(0xFF938F99),
    shadow: const Color(0xFF000000),
    inverseSurface: const Color(0xFFE6E0E9),
    onInverseSurface: const Color(0xFF322F35),
    inversePrimary: Colorscontainer.greenColor,
    surfaceTint: Colorscontainer.greenColor,
  ),
  textTheme: TextTheme(
    displayLarge: TextUtils.setTextStyle(
        fontSize: 96, fontWeight: FontWeight.w300, color: Colors.white70),
    displayMedium: TextUtils.setTextStyle(
        fontSize: 60, fontWeight: FontWeight.w300, color: Colors.white70),
    displaySmall: TextUtils.setTextStyle(
        fontSize: 48, fontWeight: FontWeight.w400, color: Colors.white70),
    headlineLarge: TextUtils.setTextStyle(
        fontSize: 40, fontWeight: FontWeight.w400, color: Colors.white70),
    headlineMedium: TextUtils.setTextStyle(
        fontSize: 34, fontWeight: FontWeight.w400, color: Colors.white70),
    headlineSmall: TextUtils.setTextStyle(
        fontSize: 24, fontWeight: FontWeight.w400, color: Colors.white70),
    titleLarge: TextUtils.setTextStyle(
        fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white70),
    titleMedium: TextUtils.setTextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white70),
    titleSmall: TextUtils.setTextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
    bodyLarge: TextUtils.setTextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white70),
    bodyMedium: TextUtils.setTextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
    bodySmall: TextUtils.setTextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white54),
    labelLarge: TextUtils.setTextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
    labelMedium: TextUtils.setTextStyle(
        fontSize: 11, fontWeight: FontWeight.w400, color: Colors.white70),
    labelSmall: TextUtils.setTextStyle(
        fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white70),
  ),
  primaryTextTheme: TextTheme(
    displayLarge: TextUtils.setTextStyle(
        fontSize: 96, fontWeight: FontWeight.w300, color: Colors.white),
    displayMedium: TextUtils.setTextStyle(
        fontSize: 60, fontWeight: FontWeight.w300, color: Colors.white),
    displaySmall: TextUtils.setTextStyle(
        fontSize: 48, fontWeight: FontWeight.w400, color: Colors.white),
    headlineLarge: TextUtils.setTextStyle(
        fontSize: 40, fontWeight: FontWeight.w400, color: Colors.white),
    headlineMedium: TextUtils.setTextStyle(
        fontSize: 34, fontWeight: FontWeight.w400, color: Colors.white),
    headlineSmall: TextUtils.setTextStyle(
        fontSize: 24, fontWeight: FontWeight.w400, color: Colors.white),
    titleLarge: TextUtils.setTextStyle(
        fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
    titleMedium: TextUtils.setTextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
    titleSmall: TextUtils.setTextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
    bodyLarge: TextUtils.setTextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
    bodyMedium: TextUtils.setTextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
    bodySmall: TextUtils.setTextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
    labelLarge: TextUtils.setTextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
    labelMedium: TextUtils.setTextStyle(
        fontSize: 11, fontWeight: FontWeight.w400, color: Colors.white),
    labelSmall: TextUtils.setTextStyle(
        fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: const Color(0xFF2A2A2A),
    filled: true,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colorscontainer.greenColor),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colorscontainer.greenColor, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFCF6679)),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFCF6679), width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    labelStyle: TextStyle(color: Colorscontainer.greenColor),
    hintStyle: const TextStyle(color: Color(0x80FFFFFF)),
  ),
  iconTheme: IconThemeData(color: Colorscontainer.greenColor),
  primaryIconTheme: const IconThemeData(color: Colors.black),
  sliderTheme: SliderThemeData(
    activeTrackColor: Colorscontainer.greenColor,
    inactiveTrackColor: Colorscontainer.greenColor.withOpacity(0.3),
    thumbColor: Colorscontainer.greenColor,
    overlayColor: Colorscontainer.greenColor.withOpacity(0.2),
    valueIndicatorColor: Colorscontainer.greenColor,
    activeTickMarkColor: const Color(0x8AFFFFFF),
    inactiveTickMarkColor: const Color(0x8AFFFFFF),
  ),
  tabBarTheme: TabBarThemeData(
    // Changed from TabBarTheme
    indicatorSize: TabBarIndicatorSize.tab,
    labelColor: Colorscontainer.greenColor,
    unselectedLabelColor: Colors.white70,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0x1FFFFFFF),
    disabledColor: const Color(0x0CFFFFFF),
    selectedColor: const Color(0x3DFFFFFF),
    secondarySelectedColor: Colorscontainer.greenColor.withOpacity(0.3),
    padding: const EdgeInsets.all(4),
    labelStyle: const TextStyle(color: Colors.white70),
    secondaryLabelStyle: const TextStyle(color: Colors.black),
    brightness: Brightness.dark,
  ),
  dialogTheme: const DialogThemeData(
    // Changed from DialogTheme
    backgroundColor: Color(0xFF1E1E1E),
    titleTextStyle: TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    contentTextStyle: TextStyle(color: Colors.white70, fontSize: 16),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colorscontainer.greenColor,
    foregroundColor: Colors.black,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    indicatorColor: Colorscontainer.greenColor.withOpacity(0.3),
    labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: Colors.white70, fontSize: 14)),
    iconTheme:
        WidgetStateProperty.all(const IconThemeData(color: Colors.white70)),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF323232),
    contentTextStyle: const TextStyle(color: Colors.white),
    actionTextColor: Colorscontainer.greenColor,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    modalBackgroundColor: Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: Color(0xFF2A2A2A),
    textStyle: TextStyle(color: Colors.white70),
  ),
  bannerTheme: const MaterialBannerThemeData(
    backgroundColor: Color(0xFF2A2A2A),
    contentTextStyle: TextStyle(color: Colors.white70),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0x1FFFFFFF),
    thickness: 1,
    space: 1,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    selectedItemColor: Colorscontainer.greenColor,
    unselectedItemColor: Colors.white70,
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    hourMinuteTextColor: Colors.white,
    dayPeriodTextColor: Colors.white70,
    dialHandColor: Colorscontainer.greenColor,
    dialBackgroundColor: const Color(0xFF2A2A2A),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colorscontainer.greenColor,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colorscontainer.greenColor,
      foregroundColor: Colors.black,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colorscontainer.greenColor,
      side: BorderSide(color: Colorscontainer.greenColor),
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colorscontainer.greenColor,
    selectionColor: Colorscontainer.greenColor.withOpacity(0.3),
    selectionHandleColor: Colorscontainer.greenColor,
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Colorscontainer.greenColor,
    linearTrackColor: Colorscontainer.greenColor.withOpacity(0.3),
    circularTrackColor: Colorscontainer.greenColor.withOpacity(0.3),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  scrollbarTheme: ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(Colorscontainer.greenColor),
    trackColor:
        WidgetStateProperty.all(Colorscontainer.greenColor.withOpacity(0.3)),
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(
    // Changed from BottomAppBarTheme
    color: Color(0xFF1E1E1E),
    elevation: 0,
  ),
  tooltipTheme: TooltipThemeData(
    decoration: BoxDecoration(
      color: const Color(0xFF424242),
      borderRadius: BorderRadius.circular(4),
    ),
    textStyle: const TextStyle(color: Colors.white),
  ),
);

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  primaryColor: Colorscontainer.greenColor,
  primaryColorLight: Colorscontainer.greenColor,
  primaryColorDark: Colorscontainer.greenColor,
  canvasColor: const Color(0xFFFAFAFA),
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  cardColor: Colors.white,
  dividerColor: const Color(0x1F000000),
  highlightColor: const Color(0x66BCBCBC),
  splashColor: const Color(0x66C8C8C8),
  unselectedWidgetColor: const Color(0x8A000000),
  disabledColor: const Color(0x61000000),
  secondaryHeaderColor: const Color(0xFFE8F5E9),
  dialogBackgroundColor: Colors.white,
  indicatorColor: Colorscontainer.greenColor,
  hintColor: const Color(0x8A000000),
  primarySwatch: MaterialColor(Colorscontainer.greenColor.value, <int, Color>{
    50: Colorscontainer.greenColor.withOpacity(0.1),
    100: Colorscontainer.greenColor.withOpacity(0.2),
    200: Colorscontainer.greenColor.withOpacity(0.3),
    300: Colorscontainer.greenColor.withOpacity(0.4),
    400: Colorscontainer.greenColor.withOpacity(0.5),
    500: Colorscontainer.greenColor,
    600: Colorscontainer.greenColor.withOpacity(0.7),
    700: Colorscontainer.greenColor.withOpacity(0.8),
    800: Colorscontainer.greenColor.withOpacity(0.9),
    900: Colorscontainer.greenColor.withOpacity(1.0),
  }),
  colorScheme: ColorScheme.light(
    brightness: Brightness.light,
    primary: Colorscontainer.greenColor,
    onPrimary: Colors.white,
    primaryContainer: Colorscontainer.greenColor.withOpacity(0.1),
    onPrimaryContainer: Colors.white,
    secondary: Colorscontainer.greenColor,
    onSecondary: Colors.white,
    secondaryContainer: Colorscontainer.greenColor.withOpacity(0.1),
    onSecondaryContainer: Colors.white,
    tertiary: Colorscontainer.greenColor,
    onTertiary: Colors.white,
    tertiaryContainer: Colorscontainer.greenColor.withOpacity(0.1),
    onTertiaryContainer: Colors.white,
    error: const Color(0xFFB3261E),
    onError: Colors.white,
    errorContainer: const Color(0xFFF9DEDC),
    onErrorContainer: const Color(0xFF410E0B),
    surface: const Color(0xFFFEF7FF),
    onSurface: const Color(0xFF1D1B20),
    surfaceContainerHighest: const Color(0xFFE7E0EC),
    onSurfaceVariant: const Color(0xFF49454F),
    outline: const Color(0xFF79747E),
    shadow: const Color(0xFF000000),
    inverseSurface: const Color(0xFF322F35),
    onInverseSurface: const Color(0xFFF5EFF7),
    inversePrimary: Colorscontainer.greenColor,
    surfaceTint: Colorscontainer.greenColor,
  ),
  textTheme: TextTheme(
    displayLarge: TextUtils.setTextStyle(
        fontSize: 96, fontWeight: FontWeight.w300, color: Colors.black87),
    displayMedium: TextUtils.setTextStyle(
        fontSize: 60, fontWeight: FontWeight.w300, color: Colors.black87),
    displaySmall: TextUtils.setTextStyle(
        fontSize: 48, fontWeight: FontWeight.w400, color: Colors.black87),
    headlineLarge: TextUtils.setTextStyle(
        fontSize: 40, fontWeight: FontWeight.w400, color: Colors.black87),
    headlineMedium: TextUtils.setTextStyle(
        fontSize: 34, fontWeight: FontWeight.w400, color: Colors.black87),
    headlineSmall: TextUtils.setTextStyle(
        fontSize: 24, fontWeight: FontWeight.w400, color: Colors.black87),
    titleLarge: TextUtils.setTextStyle(
        fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
    titleMedium: TextUtils.setTextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black87),
    titleSmall: TextUtils.setTextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
    bodyLarge: TextUtils.setTextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black87),
    bodyMedium: TextUtils.setTextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black87),
    bodySmall: TextUtils.setTextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black54),
    labelLarge: TextUtils.setTextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
    labelMedium: TextUtils.setTextStyle(
        fontSize: 11, fontWeight: FontWeight.w400, color: Colors.black87),
    labelSmall: TextUtils.setTextStyle(
        fontSize: 10, fontWeight: FontWeight.w400, color: Colors.black87),
  ),
  primaryTextTheme: TextTheme(
    displayLarge: TextUtils.setTextStyle(
        fontSize: 96, fontWeight: FontWeight.w300, color: Colors.white),
    displayMedium: TextUtils.setTextStyle(
        fontSize: 60, fontWeight: FontWeight.w300, color: Colors.white),
    displaySmall: TextUtils.setTextStyle(
        fontSize: 48, fontWeight: FontWeight.w400, color: Colors.white),
    headlineLarge: TextUtils.setTextStyle(
        fontSize: 40, fontWeight: FontWeight.w400, color: Colors.white),
    headlineMedium: TextUtils.setTextStyle(
        fontSize: 34, fontWeight: FontWeight.w400, color: Colors.white),
    headlineSmall: TextUtils.setTextStyle(
        fontSize: 24, fontWeight: FontWeight.w400, color: Colors.white),
    titleLarge: TextUtils.setTextStyle(
        fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
    titleMedium: TextUtils.setTextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
    titleSmall: TextUtils.setTextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
    bodyLarge: TextUtils.setTextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
    bodyMedium: TextUtils.setTextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
    bodySmall: TextUtils.setTextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
    labelLarge: TextUtils.setTextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
    labelMedium: TextUtils.setTextStyle(
        fontSize: 11, fontWeight: FontWeight.w400, color: Colors.white),
    labelSmall: TextUtils.setTextStyle(
        fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.white,
    filled: true,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colorscontainer.greenColor),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colorscontainer.greenColor, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFB00020)),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFB00020), width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    labelStyle: TextStyle(color: Colorscontainer.greenColor),
    hintStyle: const TextStyle(color: Color(0x8A000000)),
  ),
  iconTheme: IconThemeData(color: Colorscontainer.greenColor),
  primaryIconTheme: const IconThemeData(color: Colors.white),
  sliderTheme: SliderThemeData(
    activeTrackColor: Colorscontainer.greenColor,
    inactiveTrackColor: Colorscontainer.greenColor.withOpacity(0.3),
    thumbColor: Colorscontainer.greenColor,
    overlayColor: Colorscontainer.greenColor.withOpacity(0.2),
    valueIndicatorColor: Colorscontainer.greenColor,
    activeTickMarkColor: const Color(0x8A000000),
    inactiveTickMarkColor: const Color(0x8A000000),
  ),
  tabBarTheme: TabBarThemeData(
    // Changed from TabBarTheme
    indicatorSize: TabBarIndicatorSize.tab,
    labelColor: Colorscontainer.greenColor,
    unselectedLabelColor: Colors.black54,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0x1F000000),
    disabledColor: const Color(0x0C000000),
    selectedColor: Colorscontainer.greenColor.withOpacity(0.3),
    secondarySelectedColor: Colorscontainer.greenColor.withOpacity(0.3),
    padding: const EdgeInsets.all(4),
    labelStyle: const TextStyle(color: Colors.black87),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
    brightness: Brightness.light,
  ),
  dialogTheme: const DialogThemeData(
    // Changed from DialogTheme
    backgroundColor: Colors.white,
    titleTextStyle: TextStyle(
        color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    contentTextStyle: TextStyle(color: Colors.black87, fontSize: 16),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colorscontainer.greenColor,
    foregroundColor: Colors.white,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: Colorscontainer.greenColor.withOpacity(0.3),
    labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: Colors.black87, fontSize: 14)),
    iconTheme:
        WidgetStateProperty.all(const IconThemeData(color: Colors.black87)),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF323232),
    contentTextStyle: const TextStyle(color: Colors.white),
    actionTextColor: Colorscontainer.greenColor,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    modalBackgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: Colors.white,
    textStyle: TextStyle(color: Colors.black87),
  ),
  bannerTheme: const MaterialBannerThemeData(
    backgroundColor: Color(0xFFE0E0E0),
    contentTextStyle: TextStyle(color: Colors.black87),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0x1F000000),
    thickness: 1,
    space: 1,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colorscontainer.greenColor,
    unselectedItemColor: Colors.black54,
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: Colors.white,
    hourMinuteTextColor: Colors.black,
    dayPeriodTextColor: Colors.black87,
    dialHandColor: Colorscontainer.greenColor,
    dialBackgroundColor: const Color(0xFFE0E0E0),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colorscontainer.greenColor,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colorscontainer.greenColor,
      foregroundColor: Colors.white,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colorscontainer.greenColor,
      side: BorderSide(color: Colorscontainer.greenColor),
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colorscontainer.greenColor,
    selectionColor: Colorscontainer.greenColor.withOpacity(0.3),
    selectionHandleColor: Colorscontainer.greenColor,
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Colorscontainer.greenColor,
    linearTrackColor: Colorscontainer.greenColor.withOpacity(0.3),
    circularTrackColor: Colorscontainer.greenColor.withOpacity(0.3),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colorscontainer.greenColor,
    foregroundColor: Colors.white,
    elevation: 4,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarIconBrightness:
          Brightness.dark, // Black/dark icons → visible on light background
      statusBarBrightness:
          Brightness.light, // For iOS: light content (dark icons)
      statusBarColor: Colors.transparent,
    ),
  ),
  scrollbarTheme: ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(Colorscontainer.greenColor),
    trackColor:
        WidgetStateProperty.all(Colorscontainer.greenColor.withOpacity(0.3)),
  ),
  tooltipTheme: TooltipThemeData(
    decoration: BoxDecoration(
      color: Colors.grey[700],
      borderRadius: BorderRadius.circular(4),
    ),
    textStyle: const TextStyle(color: Colors.white),
  ),
);
