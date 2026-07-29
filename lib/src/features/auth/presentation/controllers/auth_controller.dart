import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/dio_client.dart';
import 'package:wcr_pmis_mobile/src/core/network/session_cookie_manager.dart';
import 'package:wcr_pmis_mobile/src/core/notifications/device_token_sync.dart';
import 'package:wcr_pmis_mobile/src/core/notifications/notification_tray_clearer.dart';
import 'package:wcr_pmis_mobile/src/core/notifications/pending_notification_location.dart';
import 'package:wcr_pmis_mobile/src/core/result/failure.dart';
import 'package:wcr_pmis_mobile/src/core/result/result.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/providers/auth_token_provider.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  AuthController(
    this._ref,
    this._loginUseCase,
    this._local,
    this._remote,
    this._deviceTokenSync,
    this._cookieManager,
  ) : super(const AsyncData<AuthSession?>(null));

  final Ref _ref;
  final LoginUseCase _loginUseCase;
  final AuthLocalDataSource _local;
  final AuthRemoteDataSource _remote;
  final DeviceTokenSync _deviceTokenSync;
  final SessionCookieManager? _cookieManager;
  bool _autoLoginAttempted = false;

  void _syncAuthToken(AuthSession? session) {
    final String token = session?.token.trim() ?? '';
    _ref.read(authTokenProvider.notifier).state =
        token.isEmpty ? null : token;
    _ref.read(wcrSessionActiveProvider.notifier).state = session != null;
    if (token.isEmpty && session == null) {
      _ref.read(rfiAuthTokenProvider.notifier).state = null;
    }
  }

  void _syncDeviceTokens() {
    unawaited(_deviceTokenSync.ensureSessionsAndRegister());
  }

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
      _syncAuthToken(null);
      await _local.clearSensitiveOnly();
      return failure;
    }, (AuthSession session) async {
      state = AsyncData<AuthSession?>(session);
      _syncAuthToken(session);
      await _local.saveAfterLogin(
        rememberMe: true,
        userId: userId,
        password: password,
        session: session,
      );
      _syncDeviceTokens();
      return null;
    });
  }

  void setSession(AuthSession session) {
    state = AsyncData<AuthSession?>(session);
    _syncAuthToken(session);
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
        _syncAuthToken(null);
        return failure;
      },
      (AuthSession session) async {
        state = AsyncData<AuthSession?>(session);
        _syncAuthToken(session);
        await _local.saveAfterLogin(
          rememberMe: rememberMe,
          userId: userId,
          password: password,
          session: session,
        );
        _syncDeviceTokens();
        return null;
      },
    );
  }

  Future<void> logout() async {
    // Drop any tap-to-navigate that belonged to this session.
    _ref.read(pendingNotificationNavProvider.notifier).state = null;
    // Clear tray so the next user does not see prior notifications.
    unawaited(NotificationTrayClearer.clearAll());

    // Deactivate on WCR + RFI while sessions/cookies are still valid.
    await _deviceTokenSync.deactivate();
    try {
      await _remote.logoutSession();
    } catch (_) {}
    if (_cookieManager != null) {
      await _cookieManager.clearSessionCookies();
    }
    await _local.clearAll();
    state = const AsyncData<AuthSession?>(null);
    _syncAuthToken(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>((ref) {
      return AuthController(
        ref,
        ref.watch(loginUseCaseProvider),
        ref.watch(authLocalDataSourceProvider),
        ref.watch(authRemoteDataSourceProvider),
        ref.watch(deviceTokenSyncProvider),
        ref.watch(sessionCookieManagerProvider).valueOrNull,
      );
    });
