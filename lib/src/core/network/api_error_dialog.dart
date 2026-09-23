import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/navigation/app_navigator_key.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';

/// Shows a single global failure / no-internet dialog for Dio errors.
///
/// Skipped when:
/// - `extra['silentError'] == true`
/// - HTTP 401 (session-expired flow owns that)
/// - login / forgot-password requests (screen already shows its own dialog)
abstract final class ApiErrorDialog {
  static bool _isShowing = false;

  static void showFromDio(DioException error) {
    if (error.requestOptions.extra['silentError'] == true) {
      return;
    }
    if (error.response?.statusCode == 401) {
      return;
    }
    if (_isAuthScreenRequest(error.requestOptions)) {
      return;
    }

    final BuildContext? context = appNavigatorKey.currentContext;
    if (context == null || !context.mounted || _isShowing) {
      return;
    }

    final ({String title, String message}) content = _titleAndMessage(error);
    _isShowing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? dialogContext = appNavigatorKey.currentContext;
      if (dialogContext == null || !dialogContext.mounted) {
        _isShowing = false;
        return;
      }
      AppDialog.show(
        context: dialogContext,
        title: content.title,
        message: content.message,
        type: AppDialogType.error,
      ).whenComplete(() {
        _isShowing = false;
      });
    });
  }

  static bool _isAuthScreenRequest(RequestOptions options) {
    final String path = options.uri.path.toLowerCase();
    final String full = options.uri.toString().toLowerCase();
    return path.contains('/login') ||
        path.contains('forgot') ||
        full.contains('/api/auth/login') ||
        full.contains('/api/forgot/');
  }

  static ({String title, String message}) _titleAndMessage(DioException error) {
    final String message = userFriendlyErrorMessage(error);

    switch (error.type) {
      case DioExceptionType.connectionError:
        return (title: 'No Internet', message: message);
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return (title: 'Connection Timeout', message: message);
      case DioExceptionType.badCertificate:
        return (title: 'Secure Connection Failed', message: message);
      case DioExceptionType.cancel:
        return (title: 'Request Cancelled', message: message);
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
    }

    final int? status = error.response?.statusCode;
    if (status != null && status >= 500) {
      return (title: 'Server Error', message: message);
    }
    if (status == 404) {
      return (title: 'Not Found', message: message);
    }
    if (status == 403) {
      return (title: 'Access Denied', message: message);
    }
    if (status != null && status >= 400 && status < 500) {
      return (title: 'Oops! Something went wrong', message: message);
    }

    if (isNoInternetError(error)) {
      return (title: 'No Internet', message: message);
    }

    return (title: 'Error', message: message);
  }
}
