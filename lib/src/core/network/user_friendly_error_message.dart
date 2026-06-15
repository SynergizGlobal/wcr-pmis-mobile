import 'package:dio/dio.dart';

/// Shown when the device has no network connectivity.
const String noInternetUserMessage =
    'Oops... No internet connection please check your network and try again';

const String genericErrorUserMessage =
    'Oops... Something went wrong. Please try again.';

/// Converts API/network errors into short messages safe to show in the UI.
String userFriendlyErrorMessage(
  Object error, {
  String? fallback,
}) {
  if (error is DioException) {
    return _dioExceptionMessage(error, fallback: fallback);
  }
  return _sanitizeErrorString(
    error.toString(),
    fallback: fallback ?? genericErrorUserMessage,
  );
}

bool isNoInternetError(Object error) {
  if (error is DioException) {
    return error.type == DioExceptionType.connectionError;
  }
  final String lower = error.toString().toLowerCase();
  return lower.contains('connection error') ||
      lower.contains('no internet') ||
      (lower.contains('network') && lower.contains('check'));
}

String _dioExceptionMessage(DioException error, {String? fallback}) {
  switch (error.type) {
    case DioExceptionType.connectionError:
      return noInternetUserMessage;
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Oops... Request timed out. Please try again.';
    case DioExceptionType.cancel:
      return 'Request was cancelled.';
    case DioExceptionType.badCertificate:
      return 'Oops... Secure connection failed. Please try again.';
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      break;
  }

  final dynamic data = error.response?.data;
  if (data is Map) {
    final Object? message = data['message'] ?? data['error'] ?? data['detail'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }
  }
  if (data is String && data.trim().isNotEmpty) {
    return _sanitizeErrorString(data, fallback: fallback);
  }

  final int? status = error.response?.statusCode;
  if (status == 401) {
    return 'Session expired. Please sign in again.';
  }
  if (status == 403) {
    return 'You do not have permission for this action.';
  }
  if (status == 404) {
    return 'Requested resource was not found.';
  }
  if (status != null && status >= 500) {
    return 'Oops... Server error. Please try again later.';
  }

  final String? message = error.message;
  if (message != null && message.trim().isNotEmpty) {
    return _sanitizeErrorString(message, fallback: fallback);
  }

  return fallback ?? genericErrorUserMessage;
}

String _sanitizeErrorString(String raw, {String? fallback}) {
  var text = raw.trim();
  if (text.isEmpty) {
    return fallback ?? genericErrorUserMessage;
  }

  final String lower = text.toLowerCase();
  if (lower.contains('dioexception') &&
      (lower.contains('connection error') ||
          lower.contains('no internet') ||
          lower.contains('network'))) {
    return noInternetUserMessage;
  }

  final RegExpMatch? dioMatch = RegExp(
    r'^DioException\s*\[[^\]]*\]:\s*(.+)$',
    caseSensitive: false,
  ).firstMatch(text);
  if (dioMatch != null) {
    text = dioMatch.group(1)!.trim();
  }

  if (text.startsWith('Exception: ')) {
    text = text.substring('Exception: '.length).trim();
  }

  final String textLower = text.toLowerCase();
  if (textLower.contains('no internet') ||
      textLower.contains('check your network')) {
    return noInternetUserMessage;
  }

  return text;
}
