import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/local/local_storage_service.dart';
import '../core/services/device_info_helper.dart';

/// Top-level background message handler required by Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('[FCM Background] Message received: ${message.messageId} - ${message.notification?.title}');
  } catch (e) {
    debugPrint('[FCM Background] Error in background handler: $e');
  }
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  FirebaseMessaging? _messagingInstance;
  FirebaseMessaging get _messaging => _messagingInstance ??= FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String channelId = 'curio_learning_channel';
  static const String channelName = 'Learning & Practice Reminders';
  static const String channelDescription =
      'Daily streaks, practice reminders, and educational updates from Curio Academy';

  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.high,
    playSound: true,
  );

  bool _initialized = false;
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _permissionRequested = false;

  /// Initializes Firebase Cloud Messaging and Local Notifications in the background
  /// Note: The system permission dialog is deferred until user reaches the Dashboard!
  Future<void> initialize({bool requestPermissionOnStartup = false}) async {
    if (_initialized) return;

    try {
      // 1. Register top-level background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 2. Initialize local notifications for foreground heads-up display
      await _initLocalNotifications();

      // 3. Request permissions only if requested on startup (otherwise deferred to Dashboard)
      if (requestPermissionOnStartup) {
        await requestPermissions();
      }

      // 4. Configure foreground presentation options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 5. Setup message streams
      _setupMessageListeners();

      // 6. Fetch and register token
      await _retrieveAndSyncToken();

      // 7. Subscribe to default broadcast topics
      await _subscribeToDefaultTopics();

      _initialized = true;
      debugPrint('[NotificationService] Successfully initialized Firebase Cloud Messaging.');
    } catch (e) {
      debugPrint('[NotificationService] Initialization note: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('[LocalNotifications] User tapped notification payload: ${response.payload}');
      },
    );

    if (Platform.isAndroid) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.createNotificationChannel(_androidChannel);
    }
  }

  /// Requests notification permission on Dashboard when user has settled
  Future<void> requestPermissions() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('[NotificationService] Permission status: ${settings.authorizationStatus}');

      if (Platform.isAndroid) {
        final androidImplementation = _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await androidImplementation?.requestNotificationsPermission();
      }

      // Sync token again now that permission has been determined
      await _retrieveAndSyncToken();
    } catch (e) {
      debugPrint('[NotificationService] Permission request note: $e');
    }
  }

  void _setupMessageListeners() {
    // A. Foreground message listener -> Show local heads-up notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[NotificationService] Foreground message received: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // B. App opened from background notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[NotificationService] App opened from notification: ${message.data}');
    });

    // C. App opened from terminated state
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('[NotificationService] App launched from terminated state via notification: ${message.data}');
      }
    });

    // D. Token refresh listener
    _messaging.onTokenRefresh.listen((String newToken) {
      _fcmToken = newToken;
      _saveTokenToCloud(newToken);
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: message.hashCode.abs(),
      title: notification.title ?? 'Curio Academy',
      body: notification.body ?? '',
      notificationDetails: platformDetails,
      payload: message.data.toString(),
    );
  }

  Future<void> _retrieveAndSyncToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        _fcmToken = token;
        debugPrint('[NotificationService] FCM Registration Token: $token');
        await _saveTokenToCloud(token);
      }
    } catch (e) {
      debugPrint('[NotificationService] Token retrieval error: $e');
    }
  }

  Future<void> _saveTokenToCloud(String token) async {
    try {
      final boundEmail = LocalStorageService.instance.boundMembershipEmail?.trim().toLowerCase() ?? 'anonymous';
      final isVip = LocalStorageService.instance.isPremiumUser || LocalStorageService.instance.isClosedTester;
      final profile = await LocalStorageService.instance.getStudentProfile();
      final deviceDetails = await DeviceInfoHelper.getDeviceDetails();

      final tokenData = {
        'token': token,
        'parentEmail': boundEmail,
        'studentName': profile?.studentName,
        'studentClass': profile?.studentClass.label,
        'isVip': isVip,
        'platform': Platform.operatingSystem,
        'appVersion': deviceDetails.appVersion,
        'buildNumber': deviceDetails.buildNumber,
        'deviceModel': deviceDetails.deviceModel,
        'deviceBrand': deviceDetails.deviceBrand,
        'osVersion': deviceDetails.osVersion,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 1. Store under global fcm_tokens collection
      final tokenDocId = token.length > 64 ? token.substring(token.length - 64) : token;
      try {
        await FirebaseFirestore.instance
            .collection('fcm_tokens')
            .doc(tokenDocId)
            .set(tokenData, SetOptions(merge: true));
        debugPrint('[NotificationService] Token synced to fcm_tokens/$tokenDocId');
      } catch (e) {
        debugPrint('[NotificationService] Note: fcm_tokens write error (check Firestore rules): $e');
      }

      // 2. If member has a registered email, mirror token inside their vip_students document
      if (boundEmail != 'anonymous') {
        final emailKey = boundEmail.replaceAll('.', '_');
        try {
          await FirebaseFirestore.instance
              .collection('vip_students')
              .doc(emailKey)
              .set({
                'fcmToken': token,
                'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
          debugPrint('[NotificationService] Token mirrored to vip_students/$emailKey');
        } catch (e) {
          debugPrint('[NotificationService] Mirror token to vip_students note: $e');
        }
      }
    } catch (e) {
      debugPrint('[NotificationService] Save token to cloud error: $e');
    }
  }

  Future<void> _subscribeToDefaultTopics() async {
    try {
      // General topic for all installed users
      await _messaging.subscribeToTopic('curio_all_users');
      await _messaging.subscribeToTopic('curio_learning_updates');

      // VIP members broadcast topic
      final isVip = LocalStorageService.instance.isPremiumUser || LocalStorageService.instance.isClosedTester;
      if (isVip) {
        await _messaging.subscribeToTopic('curio_vip_members');
      }
    } catch (e) {
      debugPrint('[NotificationService] Topic subscription note: $e');
    }
  }

  /// Manually subscribe/unsubscribe to VIP notifications
  Future<void> updateVipTopicSubscription(bool isVip) async {
    try {
      if (isVip) {
        await _messaging.subscribeToTopic('curio_vip_members');
      } else {
        await _messaging.unsubscribeFromTopic('curio_vip_members');
      }
    } catch (_) {}
  }
}
