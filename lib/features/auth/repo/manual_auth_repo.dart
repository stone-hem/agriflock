import 'dart:convert';
import 'package:agriflock360/core/model/user_model.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/main.dart';

class ManualAuthRepository {
  /// Login with email/phone and password
  ///
  /// Returns a Map with login response data including:
  /// - 'success': bool
  /// - 'data': LoginResponse object
  /// - 'needsOnboarding': bool (if user needs to complete onboarding)
  /// - 'needsVerification': bool (if account is inactive)
  /// - 'tempToken': String? (temporary token for onboarding)
  /// - 'email': String? (email for verification)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);

        // Save login data securely
        await secureStorage.saveLoginData(
          token: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          userData: loginResponse.user.toJson(),
          expiresInSeconds: loginResponse.expiresIn ?? 3600,
        );

        return {
          'success': true,
          'data': loginResponse,
          'needsOnboarding': false,
          'needsVerification': false,
        };
      } else {
        // Check for specific error cases
        final errorData = jsonDecode(response.body);
        final message = errorData['message'];

        if (message is Map<String, dynamic>) {
          final status = message['status'] as String?;
          final tempToken = message['tempToken'] as String?;

          if (status == 'user_onboarding') {
            return {
              'success': false,
              'needsOnboarding': true,
              'tempToken': tempToken,
            };
          } else if (status == 'account_inactive') {
            return {
              'success': false,
              'needsVerification': true,
              'email': email,
            };
          }
        }

        // Handle other errors with the generic error handler
        ApiErrorHandler.handle(response);
        return {
          'success': false,
          'needsOnboarding': false,
          'needsVerification': false,
        };
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
      rethrow;
    }
  }

  /// Register a new user account
  ///
  /// Returns a Map with signup response data:
  /// - 'success': bool
  /// - 'email': String (for email verification redirect)
  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required bool agreedToTerms,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        body: {
          'name': fullName,
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
          'agreed_to_terms': agreedToTerms,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        ApiErrorHandler.handle(response);
        return {
          'success': false,
          'email': email,
        };
      }

      return {
        'success': true,
        'email': email,
      };
    } catch (e) {
      ApiErrorHandler.handle(e);
      rethrow;
    }
  }

  /// Social login (Google/Apple) with backend authentication
  ///
  /// Returns a Map with social login response data:
  /// - 'success': bool
  /// - 'data': Map containing user data and tokens
  /// - 'needsOnboarding': bool (if user needs to complete onboarding)
  /// - 'needsVerification': bool (if account is inactive)
  /// - 'tempToken': String? (temporary token for onboarding)
  Future<Map<String, dynamic>> socialLogin({
    required Map<String, dynamic> authData,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/social-login',
        body: authData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Extract tokens and user data
        final accessToken = data['data']?['access_token'] as String?;
        final refreshToken = data['data']?['refresh_token'] as String?;
        final user = data['data']?['user'] as Map<String, dynamic>?;
        final expiresIn = data['data']?['expires_in'] as int?;

        if (accessToken != null && refreshToken != null && user != null) {
          // Save login data securely
          await secureStorage.saveLoginData(
            token: accessToken,
            refreshToken: refreshToken,
            userData: user,
            expiresInSeconds: expiresIn ?? 3600,
          );

          return {
            'success': true,
            'data': data['data'],
            'needsOnboarding': false,
            'needsVerification': false,
          };
        } else {
          throw Exception('Invalid response format from backend');
        }
      } else {
        // Check for specific error cases
        final errorData = jsonDecode(response.body);
        final message = errorData['message'];

        if (message is Map<String, dynamic>) {
          final status = message['status'] as String?;
          final tempToken = message['tempToken'] as String?;

          if (status == 'user_onboarding') {
            return {
              'success': false,
              'needsOnboarding': true,
              'tempToken': tempToken,
            };
          } else if (status == 'account_inactive') {
            return {
              'success': false,
              'needsVerification': true,
              'email': authData['email'],
            };
          }
        }

        // Handle other errors
        ApiErrorHandler.handle(response);
        return {
          'success': false,
          'needsOnboarding': false,
          'needsVerification': false,
        };
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
      rethrow;
    }
  }
}