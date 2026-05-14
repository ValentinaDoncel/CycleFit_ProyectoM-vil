import 'package:cycle_fit/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const textTheme = TextTheme(
      headlineLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: AppColors.text,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: AppColors.text,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.35,
        color: AppColors.muted,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      textTheme: textTheme,
      fontFamily: 'sans-serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
      ),
    );
  }

  static ThemeData get darkTheme {
    const textTheme = TextTheme(
      headlineLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.primarySoft,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.primarySoft,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primarySoft,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primarySoft,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: AppColors.surface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: AppColors.surface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.35,
        color: AppColors.muted,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Color(0xFF16213E),
      ),
      textTheme: textTheme,
      fontFamily: 'sans-serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A2E),
        elevation: 0,
        foregroundColor: AppColors.primarySoft,
      ),
    );
  }
}
