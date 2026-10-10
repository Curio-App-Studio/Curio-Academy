import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/services/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
    AdService().resetCadenceCounters();
    AdService().isPremiumUser = false;
    AdService().disableAdNetworkForTesting = true;
  });

  group('AdService 2-Activity Cadence Counter Tests', () {
    test('Test cadence triggers ad exactly after 2 tests', () {
      final adService = AdService();
      expect(adService.testCount, 0);

      bool completed1 = false;
      adService.recordTestCompleted(onCompleted: () => completed1 = true);
      expect(adService.testCount, 1);
      expect(completed1, isTrue);

      bool completed2 = false;
      adService.recordTestCompleted(onCompleted: () => completed2 = true);
      // Counter should reset to 0 after triggering on the 2nd test
      expect(adService.testCount, 0);
      expect(completed2, isTrue);

      // 3rd test: counter becomes 1
      adService.recordTestCompleted();
      expect(adService.testCount, 1);

      // 4th test: counter resets to 0
      adService.recordTestCompleted();
      expect(adService.testCount, 0);
    });

    test('Story cadence triggers ad exactly after 2 stories', () {
      final adService = AdService();
      expect(adService.storyCount, 0);

      bool completed1 = false;
      adService.recordStoryCompleted(onCompleted: () => completed1 = true);
      expect(adService.storyCount, 1);
      expect(completed1, isTrue);

      bool completed2 = false;
      adService.recordStoryCompleted(onCompleted: () => completed2 = true);
      expect(adService.storyCount, 0);
      expect(completed2, isTrue);

      // 3rd story
      adService.recordStoryCompleted();
      expect(adService.storyCount, 1);

      // 4th story
      adService.recordStoryCompleted();
      expect(adService.storyCount, 0);
    });

    test('Rhyme cadence triggers ad exactly after 2 rhymes', () {
      final adService = AdService();
      expect(adService.rhymeCount, 0);

      bool completed1 = false;
      adService.recordRhymeCompleted(onCompleted: () => completed1 = true);
      expect(adService.rhymeCount, 1);
      expect(completed1, isTrue);

      bool completed2 = false;
      adService.recordRhymeCompleted(onCompleted: () => completed2 = true);
      expect(adService.rhymeCount, 0);
      expect(completed2, isTrue);

      // 3rd rhyme
      adService.recordRhymeCompleted();
      expect(adService.rhymeCount, 1);

      // 4th rhyme
      adService.recordRhymeCompleted();
      expect(adService.rhymeCount, 0);
    });

    test('Cadences operate independently', () {
      final adService = AdService();

      adService.recordTestCompleted();
      expect(adService.testCount, 1);
      expect(adService.storyCount, 0);
      expect(adService.rhymeCount, 0);

      adService.recordStoryCompleted();
      expect(adService.testCount, 1);
      expect(adService.storyCount, 1);
      expect(adService.rhymeCount, 0);

      adService.recordRhymeCompleted();
      expect(adService.testCount, 1);
      expect(adService.storyCount, 1);
      expect(adService.rhymeCount, 1);

      // Completing 2nd test resets only testCount
      adService.recordTestCompleted();
      expect(adService.testCount, 0);
      expect(adService.storyCount, 1);
      expect(adService.rhymeCount, 1);
    });

    test('Premium users bypass ads immediately while maintaining safe callbacks', () {
      final adService = AdService();
      adService.isPremiumUser = true;

      bool called = false;
      adService.recordTestCompleted(onCompleted: () => called = true);
      expect(called, isTrue);
      expect(adService.testCount, 1);

      bool secondCalled = false;
      adService.recordTestCompleted(onCompleted: () => secondCalled = true);
      expect(secondCalled, isTrue);
      expect(adService.testCount, 0);
    });
  });
}
