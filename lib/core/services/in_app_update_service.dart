import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

/// Service managing seamless, in-app Google Play updates without taking
/// students away from Curio Academy.
class InAppUpdateService {
  InAppUpdateService._();
  static final InAppUpdateService instance = InAppUpdateService._();

  AppUpdateInfo? _updateInfo;
  bool _isChecking = false;
  bool _isFlexibleUpdateInProgress = false;

  AppUpdateInfo? get updateInfo => _updateInfo;
  bool get isChecking => _isChecking;
  bool get isFlexibleUpdateInProgress => _isFlexibleUpdateInProgress;

  /// Checks for available Google Play in-app updates.
  /// If [autoStartFlexible] is true and a flexible update is available,
  /// initiates the background download and shows a notification upon completion.
  Future<void> checkForUpdate({
    BuildContext? context,
    bool autoStartFlexible = true,
  }) async {
    // In-app updates are only supported on Android with Google Play Store installed
    if (kIsWeb || !Platform.isAndroid) return;
    if (_isChecking) return;

    _isChecking = true;
    try {
      debugPrint('[InAppUpdate] Checking for updates on Google Play...');
      final info = await InAppUpdate.checkForUpdate();
      _updateInfo = info;

      debugPrint(
        '[InAppUpdate] Availability: ${info.updateAvailability}, '
        'Flexible: ${info.flexibleUpdateAllowed}, '
        'Immediate: ${info.immediateUpdateAllowed}',
      );

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed && info.updatePriority >= 4) {
          // High priority critical security/curriculum patch
          debugPrint('[InAppUpdate] Starting immediate update...');
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed && autoStartFlexible) {
          debugPrint('[InAppUpdate] Starting background flexible update...');
          _isFlexibleUpdateInProgress = true;
          final result = await InAppUpdate.startFlexibleUpdate();
          debugPrint('[InAppUpdate] Flexible update download result: $result');

          if (result == AppUpdateResult.success && context != null && context.mounted) {
            _showUpdateReadyNotification(context);
          }
        }
      }
    } catch (e) {
      // In debug/sideloaded builds or offline mode, Google Play API throws expected error
      debugPrint('[InAppUpdate] Note: In-app update check skipped or unavailable: $e');
    } finally {
      _isChecking = false;
      _isFlexibleUpdateInProgress = false;
    }
  }

  /// Displays a friendly, child-safe in-app banner to restart and apply the downloaded update.
  void _showUpdateReadyNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(days: 1), // Remains until student taps restart or dismisses
        content: const Row(
          children: [
            Icon(Icons.rocket_launch_rounded, color: Color(0xFFFBBF24)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'An update is ready! Restart to enjoy new features.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Restart 🔄',
          textColor: const Color(0xFF38BDF8),
          onPressed: () async {
            try {
              await InAppUpdate.completeFlexibleUpdate();
            } catch (e) {
              debugPrint('[InAppUpdate] Failed to complete flexible update: $e');
            }
          },
        ),
      ),
    );
  }
}
