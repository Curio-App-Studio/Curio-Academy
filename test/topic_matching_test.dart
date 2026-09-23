import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/activity_model.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/repositories/curriculum_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
  });

  group('Grade, Subject, Chapter & Topic Matching Tests', () {
    test('LKG & UKG Math chapters generate 100% interactive Bubble Pop matching their specific topic', () async {
      final repo = CurriculumRepository();

      for (final studentClass in [StudentClass.lkg, StudentClass.ukg]) {
        final mathChapters = await repo.getChaptersForClass(
          studentClass,
          board: BoardType.cbse,
          subjectId: 'math',
        );

        expect(mathChapters.isNotEmpty, isTrue);

        for (final ch in mathChapters) {
          final acts = repo.generateActivitiesForChapter(ch.chapterId, studentClass, count: 2, chapter: ch);
          expect(acts.isNotEmpty, isTrue);

          for (final act in acts) {
            // Must be interactive bubble pop for kindergarten
            expect(act.activityType, equals(ActivityType.bubblePop),
                reason: '${studentClass.label} Math chapter "${ch.title}" must be interactive Bubble Pop!');
            expect(act.subjectId, equals('math'));
            expect(act.interactionPayload.containsKey('bubbles'), isTrue);
            expect(act.interactionPayload.containsKey('targetValue'), isTrue);

            // Must match chapter topic
            final titleLower = ch.title.toLowerCase();
            final promptLower = act.promptData.text.toLowerCase();

            if (titleLower.contains('shape') || titleLower.contains('space')) {
              expect(
                promptLower.contains('circle') || promptLower.contains('square') || promptLower.contains('triangle'),
                isTrue,
                reason: 'Shapes chapter prompt must match shapes: $promptLower',
              );
            } else if (titleLower.contains('pattern') || titleLower.contains('color')) {
              expect(
                promptLower.contains('red') || promptLower.contains('blue') || promptLower.contains('green') || promptLower.contains('yellow'),
                isTrue,
                reason: 'Colors & Patterns chapter prompt must match colors: $promptLower',
              );
            } else if (titleLower.contains('sorting') || titleLower.contains('comparing')) {
              expect(
                promptLower.contains('big') || promptLower.contains('small') || promptLower.contains('tall') || promptLower.contains('short'),
                isTrue,
                reason: 'Sorting & Comparing chapter prompt must match size/height: $promptLower',
              );
            } else if (titleLower.contains('addition') || titleLower.contains('add')) {
              expect(
                promptLower.contains('add up to'),
                isTrue,
                reason: 'Addition chapter prompt must match addition bonds: $promptLower',
              );
            } else if (titleLower.contains('subtraction') || titleLower.contains('subtract')) {
              expect(
                promptLower.contains('equal'),
                isTrue,
                reason: 'Subtraction chapter prompt must match subtraction: $promptLower',
              );
            }
          }
        }
      }
    });

    test('Class 1 Math chapters generate authentic Class 1 questions matching their respective topics', () async {
      final repo = CurriculumRepository();
      final mathChapters = await repo.getChaptersForClass(
        StudentClass.class1,
        board: BoardType.cbse,
        subjectId: 'math',
      );

      for (final ch in mathChapters) {
        final acts = repo.generateActivitiesForChapter(ch.chapterId, StudentClass.class1, count: 2, chapter: ch);
        final titleLower = ch.title.toLowerCase();

        for (final act in acts) {
          final promptLower = act.promptData.text.toLowerCase();

          if (titleLower == 'addition') {
            expect(
              promptLower.contains('+') || promptLower.contains('more') || promptLower.contains('apples'),
              isTrue,
              reason: 'Addition chapter must ask addition questions, got: $promptLower',
            );
          } else if (titleLower == 'subtraction') {
            expect(
              promptLower.contains('-') || promptLower.contains('flew away') || promptLower.contains('birds'),
              isTrue,
              reason: 'Subtraction chapter must ask subtraction questions, got: $promptLower',
            );
          } else if (titleLower == 'time') {
            expect(
              promptLower.contains("o'clock") || promptLower.contains('sun') || promptLower.contains('day') || promptLower.contains('night'),
              isTrue,
              reason: 'Time chapter must ask time questions, got: $promptLower',
            );
          } else if (titleLower == 'measurement') {
            expect(
              promptLower.contains('longer') || promptLower.contains('heavier') || promptLower.contains('taller') || promptLower.contains('handspan'),
              isTrue,
              reason: 'Measurement chapter must ask measurement questions, got: $promptLower',
            );
          } else if (titleLower == 'money') {
            expect(
              promptLower.contains('₹') || promptLower.contains('coin') || promptLower.contains('rupee'),
              isTrue,
              reason: 'Money chapter must ask money questions, got: $promptLower',
            );
          } else if (titleLower == 'patterns') {
            expect(
              promptLower.contains('pattern') || promptLower.contains('sequence') || promptLower.contains('___'),
              isTrue,
              reason: 'Patterns chapter must ask pattern questions, got: $promptLower',
            );
          } else if (titleLower == 'data handling') {
            expect(
              promptLower.contains('fruit') || promptLower.contains('pets') || promptLower.contains('toys') || promptLower.contains('how many'),
              isTrue,
              reason: 'Data handling chapter must ask data counting questions, got: $promptLower',
            );
          }
        }
      }
    });

    test('Class 1 English chapters generate authentic Class 1 questions matching their respective topics', () async {
      final repo = CurriculumRepository();
      final englishChapters = await repo.getChaptersForClass(
        StudentClass.class1,
        board: BoardType.cbse,
        subjectId: 'english',
      );

      for (final ch in englishChapters) {
        final acts = repo.generateActivitiesForChapter(ch.chapterId, StudentClass.class1, count: 2, chapter: ch);
        final titleLower = ch.title.toLowerCase();

        for (final act in acts) {
          final promptLower = act.promptData.text.toLowerCase();

          if (titleLower.contains('naming word') || titleLower.contains('noun')) {
            expect(
              promptLower.contains('noun') || promptLower.contains('naming word'),
              isTrue,
              reason: 'Nouns chapter must ask noun questions, got: $promptLower',
            );
          } else if (titleLower.contains('action word') || titleLower.contains('verb')) {
            if (titleLower.contains('opposite')) {
              expect(
                promptLower.contains('opposite') || promptLower.contains('verb') || promptLower.contains('action'),
                isTrue,
                reason: 'Opposites & Verbs chapter, got: $promptLower',
              );
            } else {
              expect(
                promptLower.contains('verb') || promptLower.contains('action'),
                isTrue,
                reason: 'Verbs chapter must ask verb questions, got: $promptLower',
              );
            }
          } else if (titleLower.contains('article')) {
            expect(
              promptLower.contains('article') || promptLower.contains("'a'") || promptLower.contains("'an'"),
              isTrue,
              reason: 'Articles chapter must ask article questions, got: $promptLower',
            );
          } else if (titleLower.contains('describing word')) {
            expect(
              promptLower.contains('adjective') || promptLower.contains('describing'),
              isTrue,
              reason: 'Adjectives chapter must ask adjective questions, got: $promptLower',
            );
          }
        }
      }
    });

    test('Zero boilerplate meta-questions or improper distractors across all 10 grades', () async {
      final repo = CurriculumRepository();

      for (final studentClass in StudentClass.values) {
        for (final subject in ['math', 'english']) {
          final chapters = await repo.getChaptersForClass(
            studentClass,
            board: BoardType.cbse,
            subjectId: subject,
          );

          for (final ch in chapters.take(5)) {
            final acts = repo.generateActivitiesForChapter(ch.chapterId, studentClass, count: 2, chapter: ch);

            for (final act in acts) {
              final promptLower = act.promptData.text.toLowerCase();

              expect(promptLower.contains('elementary practice topic'), isFalse,
                  reason: 'No elementary practice topic boilerplate in ${studentClass.label} $subject ${ch.title}');
              expect(promptLower.contains('which foundational rule'), isFalse);
              expect(promptLower.contains('which core topic in'), isFalse);
              expect(promptLower.contains('governing formula'), isFalse);
              expect(promptLower.contains('primary study focus of'), isFalse);

              final opts = (act.interactionPayload['options'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
              for (final opt in opts) {
                expect(opt.contains('elementary practice topic'), isFalse);
                expect(opt.contains('undefined or infinite value'), isFalse);
                expect(opt.contains('applies only when the variable is zero'), isFalse);
              }
            }
          }
        }
      }
    });
  });
}
