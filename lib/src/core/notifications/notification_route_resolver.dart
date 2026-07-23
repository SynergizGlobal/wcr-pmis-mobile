import 'package:wcr_pmis_mobile/src/features/rfi/domain/utils/rfi_user_role.dart';

/// Maps FCM `data.type` to an in-app GoRouter location.
abstract final class NotificationRouteResolver {
  static const String createdRfiListPath = '/rfi/list/created';
  static const String inspectionPath = '/rfi/inspection';
  static const String validationPath = '/rfi/validation';
  static const String rfiLogPath = '/rfi/log';

  static String resolve({
    required String? type,
    required RfiUserRole role,
  }) {
    switch ((type ?? '').trim().toUpperCase()) {
      case 'RFI_CREATED':
      case 'RFI_UPDATED':
        return createdRfiListPath;
      case 'RFI_INSPECTION':
        return inspectionPath;
      case 'RFI_VALIDATION':
        return role.canViewValidation ? validationPath : rfiLogPath;
      case 'RFI_CLOSED':
      case 'RFI_DELETED':
        return rfiLogPath;
      default:
        return rfiLogPath;
    }
  }

  static String? typeFromData(Map<String, dynamic> data) {
    final dynamic raw = data['type'] ?? data['notificationType'];
    final String value = raw?.toString().trim() ?? '';
    return value.isEmpty ? null : value;
  }

  static String? rfiIdFromData(Map<String, dynamic> data) {
    final dynamic raw = data['rfiId'] ?? data['rfi_id'] ?? data['id'];
    final String value = raw?.toString().trim() ?? '';
    return value.isEmpty ? null : value;
  }
}
