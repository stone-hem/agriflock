import 'dart:convert';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:http/http.dart' as http;
import 'toast_util.dart';

class ApiErrorHandler {
  // Private constructor to prevent instantiation
  ApiErrorHandler._();

  /// Handle API errors from responses or exceptions
  static void handle(dynamic error) {
    try {
      // Convert the error to a readable string for logging
      if (error is http.Response) {
        final bodyStr = error.body.isNotEmpty ? error.body : error.reasonPhrase ?? '';
        LogUtil.error('HTTP ${error.statusCode}: $bodyStr');
      } else {
        LogUtil.error(error.toString());
      }

      // If it's an HTTP response
      if (error is http.Response) {
        final statusCode = error.statusCode;
        final body = error.body.isNotEmpty ? jsonDecode(error.body) : {};

        if (statusCode == 422) {
          // Validation errors
          if (body['errors'] != null && body['errors'] is Map) {
            final errors = body['errors'] as Map<String, dynamic>;
            final messages = errors.values
                .map((e) => e is List ? e.join('\n') : e.toString())
                .join('\n');
            ToastUtil.showError(messages);
          } else if (body['message'] != null) {
            ToastUtil.showError(body['message']);
          } else {
            ToastUtil.showError("Validation error occurred");
          }
        } else if (statusCode == 401) {
          // Handle nested 401 error format
          if (body['message'] != null) {
            // Check if message is a nested object (as in your error format)
            if (body['message'] is Map<String, dynamic>) {
              final nestedMessage = body['message'] as Map<String, dynamic>;
              if (nestedMessage['message'] != null) {
                ToastUtil.showError(nestedMessage['message'].toString());
              } else if (nestedMessage['error'] != null) {
                ToastUtil.showError(nestedMessage['error'].toString());
              } else {
                ToastUtil.showError("Unauthorized. Please login.");
              }
            } else {
              // Message is a string
              ToastUtil.showError(body['message'].toString());
            }
          } else {
            ToastUtil.showError("Unauthorized. Please login.");
          }
        } else if (statusCode == 404) {
          ToastUtil.showError(body['message'] ?? "Resource not found");
        } else if (statusCode == 409) {
        ToastUtil.showError(body['message'] ?? "Conflict");
      } else if (statusCode >= 500) {
          ToastUtil.showError("Server error. Please try again later.");
        } else if (body['message'] != null) {
          ToastUtil.showError(body['message']);
        } else {
          ToastUtil.showError("Something went wrong. Please try again.");
        }
      } else if (error is String) {
        // Plain error string
        ToastUtil.showError(error);
      } else {
        // Any other type of exception
        ToastUtil.showError("An unexpected error occurred");
      }
    } catch (e) {
      // Fallback in case parsing fails
      ToastUtil.showError("An error occurred. Please try again.");
    }
  }
}