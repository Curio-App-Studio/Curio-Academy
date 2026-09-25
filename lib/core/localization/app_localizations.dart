import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_service.dart';
import '../../data/local/local_storage_service.dart';

/// Supported application languages
enum AppLanguage {
  english('en', 'English', '🇬🇧', 'en-IN'),
  hindi('hi', 'हिन्दी', '🇮🇳', 'hi-IN');

  final String code;
  final String label;
  final String flag;
  final String ttsLocale;

  const AppLanguage(this.code, this.label, this.flag, this.ttsLocale);

  static AppLanguage fromCode(String? code) {
    if (code == 'hi') return AppLanguage.hindi;
    return AppLanguage.english;
  }
}

/// Riverpod 3.x Notifier for global language state
class AppLanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    return AppLanguage.fromCode(LocalStorageService.instance.getAppLanguage());
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (state == language) return;
    state = language;
    await LocalStorageService.instance.saveAppLanguage(language.code);
    // Update TTS speech settings
    final curSettings = AudioService.instance.currentVoiceSettings;
    await AudioService.instance.setVoiceSettings(
      curSettings.copyWith(locale: language.ttsLocale),
    );
  }

  Future<void> toggleLanguage() async {
    final next = state == AppLanguage.english ? AppLanguage.hindi : AppLanguage.english;
    await setLanguage(next);
  }
}

final appLanguageProvider = NotifierProvider<AppLanguageNotifier, AppLanguage>(() {
  return AppLanguageNotifier();
});

/// Comprehensive translation strings for Curio Academy
class AppLocalizations {
  final AppLanguage language;
  const AppLocalizations(this.language);

  bool get isHindi => language == AppLanguage.hindi;

  // General App & Brand
  String get appTitle => isHindi ? 'क्यूरियो एकेडमी' : 'Curio Academy';
  String get brandSubtitle => isHindi ? 'इंटरएक्टिव लर्निंग साथी' : 'Interactive Learning Companion';

  // Navigation & Subjects
  String get math => isHindi ? 'गणित' : 'Math';
  String get english => isHindi ? 'अंग्रेज़ी' : 'English';
  String get science => isHindi ? 'विज्ञान' : 'Science';
  String get mathChapters => isHindi ? '📐 गणित अध्याय' : '📐 Math Chapters';
  String get englishChapters => isHindi ? '📚 अंग्रेज़ी अध्याय' : '📚 English Chapters';
  String get comingSoon => isHindi ? 'शीघ्र' : 'Soon';

  // Total Stars & Motivation
  String get totalStars => isHindi ? 'कुल सितारे' : 'Total Stars';
  String get starsEarned => isHindi ? 'कुल सितारे मिले' : 'Total Stars Earned';
  String get superExplorer => isHindi ? 'सुपर लर्नर 🏆' : 'Super Explorer 🏆';
  String get keepPracticingMotivation => isHindi
      ? 'शानदार प्रगति! नए सितारे कमाने के लिए अभ्यास जारी रखें! 🌟'
      : 'Keep practicing to earn more shining stars! 🌟';

  // Challenge Navigation & Action Bar
  String get nextQuestion => isHindi ? 'अगला प्रश्न ➡️' : 'Next Question ➡️';
  String get nextQuestionNew => isHindi ? 'नया प्रश्न ✨' : 'Next Question (New ✨)';
  String get prevQuestion => isHindi ? 'पिछला' : 'Prev';
  String get skipQuestion => isHindi ? 'छोड़ें' : 'Skip';
  String get checkAnswer => isHindi ? 'उत्तर जांचें' : 'Check Answer';
  String get tryAgain => isHindi ? 'पुनः प्रयास करें' : 'Try Again';
  String get selectAnswerPrompt => isHindi ? 'अपना उत्तर चुनें:' : 'Select your answer:';

  // Hints & Scaffolding
  String get needAHint => isHindi ? 'मदद चाहिए?' : 'Need a hint?';
  String get hint => isHindi ? 'संकेत 💡' : 'Hint 💡';
  String get fullExplanation => isHindi ? 'चरणबद्ध समाधान देखें 💡' : 'Step-by-Step Solution 💡';
  String get explanationTitle => isHindi ? 'अवधारणा समाधान' : 'Concept Explanation';
  String get understoodClose => isHindi ? 'समझ गया! 👍' : 'Got it! 👍';

  // Feedback & Cheers
  String get awesome => isHindi ? 'शाबाश!' : 'Awesome!';
  String get correctCheer => isHindi ? 'बिल्कुल सही! 🌟' : 'That is correct! 🌟';
  String get incorrectGentle => isHindi ? 'कोई बात नहीं! फिर से कोशिश करें!' : 'Not quite! Give it another try!';
  String get wellDone => isHindi ? 'बहुत बढ़िया!' : 'Well Done!';

  // Activities & Games
  String get practice => isHindi ? 'अभ्यास' : 'Practice';
  String get conceptLesson => isHindi ? 'अवधारणा पाठ' : 'Concept Lesson';
  String get level => isHindi ? 'स्तर' : 'Level';
  String get question => isHindi ? 'प्रश्न' : 'Question';
  String get ofWord => isHindi ? 'का' : 'of';
  String get popBubblesTitle => isHindi ? 'बबल पॉप 🫧' : 'Bubble Pop 🫧';
  String get cardMatchTitle => isHindi ? 'जोड़ी मिलाओ 🃏' : 'Match the Pairs 🃏';
  String get tapMatchingPairs => isHindi ? 'समान कार्ड्स की जोड़ी मिलाएं!' : 'Tap matching pairs!';
  String get pairsRemaining => isHindi ? 'शेष जोड़ियां' : 'Pairs left';
  String get matchedCheer => isHindi ? 'सही जोड़ी! 🎉' : 'Perfect Match! 🎉';
  String get nextLevel => isHindi ? 'अगला स्तर ➡️' : 'Next Level ➡️';
  String get nextChallenge => isHindi ? 'अगली चुनौती ➡️' : 'Next Challenge ➡️';

  // Settings & Controls
  String get languageTitle => isHindi ? 'भाषा चुनें' : 'Select Language';
  String get voiceCompanion => isHindi ? 'आवाज़ साथी' : 'Voice Companion';
  String get scratchpad => isHindi ? 'रफ पैड' : 'Scratchpad';
  String get muteSpeaker => isHindi ? 'आवाज़ बंद करें' : 'Mute Speaker';
  String get unmuteSpeaker => isHindi ? 'आवाज़ चालू करें' : 'Unmute Speaker';
  String get tapToChangeBoardClass => isHindi ? 'बोर्ड और कक्षा बदलने के लिए टैप करें' : 'Tap to change board & class';

  // Helper factory
  static AppLocalizations of(BuildContext context) {
    return const AppLocalizations(AppLanguage.english);
  }
}

/// Extension for convenient access on WidgetRef
extension WidgetRefLocalizations on WidgetRef {
  AppLocalizations get strings {
    final lang = watch(appLanguageProvider);
    return AppLocalizations(lang);
  }
}
