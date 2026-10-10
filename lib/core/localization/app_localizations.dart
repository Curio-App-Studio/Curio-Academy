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
    void onLangChanged() {
      final code = LocalStorageService.instance.languageNotifier.value;
      final newLang = AppLanguage.fromCode(code);
      if (state != newLang) {
        state = newLang;
      }
    }

    LocalStorageService.instance.languageNotifier.addListener(onLangChanged);
    ref.onDispose(() {
      LocalStorageService.instance.languageNotifier.removeListener(onLangChanged);
    });

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
  String get evs => isHindi ? 'पर्यावरण अध्ययन (EVS)' : 'Curio EVS';
  String get evsShort => 'EVS';
  String get hindi => isHindi ? 'हिन्दी' : 'Curio Hindi';
  String get hindiShort => isHindi ? 'हिन्दी' : 'Hindi';
  String get mathChapters => isHindi ? '📐 गणित अध्याय' : '📐 Math Chapters';
  String get englishChapters => isHindi ? '📚 अंग्रेज़ी अध्याय' : '📚 English Chapters';
  String get scienceChapters => isHindi ? '🔬 विज्ञान अध्याय' : '🔬 Science Chapters';
  String get evsChapters => isHindi ? '🌿 पर्यावरण अध्ययन अध्याय' : '🌿 EVS Chapters';
  String get hindiChapters => isHindi ? '🔤 हिन्दी अध्याय' : '🔤 Hindi Chapters';
  String get comingSoon => isHindi ? 'शीघ्र' : 'Soon';

  // Total Stars & Motivation
  String get totalStars => isHindi ? 'कुल सितारे' : 'Total Stars';
  String get starsEarned => isHindi ? 'कुल सितारे मिले' : 'Total Stars Earned';
  String get discoveryPoints => isHindi ? 'डिस्कवरी पॉइंट्स' : 'Discovery Points';
  String get totalDiscoveryPoints => isHindi ? 'कुल डिस्कवरी पॉइंट्स' : 'Total Discovery Points';
  String get superExplorer => isHindi ? 'सुपर लर्नर 🏆' : 'Super Explorer 🏆';
  String get dailyStreak => isHindi ? 'दिन लगातार' : 'Day Streak';
  String get mistakeVault => isHindi ? '🎯 रिवीजन वॉल्ट' : '🎯 Mistake Vault';
  String get mistakeVaultSubtitle => isHindi ? 'गलतियाँ सुधारें और मजबूत बनें' : 'Review & master questions you missed';
  String get practiceMistakes => isHindi ? 'अभ्यास करें' : 'Practice Mistakes';
  String get noMistakes => isHindi ? 'शानदार! कोई गलत प्रश्न नहीं है 🎉' : 'Awesome! No pending mistakes 🎉';
  String get keepPracticingMotivation => isHindi
      ? 'शानदार प्रगति! नए सितारे कमाने के लिए अभ्यास जारी रखें! 🌟'
      : 'Keep practicing to earn more shining stars! 🌟';

  // Kids Friendly Home Dashboard
  String formatGreeting(String? name) {
    final effectiveName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : (isHindi ? 'नन्हे दोस्त' : 'Little Champ');
    return isHindi ? 'नमस्ते $effectiveName! 👋' : 'Hello $effectiveName! 👋';
  }

  String get studentGreeting => formatGreeting(null);
  String get studentGreetingSubtitle => isHindi
      ? 'आज कुछ नया सीखते और खेलते हैं! 🚀'
      : 'Ready to learn and play today? 🚀';
  String get changeAvatarTitle => isHindi ? 'अवतार और नाम चुनें 🎨' : 'Change Avatar & Name 🎨';
  String get changeAvatarSubtitle => isHindi ? 'अपना पसंदीदा अवतार और नाम चुनें!' : 'Pick your favorite avatar and name!';
  String get editProfile => isHindi ? 'प्रोफाइल बदलें' : 'Edit Profile';
  String get editProfileTitle => isHindi ? 'विद्यार्थी प्रोफाइल 🎒' : 'Edit Profile 🎒';
  String get manageProfileTitle => isHindi ? 'विद्यार्थी प्रोफाइल व कक्षा 🎒' : 'Edit Profile 🎒';
  String get manageProfileSubtitle => isHindi ? 'नाम, अवतार, कक्षा व बोर्ड बदलें' : 'Manage name, avatar, class & board';
  String get selectBoardTitle => isHindi ? '1. शिक्षा बोर्ड चुनें' : '1. Select Educational Board';
  String get selectClassGradeTitle => isHindi ? '2. कक्षा / स्तर चुनें' : '2. Select Class / Grade';
  String get chooseAvatarTitle => isHindi ? '3. पसंदीदा अवतार चुनें' : '3. Choose Favorite Avatar';
  String get studentNameLabel => isHindi ? 'विद्यार्थी का नाम' : 'Student Name';
  String get studentNameHint => isHindi ? 'बच्चे का नाम दर्ज करें' : 'Enter child\'s name';
  String get nameValidationError => isHindi ? 'कृपया नाम दर्ज करें' : 'Please enter child\'s name';
  String get saveProfile => isHindi ? 'सहेजें 👍' : 'Save & Continue 👍';
  String get tapToChangeAvatar => isHindi ? 'अवतार बदलने के लिए टैप करें' : 'Tap to change avatar';
  String get selectClassTitle => isHindi ? 'अपनी कक्षा चुनें 🎒' : 'Choose Your Class 🎒';
  String get selectSubjectTitle => isHindi ? 'विषय चुनें 🎨' : 'Pick a Subject 🎨';
  String get mathSubtitle => isHindi ? 'गिनती, आकृतियां और पहेलियां' : 'Numbers, Shapes & Logic';
  String get englishSubtitle => isHindi ? 'अक्षर, शब्द और ध्वनियां' : 'Letters, Words & Phonics';
  String get scienceSubtitle => isHindi ? 'प्रकृति, जीव और विज्ञान' : 'Nature, Animals & Space';
  String get evsSubtitle => isHindi ? 'प्रकृति, परिवार और पर्यावरण' : 'Nature, Family & Environment';
  String get hindiSubtitle => isHindi ? 'वर्णमाला, व्याकरण व साहित्य' : 'Varnamala, Grammar & Stories';
  String get changeBoard => isHindi ? 'बोर्ड बदलें' : 'Change Board';
  String get active => isHindi ? 'सक्रिय' : 'Active';

  // Challenge Navigation & Action Bar
  String get nextQuestion => isHindi ? 'अगला प्रश्न ➡️' : 'Next Question ➡️';
  String get nextQuestionNew => isHindi ? 'नया प्रश्न ✨' : 'Next Question (New ✨)';
  String get prevQuestion => isHindi ? 'पिछला' : 'Prev';
  String get skipQuestion => isHindi ? 'छोड़ें' : 'Skip';
  String get checkAnswer => isHindi ? 'उत्तर जांचें' : 'Check Answer';
  String get tryAgain => isHindi ? 'पुनः प्रयास करें' : 'Try Again';
  String get retryQuestion => isHindi ? 'यह प्रश्न पुनः करें' : 'Retry This Question';
  String get selectAnswerPrompt => isHindi ? 'अपना उत्तर चुनें:' : 'Select your answer:';
  String get openScratchpad => isHindi ? 'रफ पैड खोलें ✏️' : 'Open Scratchpad for Calculations ✏️';

  // Hints & Scaffolding
  String get needAHint => isHindi ? 'मदद चाहिए? 💡' : 'Need a hint? 💡';
  String get hideHint => isHindi ? 'संकेत छिपाएं' : 'Hide Hint';
  String get hint => isHindi ? 'संकेत 💡' : 'Hint 💡';
  String get pedagogicalHint => isHindi ? 'संकेत और सुराग 💡' : 'Pedagogical Hint & Clue 💡';
  String get fullExplanation => isHindi ? 'चरणबद्ध समाधान देखें 💡' : 'Step-by-Step Solution 💡';
  String get explanationTitle => isHindi ? 'अवधारणा समाधान' : 'Concept Explanation';
  String get stepByStepWorking => isHindi ? 'चरणबद्ध हल 📝' : 'Step-by-Step Working 📝';
  String get coreConcept => isHindi ? 'मुख्य अवधारणा 🧠' : 'Core Concept 🧠';
  String get goldenRules => isHindi ? 'सुनहरे नियम और सूत्र 📐' : 'Golden Rules & Formulas 📐';
  String get proTip => isHindi ? 'स्मार्ट टिप 🌟' : 'Pro-Tip 🌟';
  String get understoodClose => isHindi ? 'समझ गया! 👍' : 'Got it! 👍';
  String get understoodPractice => isHindi ? 'समझ गया, अभ्यास करें 👍' : 'Understood, Let\'s Practice 👍';

  // Learn Section & Study Guide
  String get whatYouWillLearn => isHindi ? 'आप क्या सीखेंगे 📌' : 'What You Will Learn 📌';
  String get curioSays => isHindi ? 'क्यूरियो कहता है:' : 'Curio says:';
  String get stepByStepExample => isHindi ? 'चरणबद्ध उदाहरण 💡' : 'Step-by-Step Example 💡';
  String get startPracticeNow => isHindi ? 'अभी अभ्यास शुरू करें 🚀' : 'Start Practice Now 🚀';
  String get readConceptAloud => isHindi ? 'अवधारणा सुनें 🔊' : 'Read Concept Aloud 🔊';
  String get chapterNumberLabel => isHindi ? 'अध्याय' : 'Chapter';
  String get solvedBadge => isHindi ? 'हल किया गया ✓' : 'Solved ✓';
  String get practiceSets => isHindi ? 'अभ्यास सेट' : 'Practice Sets';
  String get definitionsTab => isHindi ? '📖 अवधारणाएं एवं परिभाषाएं' : '📖 Definitions & Concepts';
  String get rulesTab => isHindi ? '📐 सूत्र एवं नियम' : '📐 Rules & Formulas';
  String get examplesTab => isHindi ? '💡 उदाहरण हल' : '💡 Solved Examples';
  String get examTrapsTab => isHindi ? '⚠️ सावधानियां' : '⚠️ Exam Traps';
  String get watchOut => isHindi ? 'सावधान! (Watch Out)' : 'Watch Out! ⚠️';
  String get whyItMatters => isHindi ? 'दैनिक जीवन में उपयोग 🌍' : 'Real-World Application 🌍';
  String get listenDefinition => isHindi ? 'परिभाषा सुनें 🔊' : 'Listen to Definition 🔊';
  String get formulasReference => isHindi ? 'महत्वपूर्ण सूत्र एवं नियम सूची 📐' : 'Important Formulas & Rules Sheet 📐';
  String get commonMistakesTitle => isHindi ? 'परीक्षा में होने वाली सामान्य गलतियाँ ⚠️' : 'Common Exam Traps to Avoid ⚠️';

  // Digital Textbook & Comprehensive Reading
  String get textbookTitle => isHindi ? 'सम्पूर्ण डिजिटल पाठ्यपुस्तक' : 'Complete Digital Textbook';
  String get readTextbook => isHindi ? '📖 सम्पूर्ण पाठ्यपुस्तक पढ़ें' : '📖 Read Complete Textbook';
  String get pointsToRememberTitle => isHindi ? '📌 स्मरण रखने योग्य मुख्य बिंदु' : '📌 Points to Remember (Summary)';
  String get didYouKnowTitle => isHindi ? '💡 क्या आप जानते हैं?' : '💡 Did You Know?';
  String get quickCheckTitle => isHindi ? '⚡ त्वरित समझ जाँच' : '⚡ Concept Quick Check';
  String get showAnswer => isHindi ? 'उत्तर देखें' : 'Show Answer';
  String get hideAnswer => isHindi ? 'उत्तर छिपाएं' : 'Hide Answer';
  String get chapterTest => isHindi ? '📝 अध्याय परीक्षा' : '📝 Chapter Test';
  String get generateMoreQuestions => isHindi ? '➕ और अभ्यास प्रश्न जोड़ें' : '➕ Generate More Questions';
  String get exerciseSets => isHindi ? 'अभ्यास प्रश्नावली' : 'Exercise Sets';

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
  // Exam / Unit Test Mode
  String get examMode => isHindi ? 'यूनिट टेस्ट / परीक्षा' : 'Unit Test / Exam Mode';
  String get takeExam => isHindi ? 'परीक्षा दें 📝' : 'Take Exam 📝';
  String get startTimedExam => isHindi ? 'समयबद्ध टेस्ट शुरू करें ⏱️' : 'Start Timed Test ⏱️';
  String get examReportCard => isHindi ? 'परीक्षा रिपोर्ट कार्ड 🎓' : 'Exam Report Card 🎓';
  String get examScore => isHindi ? 'कुल अंक' : 'Total Score';
  String get examTimeLeft => isHindi ? 'शेष समय' : 'Time Left';
  String get examPassed => isHindi ? 'शाबाश! उत्कृष्ट प्रदर्शन! 🎉' : 'Outstanding Performance! 🎉';
  String get examNeedsPractice => isHindi ? 'अच्छा प्रयास! थोड़ा और अभ्यास करें 💪' : 'Good Effort! Keep Practicing 💪';
  String get submitExam => isHindi ? 'टेस्ट जमा करें ✅' : 'Submit Test ✅';
  String get retakeExam => isHindi ? 'दोबारा टेस्ट दें 🔄' : 'Retake Test 🔄';

  // Visual Diagram Explorer & Simulations
  String get diagramExplorer => isHindi ? 'मॉडल और चित्र 🔬' : 'Visual Models & Diagrams 🔬';
  String get exploreDiagram => isHindi ? 'मॉडल देखें 🔬' : 'Explore Model 🔬';
  String get tapHotspotsToLearn => isHindi ? 'अंगों व भागों को समझने के लिए टैप करें 👆' : 'Tap on parts to explore details 👆';

  // App Updates & Reviews
  String get rateAndFeedback => isHindi ? 'रेट करें व सुझाव दें ⭐' : 'Rate Us & Feedback ⭐';
  String get checkForUpdates => isHindi ? 'अपडेट जांचें 🔄' : 'Check for Updates 🔄';
  String get upToDate => isHindi ? 'आप ऐप के नवीनतम संस्करण पर हैं! 🚀' : 'Curio Academy is up to date! 🚀';

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
