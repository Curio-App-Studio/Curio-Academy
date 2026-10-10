import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/data/models/chapter_model.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/services/hindi_question_generator.dart';
import 'package:curio_math/data/repositories/curriculum_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CBSE Hindi Questions Quality & Order Tests', () {
    test('NCERT Rimjhim 4 मन के भोले-भाले बादल produces 5 distinct, well-ordered questions', () {
      final ch = Chapter(
        chapterId: 'hin_c4_ncert_01',
        chapterNumber: 1,
        title: 'मन के भोले-भाले बादल',
        grade: 'Class 4',
        subjectId: 'hindi',
        board: 'cbse',
        publisher: 'ncert',
        icon: '☁️',
      );

      final activities = HindiQuestionGenerator.instance.generateActivitiesForChapter(
        ch,
        StudentClass.class4,
        count: 5,
      );

      expect(activities.length, equals(5));

      final prompts = activities.map((a) => a.promptData.text).toSet();
      // All 5 prompts must be completely unique
      expect(prompts.length, equals(5));

      // Check authentic story questions
      expect(activities[0].promptData.text, contains('झब्बर-झब्बर'));
      expect(activities[1].promptData.text, contains('तुलना'));
      expect(activities[2].promptData.text, contains('मतवाले'));
      expect(activities[3].promptData.text, contains('बरसाते'));
      expect(activities[4].promptData.text, contains('प्रतीत'));

      expect(activities[0].validationRule.expectedAnswer, contains('काले बादलों'));
      expect(activities[2].validationRule.expectedAnswer, contains('शेरों'));
      expect(activities[3].validationRule.expectedAnswer, contains('पानी'));
      expect(activities[4].validationRule.expectedAnswer, contains('भोले-भाले'));

      for (final a in activities) {
        final options = (a.interactionPayload['options'] as List).cast<String>();
        expect(options.length, equals(4));
        expect(options.contains(a.validationRule.expectedAnswer), isTrue);
      }
    });

    test('NCERT Rimjhim 4 जैसा सवाल वैसा जवाब produces 5 distinct Birbal & Khwaja Sara questions', () {
      final ch = Chapter(
        chapterId: 'hin_c4_ncert_02',
        chapterNumber: 2,
        title: 'जैसा सवाल वैसा जवाब',
        grade: 'Class 4',
        subjectId: 'hindi',
        board: 'cbse',
        publisher: 'ncert',
        icon: '👑',
      );

      final activities = HindiQuestionGenerator.instance.generateActivitiesForChapter(
        ch,
        StudentClass.class4,
        count: 5,
      );

      expect(activities.length, equals(5));
      final prompts = activities.map((a) => a.promptData.text).toSet();
      expect(prompts.length, equals(5));

      expect(activities[0].promptData.text, contains('ख्वाजा सरा'));
      expect(activities[1].promptData.text, contains('पहला कठिन सवाल'));
      expect(activities[2].promptData.text, contains('संसार के केंद्र'));
      expect(activities[3].promptData.text, contains('तारों'));
      expect(activities[4].promptData.text, contains('सटीक उत्तरों'));

      expect(activities[1].validationRule.expectedAnswer, contains('संसार का केंद्र'));
      expect(activities[3].validationRule.expectedAnswer, contains('भेड़'));
    });

    test('NCERT Rimjhim 4 किरमिच की गेंद produces 5 distinct authentic story questions', () {
      final ch = Chapter(
        chapterId: 'hin_c4_ncert_03',
        chapterNumber: 3,
        title: 'किरमिच की गेंद',
        grade: 'Class 4',
        subjectId: 'hindi',
        board: 'cbse',
        publisher: 'ncert',
        icon: '⚾',
      );

      final activities = HindiQuestionGenerator.instance.generateActivitiesForChapter(
        ch,
        StudentClass.class4,
        count: 5,
      );

      expect(activities.length, equals(5));
      final prompts = activities.map((a) => a.promptData.text).toSet();
      expect(prompts.length, equals(5));

      expect(activities[0].promptData.text, contains('सीताफल'));
      expect(activities[1].promptData.text, contains('दीपक'));
      expect(activities[2].promptData.text, contains('दिनेश'));
      expect(activities[3].promptData.text, contains('फैसला'));
      expect(activities[4].promptData.text, contains('गेंद कहाँ'));

      expect(activities[0].validationRule.expectedAnswer, contains('किरमिच की गेंद'));
      expect(activities[4].validationRule.expectedAnswer, contains('स्कूटर'));
    });

    test('NCERT Rimjhim 4 पापा जब बच्चे थे produces 5 distinct authentic questions', () {
      final ch = Chapter(
        chapterId: 'hin_c4_ncert_04',
        chapterNumber: 4,
        title: 'पापा जब बच्चे थे',
        grade: 'Class 4',
        subjectId: 'hindi',
        board: 'cbse',
        publisher: 'ncert',
        icon: '🚂',
      );

      final activities = HindiQuestionGenerator.instance.generateActivitiesForChapter(
        ch,
        StudentClass.class4,
        count: 5,
      );

      expect(activities.length, equals(5));
      final prompts = activities.map((a) => a.promptData.text).toSet();
      expect(prompts.length, equals(5));

      expect(activities[0].promptData.text, contains('शोर मचाने'));
      expect(activities[1].promptData.text, contains('डिब्बों'));
      expect(activities[2].promptData.text, contains('आइसक्रीम'));
      expect(activities[3].promptData.text, contains('कुत्ता'));
      expect(activities[4].promptData.text, contains('फौजी अफसर'));

      expect(activities[0].validationRule.expectedAnswer, contains('चौकीदार'));
      expect(activities[1].validationRule.expectedAnswer, contains('शंटिंग'));
      expect(activities[4].validationRule.expectedAnswer, contains('इंसान'));
    });

    test('CBSE Hindi Grammar chapters produce 5 varied questions with zero duplicates', () {
      final chSangya = Chapter(
        chapterId: 'hin_class4_ch03',
        chapterNumber: 3,
        title: 'संज्ञा के विकार',
        grade: 'Class 4',
        subjectId: 'hindi',
        board: 'cbse',
        publisher: 'grammar',
        icon: '🏷️',
      );

      final acts = HindiQuestionGenerator.instance.generateActivitiesForChapter(
        chSangya,
        StudentClass.class4,
        count: 5,
      );

      expect(acts.length, equals(5));
      final prompts = acts.map((a) => a.promptData.text).toSet();
      expect(prompts.length, equals(5));
    });

    test('CurriculumRepository getChaptersForClass provides chapters with 5 activities for CBSE Hindi', () async {
      final repo = CurriculumRepository();
      final chapters = await repo.getChaptersForClass(
        StudentClass.class4,
        board: BoardType.cbse,
        subjectId: 'hindi',
      );

      expect(chapters.isNotEmpty, isTrue);
      for (final ch in chapters) {
        expect(ch.activities.length, greaterThanOrEqualTo(5),
            reason: 'Chapter ${ch.title} (${ch.chapterId}) must have at least 5 activities');
      }
    });
  });
}
