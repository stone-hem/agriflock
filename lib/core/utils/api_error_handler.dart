import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:http/http.dart' as http;
import 'toast_util.dart';



class ApiErrorHandler {
  // Private constructor to prevent instantiation
  ApiErrorHandler._();

  /// Extract error message from response body, handling nested structures
  static String _extractErrorMessage(dynamic body) {
    try {
      // Handle various nested error formats
      if (body['message'] != null) {
        final message = body['message'];

        // Check if message is a nested JSON object
        if (message is Map<String, dynamic>) {
          // First check for nested message inside the message object
          if (message['message'] != null) {
            return message['message'].toString();
          }
          // Check for error field
          else if (message['error'] != null) {
            return message['error'].toString();
          }
          // Check for status field that might contain error info
          else if (message['status'] != null) {
            return message['status'].toString();
          }
          // If it's a map but we can't find specific fields, stringify it
          else {
            return message.toString();
          }
        }
        // Message is a string
        else {
          return message.toString();
        }
      }

      // Check for error field at root level
      else if (body['error'] != null) {
        return body['error'].toString();
      }

      // Check for errors array (common in validation)
      else if (body['errors'] != null) {
        if (body['errors'] is Map<String, dynamic>) {
          final errors = body['errors'] as Map<String, dynamic>;
          return errors.values
              .map((e) => e is List ? e.join('\n') : e.toString())
              .join('\n');
        } else if (body['errors'] is List) {
          return (body['errors'] as List).join('\n');
        }
      }

      // Check for status field at root level
      else if (body['status'] != null) {
        return body['status'].toString();
      }

      // Check for detail field (common in some APIs)
      else if (body['detail'] != null) {
        return body['detail'].toString();
      }

      return "An error occurred";
    } catch (e) {
      return "Unable to parse error message";
    }
  }

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
        final body = error.body.isNotEmpty ?
        (error.body.startsWith('{') || error.body.startsWith('['))
            ? jsonDecode(error.body)
            : {'message': error.body}
            : {};

        String errorMessage = _extractErrorMessage(body);

        // Handle specific status codes
        switch (statusCode) {
          case 400:
          // Bad Request
            ToastUtil.showError(errorMessage.isNotEmpty
                ? errorMessage
                : "Invalid request. Please check your input.");
            break;

          case 401:
          // Unauthorized
            ToastUtil.showError(errorMessage.isNotEmpty
                ? errorMessage
                : "Unauthorized. Please login.");
            break;

          case 403:
          // Forbidden
            ToastUtil.showError(errorMessage.isNotEmpty
                ? errorMessage
                : "You don't have permission to perform this action.");
            break;

          case 404:
          // Not Found
            ToastUtil.showError(errorMessage.isNotEmpty
                ? errorMessage
                : "Resource not found.");
            break;

          case 405:
          // Method Not Allowed
            ToastUtil.showError("Method not allowed.");
            break;

          case 408:
          // Request Timeout
            ToastUtil.showError("Request timeout. Please try again.");
            break;

          case 409:
          // Conflict
            ToastUtil.showError(errorMessage.isNotEmpty
                ? errorMessage
                : "Conflict. The resource already exists.");
            break;

          case 413:
          // Payload Too Large
            ToastUtil.showError("File too large. Please upload a smaller file.");
            break;

          case 415:
          // Unsupported Media Type
            ToastUtil.showError("Unsupported file format.");
            break;

          case 422:
          // Unprocessable Entity (Validation errors)
            ToastUtil.showError(errorMessage.isNotEmpty
                ? errorMessage
                : "Validation error. Please check your input.");
            break;

          case 429:
          // Too Many Requests
            ToastUtil.showError("Too many requests. Please try again later.");
            break;

          case 500:
          // Internal Server Error
            ToastUtil.showError("Server error. Please try again later.");
            break;

          case 502:
          // Bad Gateway
            ToastUtil.showError("Bad gateway. Please try again.");
            break;

          case 503:
          // Service Unavailable
            ToastUtil.showError("Service unavailable. Please try again later.");
            break;

          case 504:
          // Gateway Timeout
            ToastUtil.showError("Gateway timeout. Please try again.");
            break;

          default:
            if (statusCode >= 400 && statusCode < 500) {
              // Client errors
              ToastUtil.showError(errorMessage.isNotEmpty
                  ? errorMessage
                  : "Request error ($statusCode).");
            } else if (statusCode >= 500) {
              // Server errors
              ToastUtil.showError("Server error ($statusCode). Please try again later.");
            } else {
              // Unknown errors
              ToastUtil.showError(errorMessage.isNotEmpty
                  ? errorMessage
                  : "Something went wrong. Please try again.");
            }
            break;
        }
      }
      // Handle if error is an Exception containing a Response
      else if (error is Exception && error.toString().contains('Instance of \'Response\'')) {
        // This handles the case where you might have thrown Exception(response)
        // Try to extract the actual response from the exception message
        ToastUtil.showError("An error occurred. Please try again.");
      }
      else if (error is String) {
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

  /// Handle Failure result from Result pattern
  static void handleFailure<T>(Failure<T> failure) {
    try {
      if (failure.response != null) {
        // Use existing handle method for full response
        handle(failure.response!);
      } else if (failure.statusCode != null) {
        // Handle cases with status code but no response object
        _handleStatusCodeOnly(failure.statusCode!, failure.message);
      } else {
        // Handle cases without response or status code (network errors, etc.)
        _handleGenericError(failure.message);
      }
    } catch (e) {
      LogUtil.error('Error in handleFailure: $e');
      ToastUtil.showError(failure.message);
    }
  }

  /// Helper for handling cases with only status code
  static void _handleStatusCodeOnly(int statusCode, String defaultMessage) {
    switch (statusCode) {
      case 0:
      // Network error (SocketException)
        ToastUtil.showError(defaultMessage.isNotEmpty
            ? defaultMessage
            : "No internet connection. Please check your network.");
        break;
      case 400:
        ToastUtil.showError(defaultMessage.isNotEmpty
            ? defaultMessage
            : "Invalid request. Please check your input.");
        break;
      case 401:
        ToastUtil.showError(defaultMessage.isNotEmpty
            ? defaultMessage
            : "Unauthorized. Please login.");
        break;
      case 403:
        ToastUtil.showError(defaultMessage.isNotEmpty
            ? defaultMessage
            : "You don't have permission to perform this action.");
        break;
      case 404:
        ToastUtil.showError(defaultMessage.isNotEmpty
            ? defaultMessage
            : "Resource not found.");
        break;
      case 500:
        ToastUtil.showError("Server error. Please try again later.");
        break;
      default:
        if (statusCode >= 400 && statusCode < 500) {
          ToastUtil.showError(defaultMessage.isNotEmpty
              ? defaultMessage
              : "Request error ($statusCode).");
        } else if (statusCode >= 500) {
          ToastUtil.showError("Server error ($statusCode). Please try again later.");
        } else {
          ToastUtil.showError(defaultMessage.isNotEmpty
              ? defaultMessage
              : "An error occurred. Please try again.");
        }
        break;
    }
  }

  /// Helper for handling generic errors
  static void _handleGenericError(String message) {
    if (message.contains('SocketException') ||
        message.contains('Connection refused') ||
        message.contains('Network is unreachable')) {
      ToastUtil.showError("No internet connection. Please check your network.");
    } else if (message.contains('Timeout') || message.contains('timed out')) {
      ToastUtil.showError("Request timed out. Please try again.");
    } else if (message.contains('FormatException') || message.contains('Invalid JSON')) {
      ToastUtil.showError("Invalid response from server. Please try again.");
    } else {
      ToastUtil.showError(message.isNotEmpty
          ? message
          : "An unexpected error occurred");
    }
  }

  /// Helper method to check if response is successful
  static bool isSuccessResponse(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// Helper method to check if response is an error
  static bool isErrorResponse(http.Response response) {
    return response.statusCode >= 400;
  }


}