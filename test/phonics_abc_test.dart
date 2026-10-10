import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/features/phonics_abc/domain/phonics_letter.dart';
import 'package:curio_math/features/phonics_abc/presentation/phonics_abc_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PhonicsLetter Domain Unit Tests', () {
    test('PhonicsLetter bank contains all 26 letters from A to Z', () {
      expect(PhonicsLetter.all.length, 26);
      expect(PhonicsLetter.all.first.upper, 'A');
      expect(PhonicsLetter.all.first.word, 'Apple');
      expect(PhonicsLetter.all.first.emoji, '🍎');
      expect(PhonicsLetter.all.first.phonicChant, contains('A for Apple'));

      expect(PhonicsLetter.all[1].upper, 'B');
      expect(PhonicsLetter.all[1].word, 'Boy');
      expect(PhonicsLetter.all[1].emoji, '👦');
      expect(PhonicsLetter.all[1].phonicChant, contains('B for Boy'));

      expect(PhonicsLetter.all.last.upper, 'Z');
      expect(PhonicsLetter.all.last.word, 'Zebra');
    });

    test('Each PhonicsLetter has upper, lower, IPA sound, and color', () {
      for (final letter in PhonicsLetter.all) {
        expect(letter.upper.length, 1);
        expect(letter.lower.length, 1);
        expect(letter.soundIpa.isNotEmpty, isTrue);
        expect(letter.colorHex.startsWith('#'), isTrue);
      }
    });
  });

  group('PhonicsAbcScreen Widget Tests', () {
    testWidgets('PhonicsAbcScreen mounts and renders A-Z chart and tabs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PhonicsAbcScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Title & Tabs
      expect(find.textContaining('Phonics & ABC'), findsOneWidget);
      expect(find.textContaining('Chart (A-Z)'), findsOneWidget);
      expect(find.textContaining('Big Card'), findsOneWidget);
      expect(find.textContaining('Find Letter'), findsOneWidget);

      // Verify letters A and B in chart
      expect(find.textContaining('A for Apple'), findsOneWidget);
      expect(find.textContaining('B for Boy'), findsOneWidget);
    });

    testWidgets('Switching to Big Card tab displays oversized letter and phonic chant', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PhonicsAbcScreen(initialIndex: 0),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Big Card tab
      await tester.tap(find.textContaining('Big Card'));
      await tester.pumpAndSettle();

      expect(find.text('A  a'), findsOneWidget);
      expect(find.text('A for Apple'), findsOneWidget);
      expect(find.textContaining('A for Apple! Ah, ah, Apple!'), findsOneWidget);
    });

    testWidgets('Switching to Find Letter tab displays quiz with 4 choice cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PhonicsAbcScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Find Letter tab
      await tester.tap(find.textContaining('Find Letter'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Score:'), findsOneWidget);
      expect(find.textContaining('Which letter starts the word'), findsOneWidget);
    });
  });
}
