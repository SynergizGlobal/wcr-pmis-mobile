import 'package:wcr_pmis_mobile/src/features/rfi/domain/utils/rfi_user_role.dart';

/// Maps FCM `data.type` (+ optional `referenceType` / `referenceId`) to a route.
abstract final class NotificationRouteResolver {
  static const String createdRfiListPath = '/rfi/list/created';
  static const String inspectionPath = '/rfi/inspection';
  static const String validationPath = '/rfi/validation';
  static const String rfiLogPath = '/rfi/log';
  static const String rfiHomePath = '/rfi/dashboard';
  static const String wcrHomePath = '/';
  static const String qualityInspectionPath = '/quality-inspections';
  static const String qualityInspectionDetailPath = '/add-quality-inspection';
  static const String validateDataApprovedPath = '/validate-data?tab=approved';
  static const String validateDataRejectedPath = '/validate-data?tab=rejected';

  static String resolve({
    required String? type,
    required RfiUserRole role,
    String? referenceType,
    String? referenceId,
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
      case 'QUALITY_INSPECTION':
        return _qualityInspectionPath(referenceId);
      case 'PROGRESS_VALIDATION_APPROVED':
        return validateDataApprovedPath;
      case 'PROGRESS_VALIDATION_REJECTED':
        return validateDataRejectedPath;
      default:
        return _homeForReferenceType(referenceType);
    }
  }

  static String _qualityInspectionPath(String? referenceId) {
    final String id = (referenceId ?? '').trim();
    if (id.isEmpty) {
      return qualityInspectionPath;
    }
    return '$qualityInspectionDetailPath'
        '?inspection_id=${Uri.encodeQueryComponent(id)}';
  }

  static String _homeForReferenceType(String? referenceType) {
    switch ((referenceType ?? '').trim().toUpperCase()) {
      case 'RFI':
        return rfiHomePath;
      case 'WCR':
        return wcrHomePath;
      default:
        return wcrHomePath;
    }
  }

  static String? typeFromData(Map<String, dynamic> data) {
    final dynamic raw = data['type'] ?? data['notificationType'];
    final String value = raw?.toString().trim() ?? '';
    return value.isEmpty ? null : value;
  }

  static String? referenceTypeFromData(Map<String, dynamic> data) {
    final dynamic raw =
        data['referenceType'] ?? data['reference_type'] ?? data['refType'];
    final String value = raw?.toString().trim() ?? '';
    return value.isEmpty ? null : value;
  }

  static String? referenceIdFromData(Map<String, dynamic> data) {
    final dynamic raw = data['referenceId'] ??
        data['reference_id'] ??
        data['rfiId'] ??
        data['rfi_id'] ??
        data['id'];
    final String value = raw?.toString().trim() ?? '';
    return value.isEmpty ? null : value;
  }

  static String? rfiIdFromData(Map<String, dynamic> data) {
    return referenceIdFromData(data);
  }

  static String? userIdFromData(Map<String, dynamic> data) {
    final dynamic raw = data['userId'] ?? data['user_id'] ?? data['uid'];
    final String value = raw?.toString().trim() ?? '';
    return value.isEmpty ? null : value;
  }

  /// When FCM includes [notificationUserId], it must match the session user.
  /// Missing FCM userId is allowed (older payloads).
  static bool isIntendedForUser({
    required String? notificationUserId,
    required String? sessionUserId,
  }) {
    final String target = (notificationUserId ?? '').trim();
    if (target.isEmpty) {
      return true;
    }
    final String current = (sessionUserId ?? '').trim();
    if (current.isEmpty) {
      return true;
    }
    return target.toUpperCase() == current.toUpperCase();
  }
}
