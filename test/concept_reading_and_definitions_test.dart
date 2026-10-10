import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/data/models/chapter_model.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/services/concept_reading_service.dart';
import 'package:curio_math/features/concept_learning/presentation/concept_lesson_sheet.dart';
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

  group('ConceptReadingService Comprehensive Syllabus Coverage Tests', () {
    test('Math domains produce detailed definitions, formulas, and worked examples', () {
      // Test Shapes & Space (LKG/UKG/Primary)
      final shapeChapter = makeChapter(
        title: 'Shapes & Space',
        grade: 'LKG',
        subjectId: 'math',
      );
      final shapeMaterial = ConceptReadingService.instance.getStudyMaterial(shapeChapter);
      expect(shapeMaterial.definitions.isNotEmpty, isTrue);
      expect(shapeMaterial.definitions.any((d) => d.term.contains('Circle')), isTrue);
      expect(shapeMaterial.definitions.any((d) => d.hindiTerm.contains('वृत्त')), isTrue);
      expect(shapeMaterial.quickRulesAndFormulas.isNotEmpty, isTrue);
      expect(shapeMaterial.solvedExamples.isNotEmpty, isTrue);
      expect(shapeMaterial.examTraps.isNotEmpty, isTrue);

      // Test Rational Numbers & Integers (Middle School Class 7/8)
      final rationalChapter = makeChapter(
        title: 'Rational Numbers',
        grade: 'Class 8',
        subjectId: 'math',
      );
      final rationalMaterial = ConceptReadingService.instance.getStudyMaterial(rationalChapter);
      expect(rationalMaterial.definitions.any((d) => d.term.contains('Rational Numbers')), isTrue);
      expect(rationalMaterial.definitions.firstWhere((d) => d.term.contains('Rational Numbers')).formula, contains('p / q'));
      expect(rationalMaterial.quickRulesAndFormulas.any((r) => r.contains('q ≠ 0')), isTrue);
      expect(rationalMaterial.solvedExamples.any((e) => e.question.toLowerCase().contains('rational')), isTrue);

      // Test Algebra & Linear Equations (Middle School Class 6/7/8)
      final algebraChapter = makeChapter(
        title: 'Linear Equations in One Variable',
        grade: 'Class 8',
        subjectId: 'math',
      );
      final algebraMaterial = ConceptReadingService.instance.getStudyMaterial(algebraChapter);
      expect(algebraMaterial.definitions.any((d) => d.term.contains('Algebraic') || d.term.contains('Linear')), isTrue);
      expect(algebraMaterial.solvedExamples.isNotEmpty, isTrue);

      // Test Commercial Math (Percentages, Profit & Loss)
      final percentChapter = makeChapter(
        title: 'Comparing Quantities: Percentage & Profit',
        grade: 'Class 7',
        subjectId: 'math',
      );
      final percentMaterial = ConceptReadingService.instance.getStudyMaterial(percentChapter);
      expect(percentMaterial.definitions.any((d) => d.term.contains('Percentage')), isTrue);
      expect(percentMaterial.definitions.any((d) => d.term.contains('Simple Interest')), isTrue);
      expect(percentMaterial.definitions.firstWhere((d) => d.term.contains('Simple Interest')).formula, contains('SI = (P × R × T) / 100'));
    });

    test('English domains produce grammar definitions, phonetic rules, and traps', () {
      // Test Alphabet & Phonics (LKG/UKG)
      final phonicsChapter = makeChapter(
        title: 'Alphabet & Phonics Fun',
        grade: 'UKG',
        subjectId: 'english',
      );
      final phonicsMaterial = ConceptReadingService.instance.getStudyMaterial(phonicsChapter);
      expect(phonicsMaterial.definitions.any((d) => d.term.contains('Phonics')), isTrue);
      expect(phonicsMaterial.definitions.any((d) => d.term.contains('Rhyming')), isTrue);
      expect(phonicsMaterial.solvedExamples.any((e) => e.conceptHighlight.contains('Phonics')), isTrue);

      // Test Nouns & Pronouns
      final nounChapter = makeChapter(
        title: 'Nouns: Proper, Common, Collective',
        grade: 'Class 3',
        subjectId: 'english',
      );
      final nounMaterial = ConceptReadingService.instance.getStudyMaterial(nounChapter);
      expect(nounMaterial.definitions.any((d) => d.term.contains('Noun')), isTrue);
      expect(nounMaterial.definitions.any((d) => d.term.contains('Pronoun')), isTrue);
      expect(nounMaterial.quickRulesAndFormulas.any((r) => r.contains('Plural') || r.contains('plural')), isTrue);

      // Test Tenses & Verbs
      final tenseChapter = makeChapter(
        title: 'Verbs & Tenses Mastery',
        grade: 'Class 5',
        subjectId: 'english',
      );
      final tenseMaterial = ConceptReadingService.instance.getStudyMaterial(tenseChapter);
      expect(tenseMaterial.definitions.any((d) => d.term.contains('Verb')), isTrue);
      expect(tenseMaterial.examTraps.any((t) => t.contains('Subject-Verb') || t.contains('verb')), isTrue);

      // Test Active & Passive Voice
      final voiceChapter = makeChapter(
        title: 'Active and Passive Voice',
        grade: 'Class 7',
        subjectId: 'english',
      );
      final voiceMaterial = ConceptReadingService.instance.getStudyMaterial(voiceChapter);
      expect(voiceMaterial.definitions.any((d) => d.term.contains('Voice')), isTrue);
      expect(voiceMaterial.quickRulesAndFormulas.any((r) => r.contains('Past Participle (V3)')), isTrue);
    });

    test('Fallback generator provides rich bilingual study content for custom topics', () {
      final customChapter = makeChapter(
        title: 'Quantum Robotics for Beginners',
        grade: 'Class 4',
        subjectId: 'math',
      );
      final customMaterial = ConceptReadingService.instance.getStudyMaterial(customChapter);
      expect(customMaterial.definitions.isNotEmpty, isTrue);
      expect(customMaterial.overview.contains('Quantum Robotics for Beginners'), isTrue);
      expect(customMaterial.hindiOverview.contains('Quantum Robotics for Beginners'), isTrue);
      expect(customMaterial.quickRulesAndFormulas.isNotEmpty, isTrue);
      expect(customMaterial.hindiQuickRulesAndFormulas.isNotEmpty, isTrue);
      expect(customMaterial.solvedExamples.isNotEmpty, isTrue);
      expect(customMaterial.examTraps.isNotEmpty, isTrue);
    });
  });

  group('ConceptLessonSheet 4-Tab Reading UI Tests', () {
    testWidgets('renders all 4 tabs and allows seamless tab navigation', (tester) async {
      await LocalStorageService.instance.saveAppLanguage('en');
      final rationalChapter = makeChapter(
        title: 'Rational Numbers',
        grade: 'Class 8',
        subjectId: 'math',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConceptLessonSheet(
                chapter: rationalChapter,
                profile: const StudentProfile(studentClass: StudentClass.class8),
                onStartPractice: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Chapter title in header
      expect(find.text('Rational Numbers'), findsOneWidget);

      // Check 4 Tab titles in English
      expect(find.text('📖 Definitions & Concepts'), findsOneWidget);
      expect(find.text('📐 Rules & Formulas'), findsOneWidget);
      expect(find.text('💡 Solved Examples'), findsOneWidget);
      expect(find.text('⚠️ Exam Traps'), findsOneWidget);

      // Tab 1: Concepts is open by default
      expect(find.textContaining('Rational Numbers'), findsWidgets);

      // Switch to Tab 2: Formulas & Rules
      await tester.tap(find.text('📐 Rules & Formulas'));
      await tester.pumpAndSettle();
      expect(find.text('Important Formulas & Rules Sheet 📐'), findsOneWidget);
      expect(find.textContaining('Denominator can never be zero'), findsOneWidget);

      // Switch to Tab 3: Worked Examples
      await tester.tap(find.text('💡 Solved Examples'));
      await tester.pumpAndSettle();
      expect(find.text('Step-by-Step Example 💡'), findsOneWidget);
      expect(find.textContaining('Step-by-Step Working:'), findsOneWidget);
      expect(find.textContaining('Final Answer:'), findsOneWidget);

      // Switch to Tab 4: Exam Traps & Tips
      await tester.tap(find.text('⚠️ Exam Traps'));
      await tester.pumpAndSettle();
      expect(find.text('Common Exam Traps to Avoid ⚠️'), findsOneWidget);
      expect(find.text('Pro-Tip 🌟'), findsOneWidget);
    });

    testWidgets('renders authentic Hindi labels and content in Hindi mode', (tester) async {
      await LocalStorageService.instance.saveAppLanguage('hi');
      final phonicsChapter = makeChapter(
        title: 'Alphabet & Phonics Fun',
        grade: 'UKG',
        subjectId: 'english',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConceptLessonSheet(
                chapter: phonicsChapter,
                profile: const StudentProfile(studentClass: StudentClass.ukg),
                onStartPractice: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Hindi 4 Tab labels
      expect(find.text('📖 अवधारणाएं एवं परिभाषाएं'), findsOneWidget);
      expect(find.text('📐 सूत्र एवं नियम'), findsOneWidget);
      expect(find.text('💡 उदाहरण हल'), findsOneWidget);
      expect(find.text('⚠️ सावधानियां'), findsOneWidget);

      // Check Hindi concept definitions
      expect(find.textContaining('ध्वनि और अक्षर'), findsOneWidget);

      // Switch to Hindi Rules tab
      await tester.tap(find.text('📐 सूत्र एवं नियम'));
      await tester.pumpAndSettle();
      expect(find.text('महत्वपूर्ण सूत्र एवं नियम सूची 📐'), findsOneWidget);

      // Switch to Hindi Examples tab
      await tester.tap(find.text('💡 उदाहरण हल'));
      await tester.pumpAndSettle();
      expect(find.text('चरणबद्ध उदाहरण 💡'), findsOneWidget);
      expect(find.textContaining('चरणबद्ध हल:'), findsOneWidget);
    });
  });
}
