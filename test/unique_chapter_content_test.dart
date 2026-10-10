import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/data/models/chapter_model.dart';
import 'package:curio_math/data/services/concept_reading_service.dart';

void main() {
  group('Unique Chapter Reading & Syllabus Content Tests', () {
    final chMath1 = Chapter(
      chapterId: 'math_shapes',
      chapterNumber: 1,
      title: 'Shapes and Space',
      grade: 'Class 1',
      subjectId: 'math',
      icon: '📐',
      description: 'Learn shapes and spatial relationships like inside, outside, top, bottom.',
      keyConcepts: ['Inside-Outside', 'Bigger-Smaller', 'Top-Bottom', 'Rolling-Sliding'],
      rules: ['Objects with curved surfaces roll.', 'Flat objects slide.'],
      mascotAdvice: 'Look around your room to identify shapes!',
      exampleQuestion: 'Which object rolls: a ball or a box?',
      exampleExplanation: 'A ball is spherical with curved surface so it rolls.',
      exampleAnswer: 'A ball rolls.',
      funFact: 'Spheres roll easily in every direction!',
    );

    final chMath2 = Chapter(
      chapterId: 'math_numbers',
      chapterNumber: 2,
      title: 'Numbers from One to Nine',
      grade: 'Class 1',
      subjectId: 'math',
      icon: '🔢',
      description: 'Master counting objects and writing numerals from 1 to 9.',
      keyConcepts: ['One-to-One Correspondence', 'Cardinality', 'Number 0 to 9'],
      rules: ['Each count word corresponds to one object.', 'The last number named gives the total count.'],
      mascotAdvice: 'Count items using your fingers to never miss one!',
      exampleQuestion: 'How many apples are there in a group of 5 apples?',
      exampleExplanation: 'Count each apple one by one: 1, 2, 3, 4, 5.',
      exampleAnswer: '5 apples.',
      funFact: 'The digit 0 was invented by Indian mathematicians!',
    );

    final chEng = Chapter(
      chapterId: 'eng_nouns',
      chapterNumber: 1,
      title: 'Naming Words (Nouns)',
      grade: 'Class 1',
      subjectId: 'english',
      icon: '📖',
      description: 'Understand naming words for people, places, animals, and things.',
      keyConcepts: ['Proper Noun', 'Common Noun', 'Singular & Plural'],
      rules: ['Every noun names a person, place, animal, or thing.', 'Proper nouns start with a capital letter.'],
      mascotAdvice: 'Capitalize special names like your name and city!',
      exampleQuestion: 'Identify the noun: The cat ran fast.',
      exampleExplanation: 'Cat is the name of an animal, so it is a noun.',
      exampleAnswer: 'Cat is the noun.',
      funFact: 'The word alphabet comes from alpha and beta!',
    );

    test('Chapters within same class have completely distinct definitions, rules, and exam traps', () {
      final mat1 = ConceptReadingService.instance.getStudyMaterial(chMath1);
      final mat2 = ConceptReadingService.instance.getStudyMaterial(chMath2);

      // Verify titles and overviews are unique
      expect(mat1.title, isNot(equals(mat2.title)));
      expect(mat1.overview, isNot(equals(mat2.overview)));

      // Verify Definitions are tailored to keyConcepts
      expect(mat1.definitions.first.term, equals('Inside-Outside'));
      expect(mat2.definitions.first.term, equals('One-to-One Correspondence'));
      expect(mat1.definitions.first.term, isNot(equals(mat2.definitions.first.term)));

      // Verify Rules are unique and from chapter
      expect(mat1.quickRulesAndFormulas.first, equals('Objects with curved surfaces roll.'));
      expect(mat2.quickRulesAndFormulas.first, equals('Each count word corresponds to one object.'));
      expect(mat1.quickRulesAndFormulas.first, isNot(equals(mat2.quickRulesAndFormulas.first)));

      // Verify Solved Examples are unique
      expect(mat1.solvedExamples.first.question, equals('Which object rolls: a ball or a box?'));
      expect(mat2.solvedExamples.first.question, equals('How many apples are there in a group of 5 apples?'));

      // Verify Exam Traps have chapter-specific advice and trap
      expect(mat1.examTraps.any((t) => t.contains(chMath1.mascotAdvice!)), isTrue);
      expect(mat2.examTraps.any((t) => t.contains(chMath2.mascotAdvice!)), isTrue);
      expect(mat1.examTraps.any((t) => t.contains(chMath1.title)), isTrue);
      expect(mat2.examTraps.any((t) => t.contains(chMath2.title)), isTrue);

      // Verify Textbook Sections are chapter-specific
      expect(mat1.textbookSections.length, equals(4));
      expect(mat2.textbookSections.length, equals(4));
      expect(mat1.textbookSections.first.title, contains(chMath1.title));
      expect(mat2.textbookSections.first.title, contains(chMath2.title));
    });

    test('Math and English chapters have completely distinct subjects and content', () {
      final mathMat = ConceptReadingService.instance.getStudyMaterial(chMath1);
      final engMat = ConceptReadingService.instance.getStudyMaterial(chEng);

      expect(mathMat.subjectId, equals('math'));
      expect(engMat.subjectId, equals('english'));
      expect(mathMat.definitions.first.term, isNot(equals(engMat.definitions.first.term)));
      expect(mathMat.quickRulesAndFormulas.first, isNot(equals(engMat.quickRulesAndFormulas.first)));
      expect(mathMat.solvedExamples.first.question, isNot(equals(engMat.solvedExamples.first.question)));
      expect(mathMat.textbookSections.first.title, contains(chMath1.title));
      expect(engMat.textbookSections.first.title, contains(chEng.title));
    });
  });
}
