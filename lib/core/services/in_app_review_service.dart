import 'dart:math';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing in-app Google Play reviews with child-safe parental gates
/// and milestone-based prompting.
class InAppReviewService {
  InAppReviewService._();
  static final InAppReviewService instance = InAppReviewService._();

  final InAppReview _inAppReview = InAppReview.instance;
  static const String _keyLastPromptTime = 'curio_last_review_prompt_timestamp';
  static const String _keyHasReviewed = 'curio_has_submitted_review';
  static const int _cooldownDays = 14;

  /// Checks if in-app review is available on the device.
  Future<bool> isAvailable() async {
    try {
      return await _inAppReview.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Triggers the Google Play In-App Review flow directly inside the app.
  /// If [fallbackToStoreListing] is true and in-app review dialog is unavailable,
  /// opens the Play Store listing.
  Future<void> requestInAppReview({bool fallbackToStoreListing = false}) async {
    try {
      final available = await _inAppReview.isAvailable();
      if (available) {
        debugPrint('[InAppReview] Launching native Google Play in-app review...');
        await _inAppReview.requestReview();
      } else if (fallbackToStoreListing) {
        debugPrint('[InAppReview] In-app review unavailable; opening store listing...');
        await _inAppReview.openStoreListing();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyLastPromptTime, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('[InAppReview] Error invoking in-app review: $e');
    }
  }

  /// Checks whether a milestone review prompt should be shown based on stars
  /// earned and cooldown period.
  Future<bool> shouldPromptMilestoneReview(int totalStars) async {
    if (totalStars < 25) return false;

    final prefs = await SharedPreferences.getInstance();
    final hasReviewed = prefs.getBool(_keyHasReviewed) ?? false;
    if (hasReviewed) return false;

    final lastPromptEpoch = prefs.getInt(_keyLastPromptTime) ?? 0;
    if (lastPromptEpoch > 0) {
      final lastPromptDate = DateTime.fromMillisecondsSinceEpoch(lastPromptEpoch);
      final daysSince = DateTime.now().difference(lastPromptDate).inDays;
      if (daysSince < _cooldownDays) {
        return false;
      }
    }

    return true;
  }

  /// Displays a child-safe Parent Gate dialog before opening the Play Store review.
  /// This complies with Google Play Families Policy for children under 13.
  Future<void> showParentGatedReview(BuildContext context) async {
    final random = Random();
    final a = random.nextInt(8) + 11; // 11 to 18
    final b = random.nextInt(9) + 4;  // 4 to 12
    final correctAnswer = a + b;

    final controller = TextEditingController();
    String? errorMessage;

    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.family_restroom_rounded, color: Color(0xFF6366F1), size: 28),
              SizedBox(width: 10),
              Text(
                'Parent Zone 🛡️',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help us keep Curio Academy awesome! Please verify you are a parent to share your feedback.',
                style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Text(
                  'Solve to proceed:  $a + $b = ?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3730A3),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter answer',
                  errorText: errorMessage,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onSubmitted: (_) {
                  if (int.tryParse(controller.text.trim()) == correctAnswer) {
                    Navigator.of(dialogCtx).pop(true);
                  } else {
                    setState(() => errorMessage = 'Incorrect answer. Try again!');
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (int.tryParse(controller.text.trim()) == correctAnswer) {
                  Navigator.of(dialogCtx).pop(true);
                } else {
                  setState(() => errorMessage = 'Incorrect answer. Try again!');
                }
              },
              child: const Text('Verify & Rate ⭐'),
            ),
          ],
        ),
      ),
    );

    if (verified == true) {
      await requestInAppReview(fallbackToStoreListing: true);
    }
  }

  /// Shows an encouraging mascot dialog celebrating learning achievements and
  /// inviting parents to rate the app.
  Future<void> showMilestoneDialog(BuildContext context) async {
    final shouldPrompt = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Text('🏆', style: TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 16),
            const Text(
              'You are a Star Learner!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Enjoying Curio Academy? If you or your parents love the app, a quick rating on the Play Store helps us create more free chapters!',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Maybe Later', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            icon: const Icon(Icons.star_rounded, size: 20),
            label: const Text('Rate Us ⭐'),
          ),
        ],
      ),
    );

    if (shouldPrompt == true && context.mounted) {
      await showParentGatedReview(context);
    }
  }
}
