/// Grade tiers representing distinct developmental and pedagogical stages.
enum GradeTier {
  /// Class LKG to Class 1: Pre-literacy, visual/audio heavy, oversized touch targets.
  earlyExplorer('earlyExplorer', 'Early Explorers (LKG - Class 1)', 1),

  /// Class 2 to Class 5: Gamified mastery, star multipliers, scratchpad canvas.
  primaryBuilder('primaryBuilder', 'Primary Builders (Class 2 - 5)', 2),

  /// Class 6 to Class 8: Cognitive dashboard, coordinate grids, timed streaks.
  middleAchiever('middleAchiever', 'Middle Achievers (Class 6 - 8)', 3);

  final String id;
  final String label;
  final int tierLevel;

  const GradeTier(this.id, this.label, this.tierLevel);

  static GradeTier fromJson(dynamic json) {
    if (json is String) {
      return GradeTier.values.firstWhere(
        (e) => e.name.toLowerCase() == json.toLowerCase() || e.id.toLowerCase() == json.toLowerCase(),
        orElse: () => GradeTier.earlyExplorer,
      );
    }
    return GradeTier.earlyExplorer;
  }

  String toJson() => id;

  /// Helper to determine if voice prompts are auto-triggered
  bool get autoPlayAudioPrompt => this == GradeTier.earlyExplorer;

  /// Minimum recommended touch target size (width/height)
  double get minTouchTargetSize {
    switch (this) {
      case GradeTier.earlyExplorer:
        return 64.0;
      case GradeTier.primaryBuilder:
        return 48.0;
      case GradeTier.middleAchiever:
        return 44.0;
    }
  }

  /// Flag indicating if an interactive scratchpad canvas is recommended
  bool get hasScratchpadAvailable => this != GradeTier.earlyExplorer;

  /// Mascot emoji for the grade tier
  String get mascotEmoji {
    switch (this) {
      case GradeTier.earlyExplorer:
        return '🦊';
      case GradeTier.primaryBuilder:
        return '🚀';
      case GradeTier.middleAchiever:
        return '🦉';
    }
  }
}
