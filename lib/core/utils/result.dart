// lib/core/utils/result.dart

import 'package:http/http.dart' as http;

sealed class Result<T> {
  const Result();

  /// Pattern matching method for handling success and failure cases
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, http.Response? response, int? statusCode) failure,
  }) {
    return switch (this) {
      Success<T>(data: final data) => success(data),
      Failure<T>(message: final message, response: final response, statusCode: final statusCode) =>
          failure(message, response, statusCode),
    };
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final http.Response? response;
  final int? statusCode;

  const Failure({
    required this.message,
    this.response,
    this.statusCode,
  });
}