import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

import '../core/app_logger.dart';
import 'push_notification_service.dart';

/// Spark-plan notifications — no Cloud Functions / Blaze required.
///
/// 1. Sender writes to `users/{recipientUid}/notifications` in RTDB.
/// 2. Recipient's app listens in real time and shows a local phone alert.
class NotificationDeliveryService {
  NotificationDeliveryService._();

  static final NotificationDeliveryService instance =
      NotificationDeliveryService._();

  final Set<String> _seenNotificationKeys = {};
  final Set<String> _seenGroupKeys = {};
  StreamSubscription<DatabaseEvent>? _notificationsSub;
  StreamSubscription<DatabaseEvent>? _groupNotificationsSub;
  String? _listeningUid;

  /// Write an in-app + local alert target for [recipientUid].
  Future<void> sendToUser({
    required String recipientUid,
    required String title,
    required String message,
    required String type,
    Map<String, Object?> extra = const {},
  }) async {
    if (recipientUid.isEmpty) {
      return;
    }

    await FirebaseDatabase.instance
        .ref('users/$recipientUid/notifications')
        .push()
        .set({
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'timestamp': ServerValue.timestamp,
      ...extra,
    });

    AppLogger.debug('Notification queued for $recipientUid ($type)', tag: 'NOTIFY');
  }

  /// Listen for new RTDB notification rows and show phone alerts (Android).
  Future<void> startListening(String uid) async {
    if (uid.isEmpty) {
      return;
    }

    if (_listeningUid == uid &&
        _notificationsSub != null &&
        _groupNotificationsSub != null) {
      return;
    }

    await stopListening();
    _listeningUid = uid;

    final notificationsRef =
        FirebaseDatabase.instance.ref('users/$uid/notifications');
    final groupRef =
        FirebaseDatabase.instance.ref('users/$uid/group_notifications');

    _seenNotificationKeys.clear();
    _seenGroupKeys.clear();

    final existingNotifications = await notificationsRef.get();
    if (existingNotifications.exists && existingNotifications.value is Map) {
      _seenNotificationKeys.addAll(
        (existingNotifications.value as Map).keys.map((k) => k.toString()),
      );
    }

    final existingGroup = await groupRef.get();
    if (existingGroup.exists && existingGroup.value is Map) {
      _seenGroupKeys.addAll(
        (existingGroup.value as Map).keys.map((k) => k.toString()),
      );
    }

    _notificationsSub = notificationsRef.onChildAdded.listen((event) {
      final key = event.snapshot.key;
      if (key == null || _seenNotificationKeys.contains(key)) {
        return;
      }
      _seenNotificationKeys.add(key);

      final data = _asMap(event.snapshot.value);
      final title = data['title'] as String? ?? 'FYP Helper';
      final body = data['message'] as String? ?? 'You have a new update.';

      unawaited(PushNotificationService.instance.showLocalAlert(
        title: title,
        body: body,
      ));
    });

    _groupNotificationsSub = groupRef.onChildAdded.listen((event) {
      final key = event.snapshot.key;
      if (key == null || _seenGroupKeys.contains(key)) {
        return;
      }
      _seenGroupKeys.add(key);

      final data = _asMap(event.snapshot.value);
      final body = data['message'] as String? ?? 'You have a group update.';

      unawaited(PushNotificationService.instance.showLocalAlert(
        title: 'Group Update',
        body: body,
      ));
    });

    AppLogger.debug('RTDB notification listener active for $uid', tag: 'NOTIFY');
  }

  Future<void> stopListening() async {
    await _notificationsSub?.cancel();
    await _groupNotificationsSub?.cancel();
    _notificationsSub = null;
    _groupNotificationsSub = null;
    _listeningUid = null;
    _seenNotificationKeys.clear();
    _seenGroupKeys.clear();
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  /// Resolves the other participant in a message thread.
  static String? resolveMessageRecipient(
    Map<String, dynamic>? thread,
    String senderUid,
  ) {
    if (thread == null || senderUid.isEmpty) {
      return null;
    }

    final p1 = thread['participantUid1'] as String?;
    final p2 = thread['participantUid2'] as String?;
    if (p1 != null && p2 != null) {
      if (senderUid == p1) return p2;
      if (senderUid == p2) return p1;
    }

    final userUid = thread['userUid'] as String?;
    final initiatorUid = thread['initiatorUid'] as String?;
    if (userUid != null && initiatorUid != null) {
      if (senderUid == userUid) return initiatorUid;
      if (senderUid == initiatorUid) return userUid;
    }

    return null;
  }
}
