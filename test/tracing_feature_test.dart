import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/features/tracing/domain/tracing_character.dart';
import 'package:curio_math/features/tracing/domain/tracing_repository.dart';
import 'package:curio_math/features/tracing/presentation/tracing_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
  });

  group('Tracing Domain & Repository Tests', () {
    final repo = TracingRepository.instance;

    test('TracingRepository provides characters for all 5 categories', () {
      for (final cat in TracingCategory.values) {
        final list = repo.getCharactersByCategory(cat);
        expect(list.isNotEmpty, isTrue, reason: 'Expected characters for ${cat.label}');
      }
    });

    test('English Upper has 26 characters (A-Z) with valid IDs and prompts', () {
      final list = repo.getCharactersByCategory(TracingCategory.englishUpper);
      expect(list.length, equals(26));
      final ids = list.map((c) => c.id).toSet();
      expect(ids.length, equals(26), reason: 'All character IDs must be unique');

      for (final c in list) {
        expect(c.character.isNotEmpty, isTrue);
        expect(c.soundPromptEn.isNotEmpty, isTrue);
        expect(c.soundPromptHi.isNotEmpty, isTrue);
      }
    });

    test('Numbers category has 20 characters (1-20) with valid IDs', () {
      final list = repo.getCharactersByCategory(TracingCategory.numbers);
      expect(list.length, equals(20));
      expect(list.first.character, equals('1'));
      expect(list.last.character, equals('20'));
    });

    test('Hindi Swar and Vyanjan categories contain complete Varnamala', () {
      final swar = repo.getCharactersByCategory(TracingCategory.hindiSwar);
      expect(swar.length, equals(13));
      expect(swar.first.character, equals('अ'));

      final vyanjan = repo.getCharactersByCategory(TracingCategory.hindiVyanjan);
      expect(vyanjan.length, greaterThanOrEqualTo(30));
      expect(vyanjan.first.character, equals('क'));
    });
  });

  group('LocalStorageService Tracing Persistence Tests', () {
    test('marks character as traced and increments points', () async {
      final storage = LocalStorageService.instance;
      expect(storage.getTracedCharacters(), isEmpty);

      final initialPoints = storage.totalPoints;
      final added = await storage.markCharacterTraced('en_u_a');
      expect(added, isTrue);
      expect(storage.getTracedCharacters().contains('en_u_a'), isTrue);
      expect(storage.totalPoints, equals(initialPoints + 10));

      // Marking same character again should not duplicate
      final repeat = await storage.markCharacterTraced('en_u_a');
      expect(repeat, isFalse);
    });

    test('resetProgressOnly clears traced characters', () async {
      final storage = LocalStorageService.instance;
      await storage.markCharacterTraced('num_1');
      expect(storage.getTracedCharacters().contains('num_1'), isTrue);

      await storage.resetProgressOnly();
      expect(storage.getTracedCharacters(), isEmpty);
    });
  });

  group('TracingScreen Widget Tests', () {
    testWidgets('mounts and renders header, category tabs, and action buttons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TracingScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Tracing'), findsOneWidget);
      expect(find.text('ABC'), findsOneWidget);
      expect(find.text('1 2 3'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      expect(find.textContaining('Done'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    });

    testWidgets('allows switching between categories', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TracingScreen(),
          ),
        ),
      );
      await tester.pump();

      // Tap on '1 2 3' tab
      await tester.tap(find.text('1 2 3'));
      await tester.pump();

      // Should show Number 1
      expect(find.textContaining('Number 1'), findsOneWidget);
    });
  });
}
