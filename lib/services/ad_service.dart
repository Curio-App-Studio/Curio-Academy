import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';
import '../core/audio/audio_service.dart';

/// Service responsible for managing Google Mobile Ads (AdMob)
/// and strictly enforcing Google Play Families Policy & COPPA compliance.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  bool isPremiumUser = false; // Set to true to disable all ads

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  DateTime? _lastInterstitialShownTime;

  /// Minimum duration between interstitial ads to protect kids UX.
  static const Duration _interstitialCooldown = Duration(minutes: 3);

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
      );

      await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      await MobileAds.instance.initialize();

      _isInitialized = true;
      developer.log('AdService: Google Mobile Ads initialized for Families Policy (G-Rated, Child Directed).', name: 'AdService');

      // Pre-load the first interstitial ad
      loadInterstitialAd();
    } catch (e, stack) {
      developer.log('AdService: Error during initialization: $e', error: e, stackTrace: stack, name: 'AdService');
    }
  }

  /// Pre-loads an Interstitial Ad.
  void loadInterstitialAd() {
    if (kIsWeb || isPremiumUser || _isInterstitialLoading || _interstitialAd != null) {
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
  /// Calls [onCompleted] strictly AFTER the user dismisses the ad (or if ad is skipped/fails),
  /// ensuring the speaker and future timers only start when the ad is closed.
  void showInterstitialAdIfReady({VoidCallback? onCompleted}) {
    if (kIsWeb || isPremiumUser) {
      onCompleted?.call();
      return;
    }

    // Stop any ongoing audio/TTS immediately before presenting ad
    AudioService.instance.stopAudio();

    // Check cooldown period
    if (_lastInterstitialShownTime != null) {
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
          // Extra safety check: stop audio as soon as full-screen ad opens
          AudioService.instance.stopAudio();
          developer.log('AdService: Interstitial ad showed on screen.', name: 'AdService');
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          developer.log('AdService: Interstitial ad dismissed by user.', name: 'AdService');
          ad.dispose();
          loadInterstitialAd();
          // Advance to next question and start future timer ONLY AFTER ad is closed!
          onCompleted?.call();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          developer.log('AdService: Failed to show interstitial: $error', name: 'AdService');
          ad.dispose();
          loadInterstitialAd();
          // Fallback: proceed to next question if ad fails to show
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

  /// Disposes active ads
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
