import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/features/home_dashboard/presentation/home_dashboard_screen.dart';
import 'package:curio_math/features/subject_chapters/presentation/subject_chapters_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
  });

  group('Subject Selection & Chapters Separation Tests', () {
    testWidgets('HomeDashboardScreen does NOT show chapter cards or bottom subject bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Subject cards exist on Home Dashboard
      expect(find.text('Pick a Subject 🎨'), findsOneWidget);
      expect(find.text('Math'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Science'), findsOneWidget);

      // Chapters header and chapter cards should NOT be present on HomeDashboardScreen
      expect(find.text('Math Chapters'), findsNothing);
      expect(find.text('English Chapters'), findsNothing);
      expect(find.textContaining('CHAPTER 1'), findsNothing);
      expect(find.text('Practice & Play'), findsNothing);
    });

    testWidgets('Tapping Math subject card navigates to SubjectChaptersScreen and back', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on Math card
      await tester.tap(find.text('Math'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should now be on SubjectChaptersScreen for Math
      expect(find.byType(SubjectChaptersScreen), findsOneWidget);
      expect(find.text('📐 Math Chapters'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byTooltip('Back'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should return to HomeDashboardScreen
      expect(find.byType(HomeDashboardScreen), findsOneWidget);
      expect(find.byType(SubjectChaptersScreen), findsNothing);
    });

    testWidgets('Tapping English subject card navigates to SubjectChaptersScreen with English', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on English card
      await tester.tap(find.text('English'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should now be on SubjectChaptersScreen for English
      expect(find.byType(SubjectChaptersScreen), findsOneWidget);
      expect(find.text('📚 English Chapters'), findsOneWidget);
    });

    testWidgets('SubjectChaptersScreen does not overflow on small 320px screens', (WidgetTester tester) async {
      FlutterErrorDetails? caughtDetails;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        caughtDetails = details;
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SubjectChaptersScreen(
              subjectId: 'math',
              subjectName: 'Math',
              emoji: '📐',
              primaryColor: Color(0xFFFF7B25),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      FlutterError.onError = originalOnError;
      expect(caughtDetails, isNull);
    });
  });
}
