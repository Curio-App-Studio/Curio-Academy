import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/core/audio/audio_service.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/repositories/curriculum_repository.dart';
import 'package:curio_math/shared/dialogs/reward_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
    await AudioService.instance.setMuted(false);
  });

  group('Subject Isolation & Quality Tests', () {
    test('English chapters across all 10 grades exclusively receive English activities', () async {
      final repo = CurriculumRepository();

      for (final studentClass in StudentClass.values) {
        final englishChapters = await repo.getChaptersForClass(
          studentClass,
          board: BoardType.cbse,
          subjectId: 'english',
        );

        expect(englishChapters.isNotEmpty, isTrue,
            reason: 'Should have English chapters for ${studentClass.label}');

        for (final ch in englishChapters) {
          expect(ch.subjectId, equals('english'),
              reason: 'Chapter ${ch.chapterId} must have subjectId == english');

          for (final act in ch.activities) {
            expect(act.subjectId, equals('english'),
                reason: 'Activity ${act.activityId} in ${ch.chapterId} (${studentClass.label}) must have subjectId == english!');

            // Verify no math leakage
            final lowerPrompt = act.promptData.text.toLowerCase();
            expect(lowerPrompt.contains('bubbles that have'), isFalse,
                reason: 'English question must not contain math bubble counting prompt');
            expect(lowerPrompt.contains('plus'), isFalse);
            expect(lowerPrompt.contains('minus'), isFalse);
            expect(lowerPrompt.contains('fraction'), isFalse);
          }
        }
      }
    });

    test('Math chapters across all 10 grades exclusively receive Math activities', () async {
      final repo = CurriculumRepository();

      for (final studentClass in StudentClass.values) {
        final mathChapters = await repo.getChaptersForClass(
          studentClass,
          board: BoardType.cbse,
          subjectId: 'math',
        );

        expect(mathChapters.isNotEmpty, isTrue,
            reason: 'Should have Math chapters for ${studentClass.label}');

        for (final ch in mathChapters) {
          expect(ch.subjectId, equals('math'),
              reason: 'Chapter ${ch.chapterId} must have subjectId == math');

          for (final act in ch.activities) {
            expect(act.subjectId, equals('math'),
                reason: 'Activity ${act.activityId} in ${ch.chapterId} must have subjectId == math');
          }
        }
      }
    });
  });

  group('Speaker Mute & Persistence Tests', () {
    test('AudioService toggleMute switches mute state and persists to LocalStorageService', () async {
      expect(AudioService.instance.isMuted, isFalse);
      expect(LocalStorageService.instance.isAudioMuted(), isFalse);

      await AudioService.instance.toggleMute();
      expect(AudioService.instance.isMuted, isTrue);
      expect(LocalStorageService.instance.isAudioMuted(), isTrue);

      await AudioService.instance.toggleMute();
      expect(AudioService.instance.isMuted, isFalse);
      expect(LocalStorageService.instance.isAudioMuted(), isFalse);
    });

    test('AudioService setMuted sets state and notifies listeners', () async {
      bool notified = false;
      AudioService.instance.muteNotifier.addListener(() {
        notified = true;
      });

      await AudioService.instance.setMuted(true);
      expect(AudioService.instance.isMuted, isTrue);
      expect(notified, isTrue);

      await AudioService.instance.setMuted(false);
      expect(AudioService.instance.isMuted, isFalse);
    });
  });

  group('RewardDialog & Dynamic Messaging Tests', () {
    testWidgets('RewardDialog displays custom context message rather than hardcoded bubble pop',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    RewardDialog.show(
                      context,
                      starsAwarded: 2,
                      totalPoints: 20,
                      message: 'Great effort! You worked through and got it! ⭐',
                      onContinue: () {},
                      onReplay: () {},
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('AWESOME JOB!'), findsOneWidget);
      expect(find.text('Great effort! You worked through and got it! ⭐'), findsOneWidget);
      expect(find.text('You popped all the correct bubbles!'), findsNothing);
    });
  });
}
