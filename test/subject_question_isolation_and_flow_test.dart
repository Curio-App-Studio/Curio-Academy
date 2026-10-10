import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/activity_model.dart';
import 'package:curio_math/data/models/chapter_model.dart';
import 'package:curio_math/data/models/grade_tier.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/repositories/curriculum_repository.dart';
import 'package:curio_math/data/services/procedural_question_generator.dart';
import 'package:curio_math/features/activities/concept_quiz/presentation/concept_challenge_screen.dart';
import 'package:curio_math/features/chapter_detail/presentation/chapter_detail_screen.dart';
import 'package:curio_math/features/exam_mode/presentation/timed_exam_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService.instance;
    await storage.init();
    await storage.saveAppLanguage('en');
  });

  group('Subject Question Isolation Tests', () {
    test('LKG Hindi produces authentic Hindi games with ZERO math questions', () async {
      final repo = CurriculumRepository.instance;
      final hindiChapters = await repo.getChaptersForClass(
        StudentClass.lkg,
        subjectId: 'hindi',
      );

      expect(hindiChapters, isNotEmpty);
      final ch1 = hindiChapters.first;
      expect(ch1.subjectId, equals('hindi'));
      expect(ch1.activities, isNotEmpty);

      // Verify ZERO math contamination in LKG Hindi
      for (final act in ch1.activities) {
        expect(act.subjectId, equals('hindi'));
        final text = act.promptData.text.toLowerCase();
        expect(text.contains('equal 5'), isFalse);
        expect(text.contains('math'), isFalse);
        expect(text.contains('plus'), isFalse);
        expect(text.contains('addition'), isFalse);
        expect(act.activityType != ActivityType.mcq, isTrue); // LKG must have ZERO MCQs (card match or bubble pop)
      }
    });

    test('LKG & UKG EVS produces authentic nature/animal games with ZERO math questions', () async {
      final repo = CurriculumRepository.instance;
      final evsChapters = await repo.getChaptersForClass(
        StudentClass.lkg,
        subjectId: 'evs',
      );

      expect(evsChapters, isNotEmpty);
      final ch1 = evsChapters.first;
      expect(ch1.subjectId, equals('evs'));
      expect(ch1.activities, isNotEmpty);

      for (final act in ch1.activities) {
        expect(act.subjectId, equals('evs'));
        final text = act.promptData.text.toLowerCase();
        expect(text.contains('equal 5'), isFalse);
        expect(text.contains('count the items'), isFalse);
        expect(act.activityType != ActivityType.mcq, isTrue);
      }
    });

    test('Class 3 Science produces authentic science questions with ZERO math rules', () async {
      final repo = CurriculumRepository.instance;
      final scienceChapters = await repo.getChaptersForClass(
        StudentClass.class3,
        subjectId: 'science',
      );

      expect(scienceChapters, isNotEmpty);
      final ch1 = scienceChapters.first;
      expect(ch1.subjectId, equals('science'));
      expect(ch1.activities, isNotEmpty);

      for (final act in ch1.activities) {
        expect(act.subjectId, equals('science'));
        final text = act.promptData.text.toLowerCase();
        expect(text.contains('mathematical'), isFalse);
        expect(text.contains('multiplying by zero'), isFalse);
        final opts = (act.interactionPayload['options'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
        for (final opt in opts) {
          expect(opt.contains('multiplying by zero'), isFalse);
          expect(opt.contains('arithmetic'), isFalse);
        }
      }
    });

    test('Stale math activities cached under hindi or science are purged automatically', () async {
      // Intentionally insert a contaminated math activity into local storage for a hindi chapter
      final bogusMathAct = Activity(
        activityId: 'math_proc_bogus',
        topicId: 'math_numbers',
        subjectId: 'math',
        targetGrade: 'LKG',
        gradeTier: GradeTier.earlyExplorer,
        activityType: ActivityType.bubblePop,
        promptData: const PromptData(text: 'Pop all bubbles that equal 5!'),
        interactionPayload: const {},
        validationRule: const ValidationRule(format: 'exact', expectedAnswer: '5'),
      );
      LocalStorageService.instance.saveChapterActivities('hin_lkg_ch01', [bogusMathAct]);

      // Loading chapters should detect the contamination and purge it
      final repo = CurriculumRepository.instance;
      final chapters = await repo.getChaptersForClass(StudentClass.lkg, subjectId: 'hindi');
      final ch1 = chapters.firstWhere((c) => c.chapterId == 'hin_lkg_ch01');

      for (final act in ch1.activities) {
        expect(act.promptData.text.contains('equal 5'), isFalse);
        expect(act.subjectId, equals('hindi'));
      }
    });
  });

  group('Chapter Detail Screen & Auto-Next Question Flow Tests', () {
    testWidgets('ChapterDetailScreen has NO Generate More Questions button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final chapter = Chapter(
        chapterId: 'test_sci_01',
        chapterNumber: 1,
        title: 'Parts of Plants',
        grade: 'Class 3',
        subjectId: 'science',
        icon: '🌿',
        keyConcepts: ['Roots', 'Leaves'],
        activities: [
          Activity(
            activityId: 'sci_q1',
            topicId: 'plants',
            subjectId: 'science',
            targetGrade: 'Class 3',
            gradeTier: GradeTier.primaryBuilder,
            activityType: ActivityType.mcq,
            promptData: const PromptData(text: 'Which part of the plant absorbs water?'),
            interactionPayload: const {
              'options': ['Roots 🌿', 'Flower 🌸', 'Stem 🪵'],
              'explanation': 'Roots absorb water and nutrients from the soil.',
            },
            validationRule: const ValidationRule(format: 'exact', expectedAnswer: 'Roots 🌿'),
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

      await tester.pumpAndSettle();

      // "Generate More Questions" button is GONE!
      expect(find.text('Generate More Questions'), findsNothing);
      expect(find.text('+ Generate More Questions'), findsNothing);

      // Only clean Chapter Practice / Exam button exists
      expect(find.text('Take Exam 📝'), findsOneWidget);
    });

    testWidgets('ConceptChallengeScreen automatically adds next question when answering at the end', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final initialActivity = Activity(
        activityId: 'act_init_1',
        topicId: 'plants',
        subjectId: 'science',
        targetGrade: 'Class 3',
        gradeTier: GradeTier.primaryBuilder,
        activityType: ActivityType.mcq,
        promptData: const PromptData(text: 'Which part absorbs water?'),
        interactionPayload: const {
          'options': ['Roots', 'Leaves'],
          'explanation': 'Roots absorb water.',
        },
        validationRule: const ValidationRule(format: 'exact', expectedAnswer: 'Roots'),
      );

      final chapter = Chapter(
        chapterId: 'sci_c3_ch01',
        chapterNumber: 1,
        title: 'Parts of Plants',
        grade: 'Class 3',
        subjectId: 'science',
        icon: '🌱',
        keyConcepts: ['Roots absorb water', 'Leaves do photosynthesis'],
        rules: ['Roots hold the plant in the soil.'],
        exampleQuestion: 'What anchors the plant to the ground?',
        exampleAnswer: 'Roots',
        activities: [initialActivity],
      );

      List<Activity> updatedActivities = [];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ConceptChallengeScreen(
              activity: initialActivity,
              chapter: chapter,
              studentClass: StudentClass.class3,
              onActivitiesUpdated: (list) {
                updatedActivities = list;
              },
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap an answer option
      await tester.tap(find.text('Leaves'));
      await tester.pump();

      // After attempting, the question list should automatically grow with an authentic science question!
      expect(updatedActivities.length, greaterThan(1));
      expect(updatedActivities.last.subjectId, equals('science'));
    });
  });

  group('Exam Mode Quality & Place Value Isolation Tests', () {
    test('Class 2 ICSE Place Value distractors are authentic and free from broken patterns like 712 ( tens)', () {
      final chapter = Chapter(
        chapterId: 'icse_class2_ch01',
        chapterNumber: 1,
        title: '3-Digit Numbers up to 999',
        grade: 'Class 2',
        board: 'icse',
        icon: '🔢',
        exampleQuestion: 'In the number 675, what is the PLACE VALUE of the digit 7?',
        exampleAnswer: '70 (7 tens)',
        keyConcepts: ['Hundreds, Tens, Ones (H T O)', 'Place Value vs Face Value'],
      );

      final activities = ProceduralQuestionGenerator.instance.generateActivitiesForChapter(
        chapter,
        StudentClass.class2,
        count: 5,
      );

      expect(activities, isNotEmpty);
      for (final act in activities) {
        final options = (act.interactionPayload['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
        for (final opt in options) {
          // Never contain broken digits-only patterns like "712 ( tens)"
          expect(opt.contains('( tens)'), isFalse, reason: 'Broken unit distractor: $opt');
          expect(opt.contains('712'), isFalse, reason: 'Concatenated 70 and 7 into 707+5: $opt');
          expect(opt.contains('705'), isFalse, reason: 'Concatenated 70 and 7 into 707-2: $opt');
        }
      }
    });

    test('Class 1 chapters strictly contain Class 1 and never leak Class 2 or Class 10', () async {
      final repo = CurriculumRepository.instance;
      final chapters = await repo.getChaptersForClass(
        StudentClass.class1,
        board: BoardType.icse,
        subjectId: 'math',
      );

      expect(chapters, isNotEmpty);
      for (final ch in chapters) {
        expect(ch.grade, equals('Class 1'), reason: 'Chapter ${ch.chapterId} (${ch.title}) has grade ${ch.grade}');
        expect(ch.title.contains('3-Digit Numbers'), isFalse);
      }
    });

    testWidgets('LKG activities in TimedExamScreen convert Pop commands into questions and extract real bubble options', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final lkgChapter = Chapter(
        chapterId: 'lkg_math_ch01',
        chapterNumber: 1,
        title: 'Shapes & Colors',
        grade: 'LKG',
        subjectId: 'math',
        icon: '🎨',
        activities: [
          Activity(
            activityId: 'act_bubble_shape',
            topicId: 'shapes',
            subjectId: 'math',
            targetGrade: 'LKG',
            gradeTier: GradeTier.earlyExplorer,
            activityType: ActivityType.bubblePop,
            promptData: const PromptData(text: 'Pop all the Circle ⭕ bubbles!'),
            interactionPayload: const {
              'targetValue': 'circle',
              'bubbles': [
                {'label': 'Circle ⭕', 'value': 'circle', 'isTarget': true},
                {'label': 'Square 🟦', 'value': 'square', 'isTarget': false},
                {'label': 'Triangle 🔺', 'value': 'triangle', 'isTarget': false},
              ],
            },
            validationRule: const ValidationRule(format: 'bubble_pop', expectedAnswer: 'circle'),
          ),
        ],
      );

      await LocalStorageService.instance.saveStudentProfile(
        const StudentProfile(studentName: 'Aahan', studentClass: StudentClass.lkg, board: BoardType.icse),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TimedExamScreen(
              chapter: lkgChapter,
              subjectId: 'math',
              subjectName: 'Mathematics',
              primaryColor: Colors.deepOrange,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Prompt on exam screen must NEVER say "Pop"
      expect(find.textContaining('Pop all the Circle'), findsNothing);
      expect(find.textContaining('Pop'), findsNothing);
      expect(find.textContaining('Which of these is Circle ⭕?'), findsOneWidget);

      // 2. Real options from bubbles must be extracted (zero dummy "Option B")
      expect(find.text('Circle ⭕'), findsOneWidget);
      expect(find.text('Square 🟦'), findsOneWidget);
      expect(find.text('Triangle 🔺'), findsOneWidget);
      expect(find.text('Option B'), findsNothing);
      expect(find.text('Option C'), findsNothing);

      // 3. Subtitle should be kindergarten-friendly
      expect(find.text('Fun Practice Quiz 🎒🌟'), findsOneWidget);
    });
  });
}
