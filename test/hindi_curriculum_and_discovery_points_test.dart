import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/core/localization/app_localizations.dart';
import 'package:curio_math/core/localization/hindi_curriculum_translator.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/activity_model.dart';
import 'package:curio_math/data/models/chapter_model.dart';
import 'package:curio_math/data/models/grade_tier.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/services/concept_solution_helper.dart';
import 'package:curio_math/features/concept_learning/presentation/concept_lesson_sheet.dart';
import 'package:curio_math/features/activities/concept_quiz/presentation/concept_challenge_screen.dart';
import 'package:curio_math/features/activities/concept_quiz/presentation/question_solution_sheet.dart';
import 'package:curio_math/features/chapter_detail/presentation/chapter_detail_screen.dart';
import 'package:curio_math/features/home_dashboard/presentation/home_dashboard_screen.dart';

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

  group('Discovery Points Storage & Display Tests', () {
    test('LocalStorageService persists discovery points and notifies listeners', () async {
      final storage = LocalStorageService.instance;
      expect(storage.totalPoints, equals(0));

      await storage.addDiscoveryPoints(25);
      expect(storage.totalPoints, equals(25));
      expect(storage.totalPointsNotifier.value, equals(25));

      await storage.addDiscoveryPoints(50);
      expect(storage.totalPoints, equals(75));
      expect(storage.totalPointsNotifier.value, equals(75));
    });

    testWidgets('HomeDashboardScreen displays both Total Stars and Discovery Points', (WidgetTester tester) async {
      final storage = LocalStorageService.instance;
      await storage.addDiscoveryPoints(120);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Stars and points rendered on home dashboard
      expect(find.text('⭐'), findsWidgets);
      expect(find.text('💎'), findsWidgets);
      expect(find.text('120'), findsOneWidget);
      expect(find.text('Points'), findsOneWidget);
    });
  });

  group('Hindi Curriculum Translator Tests', () {
    test('HindiCurriculumTranslator translates questions, options, chapter titles and hints accurately', () {
      // 1. Question prompts
      final slidePrompt = HindiCurriculumTranslator.translatePrompt(
        'Which of these items will SLIDE flat on the floor instead of rolling?',
      );
      expect(slidePrompt, contains('फिसलेगी'));

      final rollPrompt = HindiCurriculumTranslator.translatePrompt(
        'Which object can BOTH roll and slide?',
      );
      expect(rollPrompt, contains('लुढ़क (Roll) और फिसल (Slide)'));

      final dynamicMathPrompt = HindiCurriculumTranslator.translatePrompt('Solve for x: 2x + 4 = 10');
      expect(dynamicMathPrompt, contains('x का मान ज्ञात कीजिए'));

      // 2. Options
      expect(HindiCurriculumTranslator.translateOption('Inside'), contains('अंदर'));
      expect(HindiCurriculumTranslator.translateOption('Outside'), contains('बाहर'));
      expect(HindiCurriculumTranslator.translateOption('Rolling'), contains('लुढ़कना'));
      expect(HindiCurriculumTranslator.translateOption('Sliding'), contains('फिसलना'));

      // 3. Chapter Titles
      expect(HindiCurriculumTranslator.translateChapterTitle('Shapes and Space'), equals('आकृतियाँ और स्थान'));
      expect(HindiCurriculumTranslator.translateChapterTitle('Addition'), contains('जोड़'));

      // 4. Hints
      final hint = HindiCurriculumTranslator.translateHint('Look closely at the object shape. Flat surfaces slide, rounded surfaces roll.');
      expect(hint, contains('वस्तु के आकार को ध्यान से देखें'));
      expect(hint, contains('सपाट सतह फिसलती है'));

      // 5. Steps
      final step = HindiCurriculumTranslator.translateStep('Step 1: Subtract 4 from both sides. We get 2x = 6.');
      expect(step, contains('चरण 1:'));
      expect(step, contains('दोनों पक्षों से 4 घटाएं'));
    });

    test('ConceptSolutionHelper produces authentic Hindi hint and step solutions', () {
      final activity = Activity(
        activityId: 'math_ch1_q1',
        topicId: 'shapes_space',
        subjectId: 'math',
        targetGrade: 'Class 1',
        gradeTier: GradeTier.earlyExplorer,
        activityType: ActivityType.mcq,
        promptData: const PromptData(
          text: 'Which of these items will SLIDE flat on the floor instead of rolling?',
        ),
        interactionPayload: const {
          'options': ['Pencil Box', 'Football', 'Orange', 'Marble'],
          'expectedAnswer': 'Pencil Box',
          'explanation': 'A pencil box has flat rectangular faces so it slides!',
        },
        validationRule: const ValidationRule(format: 'exact', expectedAnswer: 'Pencil Box'),
      );

      final details = ConceptSolutionHelper.instance.getDetails(
        activity,
        isHindi: true,
      );

      expect(details.isHindi, isTrue);
      expect(details.conceptDetail, contains('सपाट सतह'));
      expect(details.hint, contains('आकार'));
      expect(details.steps.first, contains('चरण'));
    });
  });

  group('Bilingual Learn Section & Solution Modal Tests', () {
    testWidgets('ConceptLessonSheet displays authentic Hindi learning content when Hindi is selected', (WidgetTester tester) async {
      await LocalStorageService.instance.saveAppLanguage('hi');
      final chapter = Chapter(
        chapterId: 'class1_ch01',
        chapterNumber: 1,
        title: 'Shapes and Space',
        description: 'Explore shapes that roll and slide and discover spatial positions.',
        grade: 'Class 1',
        icon: '🟡',
        keyConcepts: ['Rolling vs Sliding', 'Inside and Outside'],
        rules: ['Flat faces slide smoothly.'],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      ConceptLessonSheet.show(
                        context,
                        chapter: chapter,
                        profile: const StudentProfile(
                          studentName: 'Aarav',
                          studentClass: StudentClass.class1,
                          board: BoardType.cbse,
                        ),
                        onStartPractice: () {},
                      );
                    },
                    child: const Text('Open Lesson'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.text('Open Lesson'));
      await tester.pumpAndSettle();

      // Verify Hindi curriculum texts
      expect(find.text('आकृतियाँ और स्थान'), findsOneWidget);
      expect(find.textContaining('आप क्या सीखेंगे'), findsOneWidget);
      expect(find.textContaining('क्यूरियो कहता है'), findsOneWidget);
      expect(find.textContaining('का अभ्यास करें'), findsOneWidget);
    });

    testWidgets('QuestionSolutionSheet displays Hindi steps, hints, and correct answer', (WidgetTester tester) async {
      await LocalStorageService.instance.saveAppLanguage('hi');
      final chapter = Chapter(
        chapterId: 'class1_ch01',
        chapterNumber: 1,
        title: 'Shapes and Space',
        grade: 'Class 1',
        icon: '🟡',
      );

      final activity = Activity(
        activityId: 'math_act_slide',
        topicId: 'class1_ch01',
        subjectId: 'math',
        targetGrade: 'Class 1',
        gradeTier: GradeTier.earlyExplorer,
        activityType: ActivityType.mcq,
        promptData: const PromptData(
          text: 'Which of these items will SLIDE flat on the floor instead of rolling?',
        ),
        interactionPayload: const {
          'options': ['Pencil Box', 'Football', 'Orange'],
          'expectedAnswer': 'Pencil Box',
        },
        validationRule: const ValidationRule(format: 'exact', expectedAnswer: 'Pencil Box'),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      QuestionSolutionSheet.show(
                        context,
                        activity: activity,
                        chapter: chapter,
                      );
                    },
                    child: const Text('Open Solution'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.text('Open Solution'));
      await tester.pumpAndSettle();

      // Verify Hindi solution elements
      expect(find.textContaining('चरणबद्ध हल'), findsOneWidget);
      expect(find.textContaining('मुख्य अवधारणा'), findsOneWidget);
      expect(find.textContaining('समझ गया'), findsWidgets);
    });

    testWidgets('ConceptChallengeScreen renders translated Hindi question, choices, and hints', (WidgetTester tester) async {
      await LocalStorageService.instance.saveAppLanguage('hi');
      final chapter = Chapter(
        chapterId: 'class1_ch01',
        chapterNumber: 1,
        title: 'Shapes and Space',
        grade: 'Class 1',
        icon: '🟡',
      );

      final activity = Activity(
        activityId: 'math_act_both',
        topicId: 'class1_ch01',
        subjectId: 'math',
        targetGrade: 'Class 1',
        gradeTier: GradeTier.earlyExplorer,
        activityType: ActivityType.mcq,
        promptData: const PromptData(
          text: 'Which object can BOTH roll and slide?',
        ),
        interactionPayload: const {
          'options': ['Coin', 'Ball', 'Dice'],
          'expectedAnswer': 'Coin',
        },
        validationRule: const ValidationRule(format: 'exact', expectedAnswer: 'Coin'),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ConceptChallengeScreen(
              chapter: chapter,
              activities: [activity],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Question rendered in Hindi
      expect(find.textContaining('कौन सी वस्तु लुढ़क (Roll) और फिसल (Slide)'), findsOneWidget);
      // Hindi hint buttons
      expect(find.textContaining('मदद चाहिए'), findsOneWidget);
      expect(find.textContaining('चरणबद्ध समाधान'), findsOneWidget);
      expect(find.textContaining('रफ पैड खोलें'), findsOneWidget);
    });
  });

  group('Avatar Selection & Personalized Greeting Tests', () {
    test('AppLocalizations formats greeting with student name in English and Hindi', () {
      const en = AppLocalizations(AppLanguage.english);
      const hi = AppLocalizations(AppLanguage.hindi);

      expect(en.formatGreeting('Aarav'), equals('Hello Aarav! 👋'));
      expect(en.formatGreeting('Pari'), equals('Hello Pari! 👋'));
      expect(en.formatGreeting(''), equals('Hello Little Champ! 👋'));

      expect(hi.formatGreeting('आरव'), equals('नमस्ते आरव! 👋'));
      expect(hi.formatGreeting(''), equals('नमस्ते नन्हे दोस्त! 👋'));
    });

    test('StudentProfile model and LocalStorageService persist custom avatar and name', () async {
      final storage = LocalStorageService.instance;
      const initialProfile = StudentProfile(
        board: BoardType.cbse,
        studentClass: StudentClass.class1,
        studentName: 'Aarav',
        avatarIcon: '🚀',
      );

      await storage.saveStudentProfile(initialProfile);
      final loaded = await storage.getStudentProfile();

      expect(loaded, isNotNull);
      expect(loaded!.studentName, equals('Aarav'));
      expect(loaded.avatarIcon, equals('🚀'));
    });

    testWidgets('HomeDashboardScreen displays custom avatar and Hello <name> greeting', (WidgetTester tester) async {
      await LocalStorageService.instance.saveAppLanguage('en');
      final storage = LocalStorageService.instance;
      await storage.saveStudentProfile(const StudentProfile(
        board: BoardType.cbse,
        studentClass: StudentClass.class1,
        studentName: 'Kabir',
        avatarIcon: '🐼',
      ));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should display custom avatar '🐼' and 'Hello Kabir! 👋'
      expect(find.text('🐼'), findsOneWidget);
      expect(find.text('Hello Kabir! 👋'), findsOneWidget);

      // Tap on avatar to open AvatarSelectorDialog
      await tester.tap(find.text('🐼'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile 🎒'), findsOneWidget);
      expect(find.text('Save & Continue 👍'), findsOneWidget);
    });

    test('Procedural math questions and curriculum prompts translate 100% into Hindi', () {
      expect(
        HindiCurriculumTranslator.translatePrompt('What is 4 + 3?'),
        equals('4 + 3 का मान क्या होगा?'),
      );
      expect(
        HindiCurriculumTranslator.translatePrompt('What is 9 - 4?'),
        equals('9 - 4 का मान क्या होगा?'),
      );
      expect(
        HindiCurriculumTranslator.translatePrompt(
          'Rani has 4 apples 🍎. Rohit gives her 2 more 🍎. How many apples does Rani have in all?',
        ),
        contains('रानी के पास 4 सेब 🍎 हैं'),
      );
      expect(
        HindiCurriculumTranslator.translatePrompt(
          'There were 5 birds 🐦 on a branch. 2 birds flew away. How many birds are left?',
        ),
        contains('शाखा पर 5 पक्षी 🐦 बैठे थे'),
      );
      expect(
        HindiCurriculumTranslator.translatePrompt(
          'Which shape has exactly 3 straight sides and 3 sharp corners?',
        ),
        equals('किस आकृति की ठीक 3 सीधी भुजाएँ और 3 कोने होते हैं?'),
      );
      expect(
        HindiCurriculumTranslator.translatePrompt(
          'Which of these everyday objects can easily ROLL along the floor?',
        ),
        equals('इनमें से कौन सी वस्तु फर्श पर आसानी से लुढ़क (Roll) सकती है?'),
      );
      expect(
        HindiCurriculumTranslator.translatePrompt(
          'Pop all bubbles that equal 5! (Class 1 Math)',
        ),
        contains('उन सभी बुलबुलों को फोड़ें जिनका मान 5 के बराबर है!'),
      );
      expect(
        HindiCurriculumTranslator.translatePrompt(
          'Pop all bubbles that have 3 items or the number 3! (Ch 2: Numbers 1 to 5)',
        ),
        contains('उन सभी बुलबुलों को फोड़ें जिनमें 3 वस्तुएं या संख्या 3 है!'),
      );
      expect(
        HindiCurriculumTranslator.translatePrompt(
          'Drag fractions equal to 1/2 into the Cauldron! (Ch 9: Halves & Quarters)',
        ),
        contains('1/2 के बराबर सभी भिन्नों को कड़ाही (Cauldron) में खींचें!'),
      );
      expect(
        HindiCurriculumTranslator.translatePrompt(
          'What number is formed by 2 Tens and 5 Ones?',
        ),
        equals('2 दहाई (Tens) और 5 इकाई (Ones) से कौन सी संख्या बनेगी?'),
      );
      expect(
        HindiCurriculumTranslator.translatePrompt(
          'In the number 25, how many TENS are there?',
        ),
        equals('संख्या 25 में कितनी दहाई (TENS) हैं?'),
      );
    });

    testWidgets('ChapterDetailScreen renders Hindi questions and chapter title when Hindi is active', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await LocalStorageService.instance.saveAppLanguage('hi');
      final chapter = Chapter(
        chapterId: 'class1_ch01',
        chapterNumber: 1,
        title: 'Shapes and Space',
        description: 'Explore shapes that roll and slide and discover spatial positions.',
        grade: 'Class 1',
        icon: '🟡',
        keyConcepts: ['Rolling vs Sliding', 'Inside and Outside'],
        activities: [
          Activity(
            activityId: 'c1_q1',
            topicId: 'shapes_space',
            subjectId: 'math',
            targetGrade: 'Class 1',
            gradeTier: GradeTier.earlyExplorer,
            activityType: ActivityType.mcq,
            promptData: const PromptData(
              text: 'Which of these items will SLIDE flat on the floor instead of rolling?',
            ),
            interactionPayload: const {
              'options': ['Flat Pencil Box 📦', 'Round Marble 🔮'],
              'expectedAnswer': 'Flat Pencil Box 📦',
            },
            validationRule: const ValidationRule(format: 'exact', expectedAnswer: 'Flat Pencil Box 📦'),
          ),
          Activity(
            activityId: 'c1_q2',
            topicId: 'addition',
            subjectId: 'math',
            targetGrade: 'Class 1',
            gradeTier: GradeTier.earlyExplorer,
            activityType: ActivityType.mcq,
            promptData: const PromptData(
              text: 'What is 3 + 2?',
            ),
            interactionPayload: const {
              'options': ['5', '6', '4'],
              'expectedAnswer': '5',
            },
            validationRule: const ValidationRule(format: 'exact', expectedAnswer: '5'),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ChapterDetailScreen(chapter: chapter),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Chapter title and header in Hindi
      expect(find.textContaining('आकृतियाँ और स्थान'), findsWidgets);
      expect(find.textContaining('अभ्यास प्रश्न (2)'), findsOneWidget);

      // 2. Both questions rendered in authentic Hindi on their cards!
      expect(find.textContaining('फर्श पर फिसलेगी'), findsOneWidget);
      expect(find.textContaining('3 + 2 का मान क्या होगा?'), findsOneWidget);
      expect(find.text('प्रश्न 1'), findsOneWidget);
      expect(find.text('प्रश्न 2'), findsOneWidget);
    });

    testWidgets('3-dot button shows Edit Profile and clicking it opens Edit Profile dialog', (WidgetTester tester) async {
      await LocalStorageService.instance.saveAppLanguage('en');

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Find and tap 3-dot popup menu
      final moreButton = find.byIcon(Icons.more_vert_rounded);
      expect(moreButton, findsOneWidget);
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // 2. Menu should show 'Edit Profile' and NOT 'Change Board'
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Change Board'), findsNothing);

      // 3. Tap 'Edit Profile'
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // 4. Verify Edit Profile dialog opens with complete profile management
      expect(find.text('Edit Profile 🎒'), findsOneWidget);
      expect(find.text('Save & Continue 👍'), findsOneWidget);
      expect(find.text('1. Select Educational Board'), findsOneWidget);
      expect(find.text('2. Select Class / Grade'), findsOneWidget);
      expect(find.text('3. Choose Favorite Avatar'), findsOneWidget);
    });
  });
}
