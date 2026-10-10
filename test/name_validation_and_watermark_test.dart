import 'package:curio_math/core/profile/profile_provider.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/shared/dialogs/avatar_selector_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await LocalStorageService.instance.init();
    await LocalStorageService.instance.saveStudentProfile(
      const StudentProfile(
        board: BoardType.cbse,
        studentClass: StudentClass.lkg,
        studentName: 'Little Champ',
        avatarIcon: '🦁',
      ),
    );
  });

  group('Student Name Input & Validation Tests', () {
    testWidgets('AvatarSelectorDialog opens with blank name and watermark instead of prefilled Little Champ',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AvatarSelectorDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the TextField
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      final textField = tester.widget<TextField>(textFieldFinder);
      // Verify text is empty (NOT prefilled with Little Champ)
      expect(textField.controller?.text, isEmpty);
      // Verify watermark hintText is present
      expect(textField.decoration?.hintText, isNotEmpty);
      expect(textField.decoration?.hintText, contains("child's name"));
    });

    testWidgets('Tapping Save with a blank name triggers validation error and does not dismiss',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AvatarSelectorDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Save button without entering name
      final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Save & Continue 👍');
      expect(saveButtonFinder, findsOneWidget);
      await tester.ensureVisible(saveButtonFinder);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      // Verify validation error is displayed
      expect(find.text("Please enter child's name"), findsOneWidget);
      // Verify dialog is still visible (did not dismiss)
      expect(find.byType(AvatarSelectorDialog), findsOneWidget);
    });

    testWidgets('Entering a valid name clears validation error and updates profile',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: AvatarSelectorDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter name
      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, 'Aarav');
      await tester.pumpAndSettle();

      // Tap Save
      final saveButtonFinder = find.widgetWithText(ElevatedButton, 'Save & Continue 👍');
      await tester.ensureVisible(saveButtonFinder);
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      // Profile should be updated to 'Aarav'
      final updatedProfile = container.read(studentProfileProvider);
      expect(updatedProfile.studentName, equals('Aarav'));
    });
  });
}
