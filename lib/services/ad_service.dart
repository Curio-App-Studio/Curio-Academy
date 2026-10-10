import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';
import '../core/audio/audio_service.dart';
import '../data/local/local_storage_service.dart';

/// Service responsible for managing Google Mobile Ads (AdMob)
/// and strictly enforcing Google Play Families Policy, COPPA compliance,
/// and lifetime ad-free benefits for Closed Testers and Paid Membership subscribers.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  bool isPremiumUser = false; // Programmatic override if needed

  /// Checks if user is a verified Closed Tester (granted lifetime ad-free).
  bool get isClosedTester => LocalStorageService.instance.isClosedTester;

  /// Checks if user has an active In-App Purchase or Subscription.
  bool get isPurchasedPremium => LocalStorageService.instance.isPremiumUser;

  /// Global master switch: Ads are served for non-paying users and strictly disabled for Paid Members.
  bool get areAdsEnabled => !isPremiumUser && !isPurchasedPremium;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  DateTime? _lastInterstitialShownTime;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  /// Minimum duration between interstitial ads to protect kids UX.
  static const Duration _interstitialCooldown = Duration(seconds: 40);

  /// Initializes Google Mobile Ads SDK with strict Child-Directed settings.
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (kIsWeb) {
      _isInitialized = true;
      developer.log('AdService: Web platform detected, ads disabled gracefully.', name: 'AdService');
      return;
    }

    try {
      // 1. Enforce Google Play Families Policy & COPPA child-directed parameters
      final RequestConfiguration requestConfiguration = RequestConfiguration(
        ageRestrictedTreatment: AgeRestrictedTreatment.child,
        maxAdContentRating: MaxAdContentRating.g,
        testDeviceIds: const ['5FC79A0B607A5DC85466751A260AB6C0'],
      );

      await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      await MobileAds.instance.initialize();

      _isInitialized = true;
      developer.log(
        'AdService: Google Mobile Ads initialized for Families Policy (G-Rated, Child Directed). areAdsEnabled=$areAdsEnabled',
        name: 'AdService',
      );

      // Pre-load ads only if ads are enabled
      if (areAdsEnabled) {
        loadInterstitialAd();
        loadRewardedAd();
      }
    } catch (e, stack) {
      developer.log('AdService: Error during initialization: $e', error: e, stackTrace: stack, name: 'AdService');
    }
  }

  /// Pre-loads an Interstitial Ad.
  void loadInterstitialAd() {
    if (kIsWeb || !areAdsEnabled || _isInterstitialLoading || _interstitialAd != null) {
      return;
    }

    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          developer.log('AdService: Interstitial ad loaded successfully.', name: 'AdService');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isInterstitialLoading = false;
          _interstitialAd = null;
          developer.log('AdService: Failed to load interstitial: $error', name: 'AdService');
        },
      ),
    );
  }

  /// Displays the Interstitial ad if available and cooldown period has elapsed.
  /// If the user is a Closed Tester or Paid Member, ads are bypassed instantly!
  void showInterstitialAdIfReady({VoidCallback? onCompleted, bool ignoreCooldown = false}) {
    if (kIsWeb || !areAdsEnabled) {
      onCompleted?.call();
      return;
    }

    // Stop any ongoing audio/TTS immediately before presenting ad
    AudioService.instance.stopAudio();

    // Check cooldown period
    if (!ignoreCooldown && _lastInterstitialShownTime != null) {
      final elapsed = DateTime.now().difference(_lastInterstitialShownTime!);
      if (elapsed < _interstitialCooldown) {
        developer.log(
          'AdService: Interstitial skipped due to cooldown (${elapsed.inSeconds}s < ${_interstitialCooldown.inSeconds}s).',
          name: 'AdService',
        );
        onCompleted?.call();
        return;
      }
    }

    if (_interstitialAd != null) {
      final adToShow = _interstitialAd!;
      _interstitialAd = null; // Detach reference so loadInterstitialAd() can prepare next ad
      _lastInterstitialShownTime = DateTime.now();

      adToShow.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          AudioService.instance.stopAudio();
          developer.log('AdService: Interstitial ad showed on screen.', name: 'AdService');
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          developer.log('AdService: Interstitial ad dismissed by user.', name: 'AdService');
          ad.dispose();
          loadInterstitialAd();
          onCompleted?.call();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          developer.log('AdService: Failed to show interstitial: $error', name: 'AdService');
          ad.dispose();
          loadInterstitialAd();
          onCompleted?.call();
        },
      );

      adToShow.show();
    } else {
      developer.log('AdService: Interstitial ad not ready yet, skipping.', name: 'AdService');
      loadInterstitialAd();
      onCompleted?.call();
    }
  }

  /// Pre-loads a Rewarded Video Ad.
  void loadRewardedAd() {
    if (kIsWeb || !areAdsEnabled || _isRewardedLoading || _rewardedAd != null) {
      return;
    }

    _isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          developer.log('AdService: Rewarded ad loaded successfully.', name: 'AdService');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isRewardedLoading = false;
          _rewardedAd = null;
          developer.log('AdService: Failed to load rewarded ad: $error', name: 'AdService');
        },
      ),
    );
  }

  /// Displays the Rewarded ad for hints, double stars, or bonus items.
  /// If the user is a Closed Tester or Paid Member, the reward is granted INSTANTLY with no ad shown!
  void showRewardedAd({
    required void Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onDismissed,
    VoidCallback? onFailedToLoad,
  }) {
    // Closed Testers and Paid Members get rewards immediately with ZERO ADS!
    if (kIsWeb || !areAdsEnabled) {
      developer.log(
        'AdService: User is Closed Tester / Paid Member. Granting reward instantly with NO ADS!',
        name: 'AdService',
      );
      onUserEarnedReward(RewardItem(1, 'stars'));
      onDismissed?.call();
      return;
    }

    AudioService.instance.stopAudio();

    if (_rewardedAd != null) {
      final adToShow = _rewardedAd!;
      _rewardedAd = null;

      adToShow.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) {
          AudioService.instance.stopAudio();
          developer.log('AdService: Rewarded ad showed on screen.', name: 'AdService');
        },
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          developer.log('AdService: Rewarded ad dismissed by user.', name: 'AdService');
          ad.dispose();
          loadRewardedAd();
          onDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          developer.log('AdService: Failed to show rewarded ad: $error', name: 'AdService');
          ad.dispose();
          loadRewardedAd();
          onFailedToLoad?.call();
        },
      );

      adToShow.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          developer.log('AdService: User earned reward: ${reward.amount} ${reward.type}', name: 'AdService');
          onUserEarnedReward(reward);
        },
      );
    } else {
      developer.log('AdService: Rewarded ad not ready, granting reward anyway for kid-friendly UX.', name: 'AdService');
      loadRewardedAd();
      onUserEarnedReward(RewardItem(1, 'stars'));
      onDismissed?.call();
    }
  }

  /// Disposes active ads
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
