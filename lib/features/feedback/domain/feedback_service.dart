import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/in_app_review_service.dart';
import '../data/feedback_model.dart';

class FeedbackService {
  FeedbackService._();
  static final FeedbackService instance = FeedbackService._();

  static const String _collectionName = 'user_feedback';
  static const String _keyOfflineFeedback = 'curio_pending_offline_feedback';

  /// Submits feedback to Cloud Firestore `user_feedback` collection.
  /// If offline or if Firestore encounters an error, saves locally to retry later.
  Future<bool> submitFeedback(UserFeedback feedback) async {
    try {
      debugPrint('[FeedbackService] Sending feedback (${feedback.category.name}, ${feedback.rating} stars) to Firestore...');
      await FirebaseFirestore.instance
          .collection(_collectionName)
          .add(feedback.toMap())
          .timeout(const Duration(seconds: 8));
      debugPrint('[FeedbackService] Feedback submitted successfully to Firestore.');

      // Also try syncing any previously pending offline feedbacks
      _syncOfflineQueue();
      return true;
    } catch (e) {
      debugPrint('[FeedbackService] Firestore direct write failed ($e). Caching locally in offline queue.');
      await _cacheOfflineFeedback(feedback);
      return true;
    }
  }

  /// Caches feedback to SharedPreferences if device is offline
  Future<void> _cacheOfflineFeedback(UserFeedback feedback) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyOfflineFeedback) ?? [];
      list.add(jsonEncode({
        'rating': feedback.rating,
        'category': feedback.category.name,
        'comment': feedback.comment,
        'contactInfo': feedback.contactInfo,
        'studentName': feedback.studentName,
        'studentClass': feedback.studentClass,
        'board': feedback.board,
        'appVersion': feedback.appVersion,
        'platform': feedback.platform,
        'localTimestamp': feedback.createdAt.toIso8601String(),
      }));
      await prefs.setStringList(_keyOfflineFeedback, list);
    } catch (e) {
      debugPrint('[FeedbackService] Error caching feedback locally: $e');
    }
  }

  /// Attempts to upload cached offline feedbacks when network is restored
  Future<void> _syncOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyOfflineFeedback);
      if (list == null || list.isEmpty) return;

      final remaining = <String>[];
      for (final raw in list) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          await FirebaseFirestore.instance.collection(_collectionName).add({
            ...map,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {
          remaining.add(raw);
        }
      }
      await prefs.setStringList(_keyOfflineFeedback, remaining);
    } catch (e) {
      debugPrint('[FeedbackService] Error syncing offline queue: $e');
    }
  }

  /// Triggers Google Play In-App Review or store page
  Future<void> openPlayStoreReview() async {
    await InAppReviewService.instance.requestInAppReview(fallbackToStoreListing: true);
  }
}
