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

  Failure _failureFromDio(DioException error, String fallbackMessage) {
    final Object? responseData = error.response?.data;
    String? serverMessage;
    String? serverCode;
    if (responseData is Map<String, dynamic>) {
      serverCode = responseData['error']?.toString();
      serverMessage =
          responseData['errorMessage']?.toString() ??
          responseData['message']?.toString();
    }
    final String message =
        serverMessage ?? error.message ?? fallbackMessage;
    return Failure(message, code: serverCode);
  }

  static const Failure _unknownFailure = Failure(
    'Something went wrong. Please try again.',
  );

  @override
  Future<Result<AuthSession>> login({
    required String userId,
    required String password,
  }) async {
    try {
      final session = await _remoteDataSource.login(
        userId: userId,
        password: password,
      );
      return Right<Failure, AuthSession>(session);
    } on DioException catch (error) {
      return Left<Failure, AuthSession>(
        _failureFromDio(error, 'Unable to login, please try again.'),
      );
    } catch (_) {
      return const Left<Failure, AuthSession>(_unknownFailure);
    }
  }

  @override
  Future<Result<void>> sendForgotPasswordOtp({required String emailId}) async {
    try {
      await _remoteDataSource.sendForgotPasswordOtp(emailId: emailId);
      return const Right<Failure, void>(null);
    } on DioException catch (error) {
      return Left<Failure, void>(
        _failureFromDio(error, 'Unable to send OTP. Please try again.'),
      );
    } catch (_) {
      return const Left<Failure, void>(_unknownFailure);
    }
  }

  @override
  Future<Result<void>> verifyForgotPasswordOtp({
    required String emailId,
    required String otp,
  }) async {
    try {
      await _remoteDataSource.verifyForgotPasswordOtp(
        emailId: emailId,
        otp: otp,
      );
      return const Right<Failure, void>(null);
    } on DioException catch (error) {
      return Left<Failure, void>(
        _failureFromDio(error, 'Invalid OTP. Please try again.'),
      );
    } catch (_) {
      return const Left<Failure, void>(_unknownFailure);
    }
  }

  @override
  Future<Result<void>> resetForgotPassword({
    required String emailId,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _remoteDataSource.resetForgotPassword(
        emailId: emailId,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return const Right<Failure, void>(null);
    } on DioException catch (error) {
      return Left<Failure, void>(
        _failureFromDio(error, 'Unable to reset password. Please try again.'),
      );
    } catch (_) {
      return const Left<Failure, void>(_unknownFailure);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});
