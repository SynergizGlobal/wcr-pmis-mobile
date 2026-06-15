import 'package:dio/dio.dart';

const String sessionExpiredLoginMessage =
    'Your session has expired. Please sign in again.';

bool isWcrUnauthorizedError(Object error) {
  if (error is! DioException) {
    return false;
  }
  final int? status = error.response?.statusCode;
  if (status == 401) {
    return true;
  }
  final String message = error.message?.toLowerCase() ?? '';
  return message.contains('rfi redirect failed (401)');
}

bool isWcrSessionExpiredError(Object error) {
  if (isWcrUnauthorizedError(error)) {
    return true;
  }
  final String message = error.toString().toLowerCase();
  return message.contains('session expired') ||
      message.contains('please sign in again');
}
