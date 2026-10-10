import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/core/services/in_app_review_service.dart';
import 'package:curio_math/core/services/in_app_update_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InAppUpdateService Unit Tests', () {
    test('Non-Android platform or test runner gracefully handles update check without crash', () async {
      final updateService = InAppUpdateService.instance;
      expect(updateService.isChecking, isFalse);
      expect(updateService.isFlexibleUpdateInProgress, isFalse);

      // In unit test environment (Platform is host OS, not Android device with Play Services)
      await updateService.checkForUpdate();
      expect(updateService.isChecking, isFalse);
    });
  });

  group('InAppReviewService Milestone & Logic Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Milestone review triggers only after reaching 25 stars threshold', () async {
      final reviewService = InAppReviewService.instance;

      expect(await reviewService.shouldPromptMilestoneReview(0), isFalse);
      expect(await reviewService.shouldPromptMilestoneReview(10), isFalse);
      expect(await reviewService.shouldPromptMilestoneReview(24), isFalse);
      expect(await reviewService.shouldPromptMilestoneReview(25), isTrue);
      expect(await reviewService.shouldPromptMilestoneReview(100), isTrue);
    });

    test('Milestone review respects cooldown and previous review submission', () async {
      final reviewService = InAppReviewService.instance;
      final prefs = await SharedPreferences.getInstance();

      // Recent prompt within 14 days
      await prefs.setInt('curio_last_review_prompt_timestamp', DateTime.now().millisecondsSinceEpoch);
      expect(await reviewService.shouldPromptMilestoneReview(30), isFalse);

      // Old prompt older than 14 days
      final fifteenDaysAgo = DateTime.now().subtract(const Duration(days: 15));
      await prefs.setInt('curio_last_review_prompt_timestamp', fifteenDaysAgo.millisecondsSinceEpoch);
      expect(await reviewService.shouldPromptMilestoneReview(30), isTrue);

      // Has already submitted review
      await prefs.setBool('curio_has_submitted_review', true);
      expect(await reviewService.shouldPromptMilestoneReview(30), isFalse);
    });
  });

  group('Parent Gate Widget UI Tests', () {
    testWidgets('Parent Gate dialog prompts math problem and verifies answer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => InAppReviewService.instance.showParentGatedReview(context),
                child: const Text('Open Parent Gate'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Parent Gate'));
      await tester.pumpAndSettle();

      // Parent Zone dialog is rendered
      expect(find.text('Parent Zone 🛡️'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Enter an obviously incorrect answer
      await tester.enterText(find.byType(TextField), '9999');
      await tester.tap(find.text('Verify & Rate ⭐'));
      await tester.pumpAndSettle();

      // Error message is displayed
      expect(find.text('Incorrect answer. Try again!'), findsOneWidget);
      expect(find.text('Parent Zone 🛡️'), findsOneWidget); // Dialog still open

      // Cancel closes the dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Parent Zone 🛡️'), findsNothing);
    });
  });
}
