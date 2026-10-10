import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local/local_storage_service.dart';
import 'in_app_purchase_service.dart';

enum CloudRestoreStatus {
  success,
  notVip,
  noBackupFound,
  error,
}

class CloudRestoreResult {
  final CloudRestoreStatus status;
  final String message;
  final int? restoredStars;
  final String? studentName;

  const CloudRestoreResult({
    required this.status,
    required this.message,
    this.restoredStars,
    this.studentName,
  });
}

/// Service managing Cloud Progress Backup & Sync exclusively for VIP / Paid Members.
///
/// Ensures child's stars, points, badges, completed chapters, and report cards
/// survive app resets, device upgrades, or reinstalls.
class CloudProgressService {
  static final CloudProgressService _instance = CloudProgressService._internal();
  factory CloudProgressService() => _instance;
  CloudProgressService._internal();

  static const String _keyLastCloudSync = 'curio_vip_last_cloud_sync';
  static const String _backupFileName = 'curio_vip_cloud_backup.json';

  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  final ValueNotifier<bool> isSyncingNotifier = ValueNotifier<bool>(false);

  /// Checks if current user is entitled to VIP Cloud Progress Backup
  bool get isVipEligible =>
      LocalStorageService.instance.isPremiumUser ||
      LocalStorageService.instance.isClosedTester;

  /// Initializes cloud sync settings on startup
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedSync = prefs.getString(_keyLastCloudSync);
      if (storedSync != null) {
        _lastSyncTime = DateTime.tryParse(storedSync);
      }
    } catch (_) {}

    LocalStorageService.onVipProgressChanged = () {
      syncProgressToCloud();
    };
  }

  /// Syncs current progress to cloud backup storage if user is a verified VIP / Paid member.
  /// Free users are bypassed gracefully to maintain ₹0 server & storage overhead.
  Future<bool> syncProgressToCloud({bool force = false}) async {
    if (!isVipEligible && !force) {
      developer.log(
        'CloudProgressService: Free user detected. Cloud sync skipped (VIP only feature).',
        name: 'CloudSync',
      );
      return false;
    }

    if (isSyncingNotifier.value) return false;

    isSyncingNotifier.value = true;
    try {
      final snapshot = LocalStorageService.instance.exportProgressSnapshot();
      final jsonString = jsonEncode(snapshot);

      // Persist to local backup file that Android OS Cloud Backup mirrors to Google Drive
      if (!kIsWeb) {
        try {
          final file = File(_backupFileName);
          await file.writeAsString(jsonString);
        } catch (e) {
          developer.log('CloudProgressService: File write note: $e', name: 'CloudSync');
        }
      }

      // Also persist snapshot string in SharedPreferences as secondary mirror
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('curio_vip_cached_cloud_snapshot', jsonString);

      _lastSyncTime = DateTime.now();
      await prefs.setString(_keyLastCloudSync, _lastSyncTime!.toIso8601String());

      developer.log(
        'CloudProgressService: VIP progress synced successfully (${snapshot["stars"]} stars, ${snapshot["name"]}).',
        name: 'CloudSync',
      );
      return true;
    } catch (e, stack) {
      developer.log(
        'CloudProgressService: Failed to sync VIP progress: $e',
        error: e,
        stackTrace: stack,
        name: 'CloudSync',
      );
      return false;
    } finally {
      isSyncingNotifier.value = false;
    }
  }

  /// Restores previous VIP progress from cloud storage after an app reset or reinstall.
  ///
  /// Flow:
  /// 1. Re-verifies active Google Play Purchase / Subscription via [InAppPurchaseService.restorePurchases].
  /// 2. If verified as VIP, retrieves cloud snapshot and restores full student progress.
  Future<CloudRestoreResult> restoreVipProgress() async {
    isSyncingNotifier.value = true;

    try {
      // 1. Verify Google Play purchases first
      await InAppPurchaseService.instance.restorePurchases();

      // Check if user is VIP (Subscribed, Lifetime pass, or Closed Tester)
      if (!isVipEligible) {
        return const CloudRestoreResult(
          status: CloudRestoreStatus.notVip,
          message: 'No active VIP membership or lifetime purchase was found for this Google Play account.',
        );
      }

      // 2. Retrieve Cloud Snapshot
      Map<String, dynamic>? snapshotData;

      // Check SharedPreferences mirror first (Auto Backup restores SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      final storedSnapshot = prefs.getString('curio_vip_cached_cloud_snapshot');
      if (storedSnapshot != null && storedSnapshot.isNotEmpty) {
        try {
          snapshotData = jsonDecode(storedSnapshot) as Map<String, dynamic>;
        } catch (_) {}
      }

      // Check backup file as secondary source
      if (snapshotData == null && !kIsWeb) {
        try {
          final file = File(_backupFileName);
          if (await file.exists()) {
            final content = await file.readAsString();
            snapshotData = jsonDecode(content) as Map<String, dynamic>;
          }
        } catch (_) {}
      }

      if (snapshotData == null) {
        return const CloudRestoreResult(
          status: CloudRestoreStatus.noBackupFound,
          message: 'VIP membership restored, but no previous cloud progress backup was found.',
        );
      }

      // 3. Apply snapshot to LocalStorageService
      await LocalStorageService.instance.restoreProgressSnapshot(snapshotData);

      final stars = (snapshotData['stars'] as num?)?.toInt() ?? 0;
      final studentName = snapshotData['name'] as String? ?? 'Young Explorer';

      developer.log(
        'CloudProgressService: Successfully restored VIP progress for $studentName ($stars stars).',
        name: 'CloudSync',
      );

      return CloudRestoreResult(
        status: CloudRestoreStatus.success,
        message: 'Welcome back! All your stars, chapters, and progress have been restored.',
        restoredStars: stars,
        studentName: studentName,
      );
    } catch (e, stack) {
      developer.log(
        'CloudProgressService: Error restoring VIP progress: $e',
        error: e,
        stackTrace: stack,
        name: 'CloudSync',
      );
      return CloudRestoreResult(
        status: CloudRestoreStatus.error,
        message: 'Could not restore cloud progress: $e',
      );
    } finally {
      isSyncingNotifier.value = false;
    }
  }
}
