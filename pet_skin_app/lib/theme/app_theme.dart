import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFF9B97FF);
  static const surface = Color(0xFFF5F3FF);
  static const decorativeCircle = Color(0xFFEDE9FF);
  static const textDark = Color(0xFF1A1A2E);
  static const textMedium = Color(0xFF6B7280);
  // Aliases used in vet_location_screen
  static const surfaceSoft = decorativeCircle;
  static const bgLight = Color(0xFFF8F6FF);
  static const textLight = textMedium;
  static const success = Color(0xFF2EB67D);

  AppColors._();
}

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    height: 1.2,
  );
  static const heading2 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );
  static const body = TextStyle(
    fontSize: 13,
    color: AppColors.textMedium,
    height: 1.5,
  );
  static const bodyBold = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  static const caption = TextStyle(
    fontSize: 11,
    color: AppColors.textMedium,
  );

  AppTextStyles._();
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
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
          color: AppColors.textDark,
        ),
      ),
    );
  }

  AppTheme._();
}
