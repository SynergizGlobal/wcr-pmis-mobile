import 'package:dio/dio.dart';

String rfiDioErrorMessage(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Request timed out. Please try again.';
    case DioExceptionType.connectionError:
      return 'No internet connection. Check your network and retry.';
    case DioExceptionType.cancel:
      return 'Request was cancelled.';
    case DioExceptionType.badCertificate:
      return 'Secure connection failed.';
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      break;
  }

  final dynamic data = error.response?.data;
  if (data is Map<String, dynamic>) {
    final Object? message = data['message'] ?? data['error'] ?? data['detail'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }
  }
  if (data is String && data.trim().isNotEmpty) {
    return data;
  }

  final int? status = error.response?.statusCode;
  if (status == 401) {
    return 'Session expired. Open RFI again from the app menu.';
  }
  if (status == 403) {
    return 'You do not have permission for this action.';
  }
  if (status == 404) {
    return 'Requested resource was not found.';
  }
  if (status != null && status >= 500) {
    return 'Server error ($status). Please try again later.';
  }

  return error.message ?? 'Something went wrong. Please try again.';
}
