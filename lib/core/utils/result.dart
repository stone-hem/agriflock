// lib/core/utils/result.dart

sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, dynamic response, int? statusCode) failure,
  }) {
    return switch (this) {
      Success<T>(data: final data) => success(data),
      Failure<T>(
      message: final message,
      response: final response,
      statusCode: final statusCode,
      ) =>
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
  final dynamic response;   // was http.Response? — now any decoded Dio body
  final int? statusCode;
  final String? cond;
  final Map<String, dynamic>? data;

  const Failure({
    required this.message,
    this.response,
    this.statusCode,
    this.cond,
    this.data,
  });
}