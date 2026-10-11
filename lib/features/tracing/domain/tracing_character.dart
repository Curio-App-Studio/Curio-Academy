import 'package:flutter/material.dart';

enum TracingCategory {
  englishUpper,
  englishLower,
  numbers,
  hindiSwar,
  hindiVyanjan,
}

extension TracingCategoryExtension on TracingCategory {
  String get label {
    switch (this) {
      case TracingCategory.englishUpper:
        return 'ABC';
      case TracingCategory.englishLower:
        return 'abc';
      case TracingCategory.numbers:
        return '1 2 3';
      case TracingCategory.hindiSwar:
        return 'अ आ इ';
      case TracingCategory.hindiVyanjan:
        return 'क ख ग';
    }
  }

  String get labelHi {
    switch (this) {
      case TracingCategory.englishUpper:
        return 'बड़े अक्षर (A-Z)';
      case TracingCategory.englishLower:
        return 'छोटे अक्षर (a-z)';
      case TracingCategory.numbers:
        return 'गिनती (1-20)';
      case TracingCategory.hindiSwar:
        return 'हिंदी स्वर (अ-अः)';
      case TracingCategory.hindiVyanjan:
        return 'हिंदी व्यंजन (क-ह)';
    }
  }

  String get icon {
    switch (this) {
      case TracingCategory.englishUpper:
        return '🔤';
      case TracingCategory.englishLower:
        return '🔡';
      case TracingCategory.numbers:
        return '🔢';
      case TracingCategory.hindiSwar:
        return '🕉️';
      case TracingCategory.hindiVyanjan:
        return '🇮🇳';
    }
  }
}

class TracingCharacter {
  final String id;
  final String character;
  final String titleEn;
  final String titleHi;
  final String emoji;
  final String soundPromptEn;
  final String soundPromptHi;
  final TracingCategory category;
  final Offset startHint; // Normalized (0.0 to 1.0) guide start point

  const TracingCharacter({
    required this.id,
    required this.character,
    required this.titleEn,
    required this.titleHi,
    required this.emoji,
    required this.soundPromptEn,
    required this.soundPromptHi,
    required this.category,
    this.startHint = const Offset(0.5, 0.2),
  });
}
