import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/data/models/student_profile.dart';
import 'package:curio_math/services/cloud_progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
    await CloudProgressService().initialize();
  });

  group('CloudProgressService VIP Progress Sync & Restore Tests', () {
    test('Free user does not sync to cloud (VIP only)', () async {
      final storage = LocalStorageService.instance;
      await storage.cancelPremiumStatus();
      expect(CloudProgressService().isVipEligible, isFalse);

      final synced = await CloudProgressService().syncProgressToCloud();
      expect(synced, isFalse);
    });

    test('VIP user syncs progress successfully to cloud snapshot', () async {
      final storage = LocalStorageService.instance;
      // Mark as VIP
      await storage.setPremiumUser(true);
      expect(CloudProgressService().isVipEligible, isTrue);

      // Setup sample student progress
      await storage.saveStudentProfile(
        const StudentProfile(
          studentName: 'Aarav Sharma',
          avatarIcon: '🦁',
          board: BoardType.cbse,
          studentClass: StudentClass.class2,
        ),
      );
      await storage.addBonusStars(15);
      await storage.markChapterCompleted('math_ch1');

      final synced = await CloudProgressService().syncProgressToCloud();
      expect(synced, isTrue);
      expect(CloudProgressService().lastSyncTime, isNotNull);

      // Verify snapshot contains student progress
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('curio_vip_cached_cloud_snapshot');
      expect(cachedJson, isNotNull);
      expect(cachedJson, contains('Aarav Sharma'));
      expect(cachedJson, contains('math_ch1'));
      expect(cachedJson, contains('15'));
    });

    test('Restoring cloud progress reconstructs full student profile and stars', () async {
      final storage = LocalStorageService.instance;
      await storage.setPremiumUser(true);

      // 1. Create original VIP profile & progress
      await storage.saveStudentProfile(
        const StudentProfile(
          studentName: 'Priya Patel',
          avatarIcon: '🐼',
          board: BoardType.icse,
          studentClass: StudentClass.ukg,
        ),
      );
      await storage.addBonusStars(25);
      await storage.markChapterCompleted('ukg_counting_1');
      await CloudProgressService().syncProgressToCloud();

      // 2. Simulate complete app reset (wiping student progress)
      await storage.resetStudentProgress();
      await storage.saveStudentProfile(
        const StudentProfile(
          studentName: 'Young Explorer',
          avatarIcon: '🦊',
          board: BoardType.cbse,
          studentClass: StudentClass.lkg,
        ),
      );
      expect(storage.totalStars, equals(0));

      // 3. Restore VIP progress from cloud
      final result = await CloudProgressService().restoreVipProgress();
      expect(result.status, CloudRestoreStatus.success);
      expect(result.studentName, 'Priya Patel');

      // Verify restored student profile in LocalStorageService
      final profile = await storage.getStudentProfile();
      expect(profile?.studentName, 'Priya Patel');
      expect(profile?.avatarIcon, '🐼');
      expect(profile?.board, BoardType.icse);
      expect(profile?.studentClass, StudentClass.ukg);
      expect(storage.isChapterCompleted('ukg_counting_1'), isTrue);
      expect(storage.totalStars, greaterThanOrEqualTo(25));
    });

    test('Non-VIP user cannot restore progress', () async {
      final storage = LocalStorageService.instance;
      await storage.cancelPremiumStatus();

      final result = await CloudProgressService().restoreVipProgress();
      expect(result.status, CloudRestoreStatus.notVip);
    });

    test('resetProgressOnly clears stars & chapters but preserves profile and VIP status', () async {
      final storage = LocalStorageService.instance;
      await storage.setPremiumUser(true);
      await storage.saveStudentProfile(
        const StudentProfile(
          studentName: 'Aahan',
          avatarIcon: '🦁',
          board: BoardType.icse,
          studentClass: StudentClass.class4,
        ),
      );
      await storage.addBonusStars(30);
      await storage.markChapterCompleted('ch_math_4');

      expect(storage.totalStars, greaterThanOrEqualTo(30));
      expect(storage.isChapterCompleted('ch_math_4'), isTrue);

      // Perform progress reset
      await storage.resetProgressOnly();

      // Stars and chapters are reset to 0
      expect(storage.totalStars, equals(0));
      expect(storage.totalPoints, equals(0));
      expect(storage.isChapterCompleted('ch_math_4'), isFalse);

      // Profile and VIP status are preserved
      final profile = await storage.getStudentProfile();
      expect(profile?.studentName, equals('Aahan'));
      expect(profile?.board, equals(BoardType.icse));
      expect(profile?.studentClass, equals(StudentClass.class4));
      expect(storage.isPremiumUser, isTrue);
    });

    test('resetAllAppDataExceptMembership wipes profile and progress while STRICTLY preserving VIP Membership', () async {
      final storage = LocalStorageService.instance;
      await storage.setPremiumUser(true);
      await storage.setBoundMembershipEmail('gpt.vivek@gmail.com');
      await storage.saveStudentProfile(
        const StudentProfile(
          studentName: 'Aahan',
          avatarIcon: '🦁',
          board: BoardType.icse,
          studentClass: StudentClass.class4,
        ),
      );
      await storage.addBonusStars(50);
      await storage.setOnboarded(true);

      // Perform complete app data reset
      await storage.resetAllAppDataExceptMembership();

      // Profile and onboarding are wiped
      final profile = await storage.getStudentProfile();
      expect(profile, isNull);
      expect(storage.isOnboarded(), isFalse);
      expect(storage.totalStars, equals(0));

      // VIP Membership and Google Account binding are STRICTLY preserved
      expect(storage.isPremiumUser, isTrue);
      expect(storage.boundMembershipEmail, equals('gpt.vivek@gmail.com'));
    });

    test('deleteCloudData clears local cloud snapshot and last sync time', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('curio_vip_cached_cloud_snapshot', '{"stars": 10}');
      await prefs.setString('curio_vip_last_cloud_sync', DateTime.now().toIso8601String());

      // In unit test environment without real Firebase, deleteCloudData handles gracefully
      await CloudProgressService().deleteCloudData();

      expect(prefs.getString('curio_vip_cached_cloud_snapshot'), isNull);
      expect(prefs.getString('curio_vip_last_cloud_sync'), isNull);
      expect(CloudProgressService().lastSyncTime, isNull);
    });
  });
}
