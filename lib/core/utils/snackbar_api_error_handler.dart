import 'dart:convert';
import 'package:agriflock/core/utils/log_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/core/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Context-aware error handler that uses [AppSnackBar] instead of ToastUtil.
/// Use this in screens/widgets where you have a [BuildContext].
class SnackBarApiErrorHandler {
  SnackBarApiErrorHandler._();

  static String _extractErrorMessage(dynamic body) {
    try {
      if (body['message'] != null) {
        final message = body['message'];
        if (message is Map<String, dynamic>) {
          if (message['message'] != null) {
            final inner = message['message'];
            if (inner is List) return inner.join('\n');
            if (inner is String) return inner;
            return inner.toString();
          } else if (message['error'] != null) {
            return message['error'].toString();
          } else if (message['statusCode'] != null) {
            return 'Error ${message['statusCode']}';
          }
          return message.toString();
        } else if (message is String) {
          return message;
        } else if (message is List) {
          return message.join('\n');
        }
      } else if (body['error'] != null) {
        final error = body['error'];
        if (error is Map<String, dynamic>) {
          if (error['message'] != null) return error['message'].toString();
          return error.toString();
        }
        return error.toString();
      } else if (body['errors'] != null) {
        if (body['errors'] is Map<String, dynamic>) {
          final errors = body['errors'] as Map<String, dynamic>;
          return errors.values
              .map((e) => e is List ? e.join('\n') : e.toString())
              .join('\n');
        } else if (body['errors'] is List) {
          return (body['errors'] as List).join('\n');
        }
      } else if (body['detail'] != null) {
        return body['detail'].toString();
      } else if (body['statusCode'] != null) {
        return 'Error ${body['statusCode']}';
      }
      return 'An error occurred';
    } catch (_) {
      return 'Unable to parse error message';
    }
  }

  static void _show(BuildContext context, String message) {
    AppSnackBar.show(context, message: message, type: SnackBarType.error);
  }

  /// Handle raw errors (http.Response, Exception, String, etc.)
  static void handle(BuildContext context, dynamic error) {
    try {
      if (error is http.Response) {
        final bodyStr = error.body.isNotEmpty ? error.body : error.reasonPhrase ?? '';
        LogUtil.error('HTTP ${error.statusCode}: $bodyStr');

        final body = error.body.isNotEmpty &&
                (error.body.startsWith('{') || error.body.startsWith('['))
            ? jsonDecode(error.body)
            : {'message': error.body};

        final msg = _extractErrorMessage(body);
        final statusCode = error.statusCode;

        switch (statusCode) {
          case 400:
            _show(context, msg.isNotEmpty ? msg : 'Invalid request. Please check your input.');
          case 401:
            _show(context, msg.isNotEmpty ? msg : 'Unauthorized. Please login.');
          case 403:
            _show(context, msg.isNotEmpty ? msg : "You don't have permission to perform this action.");
          case 404:
            _show(context, msg.isNotEmpty ? msg : 'Resource not found.');
          case 405:
            _show(context, 'Method not allowed.');
          case 408:
            _show(context, 'Request timeout. Please try again.');
          case 409:
            _show(context, msg.isNotEmpty ? msg : 'Conflict. The resource already exists.');
          case 413:
            _show(context, 'File too large. Please upload a smaller file.');
          case 415:
            _show(context, 'Unsupported file format.');
          case 422:
            _show(context, msg.isNotEmpty ? msg : 'Validation error. Please check your input.');
          case 429:
            _show(context, 'Too many requests. Please try again later.');
          case 500:
            _show(context, 'Server error. Please try again later.');
          case 502:
            _show(context, 'Bad gateway. Please try again.');
          case 503:
            _show(context, 'Service unavailable. Please try again later.');
          case 504:
            _show(context, 'Gateway timeout. Please try again.');
          default:
            if (statusCode >= 400 && statusCode < 500) {
              _show(context, msg.isNotEmpty ? msg : 'Request error ($statusCode).');
            } else if (statusCode >= 500) {
              _show(context, 'Server error ($statusCode). Please try again later.');
            } else {
              _show(context, msg.isNotEmpty ? msg : 'Something went wrong. Please try again.');
            }
        }
      } else if (error is String) {
        _show(context, error);
      } else {
        LogUtil.error(error.toString());
        _show(context, 'An unexpected error occurred.');
      }
    } catch (_) {
      _show(context, 'An error occurred. Please try again.');
    }
  }

  /// Handle [Failure] from the Result pattern.
  static void handleFailure<T>(BuildContext context, Failure<T> failure) {
    try {
      if (failure.response != null) {
        handle(context, failure.response!);
      } else if (failure.statusCode != null) {
        _handleStatusCodeOnly(context, failure.statusCode!, failure.message);
      } else {
        _handleGenericError(context, failure.message);
      }
    } catch (e) {
      LogUtil.error('Error in handleFailure: $e');
      _show(context, failure.message.isNotEmpty ? failure.message : 'An error occurred.');
    }
  }

  static void _handleStatusCodeOnly(BuildContext context, int statusCode, String defaultMessage) {
    switch (statusCode) {
      case 0:
        _show(context, defaultMessage.isNotEmpty ? defaultMessage : 'No internet connection. Please check your network.');
      case 400:
        _show(context, defaultMessage.isNotEmpty ? defaultMessage : 'Invalid request. Please check your input.');
      case 401:
        _show(context, defaultMessage.isNotEmpty ? defaultMessage : 'Unauthorized. Please login.');
      case 403:
        _show(context, defaultMessage.isNotEmpty ? defaultMessage : "You don't have permission to perform this action.");
      case 404:
        _show(context, defaultMessage.isNotEmpty ? defaultMessage : 'Resource not found.');
      case 500:
        _show(context, 'Server error. Please try again later.');
      default:
        if (statusCode >= 400 && statusCode < 500) {
          _show(context, defaultMessage.isNotEmpty ? defaultMessage : 'Request error ($statusCode).');
        } else if (statusCode >= 500) {
          _show(context, 'Server error ($statusCode). Please try again later.');
        } else {
          _show(context, defaultMessage.isNotEmpty ? defaultMessage : 'An error occurred. Please try again.');
        }
    }
  }

  static void _handleGenericError(BuildContext context, String message) {
    if (message.contains('SocketException') ||
        message.contains('Connection refused') ||
        message.contains('Network is unreachable')) {
      _show(context, 'No internet connection. Please check your network.');
    } else if (message.contains('Timeout') || message.contains('timed out')) {
      _show(context, 'Request timed out. Please try again.');
    } else if (message.contains('FormatException') || message.contains('Invalid JSON')) {
      _show(context, 'Invalid response from server. Please try again.');
    } else {
      _show(context, message.isNotEmpty ? message : 'An unexpected error occurred.');
    }
  }
}
