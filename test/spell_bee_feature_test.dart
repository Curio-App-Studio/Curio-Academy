import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/features/spell_bee/domain/spell_bee_word.dart';
import 'package:curio_math/features/spell_bee/domain/spell_bee_repository.dart';
import 'package:curio_math/features/spell_bee/presentation/spell_bee_hub_screen.dart';
import 'package:curio_math/features/spell_bee/presentation/spell_bee_adventure_screen.dart';
import 'package:curio_math/features/spell_bee/presentation/spell_bee_sprint_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
  });

  group('Spell Bee Domain & Repository Tests', () {
    final repo = SpellBeeRepository.instance;

    test('SpellBeeRepository contains words for all classes from LKG to Class 8', () {
      expect(SpellBeeRepository.allWords.isNotEmpty, isTrue);

      for (final studentClass in StudentClass.values) {
        final words = repo.getWordsForClass(studentClass);
        expect(words.isNotEmpty, isTrue, reason: 'Expected words for ${studentClass.label}');
        expect(words.length, greaterThanOrEqualTo(10), reason: 'Expected at least 10 words for ${studentClass.label}');
      }
    });

    test('SpellBeeRepository getWordsForStage returns exactly 5 words per stage', () {
      for (int stage = 1; stage <= 10; stage++) {
        final words = repo.getWordsForStage(StudentClass.class3, stage);
        expect(words.length, equals(5));
      }
    });

    test('SpellBeeRepository generateLetterTiles includes all word letters', () {
      const word = SpellBeeWord(
        word: 'TIGER',
        definition: 'Wild cat with stripes',
        exampleSentence: 'A tiger walks in the forest.',
        emoji: '🐅',
        targetClass: StudentClass.class1,
      );

      final tiles = repo.generateLetterTiles(word, maxDecoys: 2);
      expect(tiles.length, greaterThanOrEqualTo(word.length));

      // Must contain all original letters
      for (final char in word.letterList) {
        expect(tiles.contains(char), isTrue);
      }
    });

    test('SpellBeeRepository getRandomSprintWord returns valid word for grade', () {
      final sprintWord = repo.getRandomSprintWord(StudentClass.class5);
      expect(sprintWord.word.isNotEmpty, isTrue);
      expect(sprintWord.definition.isNotEmpty, isTrue);
    });
  });

  group('Spell Bee LocalStorage Persistence Tests', () {
    test('LocalStorageService saves and updates spell bee high score', () async {
      final storage = LocalStorageService.instance;
      expect(storage.spellBeeHighScore, greaterThanOrEqualTo(0));

      final updated = await storage.updateSpellBeeHighScore(120);
      expect(updated, isTrue);
      expect(storage.spellBeeHighScore >= 120, isTrue);
      expect(storage.spellBeeHighScoreNotifier.value >= 120, isTrue);
    });

    test('LocalStorageService persists stage star ratings', () async {
      final storage = LocalStorageService.instance;
      await storage.saveSpellBeeStageStars('class 4', 1, 3);
      final stars = storage.getSpellBeeStageStars('class 4', 1);
      expect(stars, equals(3));
    });
  });

  group('Spell Bee Widget Rendering Tests', () {
    testWidgets('SpellBeeHubScreen mounts and renders adventure and sprint options', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SpellBeeHubScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Spell Bee Champion'), findsOneWidget);
      expect(find.textContaining('Level Adventure'), findsOneWidget);
      expect(find.textContaining('60-Second Speed Sprint'), findsOneWidget);
      expect(find.text('How to Play Spell Bee'), findsOneWidget);
    });

    testWidgets('SpellBeeAdventureScreen mounts and displays stage map cards', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SpellBeeAdventureScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Adventure Stage Map'), findsOneWidget);
      expect(find.text('Stage 1'), findsOneWidget);
      expect(find.text('#1'), findsOneWidget);
    });

    testWidgets('SpellBeeSprintScreen mounts and displays 60s timer and controls', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SpellBeeSprintScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('60s Speed Spell Bee'), findsOneWidget);
      expect(find.text('Del'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Cleanly dispose by pumping a clean replacement widget
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
