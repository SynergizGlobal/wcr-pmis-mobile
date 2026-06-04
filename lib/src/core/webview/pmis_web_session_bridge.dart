import 'dart:convert';

import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';

/// Mirrors the React web app's post-login `localStorage` keys.
abstract final class PmisWebSessionBridge {
  /// Value written by the web login flow (`localStorage.setItem("token", …)`).
  static const String webSessionToken = 'SESSION_AUTH';

  static Map<String, dynamic> userPayloadFromSession(AuthSession session) {
    return <String, dynamic>{
      'token': session.token,
      'userId': session.userId,
      'userName': session.userName,
      'emailId': session.emailId,
      'userRoleNameFk': session.userRoleNameFk,
      'userTypeFk': session.userTypeFk,
      'departmentFk': session.departmentFk,
      'designation': session.designation,
    };
  }

  /// JavaScript run on the PMIS origin before navigating to embedded routes.
  static String buildStorageBootstrapScript({
    required AuthSession session,
    String? projectId,
    String? projectName,
  }) {
    final Map<String, dynamic> user = userPayloadFromSession(session);
    final StringBuffer script = StringBuffer('(function(){');
    script.write('localStorage.setItem("token",${jsonEncode(webSessionToken)});');
    script.write('localStorage.setItem("user",${jsonEncode(jsonEncode(user))});');
    script.write(
      'localStorage.setItem("userName",${jsonEncode(session.userName)});',
    );
    script.write(
      'localStorage.setItem("designation",${jsonEncode(session.designation)});',
    );
    script.write(
      'localStorage.setItem("userRoleNameFk",${jsonEncode(session.userRoleNameFk)});',
    );
    script.write(
      'localStorage.setItem("userTypeFk",${jsonEncode(session.userTypeFk)});',
    );

    final String? trimmedProjectId = projectId?.trim();
    if (trimmedProjectId != null && trimmedProjectId.isNotEmpty) {
      script.write(
        'sessionStorage.setItem("projectId",${jsonEncode(trimmedProjectId)});',
      );
    }
    final String? trimmedProjectName = projectName?.trim();
    if (trimmedProjectName != null && trimmedProjectName.isNotEmpty) {
      script.write(
        'sessionStorage.setItem("projectName",${jsonEncode(trimmedProjectName)});',
      );
    }
    script.write('})();');
    return script.toString();
  }
}
