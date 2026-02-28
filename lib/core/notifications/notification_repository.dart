import 'dart:convert';

import 'package:agriflock/core/notifications/notification_model.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/core/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

/// Fetches past notifications from the REST API.
/// Real-time additions come via [NotificationService] (WebSocket).
class NotificationRepository {
  NotificationRepository({SecureStorage? storage})
      : _storage = storage ?? SecureStorage();

  final SecureStorage _storage;
  static const _base = 'https://api.agriflock.com/api/v1';

  Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Result<List<AppNotification>>> fetchNotifications() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/notifications'),
        headers: await _headers(),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        // Handle both { data: [...] } and plain [...]
        final List<dynamic> items = body is List
            ? body
            : (body as Map<String, dynamic>)['data'] ??
                body['notifications'] ??
                [];
        return Success(
          items
              .map((e) =>
                  AppNotification.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return Failure(
          message: 'Failed to load notifications (${res.statusCode})');
    } catch (e) {
      return Failure(message: e.toString());
    }
  }
}
