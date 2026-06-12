import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';

/// Quality Inspection permissions by [AuthSession.userTypeFk] and
/// [AuthSession.userRoleNameFk] (IT Admin overrides with full access).
///
/// [QualityInspectionUserGroup.viewOnly] — HOD and Management: open any stage,
/// read-only (no create, edit, or submit).
///
/// Workflow steps (matches API [inspection_step] after transitions):
/// 1 — create, 2 — raise NCR, 3 — contractor rectification (Rectification Pending),
/// 4 — engineer closure (Rectification Submitted), 5 — passed (view only).
enum QualityInspectionUserGroup {
  itAdmin,
  inspector,
  contractor,
  viewOnly,
  restricted,
}

class QualityInspectionUserAccess {
  const QualityInspectionUserAccess(this.group);

  final QualityInspectionUserGroup group;

  static QualityInspectionUserAccess fromSession(AuthSession? session) {
    final String roleName = session?.userRoleNameFk.trim() ?? '';
    final String userType = session?.userTypeFk.trim() ?? '';
    if (roleName == 'IT Admin') {
      return const QualityInspectionUserAccess(
        QualityInspectionUserGroup.itAdmin,
      );
    }
    if (_restrictedTypes.contains(userType)) {
      return const QualityInspectionUserAccess(
        QualityInspectionUserGroup.restricted,
      );
    }
    if (_viewOnlyTypes.contains(userType)) {
      return const QualityInspectionUserAccess(
        QualityInspectionUserGroup.viewOnly,
      );
    }
    if (_contractorTypes.contains(userType)) {
      return const QualityInspectionUserAccess(
        QualityInspectionUserGroup.contractor,
      );
    }
    if (_inspectorTypes.contains(userType)) {
      return const QualityInspectionUserAccess(
        QualityInspectionUserGroup.inspector,
      );
    }
    return const QualityInspectionUserAccess(
      QualityInspectionUserGroup.restricted,
    );
  }

  static const Set<String> _contractorTypes = <String>{
    'Contractor',
    'Contractor Rep',
  };

  static const Set<String> _inspectorTypes = <String>{
    'DyHOD',
    'Officer (Jr./Sr. Scale)',
  };

  static const Set<String> _viewOnlyTypes = <String>{
    'HOD',
    'Management',
  };

  static const Set<String> _restrictedTypes = <String>{
    'Finance',
    'Office Executives',
  };

  bool get isItAdmin => group == QualityInspectionUserGroup.itAdmin;

  bool get isViewOnly => group == QualityInspectionUserGroup.viewOnly;

  bool get canAccessModule => group != QualityInspectionUserGroup.restricted;

  /// Stage 1 — create inspection.
  bool get canCreateInspection =>
      isItAdmin || group == QualityInspectionUserGroup.inspector;

  /// Stage 2 — raise NCR.
  bool get canRaiseNcr =>
      isItAdmin || group == QualityInspectionUserGroup.inspector;

  /// Stage 3 — contractor rectification response.
  bool get canRespondToNcr =>
      isItAdmin || group == QualityInspectionUserGroup.contractor;

  /// Stage 4 — engineer closure (Rectification Submitted → Passed).
  bool get canCloseInspection =>
      isItAdmin || group == QualityInspectionUserGroup.inspector;

  /// Alias kept for existing call sites.
  bool get canReinspect => canCloseInspection;

  bool canWorkOnWorkflowStep(int step) {
    if (isViewOnly) {
      return false;
    }
    if (step < 1 || step > 5) {
      return false;
    }
    if (step == 5) {
      return false;
    }
    if (isItAdmin) {
      return step != 3;
    }
    switch (step) {
      case 1:
        return canCreateInspection;
      case 2:
        return canRaiseNcr;
      case 3:
        return canRespondToNcr;
      case 4:
        return canCloseInspection;
      default:
        return false;
    }
  }

  /// View-only open (no submit) — e.g. DyHOD at contractor rectification (step 3).
  bool canViewInspection(int step) {
    if (!canAccessModule) {
      return false;
    }
    if (isViewOnly && step >= 1 && step <= 5) {
      return true;
    }
    if (canWorkOnWorkflowStep(step)) {
      return true;
    }
    if (step == 5) {
      return true;
    }
    if (step == 3) {
      return group == QualityInspectionUserGroup.inspector ||
          group == QualityInspectionUserGroup.contractor ||
          isItAdmin;
    }
    if (step == 4) {
      return group == QualityInspectionUserGroup.contractor || isItAdmin;
    }
    return false;
  }

  /// Whether the user may open the form (edit or read-only).
  bool canOpenInspection(int step) => canViewInspection(step);

  /// Resolves workflow step (1–5) from list/detail payload.
  static int resolveWorkflowStep(Map<String, dynamic> data) {
    final int parsed = int.tryParse(_readString(data['inspection_step'])) ?? 0;
    if (parsed >= 1 && parsed <= 5) {
      return parsed;
    }

    final String status = _readString(data['inspection_status']).toLowerCase();
    if (status == 'draft') {
      return 1;
    }
    if (status == 'passed' || status.contains('closed')) {
      return 5;
    }
    if (status.contains('rectification submitted')) {
      return 4;
    }
    if (status.contains('rectification pending')) {
      return 3;
    }
    if (status.contains('ncr raised')) {
      return 3;
    }
    if (status.contains('in progress')) {
      return 2;
    }
    if (_hasRaisedNcr(data)) {
      return 3;
    }
    return 1;
  }

  static bool _hasRaisedNcr(Map<String, dynamic> data) {
    final dynamic rows = data['ncrRows'];
    if (rows is! List) {
      return false;
    }
    for (final dynamic row in rows) {
      if (row is! Map) {
        continue;
      }
      final String ncr = _readString(row['is_ncr_required']);
      if (ncr == 'Yes') {
        return true;
      }
    }
    return false;
  }

  static String _readString(dynamic value) {
    if (value == null) {
      return '';
    }
    final String text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return '';
    }
    return text;
  }
}

final qualityInspectionAccessProvider = Provider<QualityInspectionUserAccess>((
  Ref ref,
) {
  return QualityInspectionUserAccess.fromSession(
    ref.watch(authControllerProvider).valueOrNull,
  );
});
