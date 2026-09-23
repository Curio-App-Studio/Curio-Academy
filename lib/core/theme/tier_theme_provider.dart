import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/grade_tier.dart';

/// StateNotifier managing current learner's active grade tier
class GradeTierNotifier extends StateNotifier<GradeTier> {
  GradeTierNotifier() : super(GradeTier.earlyExplorer);

  void setTier(GradeTier tier) {
    state = tier;
  }
}

/// Global provider for the active GradeTier
final gradeTierProvider = StateNotifierProvider<GradeTierNotifier, GradeTier>((ref) {
  return GradeTierNotifier();
});
