import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/model/user_model.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/main.dart';
import 'package:http/http.dart' as http;

class ManualAuthRepository {
  /// Extract a readable error message from API error response data.
  String _extractMessage(Map<String, dynamic> errorData) {
    final rawMessage = errorData['message'];
    if (rawMessage is String) return rawMessage;
    if (rawMessage is Map) {
      final inner = rawMessage['message'];
      if (inner is List) return inner.join('\n');
      if (inner is String) return inner;
      return rawMessage.toString();
    }
    if (rawMessage is List) return rawMessage.join('\n');
    return 'An error occurred';
  }

  /// Login with email/phone and password
  ///
  /// Returns [Result<LoginResponse>]:
  /// - [Success] with LoginResponse when login succeeds
  /// - [Failure] with cond for conditional routing:
  ///   - 'user_onboarding': user needs to complete onboarding (data contains tempToken)
  ///   - 'account_inactive': user needs to verify email (data contains email, userId)
  ///   - 'unverified_vet': vet account pending verification
  Future<Result<LoginResponse>> login({
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

        await secureStorage.saveLoginData(
          token: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          sessionId: loginResponse.sessionId,
          userData: loginResponse.user.toJson(),
          expiresInSeconds: loginResponse.expiresIn,
          currency: loginResponse.currency ?? 'USD',
        );
        if(loginResponse.cond=='no_subscription_plan'){
        secureStorage.saveSubscriptionState('no_subscription_plan');
        }
        if(loginResponse.cond=='expired_subscription_plan'){
          secureStorage.saveSubscriptionState('expired_subscription_plan');
        }
        if(loginResponse.cond=='has_subscription_plan') {
          secureStorage.saveSubscriptionState('has_subscription_plan');
        }
        return Success(loginResponse);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        LogUtil.info(response.body);

        final cond = errorData['cond'] as String?;
        final tempToken = errorData['tempToken'] as String?;
        final userId = errorData['user_id'] as String?;
        final message = _extractMessage(errorData);

        return Failure(
          message: message,
          response: response,
          statusCode: response.statusCode,
          cond: cond,
          data: {
            if (tempToken != null) 'tempToken': tempToken,
            if (userId != null) 'userId': userId,
            'email': email,
          },
        );
      }
    } catch (e) {
      return Failure(message: e.toString(), statusCode: 0);
    }
  }

  /// Register a new user account
  ///
  /// Returns [Result<Map<String, dynamic>>]:
  /// - [Success] with {email, userId}
  /// - [Failure] with error message
  Future<Result<Map<String, dynamic>>> signUp({
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        LogUtil.info(response.body);
        final data = jsonDecode(response.body);
        return Success({
          'email': email,
          'userId': data['user_id'],
        });
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return Failure(
          message: _extractMessage(errorData),
          response: response,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      LogUtil.error(e.toString());
      return Failure(message: e.toString(), statusCode: 0);
    }
  }

  /// Social login (Google/Apple) with backend authentication
  ///
  /// Returns [Result<Map<String, dynamic>>]:
  /// - [Success] with the data map from response (contains user, tokens, etc.)
  /// - [Failure] with cond for conditional routing (same as login)
  Future<Result<Map<String, dynamic>>> socialLogin({
    required Map<String, dynamic> authData,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/social-login',
        body: authData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final accessToken = data['data']?['access_token'] as String?;
        final refreshToken = data['data']?['refresh_token'] as String?;
        final currency = data['data']?['currency'] as String?;
        final user = data['data']?['user'] as Map<String, dynamic>?;
        final expiresIn = data['data']?['expires_in'] as int?;

        if (accessToken != null && refreshToken != null && user != null) {
          await secureStorage.saveLoginData(
            token: accessToken,
            refreshToken: refreshToken,
            sessionId: user['session_id'] as String,
            userData: user,
            expiresInSeconds: expiresIn ?? 3600,
            currency: currency ?? 'USD',
          );

          return Success(data['data'] as Map<String, dynamic>);
        } else {
          return const Failure(
            message: 'Invalid response format from backend',
            statusCode: 200,
          );
        }
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;

        // Support both new format (cond at root) and old format (status inside message)
        String? cond = errorData['cond'] as String?;
        String? tempToken = errorData['tempToken'] as String?;

        final rawMessage = errorData['message'];
        String message;

        if (rawMessage is Map<String, dynamic>) {
          cond ??= rawMessage['status'] as String?;
          tempToken ??= rawMessage['tempToken'] as String?;
          message = rawMessage['message']?.toString() ?? 'Social login failed';
        } else {
          message = _extractMessage(errorData);
        }

        return Failure(
          message: message,
          response: response,
          statusCode: response.statusCode,
          cond: cond,
          data: {
            if (tempToken != null) 'tempToken': tempToken,
            'email': authData['email'],
          },
        );
      }
    } catch (e) {
      return Failure(message: e.toString(), statusCode: 0);
    }
  }

  /// Forgot Password - Request OTP
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/forgot-password',
        body: {'email': email.trim()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['message'] ?? 'Reset OTP sent successfully!',
        };
      } else {
        ApiErrorHandler.handle(response);
        return {
          'success': false,
          'email': email,
        };
      }
    } catch (e) {
      LogUtil.error(e.toString());
      ApiErrorHandler.handle(e);
      rethrow;
    }
  }

  /// Reset Password with OTP
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/reset-password',
        body: {
          'code': otp.trim(),
          'password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['message'] ?? 'Password reset successfully!',
        };
      } else {
        ApiErrorHandler.handle(response);
        return {
          'success': false,
          'message': 'Password reset failed',
        };
      }
    } catch (e) {
      LogUtil.error(e.toString());
      ApiErrorHandler.handle(e);
      rethrow;
    }
  }

  /// Verify Email with OTP (using /auth/verify-email endpoint)
  Future<Map<String, dynamic>> verifyEmail({
    required String otpCode,
    required String userId,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/verify-email',
        body: {
          'code': otpCode.trim(),
          'userId':userId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'] as Map<String, dynamic>?;

        return {
          'success': true,
          'tempToken': message?['tempToken'],
          'message': 'Email verified successfully!',
        };
      } else {
        ApiErrorHandler.handle(response);
        return {
          'success': false,
          'message': 'Email verification failed',
        };
      }
    } catch (e) {
      LogUtil.error(e.toString());
      ApiErrorHandler.handle(e);
      rethrow;
    }
  }

  /// Resend Verification OTP (using /auth/resend-code endpoint)
  Future<Map<String, dynamic>> resendVerificationCode({
    required String identifier,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/resend-code',
        body: {
          'identifier': identifier.trim(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['message'] ?? 'Verification code resent successfully!',
        };
      } else {
        ApiErrorHandler.handle(response);
        return {
          'success': false,
          'message': 'Failed to resend verification code',
        };
      }
    } catch (e) {
      LogUtil.error(e.toString());
      ApiErrorHandler.handle(e);
      rethrow;
    }
  }

  Future<Result> getVetStatus() async {
    try {
      final response = await apiClient.get('/extension-officers/status');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        LogUtil.info('Vet status: $jsonResponse');

        return Success(true);
      } else {
        LogUtil.error('Network error checking status: ${response.body}');
        return Failure(
          message: 'Failed checking status',
          response: response,
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      LogUtil.error('Network error checking status: $e');
      return const Failure(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      LogUtil.error('Error checking status: $e');

      if (e is http.Response) {
        return Failure(
          message: 'Failed checking status',
          response: e,
          statusCode: e.statusCode,
        );
      }

      return Failure(message: e.toString());
    }
  }

}
