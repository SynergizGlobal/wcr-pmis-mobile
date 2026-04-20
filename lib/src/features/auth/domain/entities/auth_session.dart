import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.token,
    required this.userName,
  });

  final String token;
  final String userName;

  @override
  List<Object?> get props => <Object?>[token, userName];
}
