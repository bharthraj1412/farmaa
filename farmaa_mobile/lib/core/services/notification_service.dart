import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background message handler — must be top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  log('[FCM] Background message: ${message.notification?.title}');
}

/// Notification service wrapping FCM + flutter_local_notifications.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _local = FlutterLocalNotificationsPlugin();
  final _fcm = FirebaseMessaging.instance;
  bool _initialized = false;

  static const _channelId = 'farmaa_channel';
  static const _channelName = 'Farmaa Notifications';

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // ── Local notifications setup ──────────────────────────────
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _local.initialize(initSettings);

    // Create the high-importance channel (Android 8+)
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.max,
    );
    final androidImplementation = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(channel);
    await androidImplementation?.requestNotificationsPermission();

    // ── FCM permissions ────────────────────────────────────────
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('[FCM] Permission: ${settings.authorizationStatus}');

    // ── FCM token ─────────────────────────────────────────────
    // Use a timeout to prevent getToken() from hanging on devices without Play Services
    try {
      final token = await _fcm.getToken().timeout(const Duration(seconds: 5));
      log('[FCM] Token: $token');
    } catch (e) {
      log('[FCM] Token fetch failed or timed out: $e');
    }

    // ── Background handler ─────────────────────────────────────
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // ── Foreground handler ─────────────────────────────────────
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        showLocal(
          title: notification.title ?? 'Farmaa',
          body: notification.body ?? '',
        );
      }
    });

    // Token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      log('[FCM] Token refreshed: $newToken');
      // TODO: Update token on backend
    });
  }

  /// Show a local notification immediately.
  Future<void> showLocal({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
