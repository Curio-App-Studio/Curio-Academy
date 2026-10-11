import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/grade_tier.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/features/smart_revision/domain/concept_flashcard.dart';
import 'package:curio_math/features/smart_revision/presentation/smart_revision_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
  });

  group('Flashcard Repository Tests', () {
    final repo = FlashcardRepository.instance;

    test('Flashcard repository contains cards for all subjects', () {
      final allCards = repo.getAllFlashcards();
      expect(allCards.isNotEmpty, isTrue);

      final mathCards = repo.getFlashcardsForTier(GradeTier.earlyExplorer, filterSubject: 'math');
      final scienceCards = repo.getFlashcardsForTier(GradeTier.earlyExplorer, filterSubject: 'science');
      final englishCards = repo.getFlashcardsForTier(GradeTier.earlyExplorer, filterSubject: 'english');
      final hindiCards = repo.getFlashcardsForTier(GradeTier.earlyExplorer, filterSubject: 'hindi');

      expect(mathCards.isNotEmpty, isTrue, reason: 'Must have math flashcards');
      expect(scienceCards.isNotEmpty, isTrue, reason: 'Must have science flashcards');
      expect(englishCards.isNotEmpty, isTrue, reason: 'Must have english flashcards');
      expect(hindiCards.isNotEmpty, isTrue, reason: 'Must have hindi flashcards');
    });

    test('Flashcards have valid IDs, questions, answers, and explanations', () {
      final allCards = repo.getAllFlashcards();
      final ids = <String>{};

      for (final card in allCards) {
        expect(ids.contains(card.id), isFalse, reason: 'Duplicate card ID: ${card.id}');
        ids.add(card.id);

        expect(card.frontPromptEn.isNotEmpty, isTrue);
        expect(card.backAnswerEn.isNotEmpty, isTrue);
        expect(card.explanationEn.isNotEmpty, isTrue);
        expect(card.frontPromptHi.isNotEmpty, isTrue);
        expect(card.backAnswerHi.isNotEmpty, isTrue);
      }
    });

    test('Tier filtering works correctly', () {
      final earlyCards = repo.getFlashcardsForTier(GradeTier.earlyExplorer);
      final primaryCards = repo.getFlashcardsForTier(GradeTier.primaryBuilder);
      final middleCards = repo.getFlashcardsForTier(GradeTier.middleAchiever);

      expect(earlyCards.isNotEmpty, isTrue);
      expect(primaryCards.isNotEmpty, isTrue);
      expect(middleCards.isNotEmpty, isTrue);

      for (final c in earlyCards) {
        expect(c.targetTier, equals(GradeTier.earlyExplorer));
      }
      for (final c in primaryCards) {
        expect(c.targetTier, equals(GradeTier.primaryBuilder));
      }
      for (final c in middleCards) {
        expect(c.targetTier, equals(GradeTier.middleAchiever));
      }
    });

    test('StudentClass lookup returns appropriate flashcards', () {
      final lkgCards = repo.getFlashcardsForClass(StudentClass.lkg);
      final class5Cards = repo.getFlashcardsForClass(StudentClass.class5);
      final class8Cards = repo.getFlashcardsForClass(StudentClass.class8);

      expect(lkgCards.isNotEmpty, isTrue);
      expect(class5Cards.isNotEmpty, isTrue);
      expect(class8Cards.isNotEmpty, isTrue);
    });
  });

  group('SmartRevisionScreen Widget Tests', () {
    testWidgets('Renders SmartRevisionScreen with both Mistake Bank and Flashcard tabs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SmartRevisionScreen(initialTabIndex: 0),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check App Bar or title
      expect(find.text('🧠 Smart Study & Revision'), findsOneWidget);
      expect(find.text('Mistake Bank'), findsOneWidget);
      expect(find.text('Concept Cards'), findsOneWidget);

      // In tab 0 (Mistake bank), when empty, shows zero mistakes celebration
      expect(find.text('Zero Mistakes Found!'), findsOneWidget);

      // Switch to Flashcards tab
      await tester.tap(find.text('Concept Cards'));
      await tester.pumpAndSettle();

      // Verify flashcard UI is rendered
      expect(find.text('Tap card to flip for answer 🔄'), findsOneWidget);
      expect(find.text('I Know This! 👍 (+5 pts)'), findsOneWidget);
    });

    testWidgets('Tapping flashcard flips the card to reveal answer', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SmartRevisionScreen(initialTabIndex: 1),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify front instructions are visible
      expect(find.text('Tap card to flip for answer 🔄'), findsOneWidget);

      // Find and tap the card container
      final flipTarget = find.text('Tap card to flip for answer 🔄');
      await tester.tap(flipTarget);
      await tester.pumpAndSettle();

      // Now back is showing
      expect(find.text('Tap to flip back to question 🔄'), findsOneWidget);
    });
  });
}
