import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppSpacing {
  // 4px grid
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets listPadding = EdgeInsets.symmetric(vertical: sm);

  // Section spacing
  static const SizedBox sectionGap = SizedBox(height: lg);
  static const SizedBox itemGap = SizedBox(height: md);
  static const SizedBox smallGap = SizedBox(height: sm);
  static const SizedBox tinyGap = SizedBox(height: xs);

  // Horizontal gaps
  static const SizedBox hSectionGap = SizedBox(width: lg);
  static const SizedBox hItemGap = SizedBox(width: md);
  static const SizedBox hSmallGap = SizedBox(width: sm);
  static const SizedBox hTinyGap = SizedBox(width: xs);
}
