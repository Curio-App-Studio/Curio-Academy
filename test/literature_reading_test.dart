import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/core/profile/profile_provider.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/repositories/curriculum_repository.dart';
import 'package:curio_math/data/services/literature_reading_service.dart';
import 'package:curio_math/features/concept_learning/presentation/textbook_reader_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
    await LiteratureReadingService.instance.init();
  });

  group('LiteratureReadingService Unit Tests', () {
    test('Literature reading data loads and contains Hindi chapters, excludes English', () {
      final service = LiteratureReadingService.instance;
      expect(service.hasReadingData('eng_c4_mag_01'), isFalse);
      expect(service.hasReadingData('hin_c4_mri_01'), isTrue);

      final mirandaData = service.getReadingData('hin_c4_mri_01');
      expect(mirandaData, isNotNull);
      expect(mirandaData!['title'], contains('पुष्प की अभिलाषा'));
      expect(mirandaData['author'], 'माखनलाल चतुर्वेदी');
      expect(mirandaData['sections'], isNotEmpty);
      expect(mirandaData['glossary'], isNotEmpty);
      expect(mirandaData['moral'], isNotEmpty);
    });

    test('Miranda Publisher Hindi literature chapters have complete Hindi reading data', () {
      final service = LiteratureReadingService.instance;
      final miranda1 = service.getReadingData('hin_c4_mri_01');
      expect(miranda1, isNotNull);
      expect(miranda1!['title'], contains('पुष्प की अभिलाषा'));
      expect(miranda1['author'], 'माखनलाल चतुर्वेदी');
      expect(miranda1['isPoem'], isNotNull);
      expect((miranda1['sections'] as List).length, greaterThanOrEqualTo(2));
      expect((miranda1['glossary'] as List).length, greaterThanOrEqualTo(2));
    });

    test('ConceptReadingService bridges to LiteratureReadingService for Hindi literature chapters, but never for English', () async {
      final repo = CurriculumRepository.instance;
      final hindiChapters = await repo.getChaptersForClass(
        StudentClass.class4,
        board: BoardType.icse,
        subjectId: 'hindi',
        publisher: 'miranda',
        track: 'literature',
      );

      final firstHindi = hindiChapters.first;
      expect(LiteratureReadingService.instance.isLiteratureChapter(firstHindi), isTrue);

      final englishChapters = await repo.getChaptersForClass(
        StudentClass.class4,
        board: BoardType.icse,
        subjectId: 'english',
      );
      final firstEnglish = englishChapters.first;
      expect(LiteratureReadingService.instance.isLiteratureChapter(firstEnglish), isFalse);
    });
  });

  group('TextbookReaderScreen Literature Widget Tests', () {
    testWidgets('Renders full literature story with author, scenes, glossary, and quick check', (tester) async {
      tester.view.physicalSize = const Size(1080, 8000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const profile = StudentProfile(
        board: BoardType.icse,
        studentClass: StudentClass.class4,
        studentName: 'Aarav',
        avatarIcon: '🦊',
      );

      final repo = CurriculumRepository.instance;
      final chapters = await repo.getChaptersForClass(
        StudentClass.class4,
        board: BoardType.icse,
        subjectId: 'hindi',
        publisher: 'miranda',
        track: 'literature',
      );
      final chapter = chapters.firstWhere((c) => c.chapterId == 'hin_c4_mri_01');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studentProfileProvider.overrideWith((ref) => StudentProfileNotifier(ref)..updateProfile(
              name: profile.studentName,
              avatar: profile.avatarIcon,
              board: profile.board,
              studentClass: profile.studentClass,
            )),
          ],
          child: MaterialApp(
            home: TextbookReaderScreen(
              chapter: chapter,
              profile: profile,
              onStartPractice: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AppBar displays Literature reader title
      expect(find.text('📖 Story & Literature Reader'), findsOneWidget);

      // Verify Chapter title and author byline
      expect(find.textContaining('पुष्प की अभिलाषा'), findsWidgets);
      expect(find.textContaining('माखनलाल चतुर्वेदी'), findsWidgets);

      // Verify Vocabulary & Glossary header exists
      expect(find.text('Vocabulary & Word Meanings'), findsOneWidget);

      // Verify Central Theme & Moral exists
      expect(find.text('Central Theme & Moral'), findsOneWidget);

      // Verify Quick check interactive reveal button exists
      expect(find.text('Show Answer'), findsWidgets);
      await tester.tap(find.text('Show Answer').first);
      await tester.pumpAndSettle();
      expect(find.text('Hide Answer'), findsWidgets);
    });
  });
}
