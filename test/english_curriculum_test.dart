import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/data/models/activity_model.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/models/voice_settings.dart';
import 'package:curio_math/data/repositories/curriculum_repository.dart';
import 'package:curio_math/data/services/english_question_generator.dart';
import 'package:curio_math/data/services/concept_solution_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('English Curriculum & Question Generation Tests', () {
    test('CurriculumRepository provides English as an enabled subject', () async {
      final repo = CurriculumRepository();
      final subjects = await repo.getSubjects();
      final english = subjects.firstWhere((s) => s.id == 'english');
      expect(english.isEnabled, isTrue);
      expect(english.name, 'Curio English');
    });

    test('English chapters are loaded for all 10 grades (LKG to Class 8)', () async {
      final repo = CurriculumRepository();

      for (final sc in StudentClass.values) {
        final chapters = await repo.getChaptersForClass(
          sc,
          board: BoardType.cbse,
          subjectId: 'english',
        );

        expect(
          chapters.isNotEmpty,
          isTrue,
          reason: 'Expected English chapters for ${sc.label}',
        );

        for (final ch in chapters) {
          expect(ch.subjectId, equals('english'));
          expect(ch.title.isNotEmpty, isTrue);
          expect(ch.description.isNotEmpty, isTrue);
          expect(ch.keyConcepts.isNotEmpty, isTrue);
          expect(ch.rules.isNotEmpty, isTrue);
          expect(ch.exampleQuestion != null, isTrue);

          // Zero class name leak in chapter metadata
          expect(ch.title.contains(RegExp(r'Class\s*\d', caseSensitive: false)), isFalse);
          expect(ch.description.contains(RegExp(r'Class\s*\d', caseSensitive: false)), isFalse);
        }
      }
    });

    test('English curriculum provides >= 10 chapters and differentiates CBSE vs ICSE', () async {
      final repo = CurriculumRepository();

      for (final sc in StudentClass.values) {
        final cbseChapters = await repo.getChaptersForClass(
          sc,
          board: BoardType.cbse,
          subjectId: 'english',
        );
        final icseChapters = await repo.getChaptersForClass(
          sc,
          board: BoardType.icse,
          subjectId: 'english',
        );

        if (sc == StudentClass.lkg || sc == StudentClass.ukg) {
          expect(cbseChapters.length, greaterThanOrEqualTo(5));
          expect(icseChapters.length, greaterThanOrEqualTo(5));
        } else {
          expect(
            cbseChapters.length,
            greaterThanOrEqualTo(10),
            reason: 'Expected >= 10 CBSE chapters for ${sc.label}',
          );
          expect(
            icseChapters.length,
            greaterThanOrEqualTo(10),
            reason: 'Expected >= 10 ICSE chapters for ${sc.label}',
          );

          // CBSE and ICSE must have distinct chapter IDs and titles
          final cbseIds = cbseChapters.map((c) => c.chapterId).toSet();
          final icseIds = icseChapters.map((c) => c.chapterId).toSet();
          expect(
            cbseIds.intersection(icseIds).isEmpty,
            isTrue,
            reason: 'CBSE and ICSE should have distinct chapter sets for ${sc.label}',
          );
        }
      }
    });

    test('EnglishQuestionGenerator generates zero-leak, high-quality activities', () async {
      final repo = CurriculumRepository();

      for (final sc in StudentClass.values) {
        final chapters = await repo.getChaptersForClass(
          sc,
          board: BoardType.cbse,
          subjectId: 'english',
        );

        for (final chapter in chapters) {
          final activities = EnglishQuestionGenerator.instance.generateActivitiesForChapter(
            chapter,
            sc,
            count: 3,
          );

          expect(activities.length, equals(3));

          for (final activity in activities) {
            final prompt = activity.promptData.text;
            final answer = activity.validationRule.expectedAnswer;
            final options = (activity.interactionPayload['options'] as List?)?.cast<String>() ?? [];

            // 1. Zero Class Name Leaks in prompt or options
            expect(
              prompt.contains(RegExp(r'Class\s*\d', caseSensitive: false)),
              isFalse,
              reason: 'Prompt "$prompt" contains class name leak in ${chapter.title}',
            );
            expect(
              prompt.contains(RegExp(r'Grade\s*\d', caseSensitive: false)),
              isFalse,
              reason: 'Prompt "$prompt" contains grade leak in ${chapter.title}',
            );
            for (final opt in options) {
              expect(
                opt.contains(RegExp(r'Class\s*\d', caseSensitive: false)),
                isFalse,
                reason: 'Option "$opt" contains class leak in ${chapter.title}',
              );
            }

            if (activity.activityType == ActivityType.mcq) {
              // 2. Expected answer must be in options
              expect(
                options,
                contains(answer),
                reason: 'Answer "$answer" not in options $options for ${chapter.title}',
              );

              // 3. Hint tree must have step guidance
              expect(
                activity.validationRule.hintTree.isNotEmpty,
                isTrue,
                reason: 'Hint tree empty for ${chapter.title}',
              );

              // 4. ConceptSolutionHelper extracts rich pedagogical solution
              final details = ConceptSolutionHelper.instance.getDetails(activity);
              expect(details.correctAnswer, equals(answer));
              expect(details.steps.isNotEmpty, isTrue);
              expect(details.conceptTitle.isNotEmpty, isTrue);
              expect(details.formulasAndRules.isNotEmpty, isTrue);
              expect(details.hint.isNotEmpty, isTrue);
            } else if (activity.activityType == ActivityType.bubblePop) {
              // Interactive Bubble Pop validation (for Early Explorer / Kindergarten)
              expect(activity.interactionPayload.containsKey('bubbles'), isTrue);
              expect(activity.interactionPayload.containsKey('targetValue'), isTrue);
              final bubbles = activity.interactionPayload['bubbles'] as List;
              expect(bubbles.length, greaterThanOrEqualTo(4));
              expect(activity.promptData.ttsFallback, isNotNull);
            }
          }
        }
      }
    });

    test('VoiceSettings model serializes and deserializes accurately with all personas', () {
      for (final persona in VoicePersona.values) {
        final settings = VoiceSettings(
          persona: persona,
          locale: 'en-IN',
          pitch: persona.defaultPitch,
          speechRate: persona.defaultRate,
        );

        final json = settings.toJson();
        expect(json['persona'], equals(persona.id));
        expect(json['locale'], equals('en-IN'));

        final deserialized = VoiceSettings.fromJson(json);
        expect(deserialized.persona, equals(persona));
        expect(deserialized.pitch, closeTo(persona.defaultPitch, 0.001));
        expect(deserialized.speechRate, closeTo(persona.defaultRate, 0.001));
        expect(deserialized.locale, equals('en-IN'));
      }
    });

    test('LKG English opposites generates distinct questions for Q1 and Q2 with age-appropriate distractors', () async {
      final repo = CurriculumRepository();
      final chapters = await repo.getChaptersForClass(
        StudentClass.lkg,
        board: BoardType.cbse,
        subjectId: 'english',
      );
      final oppChapter = chapters.firstWhere((c) => c.title.toLowerCase().contains('opposite'));

      final activities = EnglishQuestionGenerator.instance.generateActivitiesForChapter(
        oppChapter,
        StudentClass.lkg,
        count: 3,
      );

      expect(activities.length, equals(3));
      // Prompts must all be distinct
      final prompts = activities.map((a) => a.promptData.text).toSet();
      expect(prompts.length, equals(3), reason: 'Questions must not repeat in the same chapter');

      // Neither question should contain high-school grammar distractors
      for (final a in activities) {
        final options = (a.interactionPayload['options'] as List?)?.cast<String>() ??
            (a.interactionPayload['bubbles'] as List?)?.map((b) => b['label'].toString()).toList() ??
            [];
        for (final opt in options) {
          expect(opt.contains('clause'), isFalse, reason: 'Option "$opt" should not be for LKG');
          expect(opt.contains('predicate'), isFalse, reason: 'Option "$opt" should not be for LKG');
          expect(opt.contains('prepositional'), isFalse, reason: 'Option "$opt" should not be for LKG');
        }
      }
    });

    test('All LKG English chapters generate 100% interactive Bubble Pop activities with voice TTS', () async {
      final repo = CurriculumRepository();
      final chapters = await repo.getChaptersForClass(
        StudentClass.lkg,
        board: BoardType.cbse,
        subjectId: 'english',
      );

      for (final ch in chapters) {
        final activities = EnglishQuestionGenerator.instance.generateActivitiesForChapter(
          ch,
          StudentClass.lkg,
          count: 3,
        );

        expect(activities.length, equals(3));
        for (final act in activities) {
          expect(act.activityType, equals(ActivityType.bubblePop),
              reason: 'LKG activity must be interactive Bubble Pop, not text MCQ');
          expect(act.promptData.ttsFallback, isNotNull,
              reason: 'LKG activity must have TTS audio prompt');
          expect(act.interactionPayload.containsKey('bubbles'), isTrue);
          final bubbles = act.interactionPayload['bubbles'] as List;
          expect(bubbles.length, greaterThanOrEqualTo(5));
          expect(act.interactionPayload.containsKey('targetValue'), isTrue);
        }
      }
    });
  });
}
