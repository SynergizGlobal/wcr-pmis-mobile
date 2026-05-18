import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/constants/api_constants.dart';
import 'package:wcr_pmis_mobile/src/core/network/dio_client.dart';
import 'package:wcr_pmis_mobile/src/core/network/rfi_dio_client.dart';

final rfiHandoffDataSourceProvider = Provider<RfiHandoffDataSource>((ref) {
  return RfiHandoffDataSource(
    ref.watch(dioProvider),
    ref.watch(rfiDioProvider),
  );
});

class RfiHandoffResult {
  const RfiHandoffResult({
    required this.token,
    required this.redirectUrl,
    this.user,
  });

  final String token;
  final String redirectUrl;
  final Map<String, dynamic>? user;
}

class RfiHandoffDataSource {
  const RfiHandoffDataSource(this._wcrDio, this._rfiDio);

  final Dio _wcrDio;
  final Dio _rfiDio;

  static const String _rfiLoginPath = ApiConstants.rfiSsoLoginPath;

  Future<RfiHandoffResult> performRedirect() async {
    final Response<dynamic> response = await _wcrDio.get<dynamic>(
      ApiConstants.wcrRfiRedirectPath,
      options: Options(
        followRedirects: true,
        validateStatus: (int? status) => status != null && status < 500,
      ),
    );

    final int? status = response.statusCode;
    if (status != null && status >= 400) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'RFI redirect failed ($status)',
      );
    }

    final String redirectUrl = _extractRedirectUrl(response.data);
    if (redirectUrl.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'RFI redirect response missing redirectUrl',
      );
    }

    final Uri loginUri = Uri.parse(redirectUrl);
    final String token = loginUri.queryParameters['token']?.trim() ?? '';
    if (token.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'RFI redirectUrl missing token query parameter',
      );
    }

    final Map<String, dynamic>? user = await _exchangeTokenForRfiSession(token);

    return RfiHandoffResult(
      token: _extractTokenFromBody(user) ?? token,
      redirectUrl: redirectUrl,
      user: user,
    );
  }

  Future<Map<String, dynamic>?> _exchangeTokenForRfiSession(String token) async {
    final Response<dynamic> loginResponse = await _rfiDio.post<dynamic>(
      _rfiLoginPath,
      data: <String, dynamic>{'token': token},
      options: Options(
        extra: const <String, dynamic>{'skipAuth': true},
        validateStatus: (int? code) => code != null && code < 500,
      ),
    );

    final int? code = loginResponse.statusCode;
    if (code == null || code >= 400) {
      final String message = _readErrorMessage(loginResponse.data) ??
          'RFI login failed ($code)';
      throw DioException(
        requestOptions: loginResponse.requestOptions,
        response: loginResponse,
        type: DioExceptionType.badResponse,
        message: message,
      );
    }

    final dynamic data = loginResponse.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  String _extractRedirectUrl(dynamic data) {
    if (data is! Map) {
      return '';
    }
    final dynamic value = data['redirectUrl'] ?? data['redirect_url'];
    return value?.toString().trim() ?? '';
  }

  String? _extractTokenFromBody(Map<String, dynamic>? body) {
    if (body == null) {
      return null;
    }
    for (final String key in <String>['token', 'jwt', 'accessToken']) {
      final dynamic value = body[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  String? _readErrorMessage(dynamic data) {
    if (data is Map) {
      final dynamic message = data['message'] ?? data['error'];
      if (message != null) {
        return message.toString();
      }
    }
    return null;
  }
}
