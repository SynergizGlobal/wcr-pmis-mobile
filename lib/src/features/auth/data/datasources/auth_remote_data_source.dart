import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/dio_client.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/models/auth_session_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSessionModel> login({
    required String userId,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/login',
      data: <String, dynamic>{
        'userId': userId,
        'password': password,
      },
    );
    final data = response.data ?? <String, dynamic>{};
    if (data.isEmpty) {
      return AuthSessionModel(token: 'session-${DateTime.now().millisecondsSinceEpoch}', userName: userId);
    }
    return AuthSessionModel.fromJson(data);
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});
