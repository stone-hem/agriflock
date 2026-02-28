import 'dart:convert';
import 'dart:async';
import 'package:agriflock/app_routes.dart';
import 'package:agriflock/core/constants/app_constants.dart';
import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ApiClient {
  final SecureStorage storage;
  final GlobalKey<NavigatorState> navigatorKey;

  bool _isRefreshing = false;
  final List<Completer<bool>> _refreshCompleters = [];

  ApiClient({
    required this.storage,
    required this.navigatorKey,
  });

  Future<Map<String, String>> _getHeaders({Map<String, String>? extraHeaders}) async {
    final token = await storage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?extraHeaders,
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Enhanced token refresh with proper queuing
  Future<bool> _refreshToken() async {
    // If already refreshing, wait for that refresh to complete
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _refreshCompleters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await storage.getRefreshToken();

      if (refreshToken == null) {
        await _handleUnauthorized();
        _completeWaitingRefreshes(false);
        return false;
      }

      final uri = Uri.parse('${AppConstants.baseUrl}/auth/refresh');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
          'session_id': await storage.getSessionId()
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await storage.updateTokens(
          token: data['access_token'] ?? data['accessToken'] ?? data['token'],
          refreshToken: data['refresh_token'] ?? data['refreshToken'],
          expiresInSeconds: data['expires_in'] ?? data['expiresIn'] ?? 3600,
        );

        _completeWaitingRefreshes(true);
        return true;
      } else {
        await _handleUnauthorized();
        _completeWaitingRefreshes(false);
        return false;
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
      await _handleUnauthorized();
      _completeWaitingRefreshes(false);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // Complete all waiting refresh requests
  void _completeWaitingRefreshes(bool success) {
    for (var completer in _refreshCompleters) {
      if (!completer.isCompleted) {
        completer.complete(success);
      }
    }
    _refreshCompleters.clear();
  }

  Future<void> _handleUnauthorized() async {
    await storage.clearAll();
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  // Enhanced response handler with automatic retry
  Future<http.Response> _handleResponse(
      http.Response response,
      Future<http.Response> Function() retryRequest,
      {bool hasRetried = false}
      ) async {
    if (response.statusCode == 401 && !hasRetried) {
      debugPrint('Received 401, attempting token refresh...');

      final refreshed = await _refreshToken();

      if (refreshed) {
        debugPrint('Token refreshed, retrying request...');
        // Retry the original request with new token
        final retryResponse = await retryRequest();

        // Mark as retried to prevent infinite loops
        return await _handleResponse(retryResponse, retryRequest, hasRetried: true);
      } else {
        debugPrint('Token refresh failed, logging out...');
        await _handleUnauthorized();
      }
    } else if (response.statusCode == 401 && hasRetried) {
      // Already retried once and still got 401, logout
      debugPrint('Retry also failed with 401, logging out...');
      await _handleUnauthorized();
    }

    return response;
  }

  // GET request with automatic retry
  Future<http.Response> get(
      String endpoint, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint')
          .replace(queryParameters: queryParameters);

      Future<http.Response> makeRequest() async {
        return await http.get(
          uri,
          headers: await _getHeaders(extraHeaders: headers),
        );
      }

      final response = await makeRequest();
      return await _handleResponse(response, makeRequest);
    } catch (e) {
      LogUtil.error('GET request error: $e');
      rethrow;
    }
  }

  // POST request with automatic retry
  Future<http.Response> post(
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
      }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

      Future<http.Response> makeRequest() async {
        return await http.post(
          uri,
          headers: await _getHeaders(extraHeaders: headers),
          body: body != null ? jsonEncode(body) : null,
        );
      }

      final response = await makeRequest();
      return await _handleResponse(response, makeRequest);
    } catch (e) {
      LogUtil.error('POST request error: $e');
      rethrow;
    }
  }

  // PUT request with automatic retry
  Future<http.Response> put(
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
      }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

      Future<http.Response> makeRequest() async {
        return await http.put(
          uri,
          headers: await _getHeaders(extraHeaders: headers),
          body: body != null ? jsonEncode(body) : null,
        );
      }

      final response = await makeRequest();
      return await _handleResponse(response, makeRequest);
    } catch (e) {
      LogUtil.error('PUT request error: $e');
      rethrow;
    }
  }

  // PATCH request with automatic retry
  Future<http.Response> patch(
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
      }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

      Future<http.Response> makeRequest() async {
        return await http.patch(
          uri,
          headers: await _getHeaders(extraHeaders: headers),
          body: body != null ? jsonEncode(body) : null,
        );
      }

      final response = await makeRequest();
      return await _handleResponse(response, makeRequest);
    } catch (e) {
      LogUtil.error('PATCH request error: $e');
      rethrow;
    }
  }

  // DELETE request with automatic retry
  Future<http.Response> delete(
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
      }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

      Future<http.Response> makeRequest() async {
        return await http.delete(
          uri,
          headers: await _getHeaders(extraHeaders: headers),
          body: body != null ? jsonEncode(body) : null,
        );
      }

      final response = await makeRequest();
      return await _handleResponse(response, makeRequest);
    } catch (e) {
      LogUtil.error('DELETE request error: $e');
      rethrow;
    }
  }

  // Multipart POST with automatic retry
  Future<http.StreamedResponse> postMultipart(
      String endpoint, {
        Map<String, String>? fields,
        Map<String, String>? headers,
        List<http.MultipartFile>? files,
        String method = 'POST', // Add method parameter with default value
      }) async {
    try {
      Future<http.StreamedResponse> makeRequest() async {
        final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
        final request = http.MultipartRequest(method, uri); // Use the method parameter

        final token = await storage.getToken();
        final authHeaders = {
          'Accept': 'application/json',
          ...?headers,
        };

        if (token != null) {
          authHeaders['Authorization'] = 'Bearer $token';
        }

        request.headers.addAll(authHeaders);

        if (fields != null) {
          // Remove _method if it exists in fields
          final cleanFields = Map<String, String>.from(fields);
          cleanFields.remove('_method');
          request.fields.addAll(cleanFields);
        }

        if (files != null) {
          request.files.addAll(files);
        }

        return await request.send();
      }

      final streamedResponse = await makeRequest();

      if (streamedResponse.statusCode == 401) {
        final refreshed = await _refreshToken();

        if (refreshed) {
          return await makeRequest();
        } else {
          await _handleUnauthorized();
        }
      }

      return streamedResponse;
    } catch (e) {
      LogUtil.error('Multipart request error: $e');
      rethrow;
    }
  }

  /// PUT multipart request for single file upload (specifically for avatar)
  Future<http.StreamedResponse> putMultipartSingleFile(
      String endpoint, {
        Map<String, String>? fields,
        Map<String, String>? headers,
        required http.MultipartFile file,
        String method = 'POST', // Add method parameter with default value
      }) async {
    try {
      Future<http.StreamedResponse> makeRequest() async {
        final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
        final request = http.MultipartRequest(method, uri);

        final token = await storage.getToken();
        final authHeaders = {
          'Accept': 'application/json',
          ...?headers,
        };

        if (token != null) {
          authHeaders['Authorization'] = 'Bearer $token';
        }

        request.headers.addAll(authHeaders);

        if (fields != null) {
          request.fields.addAll(fields);
        }

        request.files.add(file); // Add single file

        return await request.send();
      }

      final streamedResponse = await makeRequest();

      if (streamedResponse.statusCode == 401) {
        final refreshed = await _refreshToken();

        if (refreshed) {
          return await makeRequest();
        } else {
          await _handleUnauthorized();
        }
      }

      return streamedResponse;
    } catch (e) {
      LogUtil.error('PUT Multipart request error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await post('/auth/logout', body: {});
    } catch (e) {
      debugPrint('Logout endpoint error: $e');
    } finally {
      await Future.microtask(() {});
      await _handleUnauthorized();
    }
  }
}