import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/result/failure.dart';
import 'package:wcr_pmis_mobile/src/core/result/result.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/models/auth_session_model.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/usecases/login_usecase.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  AuthController(this._loginUseCase, this._local)
    : super(const AsyncData<AuthSession?>(null)) {
    Future<void>.microtask(_restoreFromDisk);
  }

  final LoginUseCase _loginUseCase;
  final AuthLocalDataSource _local;

  Future<void> _restoreFromDisk() async {
    final AuthLocalSnapshot snap = await _local.readSnapshot();
    if (!snap.rememberMe ||
        snap.userProfileJson == null ||
        snap.userProfileJson!.isEmpty) {
      return;
    }
    try {
      final Map<String, dynamic> map =
          jsonDecode(snap.userProfileJson!) as Map<String, dynamic>;
      state = AsyncData<AuthSession?>(AuthSessionModel.fromJson(map));
    } catch (_) {
      await _local.clearSensitiveOnly();
    }
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
    await _local.clearAll();
    state = const AsyncData<AuthSession?>(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>((ref) {
      return AuthController(
        ref.watch(loginUseCaseProvider),
        ref.watch(authLocalDataSourceProvider),
      );
    });
