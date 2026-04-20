import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/result/failure.dart';
import 'package:wcr_pmis_mobile/src/core/result/result.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AuthSession>> login({
    required String userId,
    required String password,
  }) async {
    try {
      final session = await _remoteDataSource.login(userId: userId, password: password);
      return Right<Failure, AuthSession>(session);
    } on DioException catch (error) {
      final responseData = error.response?.data;
      String? serverMessage;
      if (responseData is Map<String, dynamic>) {
        serverMessage = responseData['message'] as String?;
      }
      final message =
          serverMessage ?? error.message ?? 'Unable to login, please try again.';
      return Left<Failure, AuthSession>(Failure(message));
    } catch (_) {
      return const Left<Failure, AuthSession>(
        Failure('Something went wrong. Please try again.'),
      );
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});
