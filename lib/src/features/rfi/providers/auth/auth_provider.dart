import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';

/// Standalone RFI screens expect a map-shaped auth payload from [authNotifierProvider].
final authNotifierProvider =
    Provider<AsyncValue<Map<String, dynamic>?>>((Ref ref) {
  return ref.watch(authControllerProvider).when(
        data: (AuthSession? session) =>
            AsyncData<Map<String, dynamic>?>(_sessionToMap(session)),
        loading: () => const AsyncLoading<Map<String, dynamic>?>(),
        error: (Object error, StackTrace stack) =>
            AsyncError<Map<String, dynamic>?>(error, stack),
      );
});

Map<String, dynamic>? _sessionToMap(AuthSession? session) {
  if (session == null) {
    return null;
  }
  return <String, dynamic>{
    'userId': session.userId,
    'userName': session.userName,
    'userRoleNameFk': session.userRoleNameFk,
    'userTypeFk': session.userTypeFk,
    'emailId': session.emailId,
    'departmentFk': session.departmentFk,
    'designation': session.designation,
    'dyHodUserId': session.userId,
  };
}
