// lib/core/utils/result.dart

import 'package:http/http.dart' as http;

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final http.Response? response; // Full response for detailed error handling
  final int? statusCode;

  const Failure({
    required this.message,
    this.response,
    this.statusCode,
  });
}