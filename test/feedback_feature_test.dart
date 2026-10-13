import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/features/feedback/data/feedback_model.dart';
import 'package:curio_math/features/feedback/domain/feedback_service.dart';
import 'package:curio_math/features/feedback/presentation/feedback_sheet.dart';

void main() {
  group('UserFeedback Model Tests', () {
    test('UserFeedback creates map properly and handles categories and gmailId', () {
      final feedback = UserFeedback(
        gmailId: 'Parent.Aarav@gmail.com',
        rating: 5,
        category: FeedbackCategory.feature,
        comment: 'Great app! Please add multiplication tables practice.',
        contactInfo: 'parent.aarav@gmail.com',
        studentName: 'Aarav',
        studentClass: 'Class 3',
        board: 'CBSE',
        appVersion: '1.0.0',
        buildNumber: '11',
        platform: 'Android',
        deviceModel: 'SM-G991B',
        deviceBrand: 'Samsung',
        deviceManufacturer: 'Samsung',
        osVersion: 'Android 14 (API 34)',
        osSdkInt: 34,
        createdAt: DateTime(2026, 10, 13, 10, 0),
      );

      final map = feedback.toMap();
      expect(map['gmailId'], 'parent.aarav@gmail.com');
      expect(map['rating'], 5);
      expect(map['category'], 'feature');
      expect(map['comment'], 'Great app! Please add multiplication tables practice.');
      expect(map['contactInfo'], 'parent.aarav@gmail.com');
      expect(map['studentName'], 'Aarav');
      expect(map['studentClass'], 'Class 3');
      expect(map['board'], 'CBSE');
      expect(map['platform'], 'Android');
      expect(map['appVersion'], '1.0.0');
      expect(map['buildNumber'], '11');
      expect(map['fullAppVersion'], '1.0.0+11');
      expect(map['deviceModel'], 'SM-G991B');
      expect(map['deviceBrand'], 'Samsung');
      expect(map['deviceManufacturer'], 'Samsung');
      expect(map['osVersion'], 'Android 14 (API 34)');
      expect(map['osSdkInt'], 34);

      final summary = feedback.toSummaryMap();
      expect(summary['rating'], 5);
      expect(summary['category'], 'feature');
      expect(summary['device'], 'Samsung SM-G991B');
    });

    test('FeedbackService sanitizeGmailId normalizes emails safely', () {
      expect(FeedbackService.sanitizeGmailId('Vivek.Parent@Gmail.Com'), 'vivek.parent@gmail.com');
      expect(FeedbackService.sanitizeGmailId('   user@gmail.com  '), 'user@gmail.com');
      expect(FeedbackService.sanitizeGmailId('user/test@gmail.com'), 'user_test@gmail.com');
      expect(FeedbackService.sanitizeGmailId(''), 'anonymous');
      expect(FeedbackService.sanitizeGmailId(null), 'anonymous');
    });

    test('FeedbackCategory parsing fallback works reliably', () {
      expect(FeedbackCategory.fromString('bug'), FeedbackCategory.bug);
      expect(FeedbackCategory.fromString('audio'), FeedbackCategory.audio);
      expect(FeedbackCategory.fromString('non_existent'), FeedbackCategory.other);
      expect(FeedbackCategory.fromString(null), FeedbackCategory.feature);
    });

    test('FeedbackCategory localization works for English and Hindi', () {
      expect(FeedbackCategory.praise.localized(false), contains('Praise'));
      expect(FeedbackCategory.praise.localized(true), contains('प्रशंसा'));
    });
  });

  group('FeedbackBottomSheet Widget Tests', () {
    testWidgets('Displays parental gate when gate is not passed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedbackBottomSheet(initialGatePassed: false),
          ),
        ),
      );

      expect(find.textContaining('Parent Zone Check'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('Verify'), findsOneWidget);
    });

    testWidgets('Displays feedback form when gate is initially passed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeedbackBottomSheet(initialGatePassed: true),
          ),
        ),
      );

      expect(find.textContaining('Feedback & Suggestions'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
      expect(find.textContaining('Feature Request'), findsOneWidget);
      expect(find.textContaining('Report an Issue'), findsOneWidget);
      expect(find.textContaining("Parent's Gmail ID"), findsOneWidget);
      expect(find.textContaining('Submit Feedback'), findsOneWidget);
    });
  });
}
