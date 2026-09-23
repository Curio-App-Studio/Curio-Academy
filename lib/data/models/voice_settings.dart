/// Voice persona options for speech narration and mascot reading
enum VoicePersona {
  buddy('buddy', 'Curio Buddy', '🦊', 'Playful & enthusiastic companion', 1.25, 0.48),
  teacher('teacher', 'Friendly Teacher', '👩‍🏫', 'Clear, patient & articulate', 1.0, 0.45),
  mentor('mentor', 'Wise Mentor', '🦉', 'Calm, thoughtful & encouraging', 0.85, 0.42),
  robot('robot', 'Curio Spark', '🤖', 'Fun, futuristic & upbeat', 0.72, 0.52);

  final String id;
  final String label;
  final String emoji;
  final String description;
  final double defaultPitch;
  final double defaultRate;

  const VoicePersona(
    this.id,
    this.label,
    this.emoji,
    this.description,
    this.defaultPitch,
    this.defaultRate,
  );

  static VoicePersona fromId(String? id) {
    return VoicePersona.values.firstWhere(
      (p) => p.id == id,
      orElse: () => VoicePersona.buddy,
    );
  }
}

/// Speed paces for speech synthesis
enum VoiceSpeed {
  slow('slow', 'Slow 🐢', 0.38),
  normal('normal', 'Normal 🚶', 0.48),
  fast('fast', 'Fast ⚡', 0.58);

  final String id;
  final String label;
  final double rate;

  const VoiceSpeed(this.id, this.label, this.rate);

  static VoiceSpeed fromRate(double rate) {
    if (rate <= 0.40) return VoiceSpeed.slow;
    if (rate >= 0.54) return VoiceSpeed.fast;
    return VoiceSpeed.normal;
  }
}

/// Complete voice configuration
class VoiceSettings {
  final VoicePersona persona;
  final String locale; // e.g. 'en-IN', 'en-US', 'en-GB'
  final double pitch;
  final double speechRate;
  final String? systemVoiceName;

  const VoiceSettings({
    this.persona = VoicePersona.buddy,
    this.locale = 'en-IN',
    this.pitch = 1.25,
    this.speechRate = 0.48,
    this.systemVoiceName,
  });

  VoiceSettings copyWith({
    VoicePersona? persona,
    String? locale,
    double? pitch,
    double? speechRate,
    String? systemVoiceName,
  }) {
    return VoiceSettings(
      persona: persona ?? this.persona,
      locale: locale ?? this.locale,
      pitch: pitch ?? this.pitch,
      speechRate: speechRate ?? this.speechRate,
      systemVoiceName: systemVoiceName ?? this.systemVoiceName,
    );
  }

  Map<String, dynamic> toJson() => {
    'persona': persona.id,
    'locale': locale,
    'pitch': pitch,
    'speechRate': speechRate,
    'systemVoiceName': systemVoiceName,
  };

  factory VoiceSettings.fromJson(Map<String, dynamic> json) {
    final persona = VoicePersona.fromId(json['persona'] as String?);
    return VoiceSettings(
      persona: persona,
      locale: json['locale'] as String? ?? 'en-IN',
      pitch: (json['pitch'] as num?)?.toDouble() ?? persona.defaultPitch,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? persona.defaultRate,
      systemVoiceName: json['systemVoiceName'] as String?,
    );
  }
}
