import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.token,
    required super.userName,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      token: (json['token'] ?? json['accessToken'] ?? json['jwt'] ?? '').toString(),
      userName: (json['userName'] ?? json['userId'] ?? json['name'] ?? 'User').toString(),
    );
  }
}
