/// Notification Service
///
/// Initializes Firebase Messaging, requests permission, obtains the FCM token,
/// and registers handlers for foreground and background notification taps.
/// Foreground messages are shown as local notifications with sound.
/// All received messages are persisted to Hive for the notifications inbox.
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import '../../features/notifications/data/datasources/notifications_local_datasource.dart';
import '../../features/notifications/domain/entities/app_notification.dart';

/// Android notification channel for low-stock alerts.
const _channel = AndroidNotificationChannel(
  'low_stock_alerts',
  'Low Stock Alerts',
  description: 'Notifications when product stock falls below the reorder threshold.',
  importance: Importance.high,
  playSound: true,
);

final _localNotifications = FlutterLocalNotificationsPlugin();

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized by the time this runs on Android.
  await _saveToHive(message);
}

/// Save an FCM message to the local Hive notifications box.
Future<void> _saveToHive(RemoteMessage message) async {
  try {
    await NotificationsLocalDatasource.openBox();
    final notification = AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      data: Map<String, String>.from(message.data),
      isRead: false,
      createdAt: message.sentTime ?? DateTime.now(),
    );
    await notificationsLocalDatasource.save(notification);
  } catch (e) {
    debugPrint('🔔 Failed to save notification to Hive: $e');
  }
}

class NotificationService {
  NotificationService._();

  static final _messaging = FirebaseMessaging.instance;

  /// Initialize Firebase, local notifications plugin, request permission, set up handlers.
  /// Call once from main() after WidgetsFlutterBinding.ensureInitialized().
  static Future<void> initialize() async {
    // Web is not a supported target — skip Firebase init on web to avoid
    // the "FirebaseOptions cannot be null" assertion from firebase_core_web.
    if (kIsWeb) return;

    await Firebase.initializeApp();

    // Register background handler before any other Firebase calls
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Initialize local notifications plugin
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit),
    );

    // Request permission (Android 13+ / iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Tell FCM to deliver messages to the app even when in foreground (Android)
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');
  }

  /// Obtain the FCM token and register it with the backend.
  /// Call after the user is authenticated.
  static Future<void> registerToken(ApiClient apiClient) async {
    if (kIsWeb) return;
    try {
      final token = await _messaging.getToken();
      if (token == null) {
        debugPrint('🔔 FCM token is null — skipping registration');
        return;
      }
      debugPrint('🔔 FCM token: ${token.substring(0, 20)}...');

      await apiClient.post(
        ApiEndpoints.merchantFcmToken,
        data: {'token': token},
      );
      debugPrint('🔔 FCM token registered with backend');

      // Re-register whenever the token is refreshed
      _messaging.onTokenRefresh.listen((newToken) {
        apiClient
            .post(ApiEndpoints.merchantFcmToken, data: {'token': newToken})
            .then((_) {})
            .catchError((e) {
          debugPrint('🔔 Token refresh registration failed: $e');
        });
      });
    } catch (e) {
      // Non-fatal — notifications simply won't work until next login
      debugPrint('🔔 Failed to register FCM token: $e');
    }
  }

  /// Set up handlers for notification taps and foreground messages.
  /// [onTap] receives the data payload map for navigation.
  /// [onNewNotification] is called whenever a message is received (to update the inbox).
  static void setupTapHandlers({
    required void Function(Map<String, dynamic> data) onTap,
    required void Function(AppNotification notification) onNewNotification,
  }) {
    if (kIsWeb) return;
    // App opened from terminated state via notification tap
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message?.data.isNotEmpty == true) {
        onTap(message!.data);
      }
    });

    // App brought to foreground via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.isNotEmpty) {
        onTap(message.data);
      }
    });

    // Foreground notification — show local notification banner + save to inbox
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint('🔔 Foreground notification: ${message.notification?.title}');

      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';

      // Show visible banner with sound
      if (title.isNotEmpty) {
        await _localNotifications.show(
          message.hashCode,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }

      // Save to Hive and notify the inbox provider
      final notification = AppNotification(
        id: message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        data: Map<String, String>.from(message.data),
        isRead: false,
        createdAt: message.sentTime ?? DateTime.now(),
      );
      await notificationsLocalDatasource.save(notification);
      onNewNotification(notification);
    });
  }
}
