import 'package:flutter/material.dart';

class AppColors {
  static bool isDark = false;

  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFF9B97FF);
  static const success = Color(0xFF2EB67D);

  static Color get surface => isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF5F3FF);
  static Color get decorativeCircle => isDark ? const Color(0xFF2D2C3D) : const Color(0xFFEDE9FF);
  static Color get textDark => isDark ? const Color(0xFFF5F5F7) : const Color(0xFF1A1A2E);
  static Color get textMedium => isDark ? const Color(0xFFA0A5B5) : const Color(0xFF6B7280);

  // Aliases
  static Color get surfaceSoft => decorativeCircle;
  static Color get bgLight => isDark ? const Color(0xFF12121A) : const Color(0xFFF8F6FF);
  static Color get textLight => textMedium;

  AppColors._();
}

class AppTextStyles {
  static TextStyle get heading1 => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    height: 1.2,
  );
  static TextStyle get heading2 => TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );
  static TextStyle get body => TextStyle(
    fontSize: 13,
    color: AppColors.textMedium,
    height: 1.5,
  );
  static TextStyle get bodyBold => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  static TextStyle get caption => TextStyle(
    fontSize: 11,
    color: AppColors.textMedium,
  );

  AppTextStyles._();
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      cardColor: const Color(0xFFF5F3FF),
      fontFamily: 'sans-serif',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: const Color(0xFF1E1E2E),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF12121A),
      cardColor: const Color(0xFF1C1C27),
      fontFamily: 'sans-serif',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF12121A),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF5F5F7),
        ),
      ),
    );
  }

  AppTheme._();
}
