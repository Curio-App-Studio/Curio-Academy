import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/core/localization/app_localizations.dart';
import 'package:curio_math/core/theme/app_theme.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/grade_tier.dart';
import 'package:curio_math/data/models/student_attempt_model.dart';
import 'package:curio_math/data/models/activity_model.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/repositories/curriculum_repository.dart';
import 'package:curio_math/features/activities/bubble_pop/presentation/bubble_pop_screen.dart';
import 'package:curio_math/features/activities/card_match/presentation/card_match_screen.dart';
import 'package:curio_math/features/home_dashboard/presentation/home_dashboard_screen.dart';
import 'package:curio_math/core/profile/profile_provider.dart';
import 'package:curio_math/features/phonics_abc/presentation/phonics_abc_screen.dart';
import 'package:curio_math/features/rhymes_stories/presentation/rhymes_stories_screen.dart';
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

    testWidgets('BubblePopScreen top header does NOT overflow on narrow 320px screens in Hindi', (WidgetTester tester) async {
      await LocalStorageService.instance.saveAppLanguage('hi');
      tester.view.physicalSize = const Size(320 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.buildTheme(GradeTier.earlyExplorer),
            home: const BubblePopScreen(),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('L1'), findsOneWidget);
      expect(find.text('अगला'), findsOneWidget);
      expect(tester.takeException(), isNull);
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

    test('All 5 LKG Math and English chapters have diverse interactive games (Card Match & Bubble Pop) and ZERO MCQs', () async {
      final repo = CurriculumRepository();

      for (final subject in ['math', 'english']) {
        final chapters = await repo.getChaptersForClass(
          StudentClass.lkg,
          board: BoardType.cbse,
          subjectId: subject,
        );

        expect(chapters.length, equals(5));

        for (final ch in chapters) {
          expect(ch.activities.length, greaterThanOrEqualTo(3));

          final hasCardMatch = ch.activities.any((a) => a.activityType == ActivityType.cardMatch);
          expect(hasCardMatch, isTrue, reason: 'Chapter ${ch.title} in $subject must have Card Match pair games');

          final hasBubblePop = ch.activities.any((a) => a.activityType == ActivityType.bubblePop);
          expect(hasBubblePop, isTrue, reason: 'Chapter ${ch.title} in $subject must have Bubble Pop games');

          final hasMcq = ch.activities.any((a) => a.activityType == ActivityType.mcq);
          expect(hasMcq, isFalse, reason: 'Chapter ${ch.title} in $subject must NOT have text MCQs for LKG');
        }
      }
    });

    test('Obsolete legacy cache with 100% bubble pop or MCQ is automatically invalidated and purged', () async {
      final repo = CurriculumRepository();
      final storage = LocalStorageService.instance;

      // Seed obsolete legacy 100% bubble pop
      final obsoleteBubbles = <Activity>[
        const Activity(
          activityId: 'dummy_b1',
          topicId: 't1',
          subjectId: 'math',
          targetGrade: 'LKG',
          gradeTier: GradeTier.earlyExplorer,
          activityType: ActivityType.bubblePop,
          difficultyLevel: 1,
          pointsReward: 20,
          promptData: PromptData(text: 'Pop 1'),
          interactionPayload: {'bubbles': []},
          validationRule: ValidationRule(format: 'exact', expectedAnswer: '1'),
        ),
        const Activity(
          activityId: 'dummy_b2',
          topicId: 't2',
          subjectId: 'math',
          targetGrade: 'LKG',
          gradeTier: GradeTier.earlyExplorer,
          activityType: ActivityType.bubblePop,
          difficultyLevel: 1,
          pointsReward: 20,
          promptData: PromptData(text: 'Pop 2'),
          interactionPayload: {'bubbles': []},
          validationRule: ValidationRule(format: 'exact', expectedAnswer: '2'),
        ),
      ];

      await storage.saveChapterActivities('lkg_ch01', obsoleteBubbles);

      // getChaptersForClass must detect and replace with early learning games
      final chapters = await repo.getChaptersForClass(
        StudentClass.lkg,
        board: BoardType.cbse,
        subjectId: 'math',
      );
      final ch1 = chapters.firstWhere((c) => c.chapterId == 'lkg_ch01');
      expect(ch1.activities.any((a) => a.activityType == ActivityType.cardMatch), isTrue);
      expect(ch1.activities.any((a) => a.activityType == ActivityType.bubblePop), isTrue);
      expect(ch1.activities.any((a) => a.activityType == ActivityType.mcq), isFalse);
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

      // Verify Student Greeting is rendered
      expect(find.text('Hello Little Champ! 👋'), findsOneWidget);
      expect(find.text('🦁'), findsOneWidget);

      // Verify Active Class & Board badge is rendered in Student Greeting
      expect(find.text('Class 1'), findsOneWidget);
      expect(find.text('CBSE'), findsOneWidget);

      // Verify Subject Selection is rendered
      expect(find.text('Pick a Subject 🎨'), findsOneWidget);
      expect(find.text('Math'), findsWidgets);
      expect(find.text('English'), findsWidgets);
      expect(find.text('Science'), findsNothing);
    });

    testWidgets('Tapping LanguageSwitchButton dynamically updates HomeDashboardScreen language to Hindi', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initially English
      expect(find.text('Hello Little Champ! 👋'), findsOneWidget);

      // Tap language toggle
      await tester.tap(find.byType(LanguageSwitchButton));
      await tester.pump(const Duration(milliseconds: 300));

      // Greeting and UI should now immediately update to Hindi
      expect(find.text('नमस्ते Little Champ! 👋'), findsOneWidget);
      expect(find.text('विषय चुनें 🎨'), findsOneWidget);
    });

    testWidgets('HomeDashboardScreen AppBar does not overflow on small 320px mobile screens', (WidgetTester tester) async {
      FlutterErrorDetails? caughtDetails;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        caughtDetails = details;
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      if (caughtDetails != null) {
        FlutterError.onError = originalOnError;
        if (caughtDetails!.informationCollector != null) {
          for (final d in caughtDetails!.informationCollector!()) {
            debugPrint(d.toString());
          }
        }
      } else {
        FlutterError.onError = originalOnError;
      }
      expect(caughtDetails, isNull);
    });

    testWidgets('Tapping Next in BubblePopScreen transitions to CardMatchScreen and not the same game', (WidgetTester tester) async {
      const act1 = Activity(
        activityId: 'act_b1',
        topicId: 't1',
        subjectId: 'math',
        targetGrade: 'LKG',
        gradeTier: GradeTier.earlyExplorer,
        activityType: ActivityType.bubblePop,
        promptData: PromptData(text: 'Pop 5'),
        interactionPayload: {
          'targetValue': 5,
          'bubbles': [
            {'id': '1', 'label': '5', 'value': 5, 'displayType': 'number'},
            {'id': '2', 'label': '2', 'value': 2, 'displayType': 'number'},
          ],
        },
        validationRule: ValidationRule(format: 'exact', expectedAnswer: '5'),
      );

      const act2 = Activity(
        activityId: 'act_m2',
        topicId: 't1',
        subjectId: 'math',
        targetGrade: 'LKG',
        gradeTier: GradeTier.earlyExplorer,
        activityType: ActivityType.cardMatch,
        promptData: PromptData(text: 'Match pairs'),
        interactionPayload: {
          'pairs': [
            {'key': '1', 'itemA': '1', 'emojiA': '1️⃣', 'itemB': 'Star', 'emojiB': '⭐'},
          ],
        },
        validationRule: ValidationRule(format: 'set_match', expectedAnswer: []),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: BubblePopScreen(
            activity: act1,
            activities: [act1, act2],
            initialLevelIndex: 0,
          ),
        ),
      );
      await tester.pump();

      final nextFinder = find.text('Next');
      expect(nextFinder, findsOneWidget);
      await tester.tap(nextFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(CardMatchScreen), findsOneWidget);
      expect(find.byType(BubblePopScreen), findsNothing);
    });

    testWidgets('Tapping Next in CardMatchScreen transitions to BubblePopScreen and not the same game', (WidgetTester tester) async {
      const act1 = Activity(
        activityId: 'act_m1',
        topicId: 't1',
        subjectId: 'math',
        targetGrade: 'LKG',
        gradeTier: GradeTier.earlyExplorer,
        activityType: ActivityType.cardMatch,
        promptData: PromptData(text: 'Match pairs'),
        interactionPayload: {
          'pairs': [
            {'key': '1', 'itemA': '1', 'emojiA': '1️⃣', 'itemB': 'Star', 'emojiB': '⭐'},
          ],
        },
        validationRule: ValidationRule(format: 'set_match', expectedAnswer: []),
      );

      const act2 = Activity(
        activityId: 'act_b2',
        topicId: 't1',
        subjectId: 'math',
        targetGrade: 'LKG',
        gradeTier: GradeTier.earlyExplorer,
        activityType: ActivityType.bubblePop,
        promptData: PromptData(text: 'Pop 5'),
        interactionPayload: {
          'targetValue': 5,
          'bubbles': [
            {'id': '1', 'label': '5', 'value': 5, 'displayType': 'number'},
            {'id': '2', 'label': '2', 'value': 2, 'displayType': 'number'},
          ],
        },
        validationRule: ValidationRule(format: 'exact', expectedAnswer: '5'),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: CardMatchScreen(
            activity: act1,
            activities: [act1, act2],
            initialLevelIndex: 0,
          ),
        ),
      );
      await tester.pump();

      final nextFinder = find.text('Next');
      expect(nextFinder, findsOneWidget);
      await tester.tap(nextFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(BubblePopScreen), findsOneWidget);
      expect(find.byType(CardMatchScreen), findsNothing);
    });

    testWidgets('Early Explorer Dashboard renders Interactive Mini-Games and Discovery Cards', (WidgetTester tester) async {
      final lkgProfile = StudentProfile(
        studentName: 'Aahan',
        avatarIcon: '🦁',
        board: BoardType.cbse,
        studentClass: StudentClass.lkg,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studentProfileProvider.overrideWith((ref) => StudentProfileNotifier(ref)
              ..updateProfile(
                name: lkgProfile.studentName,
                avatar: lkgProfile.avatarIcon,
                board: lkgProfile.board,
                studentClass: lkgProfile.studentClass,
              )),
          ],
          child: const MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Mini-Games Front & Center
      expect(find.text('🎮 Interactive Mini-Games'), findsOneWidget);
      expect(find.text('Bubble Pop 🫧'), findsOneWidget);
      expect(find.text('Card Match 🃏'), findsOneWidget);
      expect(find.text('Island Map 🏝️'), findsOneWidget);

      // Discovery Cards
      expect(find.text('Pick a Subject 🎨'), findsOneWidget);
      expect(find.textContaining('Picture Discovery Cards'), findsOneWidget);
      expect(find.text('Numbers & Shapes 🎈'), findsOneWidget);
      expect(find.text('ABC & Phonics 🔤'), findsOneWidget);
      expect(find.text('Rhymes & Stories 📖'), findsOneWidget);
      expect(find.text('Nature & Animals 🐾'), findsOneWidget);
      expect(find.text('Akshar Varnamala 🇮🇳'), findsOneWidget);
    });

    testWidgets('Tapping Bubble Pop mini-game opens BubblePopScreen directly', (WidgetTester tester) async {
      final lkgProfile = StudentProfile(
        studentName: 'Aahan',
        avatarIcon: '🦁',
        board: BoardType.cbse,
        studentClass: StudentClass.lkg,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studentProfileProvider.overrideWith((ref) => StudentProfileNotifier(ref)
              ..updateProfile(
                name: lkgProfile.studentName,
                avatar: lkgProfile.avatarIcon,
                board: lkgProfile.board,
                studentClass: lkgProfile.studentClass,
              )),
          ],
          child: const MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Bubble Pop 🫧'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(BubblePopScreen), findsOneWidget);
    });

    testWidgets('Tapping Card Match mini-game opens CardMatchScreen directly', (WidgetTester tester) async {
      final lkgProfile = StudentProfile(
        studentName: 'Aahan',
        avatarIcon: '🦁',
        board: BoardType.cbse,
        studentClass: StudentClass.lkg,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studentProfileProvider.overrideWith((ref) => StudentProfileNotifier(ref)
              ..updateProfile(
                name: lkgProfile.studentName,
                avatar: lkgProfile.avatarIcon,
                board: lkgProfile.board,
                studentClass: lkgProfile.studentClass,
              )),
          ],
          child: const MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Card Match 🃏'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(CardMatchScreen), findsOneWidget);
    });

    testWidgets('Tapping ABC & Phonics discovery card opens PhonicsAbcScreen', (WidgetTester tester) async {
      final lkgProfile = StudentProfile(
        studentName: 'Aahan',
        avatarIcon: '🦁',
        board: BoardType.cbse,
        studentClass: StudentClass.lkg,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studentProfileProvider.overrideWith((ref) => StudentProfileNotifier(ref)
              ..updateProfile(
                name: lkgProfile.studentName,
                avatar: lkgProfile.avatarIcon,
                board: lkgProfile.board,
                studentClass: lkgProfile.studentClass,
              )),
          ],
          child: const MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('ABC & Phonics 🔤'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(PhonicsAbcScreen), findsOneWidget);
    });

    testWidgets('Tapping Rhymes & Stories discovery card opens RhymesStoriesScreen directly', (WidgetTester tester) async {
      final lkgProfile = StudentProfile(
        studentName: 'Aahan',
        avatarIcon: '🦁',
        board: BoardType.cbse,
        studentClass: StudentClass.lkg,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studentProfileProvider.overrideWith((ref) => StudentProfileNotifier(ref)
              ..updateProfile(
                name: lkgProfile.studentName,
                avatar: lkgProfile.avatarIcon,
                board: lkgProfile.board,
                studentClass: lkgProfile.studentClass,
              )),
          ],
          child: const MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Rhymes & Stories 📖'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(RhymesStoriesScreen), findsOneWidget);
    });
  });
}
