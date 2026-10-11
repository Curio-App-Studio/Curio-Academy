import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/models/chapter_model.dart';
import 'package:curio_math/data/models/student_attempt_model.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/features/arcade/domain/arcade_question_engine.dart';
import 'package:curio_math/features/arcade/presentation/speed_math_arcade_screen.dart';
import 'package:curio_math/features/arcade/presentation/split_screen_duel_screen.dart';
import 'package:curio_math/features/adventure_map/presentation/adventure_island_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ArcadeQuestionEngine Tests', () {
    final engine = ArcadeQuestionEngine();

    test('generates valid early explorer questions with 4 unique options', () {
      for (int i = 0; i < 20; i++) {
        final q = engine.generateQuestion(StudentClass.class1);
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), isTrue);
        expect(q.options.toSet().length, 4); // All 4 options are distinct
      }
    });

    test('generates valid primary builder questions (Tables & Division)', () {
      for (int i = 0; i < 20; i++) {
        final q = engine.generateQuestion(StudentClass.class4);
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), isTrue);
        expect(q.options.toSet().length, 4);
      }
    });

    test('generates valid middle achiever questions (Squares, Integers, %)', () {
      for (int i = 0; i < 20; i++) {
        final q = engine.generateQuestion(StudentClass.class7);
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), isTrue);
        expect(q.options.toSet().length, 4);
      }
    });

    test('generateQuestion with excludedPrompts never returns an excluded question prompt', () {
      final usedPrompts = <String>{};
      for (int i = 0; i < 25; i++) {
        final q = engine.generateQuestion(StudentClass.class4, excludedPrompts: usedPrompts);
        expect(usedPrompts.contains(q.displayPrompt), isFalse,
            reason: 'Math question prompt ${q.displayPrompt} should not repeat in same sprint');
        usedPrompts.add(q.displayPrompt);
      }
      expect(usedPrompts.length, equals(25));
    });
  });

  group('LocalStorageService Speed Math & Chest Tests', () {
    test('updateSpeedMathHighScore records high scores accurately', () async {
      final storage = LocalStorageService.instance;
      final initial = storage.speedMathHighScore;

      final isNewRecord = await storage.updateSpeedMathHighScore(initial + 50);
      expect(isNewRecord, isTrue);
      expect(storage.speedMathHighScore, initial + 50);

      final notRecord = await storage.updateSpeedMathHighScore(initial + 10);
      expect(notRecord, isFalse);
    });

    test('claimChest tracks chest milestones', () async {
      final storage = LocalStorageService.instance;
      expect(storage.isChestClaimed('test_chest_99'), isFalse);
      await storage.claimChest('test_chest_99');
      expect(storage.isChestClaimed('test_chest_99'), isTrue);
    });

    test('Chapter is completed only after giving 5 answers or taking a test', () async {
      final storage = LocalStorageService.instance;
      const chapterId = 'test_req_ch_5';

      // Initially not completed
      expect(storage.isChapterCompleted(chapterId), isFalse);

      // Give 4 answers -> still not completed
      for (int i = 1; i <= 4; i++) {
        await storage.saveQuestionAttempt(
          StudentQuestionAttempt(
            activityId: 'test_act_$i',
            chapterId: chapterId,
            selectedOptionIndex: 0,
            selectedOptionText: 'Ans $i',
            isCorrect: true,
            starsEarned: 1,
            timestamp: DateTime.now(),
          ),
        );
      }
      expect(storage.getChapterAnswerCount(chapterId), 4);
      expect(storage.isChapterCompleted(chapterId), isFalse);

      // Give 5th answer -> now completed!
      await storage.saveQuestionAttempt(
        StudentQuestionAttempt(
          activityId: 'test_act_5',
          chapterId: chapterId,
          selectedOptionIndex: 0,
          selectedOptionText: 'Ans 5',
          isCorrect: true,
          starsEarned: 1,
          timestamp: DateTime.now(),
        ),
      );
      expect(storage.getChapterAnswerCount(chapterId), 5);
      expect(storage.isChapterCompleted(chapterId), isTrue);

      // Directly marking complete (e.g. from taking a unit test) marks complete immediately
      const testExamChapterId = 'test_exam_ch_1';
      expect(storage.isChapterCompleted(testExamChapterId), isFalse);
      await storage.markChapterCompleted(testExamChapterId);
      expect(storage.isChapterCompleted(testExamChapterId), isTrue);
    });
  });

  group('Arcade & Adventure Island Widget Tests', () {
    testWidgets('SpeedMathArcadeScreen renders HUD, timer, and 4 option buttons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SpeedMathArcadeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TIME LEFT'), findsOneWidget);
      expect(find.text('SCORE'), findsOneWidget);
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('SplitScreenDuelScreen renders Player 1 (inverted) and Player 2', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplitScreenDuelScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Player 2'), findsOneWidget);
      expect(find.textContaining('FIRST TO 5'), findsOneWidget);
    });

    testWidgets('AdventureIslandScreen renders chapter nodes and progress header', (tester) async {
      final dummyChapters = [
        Chapter(
          chapterId: 'test_ch_1',
          chapterNumber: 1,
          title: 'Numbers to 100',
          grade: 'Class 4',
          icon: '🔢',
        ),
        Chapter(
          chapterId: 'test_ch_2',
          chapterNumber: 2,
          title: 'Addition Adventures',
          grade: 'Class 4',
          icon: '➕',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AdventureIslandScreen(
              chapters: dummyChapters,
              subjectId: 'math',
              subjectName: 'Mathematics',
              emoji: '🔢',
              primaryColor: const Color(0xFF10B981),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mathematics Island Map'), findsOneWidget);
      expect(find.text('Numbers to 100'), findsOneWidget);
      expect(find.text('Addition Adventures'), findsOneWidget);
    });

    testWidgets('Treasure chest after Chapter 4 is LOCKED if Chapter 4 is not completed', (tester) async {
      final dummyChapters = List.generate(
        4,
        (i) => Chapter(
          chapterId: 'uncompleted_ch_${i + 1}',
          chapterNumber: i + 1,
          title: 'Chapter ${i + 1}',
          grade: 'Class 4',
          icon: '📚',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AdventureIslandScreen(
              chapters: dummyChapters,
              subjectId: 'math_chest_test',
              subjectName: 'Mathematics',
              emoji: '🔢',
              primaryColor: const Color(0xFF10B981),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Chest should be rendered and show Locked Chest
      expect(find.text('Locked Chest'), findsOneWidget);

      // Tapping the locked chest should show locked snackbar and NOT unlock
      await tester.ensureVisible(find.text('Locked Chest'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Locked Chest'));
      await tester.pump();

      expect(find.textContaining('Treasure locked! Complete Chapter 4 first'), findsOneWidget);
      expect(LocalStorageService.instance.isChestClaimed('chest_math_chest_test_4'), isFalse);
    });
  });
}
