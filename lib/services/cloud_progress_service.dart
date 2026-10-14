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

/// Thrown when parent attempts to sign in with a Google account different
/// from the account on which VIP membership was activated.
class DifferentGoogleAccountException implements Exception {
  final String message;
  final String boundEmail;
  final String attemptedEmail;

  const DifferentGoogleAccountException(
    this.message, {
    required this.boundEmail,
    required this.attemptedEmail,
  });

  @override
  String toString() => message;
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

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '138142325786-fh4reoko5i7u8vehfces8m61vm4dh8s4.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  String? _cachedEmail;
  String? get googleAccountEmail => currentUser?.email ?? _cachedEmail;

  /// The official Google account bound to this membership
  String? get boundMembershipEmail => LocalStorageService.instance.boundMembershipEmail;

  final ValueNotifier<bool> isSyncingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> userEmailNotifier = ValueNotifier<String?>(null);
  bool _hasPendingSync = false;

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
      if (_cachedEmail == 'storeaahan@gmail.com') {
        _cachedEmail = null;
        await prefs.remove(_keyCachedGoogleEmail);
      }
      final bound = LocalStorageService.instance.boundMembershipEmail;
      _cachedEmail = bound ?? _cachedEmail;
      userEmailNotifier.value = _cachedEmail;

      if (currentUser?.email == 'storeaahan@gmail.com') {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
      }
    } catch (_) {}

    LocalStorageService.onVipProgressChanged = () {
      if (LocalStorageService.instance.isCloudSyncEnabled) {
        syncProgressToCloud();
      }
    };

    LocalStorageService.onCloudDataDeleteRequested = () async {
      await deleteCloudData();
    };
  }

  /// Authenticates parent with Google Sign-In and Firebase Auth.
  /// Strictly enforces that only the Google account tied to this membership is allowed.
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

      final boundEmail = LocalStorageService.instance.boundMembershipEmail?.trim().toLowerCase();
      final selectedEmail = googleUser.email.trim().toLowerCase();

      // Cloud Sync will work ONLY with the same Google Account on which membership is activated
      if (boundEmail != null && boundEmail.isNotEmpty && selectedEmail != boundEmail) {
        developer.log(
          'CloudProgressService: Rejected Google Sign-In. Selected account ($selectedEmail) does not match membership account ($boundEmail).',
          name: 'CloudSync',
        );
        await googleSignIn.signOut();
        throw DifferentGoogleAccountException(
          'Cloud Sync works only with the Google Account on which membership is activated ($boundEmail). Different accounts cannot be used.',
          boundEmail: boundEmail,
          attemptedEmail: selectedEmail,
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final email = (userCredential.user?.email ?? googleUser.email).trim().toLowerCase();
      _cachedEmail = email;
      userEmailNotifier.value = email;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCachedGoogleEmail, email);

      // Permanently bind this Google Account to the membership if not already bound
      if (boundEmail == null || boundEmail.isEmpty) {
        await LocalStorageService.instance.setBoundMembershipEmail(email);
      }

      developer.log('Signed in successfully with Google: $email (UID: ${userCredential.user?.uid})', name: 'CloudSync');
      return userCredential;
    } catch (e, stack) {
      if (e is! DifferentGoogleAccountException) {
        developer.log('Google Sign-In failed: $e', error: e, stackTrace: stack, name: 'CloudSync');
      }
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

  /// Automatically connects to the membership Google Account in the background
  /// without requiring manual account connection steps, restores cloud backup if present,
  /// or auto-syncs current VIP progress to Cloud Firestore.
  Future<bool> autoSyncAndRestore({bool force = false}) async {
    if (!isVipEligible && !force) return false;
    if (!isFirebaseAvailable) return false;
    if (!force && !LocalStorageService.instance.isCloudSyncEnabled) {
      developer.log(
        'CloudProgressService: autoSyncAndRestore skipped because cloud sync is disabled by user.',
        name: 'CloudSync',
      );
      return false;
    }

    try {
      User? user = currentUser;

      // 1. Silent Google Account auth check (Never pop up account picker)
      if (user == null) {
        try {
          final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();

          if (googleUser != null) {
            final boundEmail = LocalStorageService.instance.boundMembershipEmail?.trim().toLowerCase();
            final selectedEmail = googleUser.email.trim().toLowerCase();

            if (boundEmail == null || boundEmail.isEmpty || selectedEmail == boundEmail) {
              final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
              final AuthCredential credential = GoogleAuthProvider.credential(
                accessToken: googleAuth.accessToken,
                idToken: googleAuth.idToken,
              );
              final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
              user = userCredential.user;
              final email = (user?.email ?? googleUser.email).trim().toLowerCase();
              _cachedEmail = email;
              userEmailNotifier.value = email;
            }
          }
        } catch (_) {}
      }

      // If still not signed in, connect anonymously in the background with zero popups
      if (user == null) {
        try {
          final anonCred = await FirebaseAuth.instance.signInAnonymously();
          user = anonCred.user;
        } catch (_) {}
      }

      final boundEmail = LocalStorageService.instance.boundMembershipEmail?.trim().toLowerCase();
      final effectiveEmail = boundEmail ?? (user?.isAnonymous == false ? user?.email?.trim().toLowerCase() : null);
      final localTokens = InAppPurchaseService.instance.restoredPurchaseTokens;

      if ((effectiveEmail == null || effectiveEmail.isEmpty) && localTokens.isEmpty) {
        developer.log('autoSyncAndRestore: No valid user email or purchase token found. Skipping restore.', name: 'CloudSync');
        return false;
      }

      final bestData = await _findBestCloudBackup(
        explicitEmail: effectiveEmail,
        purchaseTokens: localTokens,
        firebaseUser: user,
      );

      if (bestData != null) {
        debugPrint('[autoSyncAndRestore] Selected best candidate data: $bestData');
        final cloudStars = (bestData['stars'] as num?)?.toInt() ?? 0;
        final studentName = (bestData['name'] ?? bestData['studentName']) as String?;
        final completedChapters = bestData['completedChapters'] as List?;

        final hasRealBackup = (cloudStars > 0) ||
            (completedChapters != null && completedChapters.isNotEmpty) ||
            (studentName != null &&
                studentName.isNotEmpty &&
                studentName != 'Little Champ' &&
                studentName != 'Young Explorer');

        debugPrint('[autoSyncAndRestore] hasRealBackup: $hasRealBackup (stars=$cloudStars, name=$studentName)');

        if (hasRealBackup) {
          final restoredEmail = (bestData['parentEmail'] ?? bestData['membershipBoundEmail']) as String?;
          if (restoredEmail != null && restoredEmail.trim().isNotEmpty) {
            final cleanEmail = restoredEmail.trim().toLowerCase();
            await LocalStorageService.instance.setBoundMembershipEmail(cleanEmail);
            _cachedEmail = cleanEmail;
            userEmailNotifier.value = cleanEmail;
          }
          await LocalStorageService.instance.restoreProgressSnapshot(bestData);
          await LocalStorageService.instance.setOnboarded(true);
          await LocalStorageService.instance.setCloudSyncEnabled(true);
          debugPrint('[autoSyncAndRestore] Successfully restored VIP backup for ${restoredEmail ?? boundEmail} (${studentName ?? ""}, $cloudStars stars)!');
          developer.log(
            'autoSyncAndRestore: Automatically restored VIP backup from Cloud Firestore for ${restoredEmail ?? boundEmail} (${studentName ?? ""}, $cloudStars stars).',
            name: 'CloudSync',
          );
          return true; // Cloud backup exists and was restored!
        }
      }

      debugPrint('[autoSyncAndRestore] No cloud backup exists in Firestore for membership user (${effectiveEmail ?? localTokens}).');
      return false;
    } catch (e, stack) {
      debugPrint('[autoSyncAndRestore] Exception: $e');
      developer.log('autoSyncAndRestore note: $e', error: e, stackTrace: stack, name: 'CloudSync');
      return false;
    }
  }

  /// Searches Cloud Firestore for VIP backup candidates using:
  /// 1. Document key by email (doc(sadaf_anju@gmail_com))
  /// 2. Document field queries by email (parentEmail / membershipBoundEmail)
  /// 3. Verified Google Play purchase tokens (latestPurchaseToken, purchaseToken, purchaseTokens array, or subscription history)
  Future<Map<String, dynamic>?> _findBestCloudBackup({
    String? explicitEmail,
    Set<String>? purchaseTokens,
    User? firebaseUser,
  }) async {
    final List<Map<String, dynamic>> candidates = [];
    final boundEmail = explicitEmail ??
        LocalStorageService.instance.boundMembershipEmail?.trim().toLowerCase() ??
        (firebaseUser?.isAnonymous == false ? firebaseUser?.email?.trim().toLowerCase() : null);

    // 1. Email-based document queries
    if (boundEmail != null && boundEmail.isNotEmpty) {
      final emailKey = boundEmail.replaceAll('.', '_');
      try {
        final emailDoc = await FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(emailKey)
            .get();
        if (emailDoc.exists && emailDoc.data() != null) {
          candidates.add(emailDoc.data()!);
        }
      } catch (_) {}

      if (candidates.isEmpty && boundEmail != emailKey) {
        try {
          final rawDoc = await FirebaseFirestore.instance
              .collection(_collectionName)
              .doc(boundEmail)
              .get();
          if (rawDoc.exists && rawDoc.data() != null) {
            candidates.add(rawDoc.data()!);
          }
        } catch (_) {}
      }

      if (candidates.isEmpty && firebaseUser != null && firebaseUser.uid != emailKey) {
        try {
          final uidDoc = await FirebaseFirestore.instance
              .collection(_collectionName)
              .doc(firebaseUser.uid)
              .get();
          if (uidDoc.exists && uidDoc.data() != null) {
            candidates.add(uidDoc.data()!);
          }
        } catch (_) {}
      }

      if (candidates.isEmpty) {
        try {
          final querySnap = await FirebaseFirestore.instance
              .collection(_collectionName)
              .where('parentEmail', isEqualTo: boundEmail)
              .limit(1)
              .get();
          for (final d in querySnap.docs) {
            candidates.add(d.data());
          }
        } catch (_) {}
      }

      if (candidates.isEmpty) {
        try {
          final querySnap = await FirebaseFirestore.instance
              .collection(_collectionName)
              .where('membershipBoundEmail', isEqualTo: boundEmail)
              .limit(1)
              .get();
          for (final d in querySnap.docs) {
            candidates.add(d.data());
          }
        } catch (_) {}
      }
    }

    // 2. Token-based document queries (Crucial for Fresh Installs where local storage is empty)
    final tokens = purchaseTokens ?? InAppPurchaseService.instance.restoredPurchaseTokens;
    if (candidates.isEmpty && tokens.isNotEmpty) {
      debugPrint('[_findBestCloudBackup] Searching Firestore by ${tokens.length} restored purchase token(s)...');
      for (final token in tokens) {
        if (token.isEmpty) continue;
        try {
          final snap = await FirebaseFirestore.instance
              .collection(_collectionName)
              .where('latestPurchaseToken', isEqualTo: token)
              .limit(1)
              .get();
          for (final d in snap.docs) {
            candidates.add(d.data());
          }
        } catch (_) {}
        if (candidates.isNotEmpty) break;

        try {
          final snap = await FirebaseFirestore.instance
              .collection(_collectionName)
              .where('purchaseToken', isEqualTo: token)
              .limit(1)
              .get();
          for (final d in snap.docs) {
            candidates.add(d.data());
          }
        } catch (_) {}
        if (candidates.isNotEmpty) break;

        try {
          final snap = await FirebaseFirestore.instance
              .collection(_collectionName)
              .where('purchaseTokens', arrayContains: token)
              .limit(1)
              .get();
          for (final d in snap.docs) {
            candidates.add(d.data());
          }
        } catch (_) {}
        if (candidates.isNotEmpty) break;
      }

      // Fallback: If where queries return empty (e.g. unindexed field in rules or token in nested subscriptionHistory),
      // scan vip_students collection documents directly.
      if (candidates.isEmpty) {
        try {
          final allVipSnap = await FirebaseFirestore.instance
              .collection(_collectionName)
              .limit(100)
              .get();
          for (final doc in allVipSnap.docs) {
            final data = doc.data();
            final docToken = (data['latestPurchaseToken'] ?? data['purchaseToken'])?.toString().trim();
            if (docToken != null && tokens.contains(docToken)) {
              candidates.add(data);
              break;
            }
            final hist = data['subscriptionHistory'];
            if (hist is List) {
              for (final item in hist) {
                if (item is Map) {
                  final t = item['purchaseToken']?.toString().trim();
                  if (t != null && tokens.contains(t)) {
                    candidates.add(data);
                    break;
                  }
                }
              }
            }
            if (candidates.isNotEmpty) break;
          }
        } catch (e) {
          debugPrint('[_findBestCloudBackup] Scan note: $e');
        }
      }
    }

    if (candidates.isEmpty) return null;

    // Pick candidate with highest genuine progress
    Map<String, dynamic>? bestData;
    int bestScore = -1;

    for (final cand in candidates) {
      final stars = (cand['stars'] as num?)?.toInt() ?? 0;
      final points = (cand['points'] as num?)?.toInt() ?? 0;
      final chaptersCount = (cand['completedChapters'] as List?)?.length ?? 0;
      final attemptsCount = (cand['questionAttempts'] as Map?)?.length ?? 0;
      final hasName = (cand['name'] ?? cand['studentName'])?.toString().isNotEmpty == true;

      final score = (stars * 100) + points + (chaptersCount * 50) + (attemptsCount * 10) + (hasName ? 5 : 0);
      if (score > bestScore) {
        bestScore = score;
        bestData = cand;
      }
    }

    return bestData;
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

    if (!LocalStorageService.instance.isCloudSyncEnabled) {
      developer.log(
        'CloudProgressService: Cloud sync is disabled by user. Skipping sync.',
        name: 'CloudSync',
      );
      return false;
    }

    final snapshot = LocalStorageService.instance.exportProgressSnapshot();
    final studentName = snapshot['name']?.toString().trim();
    final stars = (snapshot['stars'] as num?)?.toInt() ?? 0;
    final chapters = (snapshot['completedChapters'] as List?)?.length ?? 0;

    // Never overwrite cloud backup with an uninitialized default or wiped profile
    final isDefaultOrEmpty = (studentName == null ||
            studentName.isEmpty ||
            studentName == 'Young Explorer' ||
            studentName == 'Little Champ') &&
        stars == 0 &&
        chapters == 0;

    if (isDefaultOrEmpty && !force) {
      developer.log(
        'CloudProgressService: Skipping cloud sync of empty/default profile to protect cloud backup.',
        name: 'CloudSync',
      );
      return false;
    }

    if (isSyncingNotifier.value) {
      _hasPendingSync = true;
      while (isSyncingNotifier.value) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return true;
    }

    isSyncingNotifier.value = true;
    try {
      do {
        _hasPendingSync = false;
        final currentSnapshot = LocalStorageService.instance.exportProgressSnapshot();
        final jsonString = jsonEncode(currentSnapshot);

        // Persist local cache mirror
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyCachedSnapshot, jsonString);

        _lastSyncTime = DateTime.now();
        await prefs.setString(_keyLastCloudSync, _lastSyncTime!.toIso8601String());

        // If Firebase is available, ensure background session and upload directly under membership Google account
        var user = currentUser;
        if (isFirebaseAvailable && user == null) {
          try {
            final googleUser = await _googleSignIn.signInSilently();
            if (googleUser != null) {
              final boundEmail = LocalStorageService.instance.boundMembershipEmail?.trim().toLowerCase();
              final selectedEmail = googleUser.email.trim().toLowerCase();
              if (boundEmail == null || boundEmail.isEmpty || selectedEmail == boundEmail) {
                final googleAuth = await googleUser.authentication;
                final credential = GoogleAuthProvider.credential(
                  accessToken: googleAuth.accessToken,
                  idToken: googleAuth.idToken,
                );
                final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
                user = userCredential.user;
                _cachedEmail = user?.email ?? googleUser.email;
                userEmailNotifier.value = _cachedEmail;
              }
            }
          } catch (_) {}
        }

        if (isFirebaseAvailable && user == null) {
          try {
            final anonCred = await FirebaseAuth.instance.signInAnonymously();
            user = anonCred.user;
          } catch (_) {}
        }

        if (isFirebaseAvailable) {
          final boundEmail = LocalStorageService.instance.boundMembershipEmail?.trim().toLowerCase() ?? (user?.isAnonymous == false ? user?.email?.trim().toLowerCase() : null);
          if (boundEmail == null || boundEmail.isEmpty) {
            developer.log('syncProgressToCloud: No bound email found. Skipping sync.', name: 'CloudSync');
            return false;
          }
          final emailKey = boundEmail.replaceAll('.', '_');

          final firestoreData = Map<String, dynamic>.from(currentSnapshot);
          firestoreData['updatedAt'] = FieldValue.serverTimestamp();
          firestoreData['parentEmail'] = boundEmail;
          firestoreData['membershipBoundEmail'] = boundEmail;
          firestoreData['studentName'] = currentSnapshot['name'];
          firestoreData['name'] = currentSnapshot['name'];
          firestoreData['isVip'] = true;

          // Save top-level purchase tokens for instant token-based recovery on fresh install
          final history = LocalStorageService.instance.getSubscriptionHistory();
          final tokens = history
              .map((s) => s.purchaseToken?.trim())
              .where((t) => t != null && t.isNotEmpty)
              .cast<String>()
              .toSet()
              .toList();
          if (tokens.isNotEmpty) {
            firestoreData['latestPurchaseToken'] = tokens.first;
            firestoreData['purchaseToken'] = tokens.first;
            firestoreData['purchaseTokens'] = tokens;
          }

          // Exactly ONE document per email in vip_students: stored at doc(emailKey)
          await FirebaseFirestore.instance
              .collection(_collectionName)
              .doc(emailKey)
              .set(firestoreData, SetOptions(merge: true));

          // Clean up any historical duplicate documents for this email to ensure ONLY ONE item exists
          if (user != null && user.uid != emailKey) {
            try {
              await FirebaseFirestore.instance
                  .collection(_collectionName)
                  .doc(user.uid)
                  .delete();
            } catch (_) {}
          }
          if (boundEmail != emailKey) {
            try {
              await FirebaseFirestore.instance
                  .collection(_collectionName)
                  .doc(boundEmail)
                  .delete();
            } catch (_) {}
          }

          developer.log(
            'CloudProgressService: VIP progress synced to Cloud Firestore under vip_students/$emailKey for $boundEmail (${currentSnapshot["stars"]} stars, ${currentSnapshot["points"]} points).',
            name: 'CloudSync',
          );
        } else {
          developer.log(
            'CloudProgressService: VIP progress cached locally. Will sync to Firestore once Firebase is available.',
            name: 'CloudSync',
          );
        }
      } while (_hasPendingSync);

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

  /// Permanently deletes all student cloud progress from Cloud Firestore as per
  /// Google Play Families Data Deletion Policy and user cancellation requests.
  Future<bool> deleteCloudData() async {
    try {
      // 1. Clear local cloud sync cache and disable auto-sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCachedSnapshot);
      await prefs.remove(_keyLastCloudSync);
      _lastSyncTime = null;
      await LocalStorageService.instance.setCloudSyncEnabled(false);

      if (!isFirebaseAvailable) return true;

      // Ensure active auth session for Firestore security rules
      var user = currentUser;
      if (user == null) {
        try {
          final googleUser = await _googleSignIn.signInSilently();
          if (googleUser != null) {
            final googleAuth = await googleUser.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
            user = userCredential.user;
          }
        } catch (_) {}
      }
      if (user == null) {
        try {
          final anonCred = await FirebaseAuth.instance.signInAnonymously();
          user = anonCred.user;
        } catch (_) {}
      }

      final boundEmail = LocalStorageService.instance.boundMembershipEmail?.trim().toLowerCase();
      final userEmail = user?.email?.trim().toLowerCase();
      final cachedEmail = _cachedEmail?.trim().toLowerCase();

      final emailCandidates = <String>{
        if (boundEmail != null && boundEmail.isNotEmpty) boundEmail,
        if (userEmail != null && userEmail.isNotEmpty) userEmail,
        if (cachedEmail != null && cachedEmail.isNotEmpty) cachedEmail,
      };

      for (final email in emailCandidates) {
        final emailKey = email.replaceAll('.', '_');
        try {
          await FirebaseFirestore.instance
              .collection(_collectionName)
              .doc(emailKey)
              .delete();
        } catch (e) {
          developer.log('Error deleting doc($emailKey): $e', name: 'CloudSync');
        }

        if (email != emailKey) {
          try {
            await FirebaseFirestore.instance
                .collection(_collectionName)
                .doc(email)
                .delete();
          } catch (e) {
            developer.log('Error deleting doc($email): $e', name: 'CloudSync');
          }
        }

        try {
          final querySnap = await FirebaseFirestore.instance
              .collection(_collectionName)
              .where('parentEmail', isEqualTo: email)
              .get();
          for (final doc in querySnap.docs) {
            try {
              await doc.reference.delete();
            } catch (_) {}
          }
        } catch (_) {}

        try {
          final querySnap = await FirebaseFirestore.instance
              .collection(_collectionName)
              .where('membershipBoundEmail', isEqualTo: email)
              .get();
          for (final doc in querySnap.docs) {
            try {
              await doc.reference.delete();
            } catch (_) {}
          }
        } catch (_) {}
      }

      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection(_collectionName)
              .doc(user.uid)
              .delete();
        } catch (_) {}

        try {
          final querySnap = await FirebaseFirestore.instance
              .collection(_collectionName)
              .where('userId', isEqualTo: user.uid)
              .get();
          for (final doc in querySnap.docs) {
            try {
              await doc.reference.delete();
            } catch (_) {}
          }
        } catch (_) {}
      }

      developer.log(
        'CloudProgressService: Cloud data permanently deleted from Firebase Firestore for $emailCandidates as per data deletion policy.',
        name: 'CloudSync',
      );
      return true;
    } catch (e, stack) {
      developer.log(
        'CloudProgressService: Error deleting cloud data: $e',
        error: e,
        stackTrace: stack,
        name: 'CloudSync',
      );
      return false;
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

      // 2. Query Cloud Firestore directly using bound email and verified purchase tokens
      if (isFirebaseAvailable) {
        User? user = currentUser;
        if (user == null) {
          try {
            final anonCred = await FirebaseAuth.instance.signInAnonymously();
            user = anonCred.user;
          } catch (_) {}
        }

        // Try automatic lookup via bound email or Google Play purchase tokens (zero dialogs)
        snapshotData = await _findBestCloudBackup(
          purchaseTokens: InAppPurchaseService.instance.restoredPurchaseTokens,
          firebaseUser: user,
        );

        // If not found and user can be prompted for Google Sign-In, allow them to choose their account
        if (snapshotData == null && promptGoogleSignIn) {
          try {
            final userCredential = await signInWithGoogle();
            if (userCredential != null) {
              final signedInEmail = userCredential.user?.email?.trim().toLowerCase();
              if (signedInEmail != null && signedInEmail.isNotEmpty) {
                snapshotData = await _findBestCloudBackup(
                  explicitEmail: signedInEmail,
                  firebaseUser: userCredential.user,
                );
              }
            }
          } on DifferentGoogleAccountException {
            rethrow;
          } catch (e) {
            developer.log('Google Sign-In note during restore: $e', name: 'CloudSync');
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
      final restoredEmail = (snapshotData['parentEmail'] ?? snapshotData['membershipBoundEmail']) as String?;
      if (restoredEmail != null && restoredEmail.trim().isNotEmpty) {
        final cleanEmail = restoredEmail.trim().toLowerCase();
        await LocalStorageService.instance.setBoundMembershipEmail(cleanEmail);
        _cachedEmail = cleanEmail;
        userEmailNotifier.value = cleanEmail;
      }
      await LocalStorageService.instance.restoreProgressSnapshot(snapshotData);
      await LocalStorageService.instance.setOnboarded(true);
      await LocalStorageService.instance.setCloudSyncEnabled(true);

      final stars = (snapshotData['stars'] as num?)?.toInt() ?? 0;
      final studentName = (snapshotData['name'] ?? snapshotData['studentName']) as String? ?? 'Young Explorer';

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
    } on DifferentGoogleAccountException catch (e) {
      developer.log(
        'CloudProgressService: Different Google account rejected during restore: ${e.message}',
        name: 'CloudSync',
      );
      return CloudRestoreResult(
        status: CloudRestoreStatus.error,
        message: e.message,
        accountEmail: e.boundEmail,
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
