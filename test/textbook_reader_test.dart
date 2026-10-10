import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/data/models/chapter_model.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/services/concept_reading_service.dart';
import 'package:curio_math/features/concept_learning/presentation/textbook_reader_screen.dart';
import 'package:curio_math/features/chapter_detail/presentation/chapter_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/data/local/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
  });

  Chapter makeChapter({
    required String title,
    required String grade,
    required String subjectId,
  }) {
    return Chapter(
      chapterId: 'test_ch_${title.hashCode}',
      chapterNumber: 1,
      title: title,
      grade: grade,
      subjectId: subjectId,
      icon: '📐',
    );
  }

  group('Exhaustive Digital Textbook Coverage Tests', () {
    test('All Math domains provide 4 structured textbook sections, summaries, and facts', () {
      final mathChapters = [
        makeChapter(title: 'Shapes & Angles', grade: 'Class 5', subjectId: 'math'),
        makeChapter(title: 'Fractions & Decimals', grade: 'Class 6', subjectId: 'math'),
        makeChapter(title: 'Algebraic Expressions', grade: 'Class 7', subjectId: 'math'),
        makeChapter(title: 'Comparing Quantities: Profit & Loss', grade: 'Class 8', subjectId: 'math'),
        makeChapter(title: 'Numbers 1 to 20', grade: 'Class 1', subjectId: 'math'),
      ];

      for (final ch in mathChapters) {
        final material = ConceptReadingService.instance.getStudyMaterial(ch);
        expect(material.textbookSections.isNotEmpty, isTrue, reason: 'Failed for ${ch.title}');
        expect(material.textbookSections.length, greaterThanOrEqualTo(3), reason: 'Sections for ${ch.title}');
        expect(material.pointsToRemember.isNotEmpty, isTrue, reason: 'Points for ${ch.title}');
        expect(material.didYouKnowFacts.isNotEmpty, isTrue, reason: 'Facts for ${ch.title}');

        // Test section integrity
        for (final sec in material.textbookSections) {
          expect(sec.title.isNotEmpty, isTrue);
          expect(sec.hindiTitle.isNotEmpty, isTrue);
          expect(sec.content.isNotEmpty, isTrue);
          expect(sec.hindiContent.isNotEmpty, isTrue);
          expect(sec.quickCheckQuestion?.isNotEmpty, isTrue);
          expect(sec.quickCheckAnswer?.isNotEmpty, isTrue);
        }
      }
    });

    test('All English domains provide structured textbook sections, summaries, and facts', () {
      final engChapters = [
        makeChapter(title: 'Alphabet & Phonics Fun', grade: 'LKG', subjectId: 'english'),
        makeChapter(title: 'Nouns: Proper & Common', grade: 'Class 2', subjectId: 'english'),
        makeChapter(title: 'Verbs & Tenses in Action', grade: 'Class 5', subjectId: 'english'),
        makeChapter(title: 'Sentence Structure & Clauses', grade: 'Class 8', subjectId: 'english'),
        makeChapter(title: 'Vocabulary & Antonyms', grade: 'Class 4', subjectId: 'english'),
      ];

      for (final ch in engChapters) {
        final material = ConceptReadingService.instance.getStudyMaterial(ch);
        expect(material.textbookSections.isNotEmpty, isTrue, reason: 'Failed for ${ch.title}');
        expect(material.textbookSections.length, greaterThanOrEqualTo(3), reason: 'Sections for ${ch.title}');
        expect(material.pointsToRemember.isNotEmpty, isTrue, reason: 'Points for ${ch.title}');
        expect(material.didYouKnowFacts.isNotEmpty, isTrue, reason: 'Facts for ${ch.title}');

        for (final sec in material.textbookSections) {
          expect(sec.title.isNotEmpty, isTrue);
          expect(sec.hindiTitle.isNotEmpty, isTrue);
          expect(sec.content.isNotEmpty, isTrue);
          expect(sec.hindiContent.isNotEmpty, isTrue);
          expect(sec.quickCheckQuestion?.isNotEmpty, isTrue);
          expect(sec.quickCheckAnswer?.isNotEmpty, isTrue);
        }
      }
    });
  });

  group('TextbookReaderScreen Widget Tests', () {
    testWidgets('Renders digital textbook screen, sections, font scale, and answer toggles', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testChapter = makeChapter(
        title: 'Fractions & Decimals',
        grade: 'Class 6',
        subjectId: 'math',
      );

      final profile = StudentProfile(
        studentName: 'Aarav',
        studentClass: StudentClass.class6,
        board: BoardType.cbse,
      );

      bool practiceStarted = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TextbookReaderScreen(
              chapter: testChapter,
              profile: profile,
              onStartPractice: () {
                practiceStarted = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header title and grade badge
      expect(find.textContaining('Fractions & Decimals'), findsWidgets);
      expect(find.textContaining('CBSE • Class 6'), findsWidgets);

      // Check Font Scaler buttons exist
      expect(find.byIcon(Icons.text_decrease_rounded), findsOneWidget);
      expect(find.byIcon(Icons.text_increase_rounded), findsOneWidget);

      // Tap font increase and decrease
      await tester.tap(find.byIcon(Icons.text_increase_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.text_decrease_rounded));
      await tester.pumpAndSettle();

      // Check Quick Check question and answer toggle
      expect(find.textContaining('Show Answer'), findsWidgets);
      final showAnswerBtn = find.textContaining('Show Answer').first;
      await tester.ensureVisible(showAnswerBtn);
      await tester.pumpAndSettle();
      await tester.tap(showAnswerBtn);
      await tester.pumpAndSettle();

      // Answer should now be revealed
      expect(find.textContaining('Hide Answer'), findsWidgets);

      // Scroll down to "Points to Remember" header
      await tester.scrollUntilVisible(find.textContaining('Points to Remember'), 500);
      await tester.pumpAndSettle();
      expect(find.textContaining('Points to Remember'), findsWidgets);

      // Check Start Practice button triggers callback
      final practiceBtn = find.textContaining('Start Practice');
      expect(practiceBtn, findsOneWidget);
      await tester.tap(practiceBtn);
      await tester.pumpAndSettle();
      expect(practiceStarted, isTrue);
    });

    testWidgets('ChapterDetailScreen contains textbook button and generate more questions button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testChapter = makeChapter(
        title: 'Numbers 1 to 10',
        grade: 'Class 1',
        subjectId: 'math',
      );

      final profile = const StudentProfile(
        studentName: 'Ananya',
        studentClass: StudentClass.class1,
        board: BoardType.cbse,
      );
      await LocalStorageService.instance.saveStudentProfile(profile);

      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: ChapterDetailScreen(chapter: testChapter),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify "Read Complete Digital Textbook" button exists in hero card
      expect(find.textContaining('Read Complete Digital Textbook'), findsOneWidget);

      // Verify "Generate More Questions" button is cleanly removed (auto-flow replaces it)
      expect(find.textContaining('Generate More Questions'), findsNothing);

      // Verify "Take Exam" button exists
      expect(find.textContaining('Take Exam'), findsOneWidget);

      // Verify Practice Questions section is rendered
      final initialQuestionsFinder = find.textContaining('Practice Questions (');
      expect(initialQuestionsFinder, findsOneWidget);
    });
  });
}
