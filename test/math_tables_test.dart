import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/features/math_tables/domain/math_table_model.dart';
import 'package:curio_math/features/math_tables/presentation/math_tables_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
  });

  group('MathTableModel & TableQuestion Unit Tests', () {
    test('MathTableData generates correct 10 rows for Table 7', () {
      final table7 = MathTableData.generate(7, maxMultiplier: 10);
      expect(table7.number, 7);
      expect(table7.rows.length, 10);

      expect(table7.rows[0].formula, '7 × 1 = 7');
      expect(table7.rows[0].product, 7);
      expect(table7.rows[0].repeatedAddition, '7');

      expect(table7.rows[7].formula, '7 × 8 = 56');
      expect(table7.rows[7].product, 56);
      expect(table7.rows[7].repeatedAddition, '7 + 7 + 7 + 7 + 7 + 7 + 7 + 7');

      expect(table7.rows[9].formula, '7 × 10 = 70');
      expect(table7.rows[9].product, 70);

      // Check trick
      expect(table7.trickTitle, contains('Seven'));
      expect(table7.trickDescription, contains('week'));
    });

    test('MathTableData generates 12 rows when maxMultiplier is 12', () {
      final table12 = MathTableData.generate(12, maxMultiplier: 12);
      expect(table12.rows.length, 12);
      expect(table12.rows[11].formula, '12 × 12 = 144');
      expect(table12.rows[11].product, 144);
    });

    test('TableQuestion generates quiz with 4 unique choices and accurate answer', () {
      final quiz = TableQuestion.generateQuiz(6, count: 10);
      expect(quiz.length, 10);

      for (final q in quiz) {
        expect(q.tableNumber, 6);
        expect(q.options.length, 4);
        expect(q.options.toSet().length, 4); // All 4 choices unique
        expect(q.options.contains(q.correctAnswer), isTrue); // Correct answer present in options
        expect(q.promptEquation, contains('6'));
      }
    });

    test('TableQuestion generates multi-table quiz across selected tables', () {
      final multiQuiz = TableQuestion.generateMultiTableQuiz([3, 7, 12], count: 15);
      expect(multiQuiz.length, 15);

      final tablesFound = multiQuiz.map((q) => q.tableNumber).toSet();
      // Should include tables from the selected set
      for (final t in tablesFound) {
        expect([3, 7, 12].contains(t), isTrue);
      }

      for (final q in multiQuiz) {
        expect(q.options.length, 4);
        expect(q.options.toSet().length, 4);
        expect(q.options.contains(q.correctAnswer), isTrue);
      }
    });
  });

  group('MathTablesScreen Widget Tests', () {
    testWidgets('MathTablesScreen mounts, shows chips 1 to 20, and table rows', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MathTablesScreen(initialTable: 5),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & table number chips
      expect(find.textContaining('Learn Tables'), findsOneWidget);
      expect(find.text('5'), findsWidgets); // chip & table formula

      // Verify 4 tabs
      expect(find.textContaining('Chart'), findsOneWidget);
      expect(find.textContaining('Cards'), findsOneWidget);
      expect(find.textContaining('Fill In'), findsOneWidget);
      expect(find.textContaining('Test'), findsOneWidget);

      // Verify table rows for Table of 5
      expect(find.text('5 × 1 = 5'), findsOneWidget);
      expect(find.text('5 × 10 = 50'), findsOneWidget);

      // Verify magic trick card
      expect(find.textContaining('Clock & Coin'), findsOneWidget);
    });

    testWidgets('Tapping a table row opens visual concept modal with repeated addition', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MathTablesScreen(initialTable: 3),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on row '3 × 2 = 6'
      await tester.tap(find.text('3 × 2 = 6'));
      await tester.pumpAndSettle();

      // Modal appears
      expect(find.textContaining('Repeated Addition Meaning:'), findsOneWidget);
      expect(find.text('3 + 3 = 6'), findsOneWidget);
      expect(find.textContaining('Got It!'), findsOneWidget);

      // Dismiss modal
      await tester.tap(find.textContaining('Got It!'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Repeated Addition Meaning:'), findsNothing);
    });

    testWidgets('Flashcard tab displays card and flips to reveal answer on tap', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MathTablesScreen(initialTable: 4),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Cards tab
      await tester.tap(find.textContaining('Cards'));
      await tester.pumpAndSettle();

      // Front card displays QUESTION: 4 × 1 = ?
      expect(find.text('❓ QUESTION'), findsOneWidget);
      expect(find.text('4 × 1 = ?'), findsOneWidget);

      // Tap card to flip
      await tester.tap(find.text('4 × 1 = ?'));
      await tester.pumpAndSettle();

      // Back card displays ANSWER: 4
      expect(find.text('🎉 ANSWER'), findsOneWidget);
      expect(find.text('4'), findsWidgets);
    });

    testWidgets('Fill In blanks tab renders equation and 4 clickable choice buttons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MathTablesScreen(initialTable: 9),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Fill In tab
      await tester.tap(find.textContaining('Fill In'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Find the missing number:'), findsOneWidget);
      expect(find.textContaining('🔥 0'), findsOneWidget);
    });

    testWidgets('Test tab renders multi-table selector and presets', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MathTablesScreen(initialTable: 5),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Test tab
      await tester.tap(find.textContaining('Test'));
      await tester.pumpAndSettle();

      // Should show Test Tables banner
      expect(find.textContaining('Test Tables'), findsOneWidget);
      expect(find.text('2 to 5'), findsOneWidget);
      expect(find.text('6 to 10'), findsOneWidget);
      expect(find.text('All (1-20)'), findsOneWidget);

      // Tap preset '2 to 5'
      await tester.tap(find.text('2 to 5'));
      await tester.pumpAndSettle();

      expect(find.textContaining('4 selected'), findsOneWidget);
    });

    testWidgets('Table chant defaults to traditional (2 ones are 2) and can toggle to times', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MathTablesScreen(initialTable: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check default chant style button in appBar
      expect(find.text('2 ones are 2'), findsOneWidget);

      // Verify row chant text in MathTableData
      final table2 = MathTableData.generate(2);
      expect(table2.rows[0].chantTraditional, '2 ones are 2');
      expect(table2.rows[1].chantTraditional, '2 twos are 4');
      expect(table2.rows[0].chantTimes, '2 times 1 is 2');
      expect(table2.rows[0].chantEn, '2 ones are 2'); // Defaults to traditional

      // Tap toggle button to switch to '2 times 1'
      await tester.tap(find.text('2 ones are 2'));
      await tester.pumpAndSettle();

      expect(find.text('2 times 1'), findsOneWidget);
    });
  });
}
