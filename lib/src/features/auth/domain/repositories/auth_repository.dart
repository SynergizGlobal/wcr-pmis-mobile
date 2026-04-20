import 'package:wcr_pmis_mobile/src/core/result/result.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> login({
    required String userId,
    required String password,
  });
}
