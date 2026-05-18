import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:wcr_pmis_mobile/src/app/config/app_config_provider.dart';
import 'package:wcr_pmis_mobile/src/core/constants/api_constants.dart';
import 'package:wcr_pmis_mobile/src/core/network/auth_interceptor.dart';
import 'package:wcr_pmis_mobile/src/core/network/network_connectivity.dart';
import 'package:wcr_pmis_mobile/src/core/network/session_cookie_manager.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/providers/auth_token_provider.dart';

final sessionCookieManagerProvider = FutureProvider<SessionCookieManager>((ref) {
  return SessionCookieManager.create();
});

final dioProvider = Provider<Dio>((ref) {
  final appConfig = ref.watch(appConfigProvider);
  final networkConnectivity = ref.watch(networkConnectivityProvider);
  final sessionCookieManager = ref.watch(sessionCookieManagerProvider).valueOrNull;
  final dio = Dio(
    BaseOptions(
      baseUrl: appConfig.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.connectTimeout,
      responseType: ResponseType.json,
      headers: const <String, String>{'Content-Type': 'application/json'},
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
      ),
    );
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          await networkConnectivity.ensureConnected(options);
          handler.next(options);
        } on DioException catch (error) {
          handler.reject(error);
        }
      },
    ),
  );
  dio.interceptors.add(
    AuthInterceptor(() => ref.read(authTokenProvider)),
  );

  if (sessionCookieManager != null) {
    dio.interceptors.add(sessionCookieManager.asInterceptor());
  }

  return dio;
});
