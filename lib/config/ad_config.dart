import 'dart:io';

/// Centralized Google Mobile Ads (AdMob) configuration.
///
/// Current IDs are Google's official AdMob test identifiers.
/// When you set up your Google AdMob account, simply replace the production IDs
/// below with your real AdMob App and Ad Unit IDs.
class AdConfig {
  /// Toggle this to false when you are ready to use real production AdMob IDs.
  static const bool isTestMode = true;

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

  // ---------------------------------------------------------------------------
  // Production IDs (Replace these when you create your AdMob account)
  // ---------------------------------------------------------------------------
  static const String _prodAndroidBannerId = 'ca-app-pub-YOUR_ADMOB_PUB_ID/BANNER_ID';
  static const String _prodIosBannerId = 'ca-app-pub-YOUR_ADMOB_PUB_ID/BANNER_ID';

  static const String _prodAndroidInterstitialId = 'ca-app-pub-YOUR_ADMOB_PUB_ID/INTERSTITIAL_ID';
  static const String _prodIosInterstitialId = 'ca-app-pub-YOUR_ADMOB_PUB_ID/INTERSTITIAL_ID';

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
}
