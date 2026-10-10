import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curio_math/data/local/local_storage_service.dart';
import 'package:curio_math/features/membership/presentation/membership_paywall_sheet.dart';
import 'package:curio_math/services/in_app_purchase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.instance.init();
  });

  group('LocalStorageService Subscription State Tests', () {
    test('Records and reads subscription start and end dates', () async {
      final storage = LocalStorageService.instance;
      final start = DateTime(2026, 10, 10);
      final end = DateTime(2026, 11, 10);

      await storage.setPremiumUser(true);
      await storage.setPremiumSubscriptionType(InAppProductIds.monthlySubscription);
      await storage.setSubscriptionDates(startDate: start, endDate: end);

      expect(storage.isPremiumUser, isTrue);
      expect(storage.premiumSubscriptionType, equals(InAppProductIds.monthlySubscription));
      expect(storage.subscriptionStartDate, equals(start));
      expect(storage.subscriptionEndDate, equals(end));
      expect(storage.isSubscriptionCanceled, isFalse);

      await storage.setSubscriptionCanceled(true);
      expect(storage.isSubscriptionCanceled, isTrue);
    });

    test('cancelPremiumStatus resets all subscription fields', () async {
      final storage = LocalStorageService.instance;
      await storage.setPremiumUser(true);
      await storage.setPremiumSubscriptionType(InAppProductIds.annualSubscription);
      await storage.setSubscriptionDates(
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 365)),
      );

      expect(storage.isPremiumUser, isTrue);

      await storage.cancelPremiumStatus();

      expect(storage.isPremiumUser, isFalse);
      expect(storage.premiumSubscriptionType, isNull);
      expect(storage.subscriptionStartDate, isNull);
      expect(storage.subscriptionEndDate, isNull);
      expect(storage.isSubscriptionCanceled, isFalse);
    });

    test('init() populates sensible fallback dates for active subscription without dates', () async {
      SharedPreferences.setMockInitialValues({
        'curio_legacy_test_vip_cleared_v2': true,
        'curio_is_premium_user': true,
        'curio_premium_sub_type': 'curio_vip_monthly',
      });

      final storage = LocalStorageService.instance;
      await storage.init();

      expect(storage.isPremiumUser, isTrue);
      expect(storage.premiumSubscriptionType, equals('curio_vip_monthly'));
      expect(storage.subscriptionStartDate, isNotNull);
      expect(storage.subscriptionEndDate, isNotNull);
      // Monthly end date should be ~30 days from start date
      final diffDays = storage.subscriptionEndDate!.difference(storage.subscriptionStartDate!).inDays;
      expect(diffDays, inInclusiveRange(28, 31));
    });
  });

  group('MembershipPaywallSheet UI Tests', () {
    testWidgets('Renders Active Subscription Card with Plan Name, End Date, and Cancel button', (tester) async {
      final storage = LocalStorageService.instance;
      await storage.setPremiumUser(true);
      await storage.setPremiumSubscriptionType(InAppProductIds.monthlySubscription);
      await storage.setSubscriptionDates(
        startDate: DateTime(2026, 10, 10),
        endDate: DateTime(2026, 11, 10),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MembershipPaywallSheet(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Active Plan Card header
      expect(find.text('CURRENT ACTIVE PLAN'), findsOneWidget);
      expect(find.text('Monthly VIP Subscription'), findsWidgets);

      // Verify Dates
      expect(find.text('Started On:'), findsOneWidget);
      expect(find.text('Next Renewal:'), findsOneWidget);
      expect(find.textContaining('10 Nov 2026'), findsOneWidget);

      // Verify Cancel or Manage Subscription button
      expect(find.text('Cancel/Manage'), findsOneWidget);

      // Verify Current Plan is disabled/marked with Active
      expect(find.text('YOUR CURRENT PLAN ✓'), findsOneWidget);
    });

    testWidgets('Tapping Cancel or Manage Subscription opens dialog with Google Play and Reset options', (tester) async {
      final storage = LocalStorageService.instance;
      await storage.setPremiumUser(true);
      await storage.setPremiumSubscriptionType(InAppProductIds.monthlySubscription);
      await storage.setSubscriptionDates(
        startDate: DateTime(2026, 10, 10),
        endDate: DateTime(2026, 11, 10),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MembershipPaywallSheet(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Cancel or Manage Subscription
      final cancelBtn = find.text('Cancel/Manage');
      expect(cancelBtn, findsOneWidget);
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      // Check dialog options
      expect(find.text('Cancel in Google Play Store'), findsOneWidget);
      expect(find.text('Remove VIP from this Device (Reset to Free)'), findsOneWidget);
      expect(find.text('Keep Subscription'), findsOneWidget);
    });

    testWidgets('Lifetime Pass renders Never Expires and hides duplicate purchase cards', (tester) async {
      final storage = LocalStorageService.instance;
      await storage.setPremiumUser(true);
      await storage.setPremiumSubscriptionType(InAppProductIds.lifetimeNoAds);
      await storage.setSubscriptionDates(
        startDate: DateTime(2026, 10, 1),
        endDate: null,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MembershipPaywallSheet(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lifetime Pass (Pay Once, Keep Forever)'), findsOneWidget);
      expect(find.textContaining('Never Expires'), findsWidgets);
      expect(find.text('Lifetime Access Unlocked! 👑'), findsOneWidget);

      // Does not show plan cards to buy again
      expect(find.text('Choose Your Plan'), findsNothing);
      expect(find.text('Switch or Upgrade Plan'), findsNothing);
    });
  });
}
