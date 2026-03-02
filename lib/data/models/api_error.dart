import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error.freezed.dart';

@freezed
class ApiError with _$ApiError {
  const factory ApiError.network({
    String? message,
  }) = NetworkError;

  const factory ApiError.server({
    required int statusCode,
    String? message,
  }) = ServerError;

  const factory ApiError.notFound({
    String? message,
  }) = NotFoundError;

  const factory ApiError.unauthorized({
    String? message,
  }) = UnauthorizedError;

  const factory ApiError.rateLimit({
    String? message,
  }) = RateLimitError;

  const factory ApiError.unknown({
    String? message,
    Object? error,
  }) = UnknownError;

  const ApiError._();

  String get displayMessage {
    return when(
      network: (msg) => msg ?? 'Network connection error. Please check your internet.',
      server: (code, msg) => msg ?? 'Server error (Status: $code). Please try again later.',
      notFound: (msg) => msg ?? 'Content not found.',
      unauthorized: (msg) => msg ?? 'Unauthorized access. Please login again.',
      rateLimit: (msg) => msg ?? 'Too many requests. Please wait a moment.',
      unknown: (msg, _) => msg ?? 'An unexpected error occurred.',
    );
  }
}
