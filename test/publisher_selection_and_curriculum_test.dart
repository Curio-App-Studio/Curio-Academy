import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/core/profile/profile_provider.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/data/repositories/curriculum_repository.dart';
import 'package:curio_math/features/subject_chapters/presentation/subject_chapters_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
  });

  group('CurriculumRepository Literature & Grammar Tests', () {
    test('Class 4 English provides no publisher options because it is universal', () {
      final repo = CurriculumRepository.instance;
      final publishers = repo.getAvailablePublishers(
        subjectId: 'english',
        studentClass: StudentClass.class4,
        board: BoardType.icse,
      );

      expect(publishers, isEmpty);
    });

    test('Class 4 Hindi provides Miranda Publisher and NCERT options', () {
      final repo = CurriculumRepository.instance;
      final publishers = repo.getAvailablePublishers(
        subjectId: 'hindi',
        studentClass: StudentClass.class4,
        board: BoardType.icse,
      );

      expect(publishers, isNotEmpty);
      final ids = publishers.map((p) => p['id']).toList();
      expect(ids, contains('miranda'));
      expect(ids, contains('ncert'));
      expect(ids, contains('all'));

      final mridula = publishers.firstWhere((p) => p['id'] == 'miranda');
      expect(mridula['book'], 'मृदुला हिंदी पाठ्य पुस्तक 4');
    });

    test('Class 4 English returns universal grammar chapters directly', () async {
      final repo = CurriculumRepository.instance;
      final chapters = await repo.getChaptersForClass(
        StudentClass.class4,
        board: BoardType.icse,
        subjectId: 'english',
      );

      expect(chapters.length, 12);
      expect(chapters[0].title, 'The Sentence: Subject, Predicate and Object');
    });

    test('Selecting Grammar track returns universal Class 4 English grammar chapters', () async {
      final repo = CurriculumRepository.instance;
      final chapters = await repo.getChaptersForClass(
        StudentClass.class4,
        board: BoardType.icse,
        subjectId: 'english',
        track: 'grammar',
      );

      expect(chapters.length, 12);
      expect(chapters[0].title, 'The Sentence: Subject, Predicate and Object');
    });

    test('Selecting Miranda Publisher returns Mridula Class 4 chapters', () async {
      final repo = CurriculumRepository.instance;
      final chapters = await repo.getChaptersForClass(
        StudentClass.class4,
        board: BoardType.icse,
        subjectId: 'hindi',
        publisher: 'miranda',
        track: 'literature',
      );

      expect(chapters.length, 22);
      expect(chapters[0].title, 'पुष्प की अभिलाषा');
      expect(chapters[0].author, 'माखनलाल चतुर्वेदी');
      expect(chapters[2].title, 'सच्चा मित्र');
      expect(chapters[5].title, 'मैं सबसे छोटी होऊँ');
      expect(chapters[5].author, 'सुमित्रानंदन पंत');
    });

    test('Selecting Hindi Grammar track returns universal Class 4 Hindi grammar chapters', () async {
      final repo = CurriculumRepository.instance;
      final chapters = await repo.getChaptersForClass(
        StudentClass.class4,
        board: BoardType.icse,
        subjectId: 'hindi',
        track: 'grammar',
      );

      expect(chapters.length, 12);
      expect(chapters[0].title, 'भाषा और व्याकरण के अंग');
      expect(chapters[1].title, 'वर्ण-संयोग और वर्तनी शुद्धि');
    });

    test('Class 4 EVS returns all 12 chapters for ICSE, CBSE, and State Board profiles', () async {
      final repo = CurriculumRepository.instance;

      final icseChapters = await repo.getChaptersForClass(
        StudentClass.class4,
        board: BoardType.icse,
        subjectId: 'evs',
      );
      expect(icseChapters.length, 12);
      expect(icseChapters[0].title, 'Going to School: Bridges and Paths Across India');
      expect(icseChapters[11].title, "A River's Journey: From Mountain to Sea");

      final cbseChapters = await repo.getChaptersForClass(
        StudentClass.class4,
        board: BoardType.cbse,
        subjectId: 'evs',
      );
      expect(cbseChapters.length, 12);

      final stateChapters = await repo.getChaptersForClass(
        StudentClass.class4,
        board: BoardType.stateBoard,
        subjectId: 'evs',
      );
      expect(stateChapters.length, 12);
    });
  });

  group('SubjectChaptersScreen Language UI Tests', () {
    testWidgets('SubjectChaptersScreen for English directly shows universal English Chapters without Literature tracks', (WidgetTester tester) async {
      final profile = const StudentProfile(
        board: BoardType.icse,
        studentClass: StudentClass.class4,
        studentName: 'Aahan Gupta',
        avatarIcon: '🦊',
      );
      await LocalStorageService.instance.saveStudentProfile(profile);

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
          child: const MaterialApp(
            home: SubjectChaptersScreen(
              subjectId: 'english',
              subjectName: 'English',
              emoji: '🇬🇧',
              primaryColor: Color(0xFF3B82F6),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Clean English chapters header is shown
      expect(find.text('📚 English Chapters'), findsOneWidget);

      // 2. No literature track or school book picker
      expect(find.text('Literature Reader'), findsNothing);
      expect(find.text('School Book'), findsNothing);
      expect(find.text('Literature Stories & Poems'), findsNothing);
    });

    testWidgets('SubjectChaptersScreen for Hindi has 2 options (Literature & Grammar) and switches dynamically', (WidgetTester tester) async {
      final profile = const StudentProfile(
        board: BoardType.icse,
        studentClass: StudentClass.class4,
        studentName: 'Aahan Gupta',
        avatarIcon: '🦊',
      );
      await LocalStorageService.instance.saveStudentProfile(profile);

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
          child: const MaterialApp(
            home: SubjectChaptersScreen(
              subjectId: 'hindi',
              subjectName: 'Hindi',
              emoji: '🇮🇳',
              primaryColor: Color(0xFFEA580C),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Literature Reader'), findsOneWidget);
      expect(find.text('Hindi Grammar'), findsOneWidget);
    });
  });
}
