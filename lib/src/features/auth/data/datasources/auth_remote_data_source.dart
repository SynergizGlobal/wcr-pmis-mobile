import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/dio_client.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/models/auth_session_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    // Temporary fallback keeps frontend unblocked until backend auth is ready.
    if (email == 'admin@wcr.com' && password == 'admin123') {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return const AuthSessionModel(token: 'local-dev-token', userName: 'Admin');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );

    return AuthSessionModel.fromJson(response.data ?? <String, dynamic>{});
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});
