import 'package:flutter/material.dart';

/// Token visual yang diambil langsung dari mockup di folder design/.
abstract class Tokens {
  static const ink = Color(0xFF0F1E1B);
  static const inkSoft = Color(0xFF1A3832);
  static const inkLine = Color(0xFF273532);
  static const surface = Color(0xFFF5F6F4);
  static const card = Color(0xFFFFFFFF);
  static const primary = Color(0xFF0F6E64);
  static const mint = Color(0xFF5FD3BF);
  static const mintSoft = Color(0xFFDCEEEA);
  static const danger = Color(0xFFB3261E);
  static const dangerTrack = Color(0xFFF0B8B2);
  static const dangerSoft = Color(0xFFF3DCD9);
  static const muted = Color(0xFF85938F);
  static const body = Color(0xFF3C3F38);
  static const hairline = Color(0xFFEAECEC);

  static const radiusCard = 20.0;
  static const radiusLarge = 28.0;
  static const gap = 16.0;
  static const pagePad = EdgeInsets.symmetric(horizontal: 20);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Tokens.primary,
    primary: Tokens.primary,
    surface: Tokens.surface,
    error: Tokens.danger,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Tokens.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: Tokens.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Tokens.ink,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: Tokens.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Tokens.radiusCard),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Tokens.ink,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: const StadiumBorder(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Tokens.ink,
        backgroundColor: Tokens.card,
        minimumSize: const Size.fromHeight(56),
        side: const BorderSide(color: Tokens.hairline),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: const StadiumBorder(),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          fontSize: 30, fontWeight: FontWeight.w800, color: Tokens.ink, height: 1.2),
      titleLarge: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700, color: Tokens.ink),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: Tokens.ink),
      bodyMedium: TextStyle(fontSize: 14, color: Tokens.body, height: 1.45),
      bodySmall: TextStyle(fontSize: 13, color: Tokens.muted, height: 1.4),
      labelLarge: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Tokens.muted),
    ),
  );
}
