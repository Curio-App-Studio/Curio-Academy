import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/chapter_model.dart';
import 'package:curio_math/data/models/student_attempt_model.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/repositories/curriculum_repository.dart';
import 'package:curio_math/data/services/concept_reading_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('P2 & P3 Priority Roadmap Feature Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await LocalStorageService.instance.init();
    });

    test('P3: science_chapters.json exists, parses, and covers LKG to Class 8 for CBSE and ICSE', () {
      final file = File('assets/curriculum/science_chapters.json');
      expect(file.existsSync(), isTrue);

      final jsonContent = file.readAsStringSync();
      final dynamic list = json.decode(jsonContent);
      expect(list, isA<List>());

      final chapters = (list as List)
          .map((item) => Chapter.fromJson(item as Map<String, dynamic>))
          .toList();

      expect(chapters.length, greaterThanOrEqualTo(100));

      final grades = chapters.map((c) => c.grade).toSet();
      expect(grades.contains('LKG'), isTrue);
      expect(grades.contains('UKG'), isTrue);
      for (int i = 1; i <= 8; i++) {
        expect(grades.contains('Class $i'), isTrue);
      }

      final boards = chapters.map((c) => c.board.toUpperCase()).toSet();
      expect(boards.contains('CBSE'), isTrue);
      expect(boards.contains('ICSE'), isTrue);
    });

    test('P3: ConceptReadingService builds rich science textbook material', () {
      final scienceChapter = Chapter(
        chapterId: 'sci_c5_01',
        chapterNumber: 1,
        title: 'Plant Reproduction and Seed Dispersal',
        grade: 'Class 5',
        board: 'cbse',
        subjectId: 'science',
        icon: '🌱',
        description: 'Understand pollination and seed dispersal mechanisms.',
        keyConcepts: ['Pollination', 'Seed Dispersal', 'Germination'],
      );

      final material = ConceptReadingService.instance.getStudyMaterial(scienceChapter);
      expect(material.chapterId, equals('sci_c5_01'));
      expect(material.subjectId, equals('science'));
      expect(material.textbookSections.length, greaterThanOrEqualTo(3));
      expect(material.definitions.isNotEmpty, isTrue);
      expect(material.solvedExamples.isNotEmpty, isTrue);
      expect(material.didYouKnowFacts.isNotEmpty, isTrue);
    });

    test('Class-based subject availability: Science is only available starting Class 3', () async {
      final repo = CurriculumRepository();

      // Math & English available across all grades
      for (final c in StudentClass.values) {
        expect(CurriculumRepository.isSubjectAvailableForClass('math', c), isTrue);
        expect(CurriculumRepository.isSubjectAvailableForClass('english', c), isTrue);
      }

      // Science is hidden in LKG, UKG, Class 1, Class 2
      expect(CurriculumRepository.isSubjectAvailableForClass('science', StudentClass.lkg), isFalse);
      expect(CurriculumRepository.isSubjectAvailableForClass('science', StudentClass.ukg), isFalse);
      expect(CurriculumRepository.isSubjectAvailableForClass('science', StudentClass.class1), isFalse);
      expect(CurriculumRepository.isSubjectAvailableForClass('science', StudentClass.class2), isFalse);

      // Science is enabled starting Class 3 to Class 8
      expect(CurriculumRepository.isSubjectAvailableForClass('science', StudentClass.class3), isTrue);
      expect(CurriculumRepository.isSubjectAvailableForClass('science', StudentClass.class5), isTrue);
      expect(CurriculumRepository.isSubjectAvailableForClass('science', StudentClass.class8), isTrue);

      // EVS is available in LKG to Class 5, and hidden in Class 6 to 8
      expect(CurriculumRepository.isSubjectAvailableForClass('evs', StudentClass.lkg), isTrue);
      expect(CurriculumRepository.isSubjectAvailableForClass('evs', StudentClass.ukg), isTrue);
      expect(CurriculumRepository.isSubjectAvailableForClass('evs', StudentClass.class1), isTrue);
      expect(CurriculumRepository.isSubjectAvailableForClass('evs', StudentClass.class2), isTrue);
      expect(CurriculumRepository.isSubjectAvailableForClass('evs', StudentClass.class3), isTrue);
      expect(CurriculumRepository.isSubjectAvailableForClass('evs', StudentClass.class5), isTrue);
      expect(CurriculumRepository.isSubjectAvailableForClass('evs', StudentClass.class6), isFalse);
      expect(CurriculumRepository.isSubjectAvailableForClass('evs', StudentClass.class8), isFalse);

      // getSubjects filters correctly
      final lkgSubjects = await repo.getSubjects(studentClass: StudentClass.lkg);
      expect(lkgSubjects.map((s) => s.id), containsAll(['math', 'english', 'evs']));
      expect(lkgSubjects.any((s) => s.id == 'science'), isFalse);

      final class5Subjects = await repo.getSubjects(studentClass: StudentClass.class5);
      expect(class5Subjects.map((s) => s.id), containsAll(['math', 'english', 'evs', 'science']));

      final class8Subjects = await repo.getSubjects(studentClass: StudentClass.class8);
      expect(class8Subjects.map((s) => s.id), containsAll(['math', 'english', 'science']));
      expect(class8Subjects.any((s) => s.id == 'evs'), isFalse);

      // getChaptersForClass returns empty list for LKG science
      final lkgScienceChapters = await repo.getChaptersForClass(StudentClass.lkg, subjectId: 'science');
      expect(lkgScienceChapters, isEmpty);
    });

    test('EVS Curriculum: evs_chapters.json exists, parses, and covers LKG to Class 5', () {
      final file = File('assets/curriculum/evs_chapters.json');
      expect(file.existsSync(), isTrue);

      final jsonContent = file.readAsStringSync();
      final dynamic list = json.decode(jsonContent);
      expect(list, isA<List>());

      final chapters = (list as List)
          .map((item) => Chapter.fromJson(item as Map<String, dynamic>))
          .toList();

      expect(chapters.length, greaterThanOrEqualTo(70));

      final grades = chapters.map((c) => c.grade).toSet();
      expect(grades.contains('LKG'), isTrue);
      expect(grades.contains('UKG'), isTrue);
      expect(grades.contains('Class 1'), isTrue);
      expect(grades.contains('Class 2'), isTrue);
      expect(grades.contains('Class 3'), isTrue);
      expect(grades.contains('Class 4'), isTrue);
      expect(grades.contains('Class 5'), isTrue);

      // Check ConceptReadingService builds rich EVS material
      final sampleEvsChapter = chapters.firstWhere((c) => c.grade == 'Class 1');
      final studyMaterial = ConceptReadingService.instance.getStudyMaterial(sampleEvsChapter);
      expect(studyMaterial.subjectId, equals('evs'));
      expect(studyMaterial.textbookSections.length, greaterThanOrEqualTo(3));
      expect(studyMaterial.definitions.isNotEmpty, isTrue);
      expect(studyMaterial.solvedExamples.isNotEmpty, isTrue);
    });

    test('P2: LocalStorageService tracks daily streak accurately', () async {
      final storage = LocalStorageService.instance;
      expect(storage.streakCount, equals(1)); // Initialized to 1 on first use

      await storage.recordDailyActivity();
      expect(storage.streakCount, equals(1));
      expect(storage.streakNotifier.value, equals(1));
    });

    test('P2: LocalStorageService records mistakes into Mistake Vault and allows clearance', () async {
      final storage = LocalStorageService.instance;
      expect(storage.mistakeCount, equals(0));

      final wrongAttempt = StudentQuestionAttempt(
        activityId: 'sci_act_01',
        chapterId: 'sci_c5_01',
        selectedOptionIndex: 2,
        selectedOptionText: 'Heavy shell',
        isCorrect: false,
        starsEarned: 0,
        timestamp: DateTime.now(),
      );

      await storage.saveQuestionAttempt(wrongAttempt);
      expect(storage.mistakeCount, equals(1));
      expect(storage.mistakeCountNotifier.value, equals(1));

      final mistakes = storage.getMistakes();
      expect(mistakes.length, equals(1));
      expect(mistakes.first.selectedOptionText, equals('Heavy shell'));
      expect(mistakes.first.isCorrect, isFalse);

      // Now clear the mistake
      await storage.clearQuestionAttempt('sci_act_01');
      expect(storage.mistakeCount, equals(0));
      expect(storage.mistakeCountNotifier.value, equals(0));
      expect(storage.getMistakes(), isEmpty);
    });
  });
}
