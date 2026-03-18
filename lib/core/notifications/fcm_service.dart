import 'dart:convert';
import 'dart:io';

import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Top-level background handler — must be outside any class
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized in main.dart — nothing extra needed here.
  LogUtil.info('FCM background message: ${message.messageId}');
}

// ─────────────────────────────────────────────────────────────────────────────
// Local notifications plugin (global — needed for the background isolate)
// ─────────────────────────────────────────────────────────────────────────────
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const _channelId = 'high_importance_channel';
const _channelName = 'High Importance Notifications';
const _restBaseUrl = 'https://api.agriflock360.com/api/v1';

// ─────────────────────────────────────────────────────────────────────────────
// FCMService singleton
// ─────────────────────────────────────────────────────────────────────────────
class FCMService {
  FCMService._();
  static final FCMService instance = FCMService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  SecureStorage? _storage;

  /// Call once from main() after Firebase.initializeApp().
  Future<void> initialize({
    required SecureStorage storage,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    _storage = storage;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _requestPermission();
    await _setupLocalNotifications();

    // Foreground messages → show local banner
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Tap when app is backgrounded
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _handleNotificationTap(message, navigatorKey),
    );

    // Tap when app was killed
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      _handleNotificationTap(initialMessage, navigatorKey);
    }

    // Register token if user is already logged in
    final authToken = await _storage?.getToken();
    if (authToken != null) await _registerDevice();

    // Re-register whenever FCM rotates the token
    _messaging.onTokenRefresh.listen((_) => _registerDevice());
  }

  /// Call after a successful login so the token is linked to the user.
  Future<void> registerTokenAfterLogin() async => _registerDevice();

  // ── Private ────────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
      provisional: false,
    );
    LogUtil.info('FCM permission: ${settings.authorizationStatus.name}');
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.high,
          ),
        );
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Suppress device-registration confirmation notifications — just log them
    final type = (message.data['type'] as String? ?? '').toLowerCase();
    final title = (notification.title ?? '').toLowerCase();
    final body = (notification.body ?? '').toLowerCase();
    final isDeviceRegistration = type.contains('device') ||
        type.contains('connect') ||
        title.contains('connected') ||
        title.contains('monitoring has started') ||
        body.contains('monitoring has started') ||
        body.contains('now connected');
    if (isDeviceRegistration) {
      LogUtil.info('FCM: device registration notification — suppressing banner');
      return;
    }

    LogUtil.info('FCM foreground: ${notification.title}');

    flutterLocalNotificationsPlugin.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void _handleNotificationTap(
    RemoteMessage message,
    GlobalKey<NavigatorState>? navigatorKey,
  ) {
    LogUtil.info('FCM tapped: ${message.data}');
    // Navigate based on data payload — extend as needed:
    // final type = message.data['type'];
    // if (type == 'vet_visit') navigatorKey?.currentState?.pushNamed('/vet-schedules');
  }

  /// Builds the full device payload and POSTs to POST /notifications/devices
  Future<void> _registerDevice() async {
    try {
      final fcmToken = await _messaging.getToken();
      if (fcmToken == null) return;

      final authToken = await _storage?.getToken();
      if (authToken == null) {
        LogUtil.warning('FCMService: no auth token — skipping device registration');
        return;
      }

      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      String deviceId;
      String? deviceName;
      String? deviceModel;
      String? osVersion;

      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceId = android.id;                        // Android ID (stable per device)
        deviceName = android.model;
        deviceModel = '${android.brand} ${android.model}';
        osVersion = 'Android ${android.version.release}';
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceId = ios.identifierForVendor ?? ios.name;
        deviceName = ios.name;
        deviceModel = ios.model;
        osVersion = 'iOS ${ios.systemVersion}';
      } else {
        deviceId = 'unknown';
      }

      final body = {
        'device_id': deviceId,
        'fcm_token': fcmToken,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'device_name': deviceName,
        'device_model': deviceModel,
        'os_version': osVersion,
        'app_version': packageInfo.version,
      };

      LogUtil.info('FCMService: registering device — $body');

      final response = await http.post(
        Uri.parse('$_restBaseUrl/notifications/devices'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        LogUtil.info('FCMService: device registered successfully');
      } else {
        LogUtil.warning(
          'FCMService: device registration failed ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      LogUtil.error('FCMService: _registerDevice error — $e');
    }
  }
}
