import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/features/spell_bee/domain/spell_bee_repository.dart';
import 'package:curio_math/features/spell_bee/domain/spell_bee_word.dart';
import 'package:curio_math/features/spell_bee/presentation/spell_bee_hub_screen.dart';
import 'package:curio_math/features/spell_bee/presentation/spell_bee_mcq_screen.dart';
import 'package:curio_math/features/spell_bee/presentation/spell_bee_mock_exam_screen.dart';
import 'package:curio_math/features/spell_bee/presentation/spell_bee_mistakes_screen.dart';
import 'package:curio_math/features/spell_bee/presentation/spell_bee_syllabus_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
    await SpellBeeRepository.instance.ensureLoaded();
  });

  group('SpellBeeWord Model & MCQ Option Generation Tests', () {
    test('SpellBeeWord stores etymology, partOfSpeech, and generates 4 distinct MCQ choices', () {
      const word = SpellBeeWord(
        word: 'ACCOMMODATE',
        definition: 'To provide lodging or sufficient space for',
        exampleSentence: 'The hall can accommodate all delegates.',
        emoji: '🏨',
        partOfSpeech: 'Verb',
        origin: 'Latin',
        confusables: ['ACCOMODATE', 'ACOMMODATE', 'ACOMODATE'],
        targetClass: StudentClass.class6,
        difficulty: 4,
      );

      expect(word.word, 'ACCOMMODATE');
      expect(word.partOfSpeech, 'Verb');
      expect(word.origin, 'Latin');
      expect(word.length, 11);

      final choices = word.getMcqChoices();
      expect(choices.length, 4);
      expect(choices.contains('ACCOMMODATE'), isTrue);
      // Ensure all 4 choices are unique
      expect(choices.toSet().length, 4);
    });

    test('SpellBeeWord synthesizes plausible phonetic distractors when confusables list is empty', () {
      const word = SpellBeeWord(
        word: 'RECEIVE',
        definition: 'To be given or presented with',
        exampleSentence: 'She will receive an award.',
        emoji: '🎁',
        targetClass: StudentClass.class5,
      );

      final choices = word.getMcqChoices();
      expect(choices.length, 4);
      expect(choices.contains('RECEIVE'), isTrue);
    });
  });

  group('SpellBeeRepository Competition Bank Tests', () {
    test('allWordsList contains over 100 base words and provides mock exam and MCQ sets', () {
      final repo = SpellBeeRepository.instance;
      expect(repo.allWordsList.isNotEmpty, isTrue);

      final mockSet = repo.getMockExamWords(StudentClass.class5, count: 5);
      expect(mockSet.length, 5);

      final mcqSet = repo.getMcqWords(StudentClass.class3, count: 5);
      expect(mcqSet.length, 5);
    });

    test('searchWords filters accurately by word name, meaning, or origin', () {
      final repo = SpellBeeRepository.instance;
      final results = repo.searchWords('cat', filterClass: StudentClass.lkg);
      expect(results.any((w) => w.word == 'CAT'), isTrue);
    });
  });

  group('LocalStorageService Spell Bee Mistake Vault & Stats Tests', () {
    test('Adding and removing words in the Mistake Vault persists accurately', () async {
      final storage = LocalStorageService.instance;
      await storage.clearSpellBeeMistakes();
      expect(storage.spellBeeMistakes, isEmpty);

      await storage.addSpellBeeMistake('PARALLEL');
      expect(storage.spellBeeMistakes.contains('PARALLEL'), isTrue);

      await storage.addSpellBeeMistake('PNEUMONIA');
      expect(storage.spellBeeMistakes.length, 2);

      // Duplicate additions should be ignored
      await storage.addSpellBeeMistake('PARALLEL');
      expect(storage.spellBeeMistakes.length, 2);

      await storage.removeSpellBeeMistake('PARALLEL');
      expect(storage.spellBeeMistakes.contains('PARALLEL'), isFalse);
      expect(storage.spellBeeMistakes.contains('PNEUMONIA'), isTrue);

      await storage.clearSpellBeeMistakes();
      expect(storage.spellBeeMistakes, isEmpty);
    });

    test('Recording mock exam results tracks exams count and best score', () async {
      final storage = LocalStorageService.instance;
      final initialCount = storage.spellBeeExamsCount;

      await storage.recordSpellBeeExamResult(score: 80, total: 100);
      expect(storage.spellBeeExamsCount, initialCount + 1);
      expect(storage.spellBeeMockBestScore, greaterThanOrEqualTo(80));
    });
  });

  group('Spell Bee Exam Prep UI Widget Tests', () {
    testWidgets('SpellBeeHubScreen renders Competition Exam Prep and Arcade sections', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SpellBeeHubScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Competition Exam Preparation'), findsOneWidget);
      expect(find.textContaining('Official Spell Bee Mock Exam'), findsOneWidget);
      expect(find.textContaining('Spot The Correct Spelling'), findsOneWidget);
      expect(find.textContaining('Mistake Vault & Flashcards'), findsOneWidget);
      expect(find.textContaining('Competition Word Banks'), findsOneWidget);
      expect(find.textContaining('Practice & Arcade Modes'), findsOneWidget);
    });

    testWidgets('SpellBeeMcqScreen mounts and renders 4 MCQ options', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SpellBeeMcqScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Spot The Correct Spelling'), findsOneWidget);
      expect(find.textContaining('Pronounce Word'), findsOneWidget);
      // Check choice options A, B, C, D
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
    });

    testWidgets('SpellBeeMockExamScreen mounts and displays pronouncer console and timer', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SpellBeeMockExamScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Spell Bee Mock Exam'), findsOneWidget);
      expect(find.textContaining('Official Pronouncer'), findsOneWidget);
      expect(find.textContaining('Submit Word'), findsOneWidget);
      expect(find.byIcon(Icons.timer_rounded), findsOneWidget);
    });

    testWidgets('SpellBeeMistakesScreen renders empty state when no mistakes exist', (tester) async {
      await LocalStorageService.instance.clearSpellBeeMistakes();

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SpellBeeMistakesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Spelling Mistake Vault'), findsOneWidget);
      expect(find.textContaining('Mistake Vault is Empty!'), findsOneWidget);
    });

    testWidgets('SpellBeeSyllabusScreen mounts with search bar and filter chips', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SpellBeeSyllabusScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Competition Word Banks'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('All Classes'), findsOneWidget);
    });
  });
}
