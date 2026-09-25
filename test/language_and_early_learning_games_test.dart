import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/core/localization/app_localizations.dart';
import 'package:curio_math/core/theme/app_theme.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/grade_tier.dart';
import 'package:curio_math/data/models/student_attempt_model.dart';
import 'package:curio_math/features/activities/bubble_pop/presentation/bubble_pop_screen.dart';
import 'package:curio_math/features/activities/card_match/presentation/card_match_screen.dart';
import 'package:curio_math/features/home_dashboard/presentation/home_dashboard_screen.dart';
import 'package:curio_math/shared/components/language_switch_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService.instance;
    await storage.init();
    for (final actId in storage.getAllQuestionAttempts().keys.toList()) {
      await storage.clearQuestionAttempt(actId);
    }
  });

  group('Language Switching & Localization Tests (Option A: English & Hindi)', () {
    test('AppLocalizations provides complete bilingual dictionary for English & Hindi', () {
      const en = AppLocalizations(AppLanguage.english);
      const hi = AppLocalizations(AppLanguage.hindi);

      expect(en.math, equals('Math'));
      expect(hi.math, equals('गणित'));

      expect(en.english, equals('English'));
      expect(hi.english, equals('अंग्रेज़ी'));

      expect(en.totalStars, equals('Total Stars'));
      expect(hi.totalStars, equals('कुल सितारे'));

      expect(en.nextQuestion, contains('Next Question'));
      expect(hi.nextQuestion, contains('अगला प्रश्न'));

      expect(en.hint.toLowerCase(), contains('hint'));
      expect(hi.hint, contains('संकेत'));
    });

    test('LocalStorageService persists language selection and updates languageNotifier', () async {
      final storage = LocalStorageService.instance;
      expect(storage.getAppLanguage(), equals('en'));

      await storage.saveAppLanguage('hi');
      expect(storage.getAppLanguage(), equals('hi'));
      expect(storage.languageNotifier.value, equals('hi'));

      await storage.saveAppLanguage('en');
      expect(storage.getAppLanguage(), equals('en'));
      expect(storage.languageNotifier.value, equals('en'));
    });

    testWidgets('LanguageSwitchButton toggles language between English and Hindi on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: SafeArea(child: LanguageSwitchButton()),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('EN'), findsOneWidget);

      // Tap to toggle to Hindi
      await tester.tap(find.byType(LanguageSwitchButton));
      await tester.pump();

      expect(LocalStorageService.instance.getAppLanguage(), equals('hi'));
      expect(find.text('हिन्दी'), findsOneWidget);

      // Tap again to toggle back to English
      await tester.tap(find.byType(LanguageSwitchButton));
      await tester.pump();

      expect(LocalStorageService.instance.getAppLanguage(), equals('en'));
      expect(find.text('EN'), findsOneWidget);
    });
  });

  group('LKG & UKG Infinite Next Level & Header Layout Tests', () {
    testWidgets('BubblePopScreen renders separated header with Total Stars and no speaker overlap', (WidgetTester tester) async {
      // Award some stars first
      final storage = LocalStorageService.instance;
      await storage.saveQuestionAttempt(StudentQuestionAttempt(
        activityId: 'dummy_act_1',
        chapterId: 'dummy_ch',
        selectedOptionIndex: 0,
        selectedOptionText: 'correct',
        isCorrect: true,
        starsEarned: 3,
        timestamp: DateTime.now(),
      ));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.buildTheme(GradeTier.earlyExplorer),
            home: const BubblePopScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify Level badge, Total Stars badge, and Next button are present in top header
      expect(find.text('L1'), findsOneWidget);
      expect(find.text('3'), findsWidgets); // Total stars chip and bubble item
      expect(find.text('Next'), findsOneWidget);

      // Verify Bubble Target & Progress bar row is rendered with goal counter (/ 4 in Level 1)
      expect(find.textContaining('/ 4'), findsOneWidget);

      // Tap 'Next' to trigger dynamic level generation on the fly!
      await tester.tap(find.text('Next'));
      await tester.pump();

      // Should seamlessly advance to Level 2
      expect(find.text('L2'), findsOneWidget);
    });

    testWidgets('CardMatchScreen mounts, displays cards, and supports Next level progression', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.buildTheme(GradeTier.earlyExplorer),
            home: const CardMatchScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify Game header, pairs left banner, and cards are rendered
      expect(find.text('Game 1'), findsOneWidget);
      expect(find.textContaining('Pairs left'), findsOneWidget);
      expect(find.byType(CardMatchScreen), findsOneWidget);

      // Tap Next to skip / advance to next Card Match level
      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(find.text('Game 2'), findsOneWidget);
    });
  });

  group('Home Dashboard Total Stars Display Tests', () {
    testWidgets('HomeDashboardScreen displays prominent Total Stars Hero Card on dashboard body', (WidgetTester tester) async {
      final storage = LocalStorageService.instance;
      await storage.saveQuestionAttempt(StudentQuestionAttempt(
        activityId: 'hero_test_act_1',
        chapterId: 'hero_ch',
        selectedOptionIndex: 0,
        selectedOptionText: 'correct',
        isCorrect: true,
        starsEarned: 3,
        timestamp: DateTime.now(),
      ));

      expect(storage.totalStars, equals(3));
      expect(storage.totalStarsNotifier.value, equals(3));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Total Stars count (3) and labels should be rendered in the Hero Card on the Home Dashboard body!
      expect(find.text('Total Stars'), findsOneWidget);
      expect(find.text('Total Stars Earned'), findsOneWidget);
      expect(find.text('Super Explorer 🏆'), findsOneWidget);
      expect(find.text('3'), findsWidgets);
    });
  });
}
