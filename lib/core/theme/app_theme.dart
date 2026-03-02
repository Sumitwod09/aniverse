import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundPrimary,
      primaryColor: AppColors.primaryAccent,
      fontFamily: AppTypography.fontFamily,
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryAccent,
        secondary: AppColors.ctaSuccess,
        surface: AppColors.backgroundSurface,
        background: AppColors.backgroundPrimary,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.heading,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated button (Primary - Green)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ctaSuccess,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // Outlined button (Secondary - Purple)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryAccent,
          side: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryAccent,
          textStyle: AppTypography.button,
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
      ),

      // Bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundSurface,
        selectedItemColor: AppColors.primaryAccent,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDivider,
        thickness: 1,
        space: 1,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedColor: AppColors.primaryAccent,
        labelStyle: AppTypography.captionMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDivider),
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: AppTypography.display,
        headlineLarge: AppTypography.heading,
        titleLarge: AppTypography.subheading,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.bodyMedium,
        labelLarge: AppTypography.button,
        labelSmall: AppTypography.caption,
      ),
    );
  }
}
