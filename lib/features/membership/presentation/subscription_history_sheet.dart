import 'package:flutter/material.dart';
import '../../../data/local/local_storage_service.dart';
import '../../../data/models/subscription_record.dart';
import '../../../services/in_app_purchase_service.dart';

/// Modal bottom sheet displaying detailed active & previous subscription history.
class SubscriptionHistorySheet extends StatefulWidget {
  const SubscriptionHistorySheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SubscriptionHistorySheet(),
    );
  }

  @override
  State<SubscriptionHistorySheet> createState() => _SubscriptionHistorySheetState();
}

class _SubscriptionHistorySheetState extends State<SubscriptionHistorySheet> {
  bool _isRefreshing = false;

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
    LocalStorageService.instance.subscriptionUpdateNotifier.addListener(_onUpdated);
    // If history has fewer than 2 items, automatically query/restore in background to fetch all past Google Play purchases
    if (LocalStorageService.instance.getSubscriptionHistory().length < 2) {
      _syncOrdersFromPlayStore();
    }
  }

  @override
  void dispose() {
    LocalStorageService.instance.subscriptionUpdateNotifier.removeListener(_onUpdated);
    super.dispose();
  }

  void _onUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _syncOrdersFromPlayStore() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await InAppPurchaseService.instance.restorePurchases();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  String _formatDate(DateTime dt, bool isHindi) {
    final months = isHindi ? _monthsHi : _monthsEn;
    final m = months[dt.month - 1];
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    return '${dt.day} $m ${dt.year}, $hour:$minute $period';
  }

  String _formatSimpleDate(DateTime dt, bool isHindi) {
    final months = isHindi ? _monthsHi : _monthsEn;
    final m = months[dt.month - 1];
    return '${dt.day} $m ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final storage = LocalStorageService.instance;
    final isHindi = storage.getAppLanguage() == 'hi';
    final activeSubType = storage.premiumSubscriptionType;
    final isPremium = storage.isPremiumUser;
    final isCanceled = storage.isSubscriptionCanceled;
    final activeStartDate = storage.subscriptionStartDate;
    final activeEndDate = storage.subscriptionEndDate;
    final rawHistory = storage.getSubscriptionHistory();

    // Ensure active subscription is represented in records even if history hasn't restored yet
    final history = List<SubscriptionRecord>.from(rawHistory);
    if (history.isEmpty && isPremium && activeSubType != null) {
      final isLifetime = activeSubType == InAppProductIds.lifetimeNoAds;
      String name = 'VIP Membership';
      String price = '₹79.00 / month';
      if (isLifetime) {
        name = 'Lifetime Pass (Pay Once, Keep Forever)';
        price = '₹799.00';
      } else if (activeSubType == InAppProductIds.annualSubscription) {
        name = 'Annual VIP Subscription (12 Months)';
        price = '₹399.00 / year';
      }

      history.add(
        SubscriptionRecord(
          productId: activeSubType,
          planName: name,
          billingPrice: price,
          purchaseDate: activeStartDate ?? DateTime.now(),
          renewalDate: activeEndDate,
          isLifetime: isLifetime,
          isAutoRenewing: !isCanceled,
        ),
      );
    }

    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final bottomPadding = mediaQuery.padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: bottomInset + (bottomPadding > 0 ? bottomPadding + 16 : 28),
      ),
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF2563EB),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? 'सदस्यता व खरीद इतिहास' : 'Subscription & Order History',
                      style: const TextStyle(
                        fontSize: 18.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isHindi
                          ? 'Google Play द्वारा सत्यापित सभी पूर्व व सक्रिय लेन-देन'
                          : 'Google Play verified active & past orders',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),

          // Scrollable List of Subscriptions
          Expanded(
            child: history.isEmpty
                ? _buildEmptyState(isHindi)
                : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (ctx, index) {
                      final item = history[index];
                      final isActive = isPremium &&
                          item.productId == activeSubType &&
                          index == 0;
                      return _buildSubscriptionRecordCard(
                        context: context,
                        record: item,
                        isActive: isActive,
                        isHindi: isHindi,
                        activeCanceled: isCanceled,
                      );
                    },
                  ),
          ),

          const SizedBox(height: 12),
          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                isHindi ? 'ठीक है (बंद करें)' : 'Done',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isHindi) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              isHindi ? 'कोई पूर्व खरीद इतिहास नहीं मिला' : 'No Purchase Records Found',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isHindi
                  ? 'Google Play Store से अभी कोई खरीदारी दर्ज नहीं हुई है।'
                  : 'No orders have been recorded from Google Play yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionRecordCard({
    required BuildContext context,
    required SubscriptionRecord record,
    required bool isActive,
    required bool isHindi,
    required bool activeCanceled,
  }) {
    final isLifetime = record.isLifetime || record.productId == InAppProductIds.lifetimeNoAds;
    final isAnnual = record.productId == InAppProductIds.annualSubscription;

    String displayPlanName = record.planName;
    if (isHindi) {
      if (isLifetime) {
        displayPlanName = 'आजीवन पास (लाइफटाइम VIP)';
      } else if (isAnnual) {
        displayPlanName = 'वार्षिक वीआईपी सदस्यता (12 माह)';
      } else {
        displayPlanName = 'मासिक वीआईपी सदस्यता';
      }
    }

    final cardBorderColor = isActive
        ? (isLifetime ? const Color(0xFFF59E0B) : const Color(0xFF10B981))
        : const Color(0xFFCBD5E1);

    final cardBgColor = isActive
        ? (isLifetime ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4))
        : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor, width: isActive ? 1.8 : 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Plan name + Status Tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isLifetime ? const Color(0xFFF59E0B) : const Color(0xFF059669))
                      : const Color(0xFF94A3B8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLifetime
                      ? Icons.workspace_premium_rounded
                      : (isActive ? Icons.verified_rounded : Icons.history_rounded),
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayPlanName,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.billingPrice,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? (isLifetime ? const Color(0xFFB45309) : const Color(0xFF047857))
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(
                isActive: isActive,
                isLifetime: isLifetime,
                isHindi: isHindi,
                activeCanceled: activeCanceled,
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),

          // Detail 1: Purchase / Order Timestamp
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: isHindi ? 'खरीद तिथि:' : 'Purchased On:',
            value: _formatDate(record.purchaseDate, isHindi),
          ),
          const SizedBox(height: 6),

          // Detail 2: Validity / Next Renewal
          _buildInfoRow(
            icon: isLifetime ? Icons.all_inclusive_rounded : Icons.update_rounded,
            label: isLifetime
                ? (isHindi ? 'वैधता:' : 'Validity:')
                : (isActive && activeCanceled
                    ? (isHindi ? 'समाप्ति तिथि:' : 'Expires On:')
                    : (isHindi ? 'नवीनीकरण तिथि:' : 'Renewal Date:')),
            value: isLifetime
                ? (isHindi ? 'हमेशा के लिए (कोई समाप्ति नहीं) 👑' : 'Never Expires (Lifetime Access) 👑')
                : (record.renewalDate != null
                    ? _formatSimpleDate(record.renewalDate!, isHindi)
                    : (isHindi ? 'उपलब्ध नहीं' : 'N/A')),
            valueColor: isLifetime
                ? const Color(0xFFB45309)
                : (isActive ? const Color(0xFF047857) : const Color(0xFF475569)),
          ),

          // Detail 3: Google Play Order ID (if available)
          if (record.orderId != null && record.orderId!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildInfoRow(
              icon: Icons.tag_rounded,
              label: isHindi ? 'ऑर्डर आईडी:' : 'Order ID:',
              value: record.orderId!,
              isMonospace: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required bool isActive,
    required bool isLifetime,
    required bool isHindi,
    required bool activeCanceled,
  }) {
    if (isActive) {
      if (activeCanceled && !isLifetime) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEF4444)),
          ),
          child: Text(
            isHindi ? 'रद्द (सक्रिय चक्र)' : 'Canceled',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Color(0xFFDC2626),
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isLifetime ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isLifetime ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isLifetime ? const Color(0xFFD97706) : const Color(0xFF059669),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              isHindi ? 'सक्रिय' : 'Active',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isLifetime ? const Color(0xFFB45309) : const Color(0xFF047857),
              ),
            ),
          ],
        ),
      );
    }

    // Previous order
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Text(
        isHindi ? 'पिछली खरीद' : 'Past Order',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isMonospace = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: isMonospace ? 'monospace' : null,
              color: valueColor ?? const Color(0xFF1E293B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
