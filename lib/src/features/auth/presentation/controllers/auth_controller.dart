import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/dio_client.dart';
import 'package:wcr_pmis_mobile/src/core/network/session_cookie_manager.dart';
import 'package:wcr_pmis_mobile/src/core/result/failure.dart';
import 'package:wcr_pmis_mobile/src/core/result/result.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/usecases/login_usecase.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  AuthController(this._loginUseCase, this._local, this._dio, this._cookieManager)
    : super(const AsyncData<AuthSession?>(null));

  final LoginUseCase _loginUseCase;
  final AuthLocalDataSource _local;
  final Dio _dio;
  final SessionCookieManager? _cookieManager;
  bool _autoLoginAttempted = false;

  Future<Failure?> tryAutoLoginIfRemembered() async {
    if (_autoLoginAttempted) {
      return null;
    }
    _autoLoginAttempted = true;
    final AuthLocalSnapshot snap = await _local.readSnapshot();
    final String userId = snap.userId?.trim() ?? '';
    final String password = snap.password ?? '';
    if (!snap.rememberMe || userId.isEmpty || password.isEmpty) {
      return null;
    }
    state = const AsyncLoading<AuthSession?>();
    final Result<AuthSession> result = await _loginUseCase(
      userId: userId,
      password: password,
    );
    return result.fold<Future<Failure?>>((Failure failure) async {
      state = const AsyncData<AuthSession?>(null);
      await _local.clearSensitiveOnly();
      return failure;
    }, (AuthSession session) async {
      state = AsyncData<AuthSession?>(session);
      await _local.saveAfterLogin(
        rememberMe: true,
        userId: userId,
        password: password,
        session: session,
      );
      return null;
    });
  }

  void setSession(AuthSession session) {
    state = AsyncData<AuthSession?>(session);
  }

  Future<Failure?> login({
    required String userId,
    required String password,
    required bool rememberMe,
  }) async {
    state = const AsyncLoading<AuthSession?>();
    final Result<AuthSession> result = await _loginUseCase(
      userId: userId,
      password: password,
    );
    return result.fold<Future<Failure?>>(
      (Failure failure) async {
        state = const AsyncData<AuthSession?>(null);
        return failure;
      },
      (AuthSession session) async {
        state = AsyncData<AuthSession?>(session);
        await _local.saveAfterLogin(
          rememberMe: rememberMe,
          userId: userId,
          password: password,
          session: session,
        );
        return null;
      },
    );
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {
      // Ignore server-side logout failures and still clear local session.
    }
    if (_cookieManager != null) {
      await _cookieManager.clearSessionCookies();
    }
    await _local.clearAll();
    state = const AsyncData<AuthSession?>(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>((ref) {
      return AuthController(
        ref.watch(loginUseCaseProvider),
        ref.watch(authLocalDataSourceProvider),
        ref.watch(dioProvider),
        ref.watch(sessionCookieManagerProvider).valueOrNull,
      );
    });
