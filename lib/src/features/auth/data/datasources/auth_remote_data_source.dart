import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/constants/api_constants.dart';
import 'package:wcr_pmis_mobile/src/core/network/dio_client.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/models/auth_session_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  static final Options _unauthenticatedOptions = Options(
    extra: const <String, dynamic>{'skipAuth': true},
  );

  Future<AuthSessionModel> login({
    required String userId,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/login',
      data: <String, dynamic>{'userId': userId, 'password': password},
    );
    final Map<String, dynamic> data = response.data ?? <String, dynamic>{};
    if (data.isEmpty) {
      return AuthSessionModel(userId: userId, userName: userId);
    }
    return AuthSessionModel.fromJson(data);
  }

  Future<void> sendForgotPasswordOtp({required String emailId}) async {
    await _dio.post<Map<String, dynamic>>(
      ApiConstants.forgotSendOtpPath,
      data: <String, dynamic>{'emailId': emailId},
      options: _unauthenticatedOptions,
    );
  }

  Future<void> verifyForgotPasswordOtp({
    required String emailId,
    required String otp,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      ApiConstants.forgotVerifyOtpPath,
      data: <String, dynamic>{'emailId': emailId, 'otp': otp},
      options: _unauthenticatedOptions,
    );
  }

  Future<void> resetForgotPassword({
    required String emailId,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      ApiConstants.forgotResetPasswordPath,
      data: <String, dynamic>{
        'emailId': emailId,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
      options: _unauthenticatedOptions,
    );
  }

  Future<void> logoutSession() async {
    await _dio.post<dynamic>(ApiConstants.authLogoutPath);
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});
