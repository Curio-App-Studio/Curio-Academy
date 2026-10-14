import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/audio/audio_service.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../services/cloud_progress_service.dart';
import '../../../services/in_app_purchase_service.dart';
import 'subscription_history_sheet.dart';

/// Modal bottom sheet allowing parents to purchase ad-free lifetime membership or subscriptions,
/// view active subscription details (plan name, start date, renewal/end date),
/// and manage or cancel subscriptions via Google Play Store.
/// Protected by a child-safe Parental Gate complying with Google Play Families Policy.
class MembershipPaywallSheet extends StatefulWidget {
  const MembershipPaywallSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const MembershipPaywallSheet(),
    );
  }

  @override
  State<MembershipPaywallSheet> createState() => _MembershipPaywallSheetState();
}

class _MembershipPaywallSheetState extends State<MembershipPaywallSheet> {
  bool _parentalGatePassed = false;
  late int _gateNum1;
  late int _gateNum2;
  late int _gateAnswer;
  final TextEditingController _gateController = TextEditingController();
  String? _gateError;
  bool _isRestoringPurchases = false;
  bool _isSyncingProgress = false;

  static const _monthsEn = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const _monthsHi = [
    'जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
    'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'
  ];

  @override
  void initState() {
    super.initState();
    _generateParentalChallenge();
    InAppPurchaseService.instance.purchasePendingNotifier.addListener(_onIapStateChanged);
    LocalStorageService.instance.premiumUserNotifier.addListener(_onIapStateChanged);
    LocalStorageService.instance.subscriptionUpdateNotifier.addListener(_onIapStateChanged);
    if (LocalStorageService.instance.isPremiumUser &&
        CloudProgressService().userEmailNotifier.value == null) {
      CloudProgressService().autoSyncAndRestore();
    }
  }

  void _onIapStateChanged() {
    if (mounted) setState(() {});
  }

  void _generateParentalChallenge() {
    final rand = Random();
    _gateNum1 = rand.nextInt(7) + 6; // 6 to 12
    _gateNum2 = rand.nextInt(7) + 6; // 6 to 12
    _gateAnswer = _gateNum1 * _gateNum2;
    _gateController.clear();
    _gateError = null;
  }

  void _verifyParentalGate() {
    final entered = int.tryParse(_gateController.text.trim());
    if (entered == _gateAnswer) {
      AudioService.instance.playSfx(CurioSfx.starAward);
      setState(() {
        _parentalGatePassed = true;
      });
    } else {
      AudioService.instance.playSfx(CurioSfx.gentleWobble);
      setState(() {
        _gateError = 'Incorrect answer. Please ask a grown-up!';
        _generateParentalChallenge();
      });
    }
  }

  @override
  void dispose() {
    InAppPurchaseService.instance.purchasePendingNotifier.removeListener(_onIapStateChanged);
    LocalStorageService.instance.premiumUserNotifier.removeListener(_onIapStateChanged);
    LocalStorageService.instance.subscriptionUpdateNotifier.removeListener(_onIapStateChanged);
    _gateController.dispose();
    super.dispose();
  }

  String _formatDisplayDate(DateTime? dt, bool isHindi, {bool isLifetime = false}) {
    if (isLifetime) {
      return isHindi ? 'हमेशा के लिए (आजीवन एक्सेस) 👑' : 'Never Expires (Lifetime Access) 👑';
    }
    if (dt == null) {
      return isHindi ? 'लोड हो रहा है...' : 'Calculating renewal...';
    }
    final months = isHindi ? _monthsHi : _monthsEn;
    final monthName = months[dt.month - 1];
    return '${dt.day} $monthName ${dt.year}';
  }

  String _getPlanTitle(String? subType, bool isHindi) {
    if (subType == InAppProductIds.lifetimeNoAds) {
      return isHindi ? 'आजीवन पास (लाइफटाइम VIP)' : 'Lifetime Pass (Pay Once, Keep Forever)';
    } else if (subType == InAppProductIds.annualSubscription) {
      return isHindi ? 'वार्षिक वीआईपी सदस्यता (12 माह)' : 'Annual VIP Subscription (12 Months)';
    } else if (subType == InAppProductIds.monthlySubscription) {
      return isHindi ? 'मासिक वीआईपी सदस्यता' : 'Monthly VIP Subscription';
    }
    return isHindi ? 'वीआईपी सदस्यता' : 'VIP Active Membership';
  }

  String _getPlanBillingFrequency(String? subType, bool isHindi) {
    if (subType == InAppProductIds.lifetimeNoAds) {
      return isHindi ? '₹799 • एकमुश्त स्थायी भुगतान' : '₹799.00 • One-Time Permanent';
    } else if (subType == InAppProductIds.annualSubscription) {
      return isHindi ? '₹399 / वर्ष • वार्षिक नवीनीकरण' : '₹399.00 / year • Renews yearly';
    } else if (subType == InAppProductIds.monthlySubscription) {
      return isHindi ? '₹79 / माह • मासिक नवीनीकरण' : '₹79.00 / month • Renews monthly';
    }
    return isHindi ? 'सक्रिय वीआईपी' : 'Active VIP';
  }

  Future<void> _openGooglePlaySubscriptions({String? sku}) async {
    final String urlStr = (sku != null && sku.isNotEmpty)
        ? 'https://play.google.com/store/account/subscriptions?package=com.curio.academy&sku=$sku'
        : 'https://play.google.com/store/account/subscriptions?package=com.curio.academy';
    final Uri uri = Uri.parse(urlStr);
    final Uri fallbackUri = Uri.parse('https://play.google.com/store/account/subscriptions');

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please open Google Play Store > Subscriptions to manage your plan.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = LocalStorageService.instance.getAppLanguage() == 'hi';
    final isPremium = LocalStorageService.instance.isPremiumUser;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: (!_parentalGatePassed && !isPremium)
              ? _buildParentalGate(isHindi)
              : _buildMembershipContent(isHindi, isPremium),
        ),
      ),
    );
  }

  /// Child-safe challenge required by Google Play Families Policy
  Widget _buildParentalGate(bool isHindi) {
    return Column(
      key: const ValueKey('parental_gate'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Color(0xFFFEF3C7),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.family_restroom_rounded, size: 36, color: Color(0xFFD97706)),
        ),
        const SizedBox(height: 14),
        Text(
          isHindi ? 'अभिभावक सुरक्षा जाँच' : 'Grown-Ups Only',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isHindi
              ? 'कृपया आगे बढ़ने के लिए निम्नलिखित गणित प्रश्न हल करें:'
              : 'Please ask a parent to answer this question to access membership options:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
          ),
          child: Text(
            '$_gateNum1 × $_gateNum2 = ?',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 140,
          child: TextField(
            controller: _gateController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            autofocus: true,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Answer',
              errorText: _gateError,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onSubmitted: (_) => _verifyParentalGate(),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _verifyParentalGate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7B25),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(isHindi ? 'जारी रखें' : 'Continue', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleRestorePurchases(bool isHindi, {bool showInitialSnackbar = true}) async {
    if (_isRestoringPurchases) return;
    _isRestoringPurchases = true;
    try {
      if (showInitialSnackbar && mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isHindi ? 'Google Play से खरीद पुनर्स्थापित की जा रही है...' : 'Restoring previous purchases from Google Play...'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      await InAppPurchaseService.instance.restorePurchases();
      final progressResult = await CloudProgressService().restoreVipProgress();
      if (mounted) {
        setState(() {});
        final isRestored = LocalStorageService.instance.isPremiumUser;
        String message = isRestored
            ? (isHindi ? 'VIP खरीद सफलतापूर्वक पुनर्स्थापित!' : 'VIP Purchases successfully restored!')
            : (isHindi ? 'कोई पूर्व खरीद नहीं मिली।' : 'No previous purchases found.');

        if (progressResult.status == CloudRestoreStatus.success) {
          message += isHindi
              ? ' (${progressResult.restoredStars ?? 0} सितारे और प्रोग्रेस वापस आ गए!)'
              : ' (${progressResult.restoredStars ?? 0} stars & progress restored!)';
        }

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isRestored ? const Color(0xFF059669) : null,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      _isRestoringPurchases = false;
    }
  }

  /// Full Membership & In-App Purchase Options
  Widget _buildMembershipContent(bool isHindi, bool isPremium) {
    final iapService = InAppPurchaseService.instance;
    final subType = LocalStorageService.instance.premiumSubscriptionType;
    final startDate = LocalStorageService.instance.subscriptionStartDate;
    final endDate = LocalStorageService.instance.subscriptionEndDate;
    final isCanceled = LocalStorageService.instance.isSubscriptionCanceled;
    final isLifetime = subType == InAppProductIds.lifetimeNoAds;

    return RefreshIndicator(
      color: const Color(0xFFFF9800),
      backgroundColor: Colors.white,
      displacement: 24,
      onRefresh: () => _handleRestorePurchases(isHindi, showInitialSnackbar: false),
      child: SingleChildScrollView(
        key: const ValueKey('membership_content'),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade600),
                  ),
                  tooltip: isHindi ? 'बंद करें' : 'Close',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Header Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFF5722)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'CURIO VIP MEMBERSHIP',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Text(
              isHindi ? '100% विज्ञापन-मुक्त पढ़ाई' : '100% Ad-Free Learning Pass',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            Text(
              isHindi
                  ? 'शांत, सुरक्षित और निर्बाध अध्ययन अनुभव के लिए विज्ञापन हटाएँ'
                  : 'Enjoy distraction-free focus, instant solutions, and bonus stars!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe_down_rounded, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  isHindi ? 'खरीद पुनर्स्थापित करने हेतु नीचे खींचें' : 'Pull down to refresh & restore purchases',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),

          // ACTIVE SUBSCRIPTION & CURRENT PLAN DETAILS
          if (isPremium) ...[
            _buildActiveSubscriptionCard(
              isHindi: isHindi,
              subType: subType,
              startDate: startDate,
              endDate: endDate,
              isCanceled: isCanceled,
            ),
            const SizedBox(height: 20),
          ],

          // Benefits List
          _buildBenefitRow(Icons.block_rounded, Colors.redAccent, isHindi ? 'शून्य विज्ञापन (No Banners & No Interstitials)' : 'Zero Ads (No Banners, No Pop-ups)'),
          _buildBenefitRow(
            Icons.cloud_sync_rounded,
            const Color(0xFF0D9488),
            isHindi
                ? 'Google अकाउंट पर प्रोग्रेस बैकअप (रीसेट के बाद भी सुरक्षित)'
                : 'Cloud Progress Backup via Google Account (Never lose progress after reset)',
          ),
          _buildBenefitRow(Icons.lightbulb_rounded, Colors.amber, isHindi ? 'तुरंत संकेत और समाधान (बिना वीडियो देखे)' : 'Instant Hints & Step-by-Step Solutions (No Video Ads)'),
          _buildBenefitRow(Icons.star_rounded, Colors.orange, isHindi ? '2x सितारे और रिवार्ड्स' : 'Double Stars & Exploration Rewards'),
          _buildBenefitRow(Icons.security_rounded, Colors.blue, isHindi ? 'बच्चों के लिए 100% सुरक्षित और COPPA अनुपालन' : 'Child-Safe & Family Play Certified'),
          const SizedBox(height: 20),

          // Plans Section
          if (!isLifetime) ...[
            Row(
              children: [
                Text(
                  isPremium
                      ? (isHindi ? 'प्लान बदलें या अपग्रेड करें (Upgrade)' : 'Switch or Upgrade Plan')
                      : (isHindi ? 'सदस्यता योजनाएं (Plans)' : 'Choose Your Plan'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Option 1: Lifetime Pass (One-Time Purchase)
            _buildPlanCard(
              title: isHindi ? 'आजीवन पास (एकमुश्त)' : 'Lifetime Pass (Pay Once, Keep Forever)',
              subtitle: isHindi ? 'LKG से कक्षा 8वीं तक सभी विषय • हमेशा के लिए' : 'LKG to Class 8 • All Subjects Forever',
              price: iapService.products.where((p) => p.id == InAppProductIds.lifetimeNoAds).isNotEmpty
                  ? iapService.products.firstWhere((p) => p.id == InAppProductIds.lifetimeNoAds).price
                  : '₹799',
              badge: isPremium
                  ? (isHindi ? 'स्थायी अपग्रेड (आजीवन VIP) 👑' : 'UPGRADE TO LIFETIME 👑')
                  : (isHindi ? 'सर्वोत्तम मूल्य (आजीवन VIP) 👑' : 'BEST VALUE (LIFETIME VIP) 👑'),
              badgeColor: const Color(0xFFFF7B25),
              isCurrentPlan: subType == InAppProductIds.lifetimeNoAds,
              isHindi: isHindi,
              onTap: () => _handlePurchase(
                iapService,
                InAppProductIds.lifetimeNoAds,
                planName: isHindi ? 'आजीवन पास (LKG से 8वीं तक)' : 'Lifetime Pass (LKG to Class 8)',
                price: '₹799',
                isHindi: isHindi,
              ),
            ),
            const SizedBox(height: 10),

            // Option 2: Annual VIP Subscription
            _buildPlanCard(
              title: isHindi ? 'वार्षिक वीआईपी सदस्यता (12 माह)' : 'Annual VIP Subscription (12 Months)',
              subtitle: isHindi ? 'सिर्फ ₹33/माह • 60% की भारी बचत' : 'Just ₹33/month • Save 60% vs monthly',
              price: iapService.products.where((p) => p.id == InAppProductIds.annualSubscription).isNotEmpty
                  ? (isHindi
                      ? '${iapService.products.firstWhere((p) => p.id == InAppProductIds.annualSubscription).price}/वर्ष'
                      : '${iapService.products.firstWhere((p) => p.id == InAppProductIds.annualSubscription).price}/year')
                  : (isHindi ? '₹399/वर्ष' : '₹399/year'),
              badge: subType == InAppProductIds.annualSubscription
                  ? (isHindi ? 'वर्तमान सक्रिय प्लान ✓' : 'YOUR CURRENT PLAN ✓')
                  : (isPremium && subType == InAppProductIds.monthlySubscription
                      ? (isHindi ? 'वार्षिक में अपग्रेड करें (60% बचत) 🌟' : 'UPGRADE & SAVE 60% 🌟')
                      : (isHindi ? 'सर्वाधिक लोकप्रिय 🌟 (₹33/माह)' : 'MOST POPULAR 🌟 (₹33/mo)')),
              badgeColor: const Color(0xFF10B981),
              isCurrentPlan: subType == InAppProductIds.annualSubscription,
              isHindi: isHindi,
              onTap: () => _handlePurchase(
                iapService,
                InAppProductIds.annualSubscription,
                planName: isHindi ? 'वार्षिक वीआईपी (12 माह)' : 'Annual VIP (12 Months)',
                price: isHindi ? '₹399/वर्ष' : '₹399/year',
                isHindi: isHindi,
              ),
            ),
            const SizedBox(height: 10),

            // Option 3: Monthly VIP Subscription (Only shown if user does not already have annual)
            if (subType != InAppProductIds.annualSubscription) ...[
              _buildPlanCard(
                title: isHindi ? 'मासिक वीआईपी सदस्यता' : 'Monthly VIP Subscription',
                subtitle: isHindi ? 'लचीला प्लान • कभी भी रद्द करें' : 'Flexible plan • Cancel anytime',
                price: iapService.products.where((p) => p.id == InAppProductIds.monthlySubscription).isNotEmpty
                    ? (isHindi
                        ? '${iapService.products.firstWhere((p) => p.id == InAppProductIds.monthlySubscription).price}/माह'
                        : '${iapService.products.firstWhere((p) => p.id == InAppProductIds.monthlySubscription).price}/month')
                    : (isHindi ? '₹79/माह' : '₹79/month'),
                badge: subType == InAppProductIds.monthlySubscription
                    ? (isHindi ? 'वर्तमान सक्रिय प्लान ✓' : 'YOUR CURRENT PLAN ✓')
                    : null,
                badgeColor: const Color(0xFF3B82F6),
                isCurrentPlan: subType == InAppProductIds.monthlySubscription,
                isHindi: isHindi,
                onTap: () => _handlePurchase(
                  iapService,
                  InAppProductIds.monthlySubscription,
                  planName: isHindi ? 'मासिक वीआईपी सदस्यता' : 'Monthly VIP Subscription',
                  price: isHindi ? '₹79/माह' : '₹79/month',
                  isHindi: isHindi,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ] else ...[
            // User owns Lifetime Pass - show congratulatory permanent card
            _buildLifetimeUnlockedBanner(isHindi),
            const SizedBox(height: 16),
          ],

          // Google Play Policy: Explicit Subscription Terms & Cancellation Notice
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              isHindi
                  ? 'सदस्यता स्वतः नवीनीकृत होती है। Google Play Store > Subscriptions से कभी भी प्रबंधित या रद्द करें।'
                  : 'Subscriptions auto-renew unless canceled. Manage or cancel anytime in Google Play Store > Subscriptions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                color: Colors.grey.shade500,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Polished Action Buttons: Restore Purchases & Order History
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      AudioService.instance.playSfx(CurioSfx.click);
                      _handleRestorePurchases(isHindi, showInitialSnackbar: true);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.restore_rounded, size: 16, color: Color(0xFF475569)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              isHindi ? 'खरीद पुनर्स्थापित' : 'Restore Purchases',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      AudioService.instance.playSfx(CurioSfx.click);
                      SubscriptionHistorySheet.show(context);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long_rounded, size: 16, color: Color(0xFF475569)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              isHindi ? 'ऑर्डर विवरण' : 'Order History',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Clean Close Action
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isHindi ? 'शीट बंद करें' : 'Close',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  /// Detailed Active Subscription Overview Card showing Plan Name, End/Renewal Date, & Cancel Option
  Widget _buildActiveSubscriptionCard({
    required bool isHindi,
    required String? subType,
    required DateTime? startDate,
    required DateTime? endDate,
    required bool isCanceled,
  }) {
    final isLifetime = subType == InAppProductIds.lifetimeNoAds;
    final planTitle = _getPlanTitle(subType, isHindi);
    final planPrice = _getPlanBillingFrequency(subType, isHindi);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLifetime
              ? [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)]
              : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLifetime ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: (isLifetime ? const Color(0xFFF59E0B) : const Color(0xFF10B981)).withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Badge & Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLifetime ? const Color(0xFFF59E0B) : const Color(0xFF059669),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLifetime ? Icons.workspace_premium_rounded : Icons.verified_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? 'वर्तमान सक्रिय प्लान' : 'CURRENT ACTIVE PLAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: isLifetime ? const Color(0xFFB45309) : const Color(0xFF047857),
                      ),
                    ),
                    Text(
                      planTitle,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isCanceled
                      ? const Color(0xFFFEF2F2)
                      : (isLifetime ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCanceled
                        ? const Color(0xFFEF4444)
                        : (isLifetime ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isCanceled
                            ? const Color(0xFFEF4444)
                            : (isLifetime ? const Color(0xFFD97706) : const Color(0xFF059669)),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isCanceled
                          ? (isHindi ? 'रद्द' : 'Canceled')
                          : (isHindi ? 'सक्रिय' : 'Active'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isCanceled
                            ? const Color(0xFFDC2626)
                            : (isLifetime ? const Color(0xFFB45309) : const Color(0xFF047857)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 12),

          // Pricing & Billing Frequency
          Row(
            children: [
              Text(
                isHindi ? 'शुल्क:' : 'Billing:',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  planPrice,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Started Date
          if (startDate != null) ...[
            Row(
              children: [
                Text(
                  isHindi ? 'शुरुआत तिथि:' : 'Started On:',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDisplayDate(startDate, isHindi),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // End / Renewal Date
          Row(
            children: [
              Text(
                isLifetime
                    ? (isHindi ? 'वैधता:' : 'Validity:')
                    : (isCanceled
                        ? (isHindi ? 'समाप्ति तिथि:' : 'Expires On:')
                        : (isHindi ? 'अगला नवीनीकरण:' : 'Next Renewal:')),
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isLifetime
                      ? (isHindi ? 'हमेशा के लिए (कोई समाप्ति नहीं) 👑' : 'Never Expires (Lifetime Access) 👑')
                      : _formatDisplayDate(endDate, isHindi, isLifetime: false),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isLifetime ? const Color(0xFFB45309) : (isCanceled ? const Color(0xFFDC2626) : const Color(0xFF047857)),
                  ),
                ),
              ),
            ],
          ),

          if (!isLifetime && !isCanceled) ...[
            const SizedBox(height: 8),
            Text(
              isHindi
                  ? '• सदस्यता प्रत्येक चक्र पर स्वतः नवीनीकृत होती है जब तक Google Play पर रद्द न की जाए।'
                  : '• Auto-renews automatically unless canceled at least 24 hours prior in Google Play.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.3),
            ),
          ],

          ValueListenableBuilder<bool>(
            valueListenable: LocalStorageService.instance.cloudSyncEnabledNotifier,
            builder: (context, isSyncEnabled, _) {
              return ValueListenableBuilder<String?>(
                valueListenable: CloudProgressService().userEmailNotifier,
                builder: (context, email, _) {
                  final isConnected = email != null && email.isNotEmpty;
                  final boundEmail = CloudProgressService().boundMembershipEmail;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () async {
                            AudioService.instance.playSfx(CurioSfx.click);
                            if (!isSyncEnabled) {
                              // Cloud sync is currently disabled - prompt to enable
                              final shouldEnable = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  title: Text(
                                    isHindi ? 'क्लाउड सिंक चालू करें?' : 'Enable Cloud Sync?',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: Text(
                                    isHindi
                                        ? 'क्लाउड सिंक सक्षम करने से आपकी सीखने की प्रगति आपके सदस्यता Google खाते पर सुरक्षित रूप से बैकअप हो जाएगी।'
                                        : 'Enabling Cloud Sync will back up your child\'s learning progress to your membership Google Account.',
                                    style: const TextStyle(fontSize: 13.5, height: 1.4),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF16A34A),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(isHindi ? 'हाँ, चालू करें' : 'Enable Sync'),
                                    ),
                                  ],
                                ),
                              );
                              if (shouldEnable != true) return;

                              await LocalStorageService.instance.setCloudSyncEnabled(true);
                              if (!isConnected) {
                                try {
                                  final cred = await CloudProgressService().signInWithGoogle();
                                  if (cred != null) {
                                    await CloudProgressService().syncProgressToCloud(force: true);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(isHindi
                                              ? 'Google खाता जुड़ा! प्रोग्रेस क्लाउड पर सुरक्षित है।'
                                              : 'Google Account connected! Progress saved to Cloud.'),
                                          backgroundColor: const Color(0xFF059669),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    final msg = e is DifferentGoogleAccountException
                                        ? (isHindi
                                            ? 'क्लाउड सिंक केवल उसी Google खाते से काम करेगा जिस पर सदस्यता सक्रिय है (${e.boundEmail})।'
                                            : e.message)
                                        : 'Sync note: $e';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(msg),
                                        backgroundColor: Colors.redAccent,
                                        duration: const Duration(seconds: 4),
                                      ),
                                    );
                                  }
                                }
                              } else {
                                if (_isSyncingProgress) return;
                                _isSyncingProgress = true;
                                try {
                                  await CloudProgressService().syncProgressToCloud(force: true);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isHindi
                                            ? 'क्लाउड सिंक चालू हुआ और प्रोग्रेस बैकअप हो गई!'
                                            : 'Cloud Sync enabled and progress backed up!'),
                                        backgroundColor: const Color(0xFF059669),
                                      ),
                                    );
                                  }
                                } finally {
                                  _isSyncingProgress = false;
                                }
                              }
                            } else {
                              // Cloud sync is enabled - perform manual sync refresh
                              if (!isConnected) {
                                try {
                                  final cred = await CloudProgressService().signInWithGoogle();
                                  if (cred != null) {
                                    await CloudProgressService().syncProgressToCloud(force: true);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(isHindi
                                              ? 'Google खाता जुड़ा! प्रोग्रेस क्लाउड पर सुरक्षित है।'
                                              : 'Google Account connected! Progress saved to Cloud.'),
                                          backgroundColor: const Color(0xFF059669),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    final msg = e is DifferentGoogleAccountException
                                        ? (isHindi
                                            ? 'क्लाउड सिंक केवल उसी Google खाते से काम करेगा जिस पर सदस्यता सक्रिय है (${e.boundEmail})।'
                                            : e.message)
                                        : 'Sync note: $e';
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(msg),
                                        backgroundColor: Colors.redAccent,
                                        duration: const Duration(seconds: 4),
                                      ),
                                    );
                                  }
                                }
                              } else {
                                if (_isSyncingProgress) return;
                                _isSyncingProgress = true;
                                try {
                                  await CloudProgressService().syncProgressToCloud(force: true);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isHindi
                                            ? 'प्रोग्रेस क्लाउड पर सिंक हो गई है।'
                                            : 'Progress synced to Cloud Firestore!'),
                                        backgroundColor: const Color(0xFF059669),
                                      ),
                                    );
                                  }
                                } finally {
                                  _isSyncingProgress = false;
                                }
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSyncEnabled
                                  ? (isConnected ? const Color(0xFFF0FDFA) : const Color(0xFFEFF6FF))
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSyncEnabled
                                    ? (isConnected ? const Color(0xFFCCFBF1) : const Color(0xFFBFDBFE))
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSyncEnabled
                                      ? (isConnected ? Icons.cloud_done_rounded : Icons.cloud_upload_outlined)
                                      : Icons.cloud_off_rounded,
                                  size: 16,
                                  color: isSyncEnabled
                                      ? (isConnected ? const Color(0xFF0D9488) : const Color(0xFF2563EB))
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    isSyncEnabled
                                        ? (isConnected
                                            ? 'Cloud Sync: $email (Active)'
                                            : (boundEmail != null && boundEmail.isNotEmpty
                                                ? (isHindi ? 'Google खाता सिंक करें ($boundEmail)' : 'Sync Membership Account ($boundEmail)')
                                                : (isHindi ? 'सदस्यता Google खाता सिंक करें' : 'Sync Membership Google Account')))
                                        : (isHindi ? 'क्लाउड सिंक: बंद (केवल डिवाइस पर)' : 'Cloud Sync: Disabled (Local Only)'),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: isSyncEnabled
                                          ? (isConnected ? const Color(0xFF0D9488) : const Color(0xFF2563EB))
                                          : Colors.grey.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isSyncEnabled ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: isSyncEnabled ? const Color(0xFF86EFAC) : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    isSyncEnabled
                                        ? (isHindi ? 'चालू' : 'ON')
                                        : (isHindi ? 'बंद' : 'OFF'),
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: isSyncEnabled ? const Color(0xFF15803D) : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  isSyncEnabled
                                      ? (isConnected ? Icons.refresh_rounded : Icons.arrow_forward_ios_rounded)
                                      : Icons.arrow_forward_ios_rounded,
                                  size: 13,
                                  color: isSyncEnabled
                                      ? (isConnected ? const Color(0xFF0D9488) : const Color(0xFF2563EB))
                                      : Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isSyncEnabled && boundEmail != null && boundEmail.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            isHindi
                                ? '🔒 क्लाउड सिंक सदस्यता वाले Google खाते ($boundEmail) पर सक्रिय है।'
                                : '🔒 Cloud Sync active with your membership Google Account ($boundEmail).',
                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                          ),
                        )
                      else if (!isSyncEnabled)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            isHindi
                                ? '⚠️ क्लाउड सिंक बंद है। प्रगति केवल इस डिवाइस पर है। चालू करने के लिए टैप करें।'
                                : '⚠️ Cloud Sync is disabled. Progress is only stored on this device. Tap to enable.',
                            style: TextStyle(fontSize: 10.5, color: Colors.amber.shade900, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // Action Buttons: Cancel/Manage and View History
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showManageSubscriptionDialog(
                    isHindi: isHindi,
                    subType: subType,
                    endDate: endDate,
                    isLifetime: isLifetime,
                  ),
                  icon: Icon(
                    isLifetime ? Icons.settings_backup_restore_rounded : Icons.cancel_outlined,
                    size: 16,
                    color: isLifetime ? const Color(0xFFB45309) : const Color(0xFFDC2626),
                  ),
                  label: Text(
                    isLifetime
                        ? (isHindi ? 'प्रबंधन' : 'Manage')
                        : (isHindi ? 'रद्द / प्रबंधन' : 'Cancel/Manage'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isLifetime ? const Color(0xFFB45309) : const Color(0xFFDC2626),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isLifetime ? const Color(0xFFF59E0B) : const Color(0xFFFCA5A5),
                      width: 1.2,
                    ),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    AudioService.instance.playSfx(CurioSfx.click);
                    SubscriptionHistorySheet.show(context);
                  },
                  icon: const Icon(
                    Icons.receipt_long_rounded,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
                  label: Text(
                    isHindi ? 'खरीद विवरण' : 'Order History',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF93C5FD),
                      width: 1.2,
                    ),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Banner when user already holds the Lifetime VIP pass
  Widget _buildLifetimeUnlockedBanner(bool isHindi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Color(0xFFB45309), size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi ? 'आजीवन सदस्यता सक्रिय है! 👑' : 'Lifetime Access Unlocked! 👑',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF78350F)),
                ),
                const SizedBox(height: 2),
                Text(
                  isHindi
                      ? 'आपके पास सर्वोच्च पास है। किसी भी नवीनीकरण या अतिरिक्त भुगतान की आवश्यकता नहीं है।'
                      : 'You own the highest tier. All grades, future chapters, and features are permanently unlocked.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Modal dialog providing direct cancellation via Google Play Store and local device reset
  void _showManageSubscriptionDialog({
    required bool isHindi,
    required String? subType,
    required DateTime? endDate,
    required bool isLifetime,
  }) {
    AudioService.instance.playSfx(CurioSfx.click);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.store_mall_directory_rounded,
                    color: Color(0xFFDC2626),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  isHindi ? 'सदस्यता रद्द या प्रबंधित करें' : 'Cancel or Manage Subscription',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isHindi
                      ? 'Google Play Store की नीति के अनुसार, सभी Android सदस्यताएँ Google Play खाते द्वारा सुरक्षित रूप से प्रबंधित होती हैं।\n\n'
                        'यदि आप सदस्यता रद्द करते हैं, तो आपसे दोबारा शुल्क नहीं लिया जाएगा, और आपकी VIP सुविधाएँ '
                        '${endDate != null ? _formatDisplayDate(endDate, isHindi) : 'वर्तमान बिलिंग अवधि'} तक पूरी तरह सक्रिय रहेंगी।'
                      : 'According to Google Play policies, Android subscriptions are managed securely via your Google Play account.\n\n'
                        'If you cancel, you will not be billed again, and your VIP benefits will remain active until '
                        '${endDate != null ? _formatDisplayDate(endDate, isHindi) : 'the end of your billing cycle'}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),

                // Button 1: Open Google Play Subscriptions (Primary)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _openGooglePlaySubscriptions(sku: subType);
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(
                      isHindi
                          ? 'Google Play में रद्द / प्रबंधित करें'
                          : 'Cancel in Google Play Store',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Button 2: Local Device Reset / Tester Option
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _confirmCancelDeviceVip(isHindi);
                    },
                    icon: const Icon(Icons.phonelink_erase_rounded, size: 16, color: Color(0xFF64748B)),
                    label: Text(
                      isHindi
                          ? 'इस डिवाइस से VIP सदस्यता हटाएं / रीसेट करें'
                          : 'Remove VIP from this Device (Reset to Free)',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Button 2b: Data Deletion Policy (Cloud Data Deletion)
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _confirmDeleteCloudData(isHindi);
                    },
                    icon: const Icon(Icons.delete_forever_rounded, size: 16, color: Color(0xFFDC2626)),
                    label: Text(
                      isHindi
                          ? 'क्लाउड डेटा हटाएं (डेटा हटाना नीति)'
                          : 'Delete Cloud Data (Data Deletion Policy)',
                      style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Button 3: Keep Subscription (Dismiss)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isHindi ? 'सदस्यता बनाए रखें' : 'Keep Subscription'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Confirmation dialog before permanently deleting cloud data as per Data Deletion Policy
  void _confirmDeleteCloudData(bool isHindi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isHindi ? 'क्लाउड बैकअप हटाएं?' : 'Delete Cloud Backup?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isHindi
              ? 'Google Play डेटा विलोपन नीति के अनुसार, यह Cloud Firestore से आपके बैकअप को हमेशा के लिए हटा देगा।'
              : 'Under Google Play Data Deletion Policy, this permanently deletes your backup records from Cloud Firestore.',
          style: const TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await CloudProgressService().deleteCloudData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (isHindi
                              ? 'क्लाउड डेटा हमेशा के लिए हटा दिया गया है।'
                              : 'Cloud backup permanently deleted from Firestore.')
                          : (isHindi
                              ? 'क्लाउड डेटा हटाने में विफल।'
                              : 'Failed to delete cloud data.'),
                    ),
                    backgroundColor: const Color(0xFFDC2626),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: Text(isHindi ? 'हाँ, क्लाउड डेटा हटाएं' : 'Yes, Delete Cloud Data'),
          ),
        ],
      ),
    );
  }

  /// Confirmation dialog before resetting local device VIP status
  void _confirmCancelDeviceVip(bool isHindi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isHindi ? 'क्या आप निश्चित हैं?' : 'Reset VIP on this Device?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isHindi
              ? 'यह इस डिवाइस से VIP स्थिति हटा देगा। आप जब चाहें "खरीद पुनर्स्थापित करें (Restore)" दबाकर इसे वापस पा सकते हैं।'
              : 'This will reset this device to the Free plan. You can restore your purchased membership anytime using "Restore Purchases".',
          style: const TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isHindi ? 'नहीं, रद्द न करें' : 'No, Keep VIP'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await LocalStorageService.instance.cancelPremiumStatus();
              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isHindi
                          ? 'VIP सदस्यता इस डिवाइस से हटा दी गई है।'
                          : 'VIP membership removed from this device.',
                    ),
                    backgroundColor: const Color(0xFFDC2626),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: Text(isHindi ? 'हाँ, हटाएं' : 'Yes, Reset'),
          ),
        ],
      ),
    );
  }

  void _handlePurchase(
    InAppPurchaseService service,
    String productId, {
    required String planName,
    required String price,
    required bool isHindi,
  }) async {
    AudioService.instance.playSfx(CurioSfx.click);
    final products = service.products;
    var match = products.where((p) => p.id == productId).toList();
    if (match.isEmpty && service.isAvailable) {
      await service.queryProducts();
      match = service.products.where((p) => p.id == productId).toList();
    }

    if (match.isNotEmpty) {
      await service.buyProduct(match.first);
    } else {
      String message;
      if (!service.isAvailable) {
        message = isHindi
            ? 'Google Play Billing सेवा इस डिवाइस पर अनुपलब्ध है। कृपया Play Store में साइन इन करें।'
            : 'Google Play Billing is unavailable on this device. Please ensure you are signed into Google Play.';
      } else if (service.notFoundIds.contains(productId)) {
        message = isHindi
            ? 'यह उत्पाद Google Play Console पर अभी सक्रिय नहीं है या आप Closed Testing लिंक से जुड़े नहीं हैं।'
            : 'Product not active in Google Play Console, or tester invite is not accepted on this Google account.';
      } else {
        message = isHindi
            ? 'Google Play Store से उत्पाद लोड हो रहे हैं... कृपया कुछ क्षण बाद पुनः प्रयास करें।'
            : 'Loading Google Play Store products... Please try again in a moment.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildBenefitRow(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    String? subtitle,
    required String price,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
    bool isCurrentPlan = false,
    bool isHindi = false,
  }) {
    return InkWell(
      onTap: isCurrentPlan
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isHindi
                        ? 'यह आपका वर्तमान सक्रिय प्लान है। अतिरिक्त भुगतान की आवश्यकता नहीं है।'
                        : 'This is your current active plan. No additional payment needed.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrentPlan ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentPlan
                ? const Color(0xFF10B981)
                : (badge != null ? (badgeColor ?? const Color(0xFFFF7B25)) : const Color(0xFFE2E8F0)),
            width: isCurrentPlan || badge != null ? 2 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCurrentPlan ? const Color(0xFF059669) : (badgeColor ?? const Color(0xFFFF7B25)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCurrentPlan ? const Color(0xFF059669) : const Color(0xFFFF7B25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isCurrentPlan
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          isHindi ? 'सक्रिय' : 'Active',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ],
                    )
                  : Text(
                      price,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
