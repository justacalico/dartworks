import 'package:flutter/material.dart';

/// Palette pulled from the MythOS / Monogon visual language: void purples,
/// hazmat yellow and terminal cyan on near-black.
abstract final class DwColors {
  static const Color voidBlack = Color(0xFF07060B);
  static const Color surface = Color(0xFF12101A);
  static const Color surfaceHigh = Color(0xFF1C1828);
  static const Color edge = Color(0xFF2E2840);

  static const Color voidPurple = Color(0xFFB44DFF);
  static const Color voidDeep = Color(0xFF5B2BBF);
  static const Color monogonYellow = Color(0xFFF2C230);
  static const Color neonCyan = Color(0xFF4DE8FF);
  static const Color warnRed = Color(0xFFFF4D5E);
  static const Color toxicGreen = Color(0xFF7CFF6B);

  static const Color textPrimary = Color(0xFFEDEBF5);
  static const Color textDim = Color(0xFF9B94B8);
  static const Color textFaint = Color(0xFF5E5878);
}

/// Text styles. Oxanium carries headers, ShareTechMono carries body/terminal.
abstract final class DwText {
  static const String headingFamily = 'Oxanium';
  static const String monoFamily = 'ShareTechMono';

  static const TextStyle logo = TextStyle(
    fontFamily: headingFamily,
    fontWeight: FontWeight.w800,
    fontSize: 64,
    letterSpacing: 12,
    color: DwColors.textPrimary,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: headingFamily,
    fontWeight: FontWeight.w800,
    fontSize: 32,
    letterSpacing: 6,
    color: DwColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: headingFamily,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    letterSpacing: 4,
    color: DwColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: headingFamily,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    letterSpacing: 3,
    color: DwColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: monoFamily,
    fontSize: 14,
    height: 1.45,
    color: DwColors.textPrimary,
  );

  static const TextStyle bodyDim = TextStyle(
    fontFamily: monoFamily,
    fontSize: 13,
    height: 1.45,
    color: DwColors.textDim,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: monoFamily,
    fontSize: 11,
    letterSpacing: 1.5,
    color: DwColors.textFaint,
  );

  static const TextStyle button = TextStyle(
    fontFamily: headingFamily,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    letterSpacing: 5,
    color: DwColors.textPrimary,
  );
}

abstract final class DwTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: DwColors.voidBlack,
      colorScheme: const ColorScheme.dark(
        primary: DwColors.voidPurple,
        secondary: DwColors.neonCyan,
        surface: DwColors.surface,
        error: DwColors.warnRed,
        onPrimary: DwColors.voidBlack,
        onSecondary: DwColors.voidBlack,
        onSurface: DwColors.textPrimary,
        onError: DwColors.textPrimary,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: DwText.monoFamily,
        bodyColor: DwColors.textPrimary,
        displayColor: DwColors.textPrimary,
      ),
      dividerColor: DwColors.edge,
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: DwColors.surfaceHigh,
        contentTextStyle: DwText.body,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: DwColors.voidPurple.withValues(alpha: 0.08),
      focusColor: DwColors.voidPurple.withValues(alpha: 0.12),
    );
  }
}
