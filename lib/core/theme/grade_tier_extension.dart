import 'package:flutter/material.dart';
import '../../data/models/grade_tier.dart';

/// Custom ThemeExtension providing tier-adaptive styling tokens
class CurioTierTheme extends ThemeExtension<CurioTierTheme> {
  final GradeTier tier;
  final Size minTouchTarget;
  final EdgeInsets buttonPadding;
  final BorderRadius borderRadius;
  final double cardElevation;
  final Color cardBackground;
  final Color promptCardColor;
  final Color badgeBackgroundColor;
  final double headerFontSize;
  final double promptFontSize;
  final double bubbleSize;
  final bool autoPlayVoicePrompts;
  final bool enableScratchpad;
  final bool showStreakTimer;
  final String typographyMood; // 'friendly_rounded', 'casual_bold', 'clean_modern'

  const CurioTierTheme({
    required this.tier,
    required this.minTouchTarget,
    required this.buttonPadding,
    required this.borderRadius,
    required this.cardElevation,
    required this.cardBackground,
    required this.promptCardColor,
    required this.badgeBackgroundColor,
    required this.headerFontSize,
    required this.promptFontSize,
    required this.bubbleSize,
    required this.autoPlayVoicePrompts,
    required this.enableScratchpad,
    required this.showStreakTimer,
    required this.typographyMood,
  });

  /// Factory for Tier 1: Early Explorer (LKG - Class 1)
  /// Oversized touch targets (64x64+), vibrant primary contrast, auto audio prompts
  factory CurioTierTheme.earlyExplorer() {
    return const CurioTierTheme(
      tier: GradeTier.earlyExplorer,
      minTouchTarget: Size(68.0, 68.0),
      buttonPadding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      borderRadius: BorderRadius.all(Radius.circular(32.0)),
      cardElevation: 8.0,
      cardBackground: Color(0xFFFFF9E6), // Soft warm sunshine
      promptCardColor: Color(0xFFFFECC8),
      badgeBackgroundColor: Color(0xFFFF6B6B),
      headerFontSize: 28.0,
      promptFontSize: 22.0,
      bubbleSize: 100.0,
      autoPlayVoicePrompts: true,
      enableScratchpad: false,
      showStreakTimer: false,
      typographyMood: 'friendly_rounded',
    );
  }

  /// Factory for Tier 2: Primary Builder (Class 2 - Class 5)
  /// Gamified badges, star multipliers, bright card grids, interactive scratchpad
  factory CurioTierTheme.primaryBuilder() {
    return const CurioTierTheme(
      tier: GradeTier.primaryBuilder,
      minTouchTarget: Size(52.0, 52.0),
      buttonPadding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
      cardElevation: 4.0,
      cardBackground: Color(0xFFF0FDF4), // Mint/Gamified green tint
      promptCardColor: Color(0xFFDCFCE7),
      badgeBackgroundColor: Color(0xFF3B82F6),
      headerFontSize: 24.0,
      promptFontSize: 19.0,
      bubbleSize: 84.0,
      autoPlayVoicePrompts: false,
      enableScratchpad: true,
      showStreakTimer: false,
      typographyMood: 'casual_bold',
    );
  }

  /// Factory for Tier 3: Middle Achiever (Class 6 - Class 8)
  /// Clean modern dashboard, coordinate grids, formula quick-sheets, timed streaks
  factory CurioTierTheme.middleAchiever() {
    return const CurioTierTheme(
      tier: GradeTier.middleAchiever,
      minTouchTarget: Size(44.0, 44.0),
      buttonPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
      cardElevation: 2.0,
      cardBackground: Color(0xFFF8FAFC), // Modern slate white
      promptCardColor: Color(0xFFEDE9FE),
      badgeBackgroundColor: Color(0xFF6366F1),
      headerFontSize: 22.0,
      promptFontSize: 17.0,
      bubbleSize: 72.0,
      autoPlayVoicePrompts: false,
      enableScratchpad: true,
      showStreakTimer: true,
      typographyMood: 'clean_modern',
    );
  }

  factory CurioTierTheme.forTier(GradeTier tier) {
    switch (tier) {
      case GradeTier.earlyExplorer:
        return CurioTierTheme.earlyExplorer();
      case GradeTier.primaryBuilder:
        return CurioTierTheme.primaryBuilder();
      case GradeTier.middleAchiever:
        return CurioTierTheme.middleAchiever();
    }
  }

  @override
  CurioTierTheme copyWith({
    GradeTier? tier,
    Size? minTouchTarget,
    EdgeInsets? buttonPadding,
    BorderRadius? borderRadius,
    double? cardElevation,
    Color? cardBackground,
    Color? promptCardColor,
    Color? badgeBackgroundColor,
    double? headerFontSize,
    double? promptFontSize,
    double? bubbleSize,
    bool? autoPlayVoicePrompts,
    bool? enableScratchpad,
    bool? showStreakTimer,
    String? typographyMood,
  }) {
    return CurioTierTheme(
      tier: tier ?? this.tier,
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
      buttonPadding: buttonPadding ?? this.buttonPadding,
      borderRadius: borderRadius ?? this.borderRadius,
      cardElevation: cardElevation ?? this.cardElevation,
      cardBackground: cardBackground ?? this.cardBackground,
      promptCardColor: promptCardColor ?? this.promptCardColor,
      badgeBackgroundColor: badgeBackgroundColor ?? this.badgeBackgroundColor,
      headerFontSize: headerFontSize ?? this.headerFontSize,
      promptFontSize: promptFontSize ?? this.promptFontSize,
      bubbleSize: bubbleSize ?? this.bubbleSize,
      autoPlayVoicePrompts: autoPlayVoicePrompts ?? this.autoPlayVoicePrompts,
      enableScratchpad: enableScratchpad ?? this.enableScratchpad,
      showStreakTimer: showStreakTimer ?? this.showStreakTimer,
      typographyMood: typographyMood ?? this.typographyMood,
    );
  }

  @override
  CurioTierTheme lerp(ThemeExtension<CurioTierTheme>? other, double t) {
    if (other is! CurioTierTheme) return this;
    return CurioTierTheme(
      tier: t < 0.5 ? tier : other.tier,
      minTouchTarget: Size.lerp(minTouchTarget, other.minTouchTarget, t)!,
      buttonPadding: EdgeInsets.lerp(buttonPadding, other.buttonPadding, t)!,
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t)!,
      cardElevation: cardElevation + (other.cardElevation - cardElevation) * t,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      promptCardColor: Color.lerp(promptCardColor, other.promptCardColor, t)!,
      badgeBackgroundColor:
          Color.lerp(badgeBackgroundColor, other.badgeBackgroundColor, t)!,
      headerFontSize:
          headerFontSize + (other.headerFontSize - headerFontSize) * t,
      promptFontSize:
          promptFontSize + (other.promptFontSize - promptFontSize) * t,
      bubbleSize: bubbleSize + (other.bubbleSize - bubbleSize) * t,
      autoPlayVoicePrompts:
          t < 0.5 ? autoPlayVoicePrompts : other.autoPlayVoicePrompts,
      enableScratchpad: t < 0.5 ? enableScratchpad : other.enableScratchpad,
      showStreakTimer: t < 0.5 ? showStreakTimer : other.showStreakTimer,
      typographyMood: t < 0.5 ? typographyMood : other.typographyMood,
    );
  }
}

/// Syntactic sugar extension on BuildContext
extension CurioTierContext on BuildContext {
  CurioTierTheme get tierTheme =>
      Theme.of(this).extension<CurioTierTheme>() ?? CurioTierTheme.earlyExplorer();
}
