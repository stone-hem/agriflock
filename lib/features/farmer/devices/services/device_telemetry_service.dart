import 'dart:async';
import 'dart:convert';

import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/secure_storage.dart';
import 'package:agriflock/features/farmer/devices/models/telemetry_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Per-device WebSocket telemetry service.
///
/// Create one per telemetry screen, call [connect], and listen to
/// [telemetryStream] / [alertStream]. Call [dispose] on screen exit.
class DeviceTelemetryService {
  static const _wsBaseUrl = 'wss://api.agriflock.com/telemetry';
  static const _maxReconnectAttempts = 6;

  final String deviceId;
  final SecureStorage _storage;

  DeviceTelemetryService({required this.deviceId, required SecureStorage storage})
      : _storage = storage;

  // ── Streams ────────────────────────────────────────────────────────────────
  final _telemetryController = StreamController<TelemetryData>.broadcast();
  final _alertController = StreamController<DeviceAlert>.broadcast();

  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;
  Stream<DeviceAlert> get alertStream => _alertController.stream;

  // ── Internal state ─────────────────────────────────────────────────────────
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _wsSub;
  bool _isConnecting = false;
  bool _disposed = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> connect() async {
    if (_isConnecting || _disposed) return;
    _isConnecting = true;

    try {
      final token = await _storage.getToken();
      if (token == null || token.isEmpty) {
        LogUtil.warning('DeviceTelemetryService: no token, skipping connect');
        return;
      }

      _closeSocket();

      final uri = Uri.parse('$_wsBaseUrl?token=${Uri.encodeComponent(token)}');
      _channel = WebSocketChannel.connect(uri);

      _wsSub = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      // Subscribe to the device after connection
      _channel!.sink.add(jsonEncode({
        'event': 'subscribe_device',
        'data': {'deviceId': deviceId},
      }));

      _reconnectAttempts = 0;
      LogUtil.info('DeviceTelemetryService: connected for device $deviceId');
    } catch (e) {
      LogUtil.error('DeviceTelemetryService: connect error — $e');
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _closeSocket();
    _telemetryController.close();
    _alertController.close();
    LogUtil.info('DeviceTelemetryService: disposed for device $deviceId');
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  void _onMessage(dynamic raw) {
    try {
      final map = jsonDecode(raw as String) as Map<String, dynamic>;
      final event = map['event'] as String?;
      final data = map['data'] as Map<String, dynamic>?;

      if (data == null) return;

      if (event == 'telemetry') {
        final telemetry = TelemetryData.fromJson(data);
        if (!_telemetryController.isClosed) {
          _telemetryController.add(telemetry);
        }
      } else if (event == 'device_alert') {
        final alert = DeviceAlert.fromJson(data);
        if (!_alertController.isClosed) {
          _alertController.add(alert);
        }
      }
    } catch (e) {
      LogUtil.error('DeviceTelemetryService: parse error — $e');
    }
  }

  void _onError(Object error) {
    LogUtil.error('DeviceTelemetryService: WS error — $error');
    if (!_disposed) _scheduleReconnect();
  }

  void _onDone() {
    LogUtil.warning('DeviceTelemetryService: WS connection closed');
    if (!_disposed) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectAttempts >= _maxReconnectAttempts) return;
    _reconnectAttempts++;
    final delay = Duration(seconds: (_reconnectAttempts * 2).clamp(2, 30));
    LogUtil.warning(
      'DeviceTelemetryService: reconnecting in ${delay.inSeconds}s '
      '(attempt $_reconnectAttempts/$_maxReconnectAttempts)',
    );
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, connect);
  }

  void _closeSocket() {
    _wsSub?.cancel();
    _wsSub = null;
    _channel?.sink.close();
    _channel = null;
  }
}
