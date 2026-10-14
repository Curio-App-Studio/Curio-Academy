import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../data/local/local_storage_service.dart';
import '../data/models/subscription_record.dart';

/// Product identifiers configured in Google Play Console (and App Store)
class InAppProductIds {
  /// One-time permanent purchase (Non-consumable)
  static const String lifetimeNoAds = 'curio_remove_ads_lifetime';

  /// Monthly recurring VIP subscription
  static const String monthlySubscription = 'curio_vip_monthly';

  /// Annual recurring VIP subscription (Best Value)
  static const String annualSubscription = 'curio_vip_annual';

  static const Set<String> allIds = {
    lifetimeNoAds,
    monthlySubscription,
    annualSubscription,
  };
}

/// Service managing Google Play Store Billing (In-App Purchases & Subscriptions)
/// Compliant with Google Play Developer Policies and Designed for Families guidelines.
class InAppPurchaseService {
  static final InAppPurchaseService instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => instance;
  InAppPurchaseService._internal();

  InAppPurchase? _iap;
  InAppPurchase get _iapInstance => _iap ??= InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => List.unmodifiable(_products);

  final ValueNotifier<bool> purchasePendingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> purchaseErrorNotifier = ValueNotifier<String?>(null);

  String? _lastError;
  String? get lastError => _lastError;

  List<String> _notFoundIds = [];
  List<String> get notFoundIds => List.unmodifiable(_notFoundIds);

  /// Returns the most recent Google Play purchase token, if available.
  String? get latestPurchaseToken {
    final history = LocalStorageService.instance.getSubscriptionHistory();
    for (final record in history) {
      if (record.purchaseToken != null && record.purchaseToken!.trim().isNotEmpty) {
        return record.purchaseToken!.trim();
      }
    }
    return null;
  }

  /// Returns all restored Google Play purchase tokens from subscription history.
  Set<String> get restoredPurchaseTokens {
    final history = LocalStorageService.instance.getSubscriptionHistory();
    return history
        .map((s) => s.purchaseToken?.trim())
        .where((t) => t != null && t.isNotEmpty)
        .cast<String>()
        .toSet();
  }

  /// Initializes Google Play Billing connection, loads products, and listens to purchase stream.
  Future<void> initialize() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      developer.log('InAppPurchaseService: Unsupported platform, running in offline sandbox.', name: 'IAP');
      return;
    }

    try {
      _isAvailable = await _iapInstance.isAvailable();
      debugPrint('[InAppPurchaseService] Billing isAvailable = $_isAvailable');
      if (!_isAvailable) {
        _lastError = 'In-App Billing is not available on this device.';
        debugPrint('[InAppPurchaseService] $_lastError');
        return;
      }

      // Listen to the purchase update stream
      _subscription = _iapInstance.purchaseStream.listen(
        _onPurchaseUpdated,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          debugPrint('[InAppPurchaseService] Purchase stream error: $error');
          developer.log('InAppPurchaseService: Purchase stream error: $error', error: error, name: 'IAP');
        },
      );

      // Query products from Google Play
      await queryProducts();
    } catch (e, stack) {
      _lastError = 'Initialization error: $e';
      debugPrint('[InAppPurchaseService] $_lastError');
      developer.log('InAppPurchaseService: Initialization error: $e', error: e, stackTrace: stack, name: 'IAP');
    }
  }

  /// Fetches product details and local currency prices from Google Play.
  Future<void> queryProducts() async {
    if (!_isAvailable) {
      debugPrint('[InAppPurchaseService] Skipping queryProducts because isAvailable = false');
      return;
    }

    try {
      debugPrint('[InAppPurchaseService] Querying product IDs: ${InAppProductIds.allIds}');
      final ProductDetailsResponse response = await _iapInstance.queryProductDetails(InAppProductIds.allIds);

      _notFoundIds = response.notFoundIDs;
      _products = response.productDetails;

      if (response.error != null) {
        _lastError = 'Query error: ${response.error!.message} (${response.error!.code})';
        debugPrint('[InAppPurchaseService] $_lastError');
      }

      debugPrint('[InAppPurchaseService] Loaded ${_products.length} products: ${_products.map((p) => p.id).toList()}');
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('[InAppPurchaseService] Not found in store: ${response.notFoundIDs}');
      }
    } catch (e) {
      _lastError = 'Error querying product details: $e';
      debugPrint('[InAppPurchaseService] $_lastError');
      developer.log('InAppPurchaseService: Error querying product details: $e', error: e, name: 'IAP');
    }
  }

  /// Initiates purchase flow for a one-time product or subscription.
  Future<bool> buyProduct(ProductDetails product) async {
    if (!_isAvailable) {
      purchaseErrorNotifier.value = 'In-app purchases are unavailable on this device.';
      return false;
    }

    purchasePendingNotifier.value = true;
    purchaseErrorNotifier.value = null;

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    try {
      if (product.id == InAppProductIds.lifetimeNoAds) {
        return await _iapInstance.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        return await _iapInstance.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      purchasePendingNotifier.value = false;
      purchaseErrorNotifier.value = e.toString();
      developer.log('InAppPurchaseService: Error launching purchase: $e', error: e, name: 'IAP');
      return false;
    }
  }

  /// Restores previous purchases across devices (Required by Google Play).
  Future<void> restorePurchases() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    if (!_isAvailable) return;
    debugPrint('[InAppPurchaseService] restorePurchases called');
    purchasePendingNotifier.value = true;
    purchaseErrorNotifier.value = null;

    try {
      await _iapInstance.restorePurchases();
      // Allow Google Play purchase stream to process and persist verified items
      await Future.delayed(const Duration(milliseconds: 1500));
    } catch (e) {
      purchaseErrorNotifier.value = 'Failed to restore purchases: $e';
      debugPrint('[InAppPurchaseService] Error restoring purchases: $e');
      developer.log('InAppPurchaseService: Error restoring purchases: $e', error: e, name: 'IAP');
    } finally {
      purchasePendingNotifier.value = false;
    }
  }

  /// Handles incoming purchase updates from Google Play.
  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    debugPrint('[InAppPurchaseService] _onPurchaseUpdated count: ${purchaseDetailsList.length}');
    final validPurchases = <PurchaseDetails>[];

    for (final purchase in purchaseDetailsList) {
      debugPrint(
        '[InAppPurchaseService] purchase status: ${purchase.status} for ${purchase.productID} date: ${purchase.transactionDate}',
      );
      developer.log(
        'InAppPurchaseService: Received purchase status: ${purchase.status} for ${purchase.productID} date: ${purchase.transactionDate}',
        name: 'IAP',
      );

      if (purchase.status == PurchaseStatus.pending) {
        purchasePendingNotifier.value = true;
      } else if (purchase.status == PurchaseStatus.error) {
        purchasePendingNotifier.value = false;
        purchaseErrorNotifier.value = purchase.error?.message ?? 'Purchase failed.';
      } else if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        validPurchases.add(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        await _iapInstance.completePurchase(purchase);
      }
    }

    if (validPurchases.isNotEmpty) {
      // Record all purchases into subscription history
      await _recordSubscriptionHistory(validPurchases);

      // Resolve the single latest/best active purchase rather than delivering intermediate older plans
      final bestPurchase = _resolveBestPurchase(validPurchases);
      await _deliverProduct(bestPurchase);
    }

    purchasePendingNotifier.value = false;
  }

  /// Converts valid purchases to SubscriptionRecords and saves to local storage
  Future<void> _recordSubscriptionHistory(List<PurchaseDetails> purchases) async {
    final existing = List<SubscriptionRecord>.from(
      LocalStorageService.instance.getSubscriptionHistory(),
    );

    for (final p in purchases) {
      final purchaseDate = _parsePurchaseDate(p) ?? DateTime.now();
      final isLifetime = p.productID == InAppProductIds.lifetimeNoAds;
      final autoRenew = _parseAutoRenewingStatus(p) ?? true;
      final orderId = _parseOrderId(p);
      final token = _parsePurchaseToken(p);

      DateTime? renewalDate;
      if (isLifetime) {
        renewalDate = null;
      } else if (p.productID == InAppProductIds.annualSubscription) {
        DateTime cycleEnd = DateTime(purchaseDate.year + 1, purchaseDate.month, purchaseDate.day);
        while (cycleEnd.isBefore(DateTime.now())) {
          cycleEnd = DateTime(cycleEnd.year + 1, cycleEnd.month, cycleEnd.day);
        }
        renewalDate = cycleEnd;
      } else {
        DateTime cycleEnd = DateTime(purchaseDate.year, purchaseDate.month + 1, purchaseDate.day);
        while (cycleEnd.isBefore(DateTime.now())) {
          cycleEnd = DateTime(cycleEnd.year, cycleEnd.month + 1, cycleEnd.day);
        }
        renewalDate = cycleEnd;
      }

      String planName = 'VIP Active Membership';
      String price = '₹79.00';
      if (p.productID == InAppProductIds.lifetimeNoAds) {
        planName = 'Lifetime Pass (Pay Once, Keep Forever)';
        price = '₹799.00';
      } else if (p.productID == InAppProductIds.annualSubscription) {
        planName = 'Annual VIP Subscription (12 Months)';
        price = '₹399.00 / year';
      } else if (p.productID == InAppProductIds.monthlySubscription) {
        planName = 'Monthly VIP Subscription';
        price = '₹79.00 / month';
      }

      final record = SubscriptionRecord(
        productId: p.productID,
        planName: planName,
        billingPrice: price,
        purchaseDate: purchaseDate,
        renewalDate: renewalDate,
        isLifetime: isLifetime,
        isAutoRenewing: autoRenew,
        orderId: orderId,
        purchaseToken: token,
      );

      final index = existing.indexWhere(
        (r) => r.productId == p.productID && r.purchaseDate.day == purchaseDate.day && r.purchaseDate.month == purchaseDate.month && r.purchaseDate.year == purchaseDate.year,
      );
      if (index >= 0) {
        existing[index] = record;
      } else {
        existing.add(record);
      }
    }

    // Sort descending by purchaseDate (most recent first)
    existing.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
    await LocalStorageService.instance.saveSubscriptionHistory(existing);
  }

  String? _parseOrderId(PurchaseDetails purchase) {
    try {
      final rawJson = purchase.verificationData.localVerificationData;
      if (rawJson.isNotEmpty && rawJson.trim().startsWith('{')) {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        if (decoded.containsKey('orderId') && decoded['orderId'] != null) {
          return decoded['orderId'].toString();
        }
      }
    } catch (_) {}
    return null;
  }

  String? _parsePurchaseToken(PurchaseDetails purchase) {
    try {
      final rawJson = purchase.verificationData.localVerificationData;
      if (rawJson.isNotEmpty && rawJson.trim().startsWith('{')) {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        if (decoded.containsKey('purchaseToken') && decoded['purchaseToken'] != null) {
          return decoded['purchaseToken'].toString();
        }
      }
    } catch (_) {}
    return null;
  }

  /// Parses the exact historical purchase timestamp from Google Play receipt metadata.
  DateTime? _parsePurchaseDate(PurchaseDetails purchase) {
    // 1. Try transactionDate milliseconds string
    if (purchase.transactionDate != null && purchase.transactionDate!.isNotEmpty) {
      final millis = int.tryParse(purchase.transactionDate!);
      if (millis != null && millis > 0) {
        return DateTime.fromMillisecondsSinceEpoch(millis);
      }
      final parsed = DateTime.tryParse(purchase.transactionDate!);
      if (parsed != null) return parsed;
    }

    // 2. Try parsing purchaseTime from Google Play localVerificationData JSON
    try {
      final rawJson = purchase.verificationData.localVerificationData;
      if (rawJson.isNotEmpty && rawJson.trim().startsWith('{')) {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        final purchaseTime = decoded['purchaseTime'];
        if (purchaseTime is int && purchaseTime > 0) {
          return DateTime.fromMillisecondsSinceEpoch(purchaseTime);
        } else if (purchaseTime is String) {
          final millis = int.tryParse(purchaseTime);
          if (millis != null && millis > 0) {
            return DateTime.fromMillisecondsSinceEpoch(millis);
          }
        }
      }
    } catch (_) {}

    return null;
  }

  /// Checks if Google Play subscription auto-renewal is explicitly canceled in receipt.
  bool? _parseAutoRenewingStatus(PurchaseDetails purchase) {
    try {
      final rawJson = purchase.verificationData.localVerificationData;
      if (rawJson.isNotEmpty && rawJson.trim().startsWith('{')) {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        if (decoded.containsKey('autoRenewing')) {
          return decoded['autoRenewing'] == true;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Resolves the single best purchase if Google Play returns multiple items in purchase history.
  PurchaseDetails _resolveBestPurchase(List<PurchaseDetails> purchases) {
    if (purchases.length == 1) {
      debugPrint('[InAppPurchaseService] Single purchase found: ${purchases.first.productID}');
      return purchases.first;
    }

    for (final p in purchases) {
      final dt = _parsePurchaseDate(p);
      final auto = _parseAutoRenewingStatus(p);
      debugPrint(
        '[InAppPurchaseService] candidate: ${p.productID}, txDate=${p.transactionDate}, parsedDate=$dt, rawJson=${p.verificationData.localVerificationData}',
      );
      developer.log(
        'InAppPurchaseService._resolveBestPurchase candidate: ${p.productID}, txDate=${p.transactionDate}, parsedDate=$dt, autoRenew=$auto',
        name: 'IAP',
      );
    }

    // Sort by transaction date descending (most recent purchase wins)
    final sorted = List<PurchaseDetails>.from(purchases);
    sorted.sort((a, b) {
      // 1. Primary: Sort by purchase/renewal timestamp descending (most recent transaction wins)
      final dateA = _parsePurchaseDate(a) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = _parsePurchaseDate(b) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final cmp = dateB.compareTo(dateA);
      if (cmp != 0) return cmp;

      // 2. Secondary: Active recurring subscriptions take priority over one-time items
      final autoA = _parseAutoRenewingStatus(a) == true ? 1 : 0;
      final autoB = _parseAutoRenewingStatus(b) == true ? 1 : 0;
      return autoB.compareTo(autoA);
    });

    debugPrint('[InAppPurchaseService] Selected best purchase -> ${sorted.first.productID}');
    developer.log('InAppPurchaseService: Selected best purchase -> ${sorted.first.productID}', name: 'IAP');
    return sorted.first;
  }

  /// Activates permanent ad-free status upon verified purchase/restore using true historical dates.
  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    debugPrint('[InAppPurchaseService] Delivering best product ${purchase.productID}');
    developer.log('InAppPurchaseService: Delivering best product ${purchase.productID}', name: 'IAP');

    final parsedPurchaseDate = _parsePurchaseDate(purchase);
    final startDate = parsedPurchaseDate ?? DateTime.now();

    DateTime? endDate;
    if (purchase.productID == InAppProductIds.lifetimeNoAds) {
      endDate = null;
    } else if (purchase.productID == InAppProductIds.annualSubscription) {
      // Annual recurring: step forward in 1-year cycles until finding the current cycle end date
      DateTime cycleEnd = DateTime(startDate.year + 1, startDate.month, startDate.day);
      while (cycleEnd.isBefore(DateTime.now())) {
        cycleEnd = DateTime(cycleEnd.year + 1, cycleEnd.month, cycleEnd.day);
      }
      endDate = cycleEnd;
    } else {
      // Monthly recurring: step forward in 1-month cycles until finding the current cycle end date
      DateTime cycleEnd = DateTime(startDate.year, startDate.month + 1, startDate.day);
      while (cycleEnd.isBefore(DateTime.now())) {
        cycleEnd = DateTime(cycleEnd.year, cycleEnd.month + 1, cycleEnd.day);
      }
      endDate = cycleEnd;
    }

    // Check cancellation status from Google Play receipt
    final isAutoRenewing = _parseAutoRenewingStatus(purchase);
    if (isAutoRenewing != null) {
      await LocalStorageService.instance.setSubscriptionCanceled(!isAutoRenewing);
    } else {
      await LocalStorageService.instance.setSubscriptionCanceled(false);
    }

    // Set dates and sub type before setting premium user flag to eliminate race conditions
    await LocalStorageService.instance.setSubscriptionDates(startDate: startDate, endDate: endDate);
    await LocalStorageService.instance.setPremiumSubscriptionType(purchase.productID);
    await LocalStorageService.instance.setPremiumUser(true);

    developer.log(
      'InAppPurchaseService: Premium successfully activated for ${purchase.productID}! '
      'Start: $startDate, End: $endDate',
      name: 'IAP',
    );
  }

  /// Disposes listeners
  void dispose() {
    _subscription?.cancel();
  }
}
