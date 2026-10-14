import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/in_app_review_service.dart';
import '../../../data/local/local_storage_service.dart';
import '../data/feedback_model.dart';

class FeedbackService {
  FeedbackService._();
  static final FeedbackService instance = FeedbackService._();

  static const String _collectionName = 'user_feedback';
  static const String _vipCollectionName = 'vip_students';
  static const String _keyOfflineFeedback = 'curio_pending_offline_feedback';

  /// Sanitizes Gmail address into a safe Firestore document key
  static String sanitizeGmailId(String? email) {
    if (email == null || email.trim().isEmpty) return 'anonymous';
    final cleaned = email.trim().toLowerCase().replaceAll('/', '_');
    return cleaned.isEmpty ? 'anonymous' : cleaned;
  }

  /// Submits feedback to Cloud Firestore, grouped under the user's Gmail ID.
  ///
  /// Grouping Hierarchy in Firestore:
  /// - Parent Document: `user_feedback/{sanitizedGmailId}`
  ///   Holds the summary (total feedbacks, latest rating, student profile, recent history).
  /// - Subcollection: `user_feedback/{sanitizedGmailId}/submissions/{submissionId}`
  ///   Holds each granular, individual feedback item with device/OS/app metadata.
  Future<bool> submitFeedback(UserFeedback feedback) async {
    final gmailDocId = sanitizeGmailId(feedback.gmailId);

    // 1. Ensure Firebase Auth session exists (anonymously or via existing credentials)
    if (FirebaseAuth.instance.currentUser == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
        debugPrint('[FeedbackService] Anonymous sign-in success: ${FirebaseAuth.instance.currentUser?.uid}');
      } catch (authErr) {
        debugPrint('[FeedbackService] Anonymous auth note: $authErr');
      }
    }

    bool userFeedbackSuccess = false;

    // 2. Attempt primary write to `user_feedback/{gmailDocId}`
    try {
      debugPrint('[FeedbackService] Sending feedback (${feedback.category.name}, ${feedback.rating} stars) for Gmail: $gmailDocId...');
      final userDocRef = FirebaseFirestore.instance.collection(_collectionName).doc(gmailDocId);

      // Save detailed submission document in the user's 'submissions' subcollection
      final submissionRef = await userDocRef
          .collection('submissions')
          .add(feedback.toMap())
          .timeout(const Duration(seconds: 8));

      // Update parent user summary document grouped by Gmail ID
      await userDocRef.set({
        'gmailId': feedback.gmailId.trim().isNotEmpty ? feedback.gmailId.trim().toLowerCase() : 'anonymous',
        'studentName': feedback.studentName ?? 'Anonymous',
        'studentClass': feedback.studentClass ?? 'Unknown',
        'board': feedback.board ?? 'CBSE',
        'totalFeedbackCount': FieldValue.increment(1),
        'latestRating': feedback.rating,
        'latestCategory': feedback.category.name,
        'latestCategoryLabel': feedback.category.labelEn,
        'latestComment': feedback.comment.trim(),
        'latestSubmittedAt': FieldValue.serverTimestamp(),
        'latestDevice': '${feedback.deviceBrand} ${feedback.deviceModel}'.trim(),
        'latestOsVersion': feedback.osVersion,
        'appVersion': '${feedback.appVersion}+${feedback.buildNumber}',
        'recentFeedbacks': FieldValue.arrayUnion([feedback.toSummaryMap()]),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 8));

      debugPrint('[FeedbackService] Feedback submitted successfully: user_feedback/$gmailDocId/submissions/${submissionRef.id}');
      userFeedbackSuccess = true;
    } catch (e) {
      debugPrint('[FeedbackService] user_feedback direct write failed ($e).');
    }

    // 3. Mirror to vip_students (if valid email is present)
    try {
      final boundEmail = feedback.gmailId.trim().isNotEmpty && feedback.gmailId != 'anonymous'
          ? feedback.gmailId.trim().toLowerCase()
          : LocalStorageService.instance.boundMembershipEmail?.trim().toLowerCase();
      if (boundEmail != null && boundEmail.isNotEmpty && boundEmail != 'anonymous') {
        final emailKey = boundEmail.replaceAll('.', '_');

        final vipDocRef = FirebaseFirestore.instance.collection(_vipCollectionName).doc(emailKey);
        await vipDocRef.collection('feedbacks').add(feedback.toMap()).timeout(const Duration(seconds: 6));
        await vipDocRef.set({
          'hasFeedback': true,
          'latestFeedbackRating': feedback.rating,
          'latestFeedbackComment': feedback.comment.trim(),
          'latestFeedbackCategory': feedback.category.name,
          'latestFeedbackAt': FieldValue.serverTimestamp(),
          'recentFeedbacks': FieldValue.arrayUnion([feedback.toSummaryMap()]),
        }, SetOptions(merge: true)).timeout(const Duration(seconds: 6));
        debugPrint('[FeedbackService] Mirrored feedback successfully to vip_students/$emailKey/feedbacks');
      }
    } catch (vipErr) {
      debugPrint('[FeedbackService] Mirror to vip_students note: $vipErr');
    }

    if (!userFeedbackSuccess) {
      // Cache locally to retry user_feedback upload when security rules allow it
      await _cacheOfflineFeedback(feedback);
    } else {
      _syncOfflineQueue();
    }

    return true;
  }

  /// Caches feedback to SharedPreferences if device is offline or permissions pending
  Future<void> _cacheOfflineFeedback(UserFeedback feedback) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyOfflineFeedback) ?? [];
      final map = feedback.toMap();
      map.remove('createdAt'); // Server timestamp placeholder cannot be jsonEncoded
      list.add(jsonEncode(map));
      await prefs.setStringList(_keyOfflineFeedback, list);
    } catch (e) {
      debugPrint('[FeedbackService] Error caching feedback locally: $e');
    }
  }

  /// Attempts to upload cached offline feedbacks when network/permissions are restored
  Future<void> _syncOfflineQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyOfflineFeedback);
      if (list == null || list.isEmpty) return;

      final remaining = <String>[];
      for (final raw in list) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          final gmailId = map['gmailId'] as String? ?? 'anonymous';
          final gmailDocId = sanitizeGmailId(gmailId);
          final userDocRef = FirebaseFirestore.instance.collection(_collectionName).doc(gmailDocId);

          await userDocRef.collection('submissions').add({
            ...map,
            'createdAt': FieldValue.serverTimestamp(),
          });

          await userDocRef.set({
            'gmailId': gmailId,
            'totalFeedbackCount': FieldValue.increment(1),
            'latestRating': map['rating'] ?? 5,
            'latestCategory': map['category'] ?? 'feature',
            'latestComment': map['comment'] ?? '',
            'latestSubmittedAt': FieldValue.serverTimestamp(),
            'appVersion': map['fullAppVersion'] ?? '1.0.0+14',
          }, SetOptions(merge: true));
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
