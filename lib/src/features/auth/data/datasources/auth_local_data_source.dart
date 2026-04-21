import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wcr_pmis_mobile/src/features/auth/data/models/auth_session_model.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';

class AuthLocalSnapshot {
  const AuthLocalSnapshot({
    required this.rememberMe,
    this.userId,
    this.password,
    this.userProfileJson,
  });

  final bool rememberMe;
  final String? userId;
  final String? password;
  final String? userProfileJson;
}

class AuthLocalDataSource {
  static const String _rememberMeKey = 'remember_me';
  static const String _savedUserIdKey = 'saved_user_id';
  static const String _savedPasswordKey = 'saved_password';
  static const String _userProfileJsonKey = 'saved_user_profile_json';

  Future<AuthLocalSnapshot> readSnapshot() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return AuthLocalSnapshot(
      rememberMe: prefs.getBool(_rememberMeKey) ?? false,
      userId: prefs.getString(_savedUserIdKey),
      password: prefs.getString(_savedPasswordKey),
      userProfileJson: prefs.getString(_userProfileJsonKey),
    );
  }

  /// Persists credentials and profile when [rememberMe] is true; otherwise clears
  /// stored password and profile (keeps last username if [userId] non-empty).
  Future<void> saveAfterLogin({
    required bool rememberMe,
    required String userId,
    required String password,
    required AuthSession session,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
    await prefs.setString(_savedUserIdKey, userId);
    if (rememberMe) {
      await prefs.setString(_savedPasswordKey, password);
      final AuthSessionModel model = session is AuthSessionModel
          ? session
          : AuthSessionModel(
              token: session.token,
              userId: session.userId,
              userName: session.userName,
              emailId: session.emailId,
              userRoleNameFk: session.userRoleNameFk,
              userTypeFk: session.userTypeFk,
              departmentFk: session.departmentFk,
              designation: session.designation,
            );
      await prefs.setString(_userProfileJsonKey, jsonEncode(model.toJson()));
      return;
    }
    await prefs.remove(_savedPasswordKey);
    await prefs.remove(_userProfileJsonKey);
  }

  Future<void> clearSensitiveOnly() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, false);
    await prefs.remove(_savedPasswordKey);
    await prefs.remove(_userProfileJsonKey);
  }

  Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_savedUserIdKey);
    await prefs.remove(_savedPasswordKey);
    await prefs.remove(_userProfileJsonKey);
  }
}

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource();
});
