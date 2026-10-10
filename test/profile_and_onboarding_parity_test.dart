import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/features/onboarding/presentation/first_time_onboarding_screen.dart';
import 'package:curio_math/shared/components/student_profile_form.dart';
import 'package:curio_math/shared/dialogs/avatar_selector_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Profile and Onboarding Parity Tests', () {
    testWidgets('FirstTimeOnboardingScreen renders StudentProfileForm with tiered classes and avatars',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FirstTimeOnboardingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verifies StudentProfileForm is embedded
      expect(find.byType(StudentProfileForm), findsOneWidget);

      // 2. Verifies the 3 Class Tiers are present
      expect(find.text('Early Explorers (Pre-primary & Grade 1)'), findsOneWidget);
      expect(find.text('Primary Builders (Grade 2 to 5)'), findsOneWidget);
      expect(find.text('Middle Achievers (Grade 6 to 8)'), findsOneWidget);

      // 3. Verifies Boards are present
      expect(find.text('CBSE'), findsOneWidget);
      expect(find.text('ICSE'), findsOneWidget);
      expect(find.text('State Board'), findsOneWidget);

      // 4. Verifies 16 avatars are present in the grid (exactly once, no top badge)
      expect(find.text('Selected Avatar'), findsNothing);
      expect(find.text('🦁'), findsOneWidget);
      expect(find.text('🐼'), findsOneWidget);
      expect(find.text('🚀'), findsWidgets); // In avatar grid + Start Learning button

      // 5. Verifies Submit button
      expect(find.text('Start Learning'), findsOneWidget);
    });

    testWidgets('AvatarSelectorDialog renders StudentProfileForm with tiered classes and avatars',
        (WidgetTester tester) async {
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

      // 1. Verifies StudentProfileForm is embedded
      expect(find.byType(StudentProfileForm), findsOneWidget);

      // 2. Verifies the 3 Class Tiers are present
      expect(find.text('Early Explorers (Pre-primary & Grade 1)'), findsOneWidget);
      expect(find.text('Primary Builders (Grade 2 to 5)'), findsOneWidget);
      expect(find.text('Middle Achievers (Grade 6 to 8)'), findsOneWidget);

      // 3. Verifies Save button
      expect(find.text('Save & Continue 👍'), findsOneWidget);
    });

    testWidgets('Selecting a class and avatar in StudentProfileForm updates state correctly',
        (WidgetTester tester) async {
      StudentClass currentClass = StudentClass.class1;
      String currentAvatar = '🦁';
      BoardType currentBoard = BoardType.cbse;
      final controller = TextEditingController(text: 'Aarav');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return SingleChildScrollView(
                    child: StudentProfileForm(
                      nameController: controller,
                      selectedBoard: currentBoard,
                      onBoardChanged: (b) => setState(() => currentBoard = b),
                      selectedClass: currentClass,
                      onClassChanged: (c) => setState(() => currentClass = c),
                      selectedAvatar: currentAvatar,
                      onAvatarChanged: (a) => setState(() => currentAvatar = a),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Class 4
      final class4Finder = find.text('Class 4');
      await tester.ensureVisible(class4Finder);
      await tester.pumpAndSettle();
      await tester.tap(class4Finder);
      await tester.pumpAndSettle();
      expect(currentClass, equals(StudentClass.class4));

      // Tap Panda Avatar
      final pandaFinder = find.text('🐼');
      await tester.ensureVisible(pandaFinder);
      await tester.pumpAndSettle();
      await tester.tap(pandaFinder);
      await tester.pumpAndSettle();
      expect(currentAvatar, equals('🐼'));

      // Tap ICSE Board
      final icseFinder = find.text('ICSE');
      await tester.ensureVisible(icseFinder);
      await tester.pumpAndSettle();
      await tester.tap(icseFinder);
      await tester.pumpAndSettle();
      expect(currentBoard, equals(BoardType.icse));
    });
  });
}
