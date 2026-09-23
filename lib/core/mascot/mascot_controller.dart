import 'package:flutter_riverpod/legacy.dart';

enum MascotMood {
  idle,
  guiding,
  cheering,
  thinking,
  celebrating,
}

class MascotState {
  final MascotMood mood;
  final String speechBubble;
  final bool isVisible;

  const MascotState({
    this.mood = MascotMood.idle,
    this.speechBubble = '',
    this.isVisible = true,
  });

  MascotState copyWith({
    MascotMood? mood,
    String? speechBubble,
    bool? isVisible,
  }) {
    return MascotState(
      mood: mood ?? this.mood,
      speechBubble: speechBubble ?? this.speechBubble,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class MascotNotifier extends StateNotifier<MascotState> {
  MascotNotifier() : super(const MascotState());

  void setMood(MascotMood mood, {String message = ''}) {
    state = state.copyWith(mood: mood, speechBubble: message);
  }

  void cheer() {
    state = state.copyWith(mood: MascotMood.cheering, speechBubble: 'Super job! 🌟');
  }

  void guide(String hint) {
    state = state.copyWith(mood: MascotMood.guiding, speechBubble: hint);
  }

  void reset() {
    state = const MascotState();
  }
}

final mascotProvider = StateNotifierProvider<MascotNotifier, MascotState>((ref) {
  return MascotNotifier();
});
