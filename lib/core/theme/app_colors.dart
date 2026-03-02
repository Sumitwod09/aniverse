import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color backgroundPrimary = Color(0xFF0A0A0F);
  static const Color backgroundSurface = Color(0xFF12121A);
  static const Color cardBackground = Color(0xFF1A1A2E);

  // Accents
  static const Color primaryAccent = Color(0xFF7C3AED); // Electric Purple
  static const Color ctaSuccess = Color(0xFF22C55E); // Green
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF4B5563);

  // Borders
  static const Color borderDivider = Color(0xFF1F2937);
  static const Color borderLight = Color(0xFF2D2D3A);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      backgroundPrimary,
    ],
    stops: [0.2, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF12121A),
    ],
  );
}
