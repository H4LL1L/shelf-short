import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData build() {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgTop,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.panel,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.lexendTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.lexend(
          fontWeight: FontWeight.w800,
          color: AppColors.textMain,
        ),
        headlineSmall: GoogleFonts.lexend(
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
        ),
        bodyLarge: GoogleFonts.lexend(
          fontWeight: FontWeight.w500,
          color: AppColors.textMain,
        ),
        bodyMedium: GoogleFonts.lexend(
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.lexend(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.panel,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
