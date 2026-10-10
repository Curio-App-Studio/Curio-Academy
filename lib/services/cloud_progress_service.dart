import 'dart:convert';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local/local_storage_service.dart';
import 'in_app_purchase_service.dart';

enum CloudRestoreStatus {
  success,
  notVip,
  cancelled,
  noBackupFound,
  error,
}

class CloudRestoreResult {
  final CloudRestoreStatus status;
  final String message;
  final int? restoredStars;
  final String? studentName;
  final String? accountEmail;

  const CloudRestoreResult({
    required this.status,
    required this.message,
    this.restoredStars,
    this.studentName,
    this.accountEmail,
  });
}

/// Service managing Cloud Progress Backup & Sync via Firebase Firestore and Google Sign-In.
/// Exclusively active for VIP / Paid Members to ensure ₹0 server overhead for free users.
class CloudProgressService {
  static final CloudProgressService _instance = CloudProgressService._internal();
  factory CloudProgressService() => _instance;
  CloudProgressService._internal();

  static const String _keyLastCloudSync = 'curio_vip_last_cloud_sync';
  static const String _keyCachedGoogleEmail = 'curio_vip_google_email';
  static const String _keyCachedSnapshot = 'curio_vip_cached_cloud_snapshot';
  static const String _collectionName = 'vip_students';

  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  String? _cachedEmail;
  String? get googleAccountEmail => currentUser?.email ?? _cachedEmail;

  final ValueNotifier<bool> isSyncingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> userEmailNotifier = ValueNotifier<String?>(null);

  /// Checks if current user is entitled to VIP Cloud Progress Backup
  bool get isVipEligible =>
      LocalStorageService.instance.isPremiumUser ||
      LocalStorageService.instance.isClosedTester;

  /// Checks if Firebase is initialized and available
  bool get isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Current signed-in Firebase user
  User? get currentUser {
    if (!isFirebaseAvailable) return null;
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Whether parent is currently signed in with Google
  bool get isGoogleSignedIn => currentUser != null || _cachedEmail != null;

  /// Initializes cloud sync settings on startup
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedSync = prefs.getString(_keyLastCloudSync);
      if (storedSync != null) {
        _lastSyncTime = DateTime.tryParse(storedSync);
      }
      _cachedEmail = prefs.getString(_keyCachedGoogleEmail);
      userEmailNotifier.value = googleAccountEmail;
    } catch (_) {}

    LocalStorageService.onVipProgressChanged = () {
      syncProgressToCloud();
    };
  }

  /// Authenticates parent with Google Sign-In and Firebase Auth.
  Future<UserCredential?> signInWithGoogle() async {
    if (!isFirebaseAvailable) {
      developer.log('Firebase not initialized. Google Sign-In requires google-services.json.', name: 'CloudSync');
      return null;
    }

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        developer.log('Parent cancelled Google Sign-In dialog.', name: 'CloudSync');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final email = userCredential.user?.email ?? googleUser.email;
      _cachedEmail = email;
      userEmailNotifier.value = email;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCachedGoogleEmail, email);

      developer.log('Signed in successfully with Google: $email (UID: ${userCredential.user?.uid})', name: 'CloudSync');
      return userCredential;
    } catch (e, stack) {
      developer.log('Google Sign-In failed: $e', error: e, stackTrace: stack, name: 'CloudSync');
      rethrow;
    }
  }

  /// Signs out of Google & Firebase Auth
  Future<void> signOutGoogle() async {
    try {
      if (isFirebaseAvailable) {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
      }
      _cachedEmail = null;
      userEmailNotifier.value = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCachedGoogleEmail);
    } catch (e) {
      developer.log('Sign-out note: $e', name: 'CloudSync');
    }
  }

  /// Syncs current student progress to Cloud Firestore for VIP / Paid members.
  /// Free users are bypassed automatically to maintain ₹0 server & storage overhead.
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

      // Persist local cache mirror
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCachedSnapshot, jsonString);

      _lastSyncTime = DateTime.now();
      await prefs.setString(_keyLastCloudSync, _lastSyncTime!.toIso8601String());

      // If Firebase is available and user is authenticated, upload to Cloud Firestore
      final user = currentUser;
      if (isFirebaseAvailable && user != null) {
        final firestoreData = Map<String, dynamic>.from(snapshot);
        firestoreData['updatedAt'] = FieldValue.serverTimestamp();
        firestoreData['parentEmail'] = user.email;
        firestoreData['studentName'] = snapshot['name'];

        await FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(user.uid)
            .set(firestoreData, SetOptions(merge: true));

        developer.log(
          'CloudProgressService: VIP progress synced to Cloud Firestore for ${user.email} (${snapshot["stars"]} stars).',
          name: 'CloudSync',
        );
      } else {
        developer.log(
          'CloudProgressService: VIP progress cached locally. Will sync to Firestore once Google Sign-In is completed.',
          name: 'CloudSync',
        );
      }

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

  /// Restores VIP progress from Cloud Firestore via Google Sign-In after an app reset or reinstall.
  ///
  /// Flow:
  /// 1. Re-verifies active Google Play Purchase / Subscription via [InAppPurchaseService.restorePurchases].
  /// 2. If verified as VIP, signs in the parent with Google (if not already signed in).
  /// 3. Retrieves cloud document from Cloud Firestore under `vip_students/{uid}`.
  /// 4. Reconstructs full student profile, stars, completed chapters, and test scores.
  Future<CloudRestoreResult> restoreVipProgress({bool promptGoogleSignIn = true}) async {
    isSyncingNotifier.value = true;

    try {
      // 1. Verify Google Play purchases first
      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
        await InAppPurchaseService.instance.restorePurchases();
      }

      // Check if user is VIP (Subscribed, Lifetime pass, or Closed Tester)
      if (!isVipEligible) {
        return const CloudRestoreResult(
          status: CloudRestoreStatus.notVip,
          message: 'No active VIP membership or lifetime purchase was found for this Google Play account.',
        );
      }

      Map<String, dynamic>? snapshotData;

      // 2. Query Cloud Firestore if Firebase is active
      if (isFirebaseAvailable) {
        User? user = currentUser;
        if (user == null && promptGoogleSignIn) {
          final cred = await signInWithGoogle();
          user = cred?.user;
          if (user == null) {
            return const CloudRestoreResult(
              status: CloudRestoreStatus.cancelled,
              message: 'Google Sign-In was cancelled.',
            );
          }
        }

        if (user != null) {
          final doc = await FirebaseFirestore.instance
              .collection(_collectionName)
              .doc(user.uid)
              .get();

          if (doc.exists && doc.data() != null) {
            snapshotData = doc.data();
          }
        }
      }

      // 3. Fallback to local snapshot mirror (for offline recovery or test environments)
      if (snapshotData == null) {
        final prefs = await SharedPreferences.getInstance();
        final storedSnapshot = prefs.getString(_keyCachedSnapshot);
        if (storedSnapshot != null && storedSnapshot.isNotEmpty) {
          try {
            snapshotData = jsonDecode(storedSnapshot) as Map<String, dynamic>;
          } catch (_) {}
        }
      }

      if (snapshotData == null) {
        return const CloudRestoreResult(
          status: CloudRestoreStatus.noBackupFound,
          message: 'VIP membership is verified, but no previous cloud progress backup was found for this Google account.',
        );
      }

      // 4. Restore progress into local storage
      await LocalStorageService.instance.restoreProgressSnapshot(snapshotData);

      final stars = (snapshotData['stars'] as num?)?.toInt() ?? 0;
      final studentName = snapshotData['name'] as String? ?? 'Young Explorer';

      developer.log(
        'CloudProgressService: Successfully restored VIP progress for $studentName ($stars stars).',
        name: 'CloudSync',
      );

      return CloudRestoreResult(
        status: CloudRestoreStatus.success,
        message: 'Welcome back! All your stars, chapters, and progress have been restored from your Google account.',
        restoredStars: stars,
        studentName: studentName,
        accountEmail: googleAccountEmail,
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
