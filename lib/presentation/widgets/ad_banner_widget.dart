import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../config/ad_config.dart';
import '../../data/local/local_storage_service.dart';
import '../../services/ad_service.dart';

/// Reusable Anchored Adaptive Banner Ad Widget that stays pinned to the bottom
/// across ALL devices (both mobile phones and large tablets).
/// Strictly complies with Google Play Families & COPPA policies, and
/// collapses to zero height for VIP members and closed testers.
class AdBannerWidget extends StatefulWidget {
  final AdSize? adSize;

  const AdBannerWidget({
    super.key,
    this.adSize,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    LocalStorageService.instance.premiumUserNotifier.addListener(_onPremiumChanged);
  }

  void _onPremiumChanged() {
    if (mounted) {
      if (!AdService().areAdsEnabled) {
        _bannerAd?.dispose();
        _bannerAd = null;
        _isLoaded = false;
      }
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null && !_isLoading && AdService().areAdsEnabled) {
      _loadBanner();
    }
  }

  Future<void> _loadBanner() async {
    if (kIsWeb || !AdService().areAdsEnabled || _isLoading) return;

    _isLoading = true;
    final width = MediaQuery.of(context).size.width.truncate();

    // Determine optimal size for phones vs tablets (width >= 728dp is tablet)
    AdSize size = widget.adSize ?? (width >= 728 ? AdSize.leaderboard : AdSize.banner);

    if (!mounted || !AdService().areAdsEnabled) {
      _isLoading = false;
      return;
    }

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isLoaded = true;
            _isLoading = false;
          });
          developer.log('AdBannerWidget: Banner loaded for width=$width, size=$size', name: 'AdBanner');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          developer.log('AdBannerWidget failed to load: $error', name: 'AdBannerWidget');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _isLoading = false;
              _bannerAd = null;
            });
          }
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    LocalStorageService.instance.premiumUserNotifier.removeListener(_onPremiumChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService().areAdsEnabled || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final adHeight = _bannerAd!.size.height.toDouble();
    final adWidth = _bannerAd!.size.width.toDouble();

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        height: adHeight,
        color: Colors.white,
        alignment: Alignment.center,
        child: SizedBox(
          width: adWidth,
          height: adHeight,
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}
