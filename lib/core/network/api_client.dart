import 'dart:convert';
import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/services/social_auth_service.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../utils/secure_storage.dart';

class ApiClient {
  final SecureStorage storage;
  final GlobalKey<NavigatorState> navigatorKey;

  // Flag to prevent multiple simultaneous refresh attempts
  bool _isRefreshing = false;

  // Queue to hold requests while refreshing
  final List<Function> _requestQueue = [];

  ApiClient({
    required this.storage,
    required this.navigatorKey,
  });

  // Get headers with authentication token
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

  // Refresh access token using refresh token
  Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      // Wait for the current refresh to complete
      await Future.delayed(const Duration(milliseconds: 100));
      return await storage.isLoggedIn();
    }

    _isRefreshing = true;

    try {
      final refreshToken = await storage.getRefreshToken();

      if (refreshToken == null) {
        await _handleUnauthorized();
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

        // Update tokens
        await storage.updateTokens(
          token: data['access_token'] ?? data['accessToken'] ?? data['token'],
          refreshToken: data['refresh_token'] ?? data['refreshToken'],
          expiresInSeconds: data['expires_in'] ?? data['expiresIn'] ?? 3600,
        );

        _isRefreshing = false;

        // Process queued requests
        _processQueue();

        return true;
      } else {
        // Refresh failed - logout user
        await _handleUnauthorized();
        _isRefreshing = false;
        return false;
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
      await _handleUnauthorized();
      _isRefreshing = false;
      return false;
    }
  }

  // Process queued requests after token refresh
  void _processQueue() {
    for (var request in _requestQueue) {
      request();
    }
    _requestQueue.clear();
  }

  // Handle 401 errors - clear storage and redirect to login
  Future<void> _handleUnauthorized() async {
    await storage.clearAll();
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  // Check if token needs refresh and refresh if necessary
  Future<bool> _ensureValidToken() async {
    final isExpired = await storage.isTokenExpired();

    if (isExpired) {
      return await _refreshToken();
    }

    return true;
  }

  // Handle response and check for 401
  Future<http.Response> _handleResponse(http.Response response, Function retryRequest) async {
    if (response.statusCode == 401) {
      // Try to refresh token
      final refreshed = await _refreshToken();

      if (refreshed) {
        // Retry the original request with new token
        return await retryRequest();
      } else {
        await _handleUnauthorized();
      }
    }
    return response;
  }

  // GET request
  Future<http.Response> get(
      String endpoint, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      // Ensure token is valid before making request
      await _ensureValidToken();

      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint')
          .replace(queryParameters: queryParameters);

      LogUtil.info(uri.toString());
      LogUtil.info(headers.toString());
      final response = await http.get(
        uri,
        headers: await _getHeaders(extraHeaders: headers),
      );

      return await _handleResponse(response, () async {
        return await http.get(
          uri,
          headers: await _getHeaders(extraHeaders: headers),
        );
      });
    } catch (e) {
      LogUtil.error(e.toString());
      rethrow;
    }
  }

  // POST request
  Future<http.Response> post(
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
      }) async {
    try {
      await _ensureValidToken();

      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

      LogUtil.info(uri.toString());
      LogUtil.info(headers.toString());
      print(body);

      final response = await http.post(
        uri,
        headers: await _getHeaders(extraHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return await _handleResponse(response, () async {
        return await http.post(
          uri,
          headers: await _getHeaders(extraHeaders: headers),
          body: body != null ? jsonEncode(body) : null,
        );
      });
    } catch (e) {
      LogUtil.error(e.toString());
      rethrow;
    }
  }

  // PUT request
  Future<http.Response> put(
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
      }) async {
    try {
      await _ensureValidToken();

      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

      final response = await http.put(
        uri,
        headers: await _getHeaders(extraHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return await _handleResponse(response, () async {
        return await http.put(
          uri,
          headers: await _getHeaders(extraHeaders: headers),
          body: body != null ? jsonEncode(body) : null,
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  // PATCH request
  Future<http.Response> patch(
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
      }) async {
    try {
      await _ensureValidToken();

      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

      final response = await http.patch(
        uri,
        headers: await _getHeaders(extraHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return await _handleResponse(response, () async {
        return await http.patch(
          uri,
          headers: await _getHeaders(extraHeaders: headers),
          body: body != null ? jsonEncode(body) : null,
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<http.Response> delete(
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
      }) async {
    try {
      await _ensureValidToken();

      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

      final response = await http.delete(
        uri,
        headers: await _getHeaders(extraHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return await _handleResponse(response, () async {
        return await http.delete(
          uri,
          headers: await _getHeaders(extraHeaders: headers),
          body: body != null ? jsonEncode(body) : null,
        );
      });
    } catch (e) {
      rethrow;
    }
  }

  // Multipart request for file uploads
  Future<http.StreamedResponse> uploadFile(
      String endpoint, {
        required String filePath,
        required String fileField,
        Map<String, String>? fields,
        Map<String, String>? headers,
      }) async {
    try {
      await _ensureValidToken();

      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      final allHeaders = await _getHeaders(extraHeaders: headers);
      request.headers.addAll(allHeaders);

      // Add file
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

      // Add other fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 401) {
        final refreshed = await _refreshToken();

        if (refreshed) {
          // Retry with new token
          final retryRequest = http.MultipartRequest('POST', uri);
          final newHeaders = await _getHeaders(extraHeaders: headers);
          retryRequest.headers.addAll(newHeaders);
          retryRequest.files.add(await http.MultipartFile.fromPath(fileField, filePath));
          if (fields != null) {
            retryRequest.fields.addAll(fields);
          }
          return await retryRequest.send();
        } else {
          await _handleUnauthorized();
        }
      }

      return streamedResponse;
    } catch (e) {
      rethrow;
    }
  }

  // NEW: General multipart POST request with multiple files support
  Future<http.StreamedResponse> postMultipart(
      String endpoint, {
        Map<String, String>? fields,
        Map<String, String>? headers,
        List<http.MultipartFile>? files,
      }) async {
    try {
      await _ensureValidToken();

      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Get auth headers (remove Content-Type as it will be set automatically for multipart)
      final token = await storage.getToken();
      final authHeaders = {
        'Accept': 'application/json',
        ...?headers,
      };

      if (token != null) {
        authHeaders['Authorization'] = 'Bearer $token';
      }

      request.headers.addAll(authHeaders);

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        request.files.addAll(files);
      }

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 401) {
        final refreshed = await _refreshToken();

        if (refreshed) {
          // Retry with new token
          final retryRequest = http.MultipartRequest('POST', uri);
          final newToken = await storage.getToken();
          final retryHeaders = {
            'Accept': 'application/json',
            ...?headers,
          };
          if (newToken != null) {
            retryHeaders['Authorization'] = 'Bearer $newToken';
          }
          retryRequest.headers.addAll(retryHeaders);

          if (fields != null) {
            retryRequest.fields.addAll(fields);
          }
          if (files != null) {
            retryRequest.files.addAll(files);
          }

          return await retryRequest.send();
        } else {
          await _handleUnauthorized();
        }
      }

      return streamedResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Manual logout method
  Future<void> logout() async {
    final SocialAuthService socialAuthService = SocialAuthService();

    try {
      // Optionally call logout endpoint
      await post('/auth/logout', body: {});
      await socialAuthService.signOut();
    } catch (e) {
      debugPrint('Logout endpoint error: $e');
    } finally {
      await _handleUnauthorized();
    }
  }
}