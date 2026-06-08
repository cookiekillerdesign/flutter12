import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Palette from documentation
class AppColors {
  static const bg = Color(0xFFEDEAE3);
  static const surface = Color(0xFFF6F4EF);
  static const ink = Color(0xFF1C1C1E);
  static const muted = Color(0xFF8E8E93);
  static const border = Color(0xFFDAD7CF);
  static const gold = Color(0xFFE9B84A);

  static const family = Color(0xFFC3B8D6);
  static const friends = Color(0xFFD4A9AC);
  static const work = Color(0xFF93C2BB);
  static const other = Color(0xFFB3C29C);
  static const deceased = Color(0xFFC2BFB9);

  static const danger = Color(0xFFFF453A);
  static const success = Color(0xFF30D158);

  static Color group(String g) {
    switch (g) {
      case 'family':
        return family;
      case 'friends':
        return friends;
      case 'work':
        return work;
      default:
        return other;
    }
  }

  static String groupLabel(String g) {
    switch (g) {
      case 'family':
        return 'Семья';
      case 'friends':
        return 'Друзья';
      case 'work':
        return 'Работа';
      default:
        return 'Другие';
    }
  }
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.ink,
        secondary: AppColors.gold,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.onestTextTheme(base.textTheme).apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
        centerTitle: false,
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  // Nunito for large numbers / dates
  static TextStyle numbers(double size,
          {FontWeight weight = FontWeight.w800, Color? color}) =>
      GoogleFonts.nunito(
          fontSize: size, fontWeight: weight, color: color ?? AppColors.ink);
}
