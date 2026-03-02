import 'package:flutter/material.dart';

class AppTypography {
  // Font family
  static const String fontFamily = 'Inter';

  // Display - 28px Bold (Screen titles)
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -0.5,
  );

  // Heading - 22px SemiBold (Section headers)
  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: -0.3,
  );

  // Subheading - 18px SemiBold (Card titles)
  static const TextStyle subheading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Body - 14px Regular (Descriptions)
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.5,
  );

  // Body Medium - 14px Medium
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    height: 1.5,
  );

  // Caption - 12px Regular (Tags, metadata)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  // Caption Medium - 12px Medium
  static const TextStyle captionMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );

  // Button - 14px SemiBold
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
