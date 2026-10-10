import 'dart:io';

/// Centralized Google Mobile Ads (AdMob) configuration.
///
/// Current IDs are Google's official AdMob test identifiers.
/// When you set up your Google AdMob account, simply replace the production IDs
/// below with your real AdMob App and Ad Unit IDs.
class AdConfig {
  /// Toggle this to false when you are ready to use real production AdMob IDs.
  static const bool isTestMode = false;

  // ---------------------------------------------------------------------------
  // Google Official Test IDs (Safe for testing without AdMob account)
  // ---------------------------------------------------------------------------
  static const String _testAndroidBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testIosBannerId =
      'ca-app-pub-3940256099942544/2934735716';

  static const String _testAndroidInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testIosInterstitialId =
      'ca-app-pub-3940256099942544/4411468910';

  static const String _testAndroidRewardedId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testIosRewardedId =
      'ca-app-pub-3940256099942544/1712485313';

  // ---------------------------------------------------------------------------
  // Production IDs
  // ---------------------------------------------------------------------------
  static const String _prodAndroidBannerId = 'ca-app-pub-7955725236973930/4664708667';
  static const String _prodIosBannerId = 'ca-app-pub-7955725236973930/4664708667';

  static const String _prodAndroidInterstitialId = 'ca-app-pub-7955725236973930/5168019975';
  static const String _prodIosInterstitialId = 'ca-app-pub-7955725236973930/5168019975';

  static const String _prodAndroidRewardedId = 'ca-app-pub-7955725236973930/9051424669';
  static const String _prodIosRewardedId = 'ca-app-pub-7955725236973930/9051424669';

  /// Returns the appropriate Banner Ad Unit ID based on platform & test mode.
  static String get bannerAdUnitId {
    if (isTestMode) {
      return Platform.isAndroid ? _testAndroidBannerId : _testIosBannerId;
    }
    return Platform.isAndroid ? _prodAndroidBannerId : _prodIosBannerId;
  }

  /// Returns the appropriate Interstitial Ad Unit ID based on platform & test mode.
  static String get interstitialAdUnitId {
    if (isTestMode) {
      return Platform.isAndroid
          ? _testAndroidInterstitialId
          : _testIosInterstitialId;
    }
    return Platform.isAndroid
        ? _prodAndroidInterstitialId
        : _prodIosInterstitialId;
  }

  /// Returns the appropriate Rewarded Ad Unit ID based on platform & test mode.
  static String get rewardedAdUnitId {
    if (isTestMode) {
      return Platform.isAndroid
          ? _testAndroidRewardedId
          : _testIosRewardedId;
    }
    return Platform.isAndroid
        ? _prodAndroidRewardedId
        : _prodIosRewardedId;
  }
}
