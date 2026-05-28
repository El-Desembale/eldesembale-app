import 'package:flutter/material.dart';

import '../../utils/design_tokens.dart';

final ColorScheme _darkScheme = ColorScheme.fromSeed(
  seedColor: kPrimaryGreen,
  brightness: Brightness.dark,
  primary: kPrimaryGreen,
  secondary: kPrimaryGreen,
  surface: kBgScreenAlt,
  onPrimary: kBgScreen,
  onSurface: kTextPrimary,
);

final ThemeData lightTheme = darkTheme;

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: _darkScheme,
  scaffoldBackgroundColor: kBgScreen,
  canvasColor: kBgScreen,
  splashFactory: NoSplash.splashFactory,
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: kTextPrimary,
      height: 1.12,
      letterSpacing: -0.4,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: kTextPrimary,
      height: 1.14,
      letterSpacing: -0.2,
    ),
    titleLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: kTextPrimary,
      height: 1.18,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: kTextPrimary,
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 14,
      height: 1.45,
      color: kTextPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 12,
      height: 1.45,
      color: kTextSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: kTextPrimary,
    ),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: kPrimaryGreen,
    selectionColor: kPrimaryGreenSoft,
    selectionHandleColor: kPrimaryGreen,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kInputSurface,
    hintStyle: const TextStyle(color: kTextSecondary, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusInput),
      borderSide: const BorderSide(color: kBorderFaint),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusInput),
      borderSide: const BorderSide(color: kBorderFaint),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusInput),
      borderSide: const BorderSide(color: kPrimaryGreen, width: 1.2),
    ),
  ),
  dividerColor: kBorderFaint,
);
