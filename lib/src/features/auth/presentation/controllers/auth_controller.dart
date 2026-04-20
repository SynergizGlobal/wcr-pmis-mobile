import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/usecases/login_usecase.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<AuthSession?>> {
  AuthController(this._loginUseCase) : super(const AsyncData<AuthSession?>(null));

  final LoginUseCase _loginUseCase;

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading<AuthSession?>();
    final result = await _loginUseCase(email: email, password: password);
    return result.fold(
      (failure) {
        state = const AsyncData<AuthSession?>(null);
        return failure.message;
      },
      (session) {
        state = AsyncData<AuthSession?>(session);
        return null;
      },
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthSession?>>((ref) {
  return AuthController(ref.watch(loginUseCaseProvider));
});
