import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/features/rhymes_stories/domain/rhyme_story_model.dart';
import 'package:curio_math/features/rhymes_stories/presentation/rhymes_stories_screen.dart';
import 'package:curio_math/features/rhymes_stories/presentation/widgets/animated_story_scene.dart';
import 'package:curio_math/features/rhymes_stories/presentation/widgets/animated_rhyme_stage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RhymesStoriesData Domain Unit Tests', () {
    test('Contains 10 Nursery Rhymes with non-empty lines and characters', () {
      expect(RhymesStoriesData.rhymes.length, 10);
      for (final rhyme in RhymesStoriesData.rhymes) {
        expect(rhyme.id.isNotEmpty, isTrue);
        expect(rhyme.title.isNotEmpty, isTrue);
        expect(rhyme.titleHi.isNotEmpty, isTrue);
        expect(rhyme.emoji.isNotEmpty, isTrue);
        expect(rhyme.lines.isNotEmpty, isTrue);
        expect(rhyme.fullText.isNotEmpty, isTrue);
        expect(rhyme.speechText.isNotEmpty, isTrue);
        expect(rhyme.character.isNotEmpty, isTrue);
      }
      expect(RhymesStoriesData.rhymes.first.title, 'Twinkle, Twinkle, Little Star');
      expect(RhymesStoriesData.rhymes[1].title, 'Baa, Baa, Black Sheep');
      expect(RhymesStoriesData.rhymes.last.title, 'Hickory Dickory Dock');
    });

    test('Contains 5 Moral Stories with scenes and morals', () {
      expect(RhymesStoriesData.stories.length, 5);
      for (final story in RhymesStoriesData.stories) {
        expect(story.id.isNotEmpty, isTrue);
        expect(story.title.isNotEmpty, isTrue);
        expect(story.moral.isNotEmpty, isTrue);
        expect(story.scenes.length, greaterThanOrEqualTo(3));
        expect(story.fullSpeechText.isNotEmpty, isTrue);
        for (final scene in story.scenes) {
          expect(scene.text.isNotEmpty, isTrue);
          expect(scene.emoji.isNotEmpty, isTrue);
        }
      }
      expect(RhymesStoriesData.stories.first.title, 'The Thirsty Crow');
      expect(RhymesStoriesData.stories[1].title, 'The Hare & The Tortoise');
    });
  });

  group('RhymesStoriesScreen Widget Tests', () {
    testWidgets('RhymesStoriesScreen mounts and shows Rhymes tab and animated stage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RhymesStoriesScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header & Tabs
      expect(find.textContaining('Rhymes & Stories'), findsOneWidget);
      expect(find.textContaining('Nursery Rhymes'), findsOneWidget);
      expect(find.textContaining('Moral Stories'), findsOneWidget);

      // Verify Rhyme is shown in the player
      expect(find.text('Play Melody 🎵'), findsOneWidget);
      expect(find.text('Read Rhyme 🗣️'), findsOneWidget);

      // Verify Animated Musical Stage is rendered
      expect(find.byType(AnimatedRhymeStage), findsOneWidget);
    });

    testWidgets('Switching to Moral Stories tab displays story reader, animation canvas, and controls', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RhymesStoriesScreen(initialTab: 1),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show Stories tab content
      expect(find.text('The Thirsty Crow'), findsWidgets);
      expect(find.textContaining('Read Story 🗣️'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Verify Animated Story Scene Canvas is rendered
      expect(find.byType(AnimatedStorySceneIllustration), findsOneWidget);

      // Verify Story selector chips exist
      expect(find.textContaining('The Hare & The Tortoise'), findsWidgets);
    });

    testWidgets('Advancing scene in story reader updates page index and highlights section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RhymesStoriesScreen(initialTab: 1),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Page 1 of'), findsOneWidget);

      // Scroll until Next button is visible on 600px test canvas
      await tester.ensureVisible(find.text('Next'));
      await tester.pump();

      // Tap Next Scene
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Page 2 of'), findsOneWidget);
      expect(find.text('Prev'), findsOneWidget);
    });

    testWidgets('Tapping section chip in timeline navigates directly to that section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RhymesStoriesScreen(initialTab: 1),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Find chip 3 in timeline and tap it
      final chip3 = find.text('3');
      expect(chip3, findsWidgets);
      await tester.tap(chip3.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Page 3 of'), findsOneWidget);
    });

    testWidgets('Tapping rhyme line activates line recitation and karaoke highlight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RhymesStoriesScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final firstLine = find.text('Twinkle, twinkle, little star,');
      expect(firstLine, findsWidgets);

      // Tap the first line to recite it
      await tester.tap(firstLine.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show speaking badge
      expect(find.text('🗣️ SPEAKING'), findsOneWidget);
    });
  });
}

