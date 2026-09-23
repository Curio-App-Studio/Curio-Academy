import 'package:flutter/material.dart';
import '../../data/models/grade_tier.dart';
import 'grade_tier_extension.dart';

class AppTheme {
  AppTheme._();

  static ThemeData buildTheme(GradeTier tier) {
    final tierExt = CurioTierTheme.forTier(tier);

    final ColorScheme colorScheme;
    switch (tier) {
      case GradeTier.earlyExplorer:
        colorScheme = const ColorScheme.light(
          primary: Color(0xFFFF6F00), // Rich playful orange
          onPrimary: Colors.white,
          secondary: Color(0xFF00B0FF), // Bright sky blue
          onSecondary: Colors.white,
          tertiary: Color(0xFF00E676), // Bright mint green
          surface: Color(0xFFFFFDE7), // Soft sunny buttercup
          onSurface: Color(0xFF1E293B),
          error: Color(0xFFFF5252),
        );
        break;
      case GradeTier.primaryBuilder:
        colorScheme = const ColorScheme.light(
          primary: Color(0xFF2563EB), // Vibrant royal blue
          onPrimary: Colors.white,
          secondary: Color(0xFF10B981), // Emerald green
          onSecondary: Colors.white,
          tertiary: Color(0xFFF59E0B), // Amber star
          surface: Color(0xFFF8FAFC),
          onSurface: Color(0xFF0F172A),
          error: Color(0xFFEF4444),
        );
        break;
      case GradeTier.middleAchiever:
        colorScheme = const ColorScheme.light(
          primary: Color(0xFF4F46E5), // Indigo
          onPrimary: Colors.white,
          secondary: Color(0xFF0EA5E9), // Cyan
          onSecondary: Colors.white,
          tertiary: Color(0xFF8B5CF6), // Violet
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF020617),
          error: Color(0xFFDC2626),
        );
        break;
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: tierExt.headerFontSize,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: tierExt.minTouchTarget,
          padding: tierExt.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: tierExt.borderRadius,
          ),
          elevation: tierExt.cardElevation,
          textStyle: TextStyle(
            fontSize: tierExt.promptFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: tierExt.cardBackground,
        elevation: tierExt.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: tierExt.borderRadius,
        ),
      ),
      extensions: [tierExt],
    );
  }
}
