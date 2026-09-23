import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/activity_model.dart';
import 'package:curio_math/data/models/chapter_model.dart';
import 'package:curio_math/data/models/grade_tier.dart';
import 'package:curio_math/data/models/student_attempt_model.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/services/procedural_question_generator.dart';
import 'package:curio_math/core/theme/grade_tier_extension.dart';

void main() {
  group('Curio Academy Universal Schema & Curriculum Tests', () {
    test('Correctly parses math_sample.json activities across all 10 grades', () {
      final file = File('assets/curriculum/math_sample.json');
      expect(file.existsSync(), isTrue);

      final jsonContent = file.readAsStringSync();
      final dynamic list = json.decode(jsonContent);
      expect(list, isA<List>());

      final activities = (list as List)
          .map((item) => Activity.fromJson(item as Map<String, dynamic>))
          .toList();

      expect(activities.length, greaterThanOrEqualTo(10));

      // Verify specific grade activities exist
      expect(activities.any((a) => a.targetGrade == 'LKG'), isTrue);
      expect(activities.any((a) => a.targetGrade == 'UKG'), isTrue);
      expect(activities.any((a) => a.targetGrade == 'Class 1'), isTrue);
      expect(activities.any((a) => a.targetGrade == 'Class 4'), isTrue);
      expect(activities.any((a) => a.targetGrade == 'Class 7'), isTrue);
      expect(activities.any((a) => a.targetGrade == 'Class 8'), isTrue);
    });

    test('Correctly parses chapters_data.json across all 10 grades with pedagogical concept notes', () {
      final file = File('assets/curriculum/chapters_data.json');
      expect(file.existsSync(), isTrue);

      final jsonContent = file.readAsStringSync();
      final dynamic list = json.decode(jsonContent);
      expect(list, isA<List>());

      final chapters = (list as List)
          .map((item) => Chapter.fromJson(item as Map<String, dynamic>))
          .toList();

      expect(chapters.length, greaterThanOrEqualTo(25));

      // Verify all 10 grades have chapters
      final grades = chapters.map((c) => c.grade).toSet();
      expect(grades.contains('LKG'), isTrue);
      expect(grades.contains('UKG'), isTrue);
      expect(grades.contains('Class 1'), isTrue);
      expect(grades.contains('Class 2'), isTrue);
      expect(grades.contains('Class 3'), isTrue);
      expect(grades.contains('Class 4'), isTrue);
      expect(grades.contains('Class 5'), isTrue);
      expect(grades.contains('Class 6'), isTrue);
      expect(grades.contains('Class 7'), isTrue);
      expect(grades.contains('Class 8'), isTrue);

      // Verify rich concept data is present
      final tickTick = chapters.firstWhere((c) => c.title == 'Tick-Tick-Tick');
      expect(tickTick.keyConcepts, isNotEmpty);
      expect(tickTick.rules, isNotEmpty);
      expect(tickTick.exampleQuestion, isNotNull);
      expect(tickTick.exampleAnswer, isNotNull);
      expect(tickTick.funFact, isNotNull);
    });

    test('ProceduralQuestionGenerator generates valid activities on-the-fly across curriculum domains', () {
      final gen = ProceduralQuestionGenerator.instance;

      // 1. Generate Class 7 Linear Equation
      final eq = gen.generateLinearEquation(targetGrade: 'Class 7');
      expect(eq.activityType, equals(ActivityType.gridCalc));
      expect(eq.targetGrade, equals('Class 7'));
      expect(eq.interactionPayload.containsKey('equation'), isTrue);
      expect(eq.interactionPayload.containsKey('xRoot'), isTrue);

      // 2. Generate Class 7 Integers
      final intAct = gen.generateIntegerProblem(targetGrade: 'Class 7');
      expect(intAct.activityType, equals(ActivityType.mcq));
      expect(intAct.targetGrade, equals('Class 7'));

      // 3. Generate Class 7 Exponents
      final expAct = gen.generateExponentProblem(targetGrade: 'Class 7');
      expect(expAct.activityType, equals(ActivityType.mcq));

      // 4. Generate Class 8 Square Root
      final sqrtAct = gen.generateSquareRootProblem(targetGrade: 'Class 8');
      expect(sqrtAct.activityType, equals(ActivityType.mcq));

      // 5. Generate Class 4 Fractions
      final frac = gen.generateEquivalentFractions(targetGrade: 'Class 4');
      expect(frac.activityType, equals(ActivityType.dragDrop));
      expect(frac.targetGrade, equals('Class 4'));

      // 6. Generate LKG Bubble Pop
      final bubble = gen.generateBubblePopCounting(targetGrade: 'LKG');
      expect(bubble.activityType, equals(ActivityType.bubblePop));
      expect(bubble.targetGrade, equals('LKG'));

      // 7. Generate batch playlist for Class 8
      final playlist = gen.generatePlaylistForClass(StudentClass.class8, count: 5);
      expect(playlist.length, equals(5));
      expect(playlist.every((a) => a.targetGrade == 'Class 8'), isTrue);
    });

    test('StudentProfile model correctly maps Classes to GradeTiers', () {
      const p1 = StudentProfile(board: BoardType.cbse, studentClass: StudentClass.lkg);
      expect(p1.tier, equals(GradeTier.earlyExplorer));

      const p2 = StudentProfile(board: BoardType.icse, studentClass: StudentClass.class4);
      expect(p2.tier, equals(GradeTier.primaryBuilder));

      const p3 = StudentProfile(board: BoardType.cbse, studentClass: StudentClass.class7);
      expect(p3.tier, equals(GradeTier.middleAchiever));
    });

    test('GradeTier ThemeExtension accurately scales touch bounds & paddings', () {
      final t1Theme = CurioTierTheme.earlyExplorer();
      expect(t1Theme.minTouchTarget.width, greaterThanOrEqualTo(64.0));
      expect(t1Theme.minTouchTarget.height, greaterThanOrEqualTo(64.0));
      expect(t1Theme.autoPlayVoicePrompts, isTrue);

      final t2Theme = CurioTierTheme.primaryBuilder();
      expect(t2Theme.minTouchTarget.width, equals(52.0));
      expect(t2Theme.enableScratchpad, isTrue);

      final t3Theme = CurioTierTheme.middleAchiever();
      expect(t3Theme.minTouchTarget.width, equals(44.0));
      expect(t3Theme.showStreakTimer, isTrue);
    });

    test('ProceduralQuestionGenerator generates authentic chapter-specific questions with zero duplicates', () {
      final gen = ProceduralQuestionGenerator.instance;

      // 1. Shapes & Space (Class 1) must generate shapes & spatial questions, NEVER bubble pop counting!
      final shapesCh = Chapter(
        chapterId: 'class1_ch01',
        chapterNumber: 1,
        title: 'Shapes and Space',
        grade: 'Class 1',
        icon: '🟡',
        keyConcepts: ['Circle, Square, Triangle', 'Inside vs Outside', 'Top vs Bottom', 'Rolling vs Sliding'],
        rules: ['A triangle has 3 sides and 3 corners', 'Round objects roll smoothly'],
      );

      final shapesActs = gen.generateActivitiesForChapter(
        shapesCh,
        StudentClass.class1,
        count: 5,
      );

      expect(shapesActs.length, equals(5));
      // None should be bubble pop counting
      expect(shapesActs.any((a) => a.activityType == ActivityType.bubblePop), isFalse);
      // All 5 must have unique prompts
      final promptSet = shapesActs.map((a) => a.promptData.text).toSet();
      expect(promptSet.length, equals(5));
      // All activities must be tagged with Shapes and Space chapterId and title
      expect(shapesActs.every((a) => a.chapterId == 'class1_ch01'), isTrue);
      expect(shapesActs.every((a) => a.chapterName == 'Shapes and Space'), isTrue);

      // 2. Add 3 more questions with existing prompts passed - must have 0 collisions
      final moreShapesActs = gen.generateActivitiesForChapter(
        shapesCh,
        StudentClass.class1,
        count: 3,
        existingPromptTexts: promptSet,
      );
      expect(moreShapesActs.length, equals(3));
      for (final a in moreShapesActs) {
        expect(promptSet.contains(a.promptData.text), isFalse);
      }

      // 3. Class 4 Chapters must generate authentic domain questions (Building with Bricks, Long and Short, Play with Patterns, etc.)
      final bricksCh = Chapter(
        chapterId: 'class4_ch01',
        chapterNumber: 1,
        title: 'Building with Bricks',
        grade: 'Class 4',
        icon: '🧱',
      );
      final bricksActs = gen.generateActivitiesForChapter(bricksCh, StudentClass.class4, count: 3);
      expect(bricksActs.every((a) => a.promptData.text.toLowerCase().contains('brick') || a.promptData.text.toLowerCase().contains('wall') || a.promptData.text.toLowerCase().contains('jaali') || a.promptData.text.toLowerCase().contains('arch') || a.promptData.text.toLowerCase().contains('kiln')), isTrue);
      // None should be generic place value
      expect(bricksActs.any((a) => a.promptData.text.toLowerCase().contains('how many tens')), isFalse);

      final patternsCh = Chapter(
        chapterId: 'class4_ch10',
        chapterNumber: 10,
        title: 'Play with Patterns',
        grade: 'Class 4',
        icon: '🎨',
      );
      final patternsActs = gen.generateActivitiesForChapter(patternsCh, StudentClass.class4, count: 3);
      expect(patternsActs.every((a) => a.promptData.text.toLowerCase().contains('pattern') || a.promptData.text.toLowerCase().contains('arrow') || a.promptData.text.toLowerCase().contains('turn') || a.promptData.text.toLowerCase().contains('sequence') || a.promptData.text.toLowerCase().contains('code')), isTrue);
    });

    test('StudentQuestionAttempt serializes and deserializes accurately', () {
      final now = DateTime.now();
      final attempt = StudentQuestionAttempt(
        activityId: 'act_test_01',
        chapterId: 'ch_test',
        selectedOptionIndex: 1,
        selectedOptionText: '6 faces',
        isCorrect: true,
        starsEarned: 25,
        timestamp: now,
      );

      final json = attempt.toJson();
      expect(json['activityId'], equals('act_test_01'));
      expect(json['selectedOptionIndex'], equals(1));
      expect(json['isCorrect'], isTrue);

      final parsed = StudentQuestionAttempt.fromJson(json);
      expect(parsed.activityId, equals(attempt.activityId));
      expect(parsed.selectedOptionText, equals('6 faces'));
      expect(parsed.isCorrect, isTrue);
      expect(parsed.starsEarned, equals(25));
    });

    test('LocalStorageService persists activities and computes next question index correctly', () async {
      final storage = LocalStorageService.instance;
      final chId = 'class4_ch_shapes';

      const act1 = Activity(
        activityId: 'shape_q1',
        topicId: 'shapes',
        subjectId: 'math',
        targetGrade: 'Class 4',
        gradeTier: GradeTier.primaryBuilder,
        activityType: ActivityType.mcq,
        promptData: PromptData(text: 'Q1'),
        interactionPayload: {},
        validationRule: ValidationRule(format: 'exact', expectedAnswer: 'A'),
      );
      const act2 = Activity(
        activityId: 'shape_q2',
        topicId: 'shapes',
        subjectId: 'math',
        targetGrade: 'Class 4',
        gradeTier: GradeTier.primaryBuilder,
        activityType: ActivityType.mcq,
        promptData: PromptData(text: 'Q2'),
        interactionPayload: {},
        validationRule: ValidationRule(format: 'exact', expectedAnswer: 'B'),
      );
      const act3 = Activity(
        activityId: 'shape_q3',
        topicId: 'shapes',
        subjectId: 'math',
        targetGrade: 'Class 4',
        gradeTier: GradeTier.primaryBuilder,
        activityType: ActivityType.mcq,
        promptData: PromptData(text: 'Q3'),
        interactionPayload: {},
        validationRule: ValidationRule(format: 'exact', expectedAnswer: 'C'),
      );

      final list = [act1, act2, act3];

      // 1. Save chapter activities
      await storage.saveChapterActivities(chId, list);
      final retrieved = storage.getChapterActivities(chId);
      expect(retrieved, isNotNull);
      expect(retrieved!.length, equals(3));
      expect(retrieved.first.activityId, equals('shape_q1'));

      // 2. Initially with zero attempts, next question index is 0
      expect(storage.getNextQuestionIndexForChapter(chId, list), equals(0));

      // 3. Attempt Q1 (index 0) -> next question index should be 1
      await storage.saveQuestionAttempt(StudentQuestionAttempt(
        activityId: 'shape_q1',
        chapterId: chId,
        selectedOptionIndex: 0,
        selectedOptionText: 'A',
        isCorrect: true,
        starsEarned: 10,
        timestamp: DateTime.now(),
      ));
      expect(storage.getNextQuestionIndexForChapter(chId, list), equals(1));

      // 4. Attempt Q2 (index 1) -> next question index should be 2
      await storage.saveQuestionAttempt(StudentQuestionAttempt(
        activityId: 'shape_q2',
        chapterId: chId,
        selectedOptionIndex: 1,
        selectedOptionText: 'B',
        isCorrect: true,
        starsEarned: 10,
        timestamp: DateTime.now(),
      ));
      expect(storage.getNextQuestionIndexForChapter(chId, list), equals(2));

      // 5. Check retrieval of attempt
      final attempt1 = storage.getQuestionAttempt('shape_q1');
      expect(attempt1, isNotNull);
      expect(attempt1!.selectedOptionText, equals('A'));
      expect(attempt1.isCorrect, isTrue);

      // 6. Test retry (clearing/overwriting attempt)
      await storage.clearQuestionAttempt('shape_q1');
      expect(storage.getQuestionAttempt('shape_q1'), isNull);
    });

    test('Differentiates CBSE and ICSE chapters across classes and validates Class 8 questions', () {
      final file = File('assets/curriculum/chapters_data.json');
      final dynamic list = json.decode(file.readAsStringSync());
      final allChapters = (list as List)
          .map((item) => Chapter.fromJson(item as Map<String, dynamic>))
          .toList();

      // 1. Verify CBSE Class 4 has 14 chapters starting with Building with Bricks
      final cbseClass4 = allChapters.where((c) => c.grade == 'Class 4' && c.board == 'cbse').toList();
      expect(cbseClass4.length, equals(14));
      expect(cbseClass4.first.title, equals('Building with Bricks'));

      // 2. Verify ICSE Class 4 has 13 chapters starting with Large Numbers & Place Value
      final icseClass4 = allChapters.where((c) => c.grade == 'Class 4' && c.board == 'icse').toList();
      expect(icseClass4.length, equals(13));
      expect(icseClass4.first.title, equals('Large Numbers & Place Value'));

      // 3. Verify CBSE Class 8 has Introduction to Graphs with valid data
      final graphsChapter = allChapters.firstWhere(
        (c) => c.grade == 'Class 8' && c.board == 'cbse' && c.title == 'Introduction to Graphs',
      );
      expect(graphsChapter.rules.isNotEmpty, isTrue);
      expect(graphsChapter.rules.any((r) => r.contains('Origin')), isTrue);
      expect(graphsChapter.exampleQuestion, isNotNull);
      expect(graphsChapter.exampleQuestion!.contains('problem:'), isFalse);
      expect(graphsChapter.exampleAnswer, isNotNull);
      expect(graphsChapter.exampleAnswer, isNot(equals('Correct!')));

      // 4. Verify ProceduralQuestionGenerator on Class 8 Introduction to Graphs
      final activities = ProceduralQuestionGenerator.instance.generateActivitiesForChapter(
        graphsChapter,
        StudentClass.class8,
        count: 3,
      );
      expect(activities.length, equals(3));
      for (final act in activities) {
        expect(act.promptData.text.contains('problem:'), isFalse);
        expect(act.validationRule.expectedAnswer, isNot(equals('Correct!')));
        // Ensure no Class 4 bleed into Class 8
        expect(act.promptData.text.toLowerCase().contains('bhopal'), isFalse);
        expect(act.promptData.text.toLowerCase().contains('brick'), isFalse);
        expect(act.promptData.text.toLowerCase().contains('fencing'), isFalse);
      }
    });
  });
}
