import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode { system, light, dark, sunset }

class AppColors {
  // Current active theme mode
  static AppThemeMode themeMode = AppThemeMode.light;

  // Determine if the active theme requires dark style rules
  static bool get _isDarkTheme {
    if (themeMode == AppThemeMode.dark) return true;
    if (themeMode == AppThemeMode.sunset) return true;
    if (themeMode == AppThemeMode.light) return false;
    // If set to system, check OS brightness setting
    return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
  }

  // fameo - X colors
  static Color get fameoPurple => const Color(0xFF6C63FF);
  static Color get fameoPurpleGradientStart => const Color(0xFF8E2DE2);
  static Color get fameoPurpleGradientEnd => const Color(0xFF4A00E0);

  // eMAGZ colors
  static Color get emagzBlue => const Color(0xFF0082FF);
  static Color get emagzBlueDark => const Color(0xFF005BC5);
  static Color get emagzBlueLight => themeMode == AppThemeMode.light
      ? const Color(0xE3E4F4FF)
      : const Color(0xFF1E2D4A);

  // Neutral Colors
  static Color get background {
    if (themeMode == AppThemeMode.sunset) {
      return const Color(0xFF160E2A); // Sunset theme dark violet
    }
    return _isDarkTheme ? const Color(0xFF171B26) : Colors.white;
  }

  static Color get cardBackground {
    if (themeMode == AppThemeMode.sunset) {
      return const Color(0xFF22173C); // Sunset theme card background
    }
    return _isDarkTheme ? const Color(0xFF212738) : Colors.white;
  }

  static Color get textDark {
    if (themeMode == AppThemeMode.sunset) {
      return const Color(0xFFECEFF4);
    }
    return _isDarkTheme ? const Color(0xFFECEFF4) : const Color(0xFF191D21);
  }

  static Color get textMuted {
    if (themeMode == AppThemeMode.sunset) {
      return const Color(0xFF8A94A6);
    }
    return _isDarkTheme ? const Color(0xFF8A94A6) : const Color(0xFF656E77);
  }

  static Color get borderLight {
    if (themeMode == AppThemeMode.sunset) {
      return const Color(0xFF332554);
    }
    return _isDarkTheme ? const Color(0xFF2D354A) : const Color(0xFFE8ECEF);
  }

  static Color get borderDark {
    if (themeMode == AppThemeMode.sunset) {
      return const Color(0xFF483572);
    }
    return _isDarkTheme ? const Color(0xFF3C4763) : const Color(0xFFD0D7DE);
  }

  static Color get error => const Color(0xFFFF4D4D);
  static Color get success => const Color(0xFF2ED573);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.fameoPurple,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.fameoPurple,
        secondary: AppColors.emagzBlue,
        error: AppColors.error,
        surface: AppColors.cardBackground,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: AppColors.textMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
