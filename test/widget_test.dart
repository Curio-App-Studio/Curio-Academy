import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curio_math/app.dart';
import 'package:curio_math/core/theme/app_theme.dart';
import 'package:curio_math/data/models/activity_model.dart';
import 'package:curio_math/data/models/chapter_model.dart';
import 'package:curio_math/data/models/grade_tier.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/services/english_question_generator.dart';
import 'package:curio_math/data/services/procedural_question_generator.dart';
import 'package:curio_math/features/activities/bubble_pop/presentation/bubble_pop_screen.dart';
import 'package:curio_math/features/activities/concept_quiz/presentation/concept_challenge_screen.dart';

void main() {
  testWidgets('CurioApp mounts and renders splash screen and brand heading', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CurioApp(),
      ),
    );

    await tester.pump();
    expect(find.textContaining('Curio Academy'), findsWidgets);
    expect(find.textContaining('SPARK YOUR POTENTIAL'), findsOneWidget);

    // Advance past splash transition
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(CurioApp), findsOneWidget);
  });

  testWidgets('BubblePopScreen mounts and renders interactive playfield', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.buildTheme(GradeTier.earlyExplorer),
          home: const BubblePopScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(find.textContaining('Pop all bubbles'), findsOneWidget);
    expect(find.byType(BubblePopScreen), findsOneWidget);
  });

  testWidgets('BubblePopScreen mounts and renders custom English chapter activity with bubbles and audio prompt', (WidgetTester tester) async {
    final chapter = Chapter(
      chapterId: 'eng_lkg_ch05',
      chapterNumber: 5,
      title: 'Opposites & Daily Words',
      grade: 'LKG',
      icon: '🌓',
      keyConcepts: ['Up vs Down', 'Big vs Small'],
      rules: ['Opposites are reversed word pairs'],
    );

    final act = EnglishQuestionGenerator.instance.generateSingleQuestion(
      chapter,
      StudentClass.lkg,
      questionIndex: 1,
    );

    expect(act.activityType, equals(ActivityType.bubblePop));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.buildTheme(GradeTier.earlyExplorer),
          home: BubblePopScreen(activity: act),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(BubblePopScreen), findsOneWidget);
    expect(find.textContaining('Pop the opposite'), findsOneWidget);
  });

  testWidgets('ConceptChallengeScreen automatically adds new question on Next after giving 2 answers', (WidgetTester tester) async {
    final chapter = Chapter(
      chapterId: 'class1_ch01',
      chapterNumber: 1,
      title: 'Shapes and Space',
      grade: 'Class 1',
      icon: '🟡',
      keyConcepts: ['Circle, Square, Triangle', 'Top vs Bottom'],
      rules: ['A circle has 0 corners'],
    );

    final initialActs = ProceduralQuestionGenerator.instance.generateActivitiesForChapter(
      chapter,
      StudentClass.class1,
      count: 2,
    );
    expect(initialActs.length, equals(2));

    List<Activity> reportedActivities = List.from(initialActs);

    await tester.pumpWidget(
      MaterialApp(
        home: ConceptChallengeScreen(
          chapter: chapter,
          activities: initialActs,
          initialIndex: 0,
          studentClass: StudentClass.class1,
          onActivitiesUpdated: (updated) {
            reportedActivities = updated;
          },
        ),
      ),
    );

    await tester.pump();
    // Initially shows Question 1 of 2
    expect(find.text('Question 1 of 2'), findsOneWidget);

    // 1. Answer Question 1
    final q1Options = (initialActs[0].interactionPayload['options'] as List);
    await tester.tap(find.text(q1Options.first.toString()));
    await tester.pump();

    // Next question button should appear
    final nextBtnFinder = find.textContaining('Next Question');
    expect(nextBtnFinder, findsOneWidget);
    await tester.ensureVisible(nextBtnFinder);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(nextBtnFinder);
    await tester.pump(const Duration(milliseconds: 300));

    // Now on Question 2 of 2
    expect(find.text('Question 2 of 2'), findsOneWidget);

    // 2. Answer Question 2 (2 answers given!)
    final q2Options = (reportedActivities[1].interactionPayload['options'] as List);
    await tester.tap(find.text(q2Options.first.toString()));
    await tester.pump(const Duration(milliseconds: 100));

    // Next question button should indicate auto-generation
    final nextBtn2Finder = find.textContaining('Next Question');
    expect(nextBtn2Finder, findsOneWidget);
    await tester.ensureVisible(nextBtn2Finder);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(nextBtn2Finder);
    await tester.pump(const Duration(milliseconds: 500));

    // 3. Question 3 of 3 is automatically generated and added!
    expect(find.text('Question 3 of 3'), findsOneWidget);
    expect(reportedActivities.length, equals(3));
  });

  testWidgets('ConceptChallengeScreen renders and toggles Speaker Mute button', (WidgetTester tester) async {
    final chapter = Chapter(
      chapterId: 'test_ch',
      chapterNumber: 1,
      title: 'Alphabet Phonics',
      grade: 'LKG',
      icon: '🔤',
      subjectId: 'english',
    );

    final acts = [
      Activity(
        activityId: 'test_act_1',
        topicId: 'test_ch',
        subjectId: 'english',
        targetGrade: 'LKG',
        gradeTier: GradeTier.earlyExplorer,
        activityType: ActivityType.mcq,
        promptData: const PromptData(text: 'Which letter comes first?'),
        interactionPayload: const {
          'options': ['A', 'B', 'C'],
          'expectedAnswer': 'A',
        },
        validationRule: const ValidationRule(
          format: 'exact',
          expectedAnswer: 'A',
        ),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ConceptChallengeScreen(
          chapter: chapter,
          activities: acts,
        ),
      ),
    );

    await tester.pump();

    // Verify Mute Speaker button is rendered in AppBar
    final muteBtnFinder = find.byTooltip('Mute Speaker');
    expect(muteBtnFinder, findsOneWidget);

    // Tap mute button
    await tester.tap(muteBtnFinder);
    await tester.pump();

    // Now tooltip should update to 'Unmute Speaker'
    expect(find.byTooltip('Unmute Speaker'), findsOneWidget);
  });
}
