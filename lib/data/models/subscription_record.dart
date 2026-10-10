/// Record representing a purchased item or subscription in Google Play history
class SubscriptionRecord {
  final String productId;
  final String planName;
  final String billingPrice;
  final DateTime purchaseDate;
  final DateTime? renewalDate;
  final bool isLifetime;
  final bool isAutoRenewing;
  final String? orderId;
  final String? purchaseToken;

  const SubscriptionRecord({
    required this.productId,
    required this.planName,
    required this.billingPrice,
    required this.purchaseDate,
    this.renewalDate,
    this.isLifetime = false,
    this.isAutoRenewing = true,
    this.orderId,
    this.purchaseToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'planName': planName,
      'billingPrice': billingPrice,
      'purchaseDate': purchaseDate.toIso8601String(),
      'renewalDate': renewalDate?.toIso8601String(),
      'isLifetime': isLifetime,
      'isAutoRenewing': isAutoRenewing,
      'orderId': orderId,
      'purchaseToken': purchaseToken,
    };
  }

  factory SubscriptionRecord.fromJson(Map<String, dynamic> json) {
    return SubscriptionRecord(
      productId: json['productId'] as String? ?? '',
      planName: json['planName'] as String? ?? 'VIP Membership',
      billingPrice: json['billingPrice'] as String? ?? '₹0.00',
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.tryParse(json['purchaseDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      renewalDate: json['renewalDate'] != null
          ? DateTime.tryParse(json['renewalDate'] as String)
          : null,
      isLifetime: json['isLifetime'] as bool? ?? false,
      isAutoRenewing: json['isAutoRenewing'] as bool? ?? true,
      orderId: json['orderId'] as String?,
      purchaseToken: json['purchaseToken'] as String?,
    );
  }
}
