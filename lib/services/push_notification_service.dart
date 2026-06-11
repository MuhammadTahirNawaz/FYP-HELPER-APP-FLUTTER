import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/app_logger.dart';
import '../core/supported_platform.dart';
import 'push_background_handler.dart';

/// Step 1: FCM token registration + foreground notification display (Android).
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const String _channelId = 'fyp_helper_alerts';
  static const String _channelName = 'FYP Helper Alerts';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _activeUid;
  StreamSubscription<String>? _tokenRefreshSub;

  bool get isAvailable => SupportedPlatform.isAndroid;

  /// Call once after [Firebase.initializeApp] in [main].
  Future<void> initialize() async {
    if (_initialized || !isAvailable) {
      return;
    }

    FirebaseMessaging.onBackgroundMessage(pushFirebaseMessagingBackgroundHandler);

    await _initializeLocalNotifications();
    await _requestPermissions();
    _listenForForegroundMessages();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen(_handleTokenRefresh);

    _initialized = true;
    AppLogger.debug('Push notification service initialized.', tag: 'FCM');
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {},
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Messages, approvals, and FYP updates',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    AppLogger.debug(
      'FCM permission: ${settings.authorizationStatus.name}',
      tag: 'FCM',
    );
  }

  void _listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.debug(
        'Foreground FCM: ${message.notification?.title ?? message.data['title']}',
        tag: 'FCM',
      );
      unawaited(_showForegroundNotification(message));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.debug('Notification opened app.', tag: 'FCM');
    });
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title =
        notification?.title ?? message.data['title'] as String? ?? 'FYP Helper';
    final body = notification?.body ??
        message.data['body'] as String? ??
        message.data['message'] as String? ??
        'You have a new update.';

    await showLocalAlert(title: title, body: body);
  }

  /// Shows a system notification on Android (used by RTDB listener + FCM).
  Future<void> showLocalAlert({
    required String title,
    required String body,
  }) async {
    if (!isAvailable) {
      return;
    }

    if (!_initialized) {
      await _initializeLocalNotifications();
      _initialized = true;
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Messages, approvals, and FYP updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  /// Saves the device FCM token under `users/{uid}/fcmToken` in RTDB.
  Future<void> syncTokenForUser(String uid) async {
    if (!isAvailable || uid.isEmpty) {
      return;
    }

    _activeUid = uid;

    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        AppLogger.debug('FCM token not available yet.', tag: 'FCM');
        return;
      }
      await _persistToken(uid, token);
    } catch (error) {
      AppLogger.error('Failed to sync FCM token', tag: 'FCM', error: error);
    }
  }

  Future<void> _handleTokenRefresh(String token) async {
    final uid = _activeUid;
    if (uid == null || token.isEmpty) {
      return;
    }
    await _persistToken(uid, token);
  }

  Future<void> _persistToken(String uid, String token) async {
    await FirebaseDatabase.instance.ref('users/$uid').update({
      'fcmToken': token,
      'fcmUpdatedAt': ServerValue.timestamp,
      'fcmPlatform': SupportedPlatform.name,
    });

    AppLogger.debug(
      'FCM token saved for $uid (${token.substring(0, 8)}…)',
      tag: 'FCM',
    );
  }

  /// Removes token from RTDB on sign-out so pushes are not sent to this device.
  Future<void> clearTokenForUser(String uid) async {
    if (!isAvailable || uid.isEmpty) {
      return;
    }

    _activeUid = null;

    try {
      await FirebaseDatabase.instance.ref('users/$uid').update({
        'fcmToken': null,
        'fcmUpdatedAt': ServerValue.timestamp,
      });
      await _messaging.deleteToken();
      AppLogger.debug('FCM token cleared for $uid', tag: 'FCM');
    } catch (error) {
      AppLogger.error('Failed to clear FCM token', tag: 'FCM', error: error);
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
  }
}
