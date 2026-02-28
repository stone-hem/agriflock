import 'dart:async';
import 'dart:convert';

import 'package:agriflock/core/notifications/notification_model.dart';
import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

/// Singleton real-time notification service.
///
/// Usage:
///   NotificationService.instance.initialize(secureStorage);
///   NotificationService.instance.connect(); // call after login
///   NotificationService.instance.disconnect(); // call on logout
///
/// Listen to live list:
///   StreamBuilder(stream: NotificationService.instance.notificationsStream, ...)
///
/// Unread badge count:
///   ValueListenableBuilder(valueListenable: NotificationService.instance.unreadCount, ...)
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  // ── Constants ──────────────────────────────────────────────────────────────
  static const _wsBaseUrl = 'wss://api.agriflock360.com/notifications';
  static const _restBaseUrl = 'https://api.agriflock360.com/api/v1';
  static const _maxReconnectAttempts = 8;

  // ── Dependencies ───────────────────────────────────────────────────────────
  SecureStorage? _storage;

  // ── State ──────────────────────────────────────────────────────────────────
  final List<AppNotification> _notifications = [];
  final _controller =
      StreamController<List<AppNotification>>.broadcast();

  /// Live stream of the full sorted notifications list.
  Stream<List<AppNotification>> get notificationsStream => _controller.stream;

  /// Reactive unread count — use with [ValueListenableBuilder].
  final ValueNotifier<int> unreadCount = ValueNotifier(0);

  /// Snapshot of the current list (for synchronous reads).
  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);

  // ── WebSocket internals ────────────────────────────────────────────────────
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _wsSub;
  bool _isConnecting = false;
  bool _stopped = false; // set on explicit disconnect / logout
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  // ── Initialise (call once from main.dart after login) ─────────────────────
  void initialize(SecureStorage storage) {
    _storage = storage;
  }

  // ── Connect ────────────────────────────────────────────────────────────────
  Future<void> connect() async {
    if (_isConnecting || _storage == null) return;
    _stopped = false;
    _isConnecting = true;

    try {
      final token = await _storage!.getToken();
      if (token == null || token.isEmpty) {
        LogUtil.warning('NotificationService: no token, skipping connect');
        return;
      }

      _closeSocket(); // clean up any existing socket

      final uri = Uri.parse('$_wsBaseUrl?token=${Uri.encodeComponent(token)}');
      _channel = WebSocketChannel.connect(uri);

      _wsSub = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _reconnectAttempts = 0;
      LogUtil.warning('NotificationService: WebSocket connected');
    } catch (e) {
      LogUtil.error('NotificationService: connect error — $e');
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  // ── Disconnect (logout / app close) ───────────────────────────────────────
  void disconnect() {
    _stopped = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _closeSocket();
    LogUtil.warning('NotificationService: disconnected');
  }

  // ── Seed with REST-fetched notifications (call after fetch) ───────────────
  void seedNotifications(List<AppNotification> list) {
    _notifications
      ..clear()
      ..addAll(list);
    _emit();
  }

  // ── Mark single notification as read ──────────────────────────────────────
  Future<void> markAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1 || _notifications[idx].isRead) return;

    _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    _emit();

    try {
      final token = await _storage?.getToken();
      if (token == null) return;
      await http.patch(
        Uri.parse('$_restBaseUrl/notifications/$id/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      LogUtil.error('NotificationService: markAsRead error — $e');
    }
  }

  // ── Mark all as read ──────────────────────────────────────────────────────
  Future<void> markAllAsRead() async {
    bool changed = false;
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (!changed) return;
    _emit();

    try {
      final token = await _storage?.getToken();
      if (token == null) return;
      await http.patch(
        Uri.parse('$_restBaseUrl/notifications/read-all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      LogUtil.error('NotificationService: markAllAsRead error — $e');
    }
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  void _onMessage(dynamic raw) {
    try {
      final map = jsonDecode(raw as String) as Map<String, dynamic>;
      if (map['event'] == 'notification') {
        final data = map['data'] as Map<String, dynamic>;
        final notification = AppNotification.fromJson(data);
        _upsert(notification);
      }
    } catch (e) {
      LogUtil.error('NotificationService: parse error — $e');
    }
  }

  void _onError(Object error) {
    LogUtil.error('NotificationService: WS error — $error');
    if (!_stopped) _scheduleReconnect();
  }

  void _onDone() {
    LogUtil.warning('NotificationService: WS connection closed');
    if (!_stopped) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_stopped || _reconnectAttempts >= _maxReconnectAttempts) return;
    _reconnectAttempts++;
    // Exponential back-off: 2s, 4s, 6s … capped at 30s
    final delay =
        Duration(seconds: (_reconnectAttempts * 2).clamp(2, 30));
    LogUtil.warning(
        'NotificationService: reconnecting in ${delay.inSeconds}s '
        '(attempt $_reconnectAttempts / $_maxReconnectAttempts)');
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _reconnectWithRefresh);
  }

  Future<void> _reconnectWithRefresh() async {
    if (_storage == null) return;
    final isExpired = await _storage!.isTokenExpired();
    if (isExpired) {
      final ok = await _doTokenRefresh();
      if (!ok) return;
    }
    await connect();
  }

  Future<bool> _doTokenRefresh() async {
    try {
      final rt = await _storage!.getRefreshToken();
      if (rt == null) return false;

      final res = await http.post(
        Uri.parse('$_restBaseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh_token': rt,
          'session_id': await _storage!.getSessionId(),
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        await _storage!.updateTokens(
          token: data['access_token'] ??
              data['accessToken'] ??
              data['token'] as String,
          refreshToken:
              data['refresh_token'] ?? data['refreshToken'] as String?,
          expiresInSeconds:
              (data['expires_in'] ?? data['expiresIn'] ?? 3600) as int,
        );
        return true;
      }
    } catch (e) {
      LogUtil.error('NotificationService: token refresh failed — $e');
    }
    return false;
  }

  void _closeSocket() {
    _wsSub?.cancel();
    _wsSub = null;
    _channel?.sink.close();
    _channel = null;
  }

  void _upsert(AppNotification n) {
    _notifications.removeWhere((e) => e.id == n.id);
    _notifications.insert(0, n);
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_notifications));
    }
    unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }
}
