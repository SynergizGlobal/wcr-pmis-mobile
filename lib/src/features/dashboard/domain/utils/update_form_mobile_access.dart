import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/update_form_item.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/quality_inspection_user_access.dart';

/// Update forms that have a native mobile screen implemented.
class UpdateFormMobileAccess {
  const UpdateFormMobileAccess._();

  /// Stable [UpdateFormItem.formId] values from getUpdateForms API.
  static const Set<String> mobileReadyFormIds = <String>{
    '38', // Projects
    '9', // Works
    '6', // Issues
    '18', // Execution & Monitoring
    '1391', // DMS
    '1240', // Utility Shifting
    '1394', // Quality Inspection
  };

  /// Stable [UpdateFormSubItem.formId] values with native mobile screens.
  static const Set<String> mobileReadySubFormIds = <String>{
    '50', // Add Structure (list + add/update flows)
    '52', // Structure Form (contract-wise structure works list)
  };

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('&', ' ')
        .replaceAll('/', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool isMobileReady(
    UpdateFormItem item, {
    required QualityInspectionUserAccess qualityInspectionAccess,
  }) {
    final String formId = item.formId.trim();
    if (mobileReadyFormIds.contains(formId)) {
      if (formId == '1394') {
        return qualityInspectionAccess.canAccessModule;
      }
      return true;
    }

    final String nameKey = _normalize(item.formName);
    final String urlKey = _normalize(
      '${item.webFormUrl ?? ''} ${item.mobileFormUrl ?? ''}',
    );

    if (nameKey.contains('project') &&
        !nameKey.contains('quality') &&
        !nameKey.contains('inspection')) {
      return true;
    }
    if (nameKey.contains('execution') &&
        (nameKey.contains('monitor') || nameKey.contains('moniter'))) {
      return true;
    }
    if (nameKey.contains('issue') || urlKey.contains('issue')) {
      return true;
    }
    if ((nameKey.contains('utility') && nameKey.contains('shifting')) ||
        urlKey.contains('utilityshifting')) {
      return true;
    }
    if ((nameKey.contains('quality') && nameKey.contains('inspection')) ||
        urlKey.contains('qualityinspection')) {
      return qualityInspectionAccess.canAccessModule;
    }
    if (nameKey.contains('dms') ||
        '$nameKey $urlKey'.contains('document management') ||
        urlKey.contains('dms')) {
      return true;
    }
    if (nameKey.contains('works') || urlKey.contains('works')) {
      return true;
    }
    if (nameKey.contains('structure') || urlKey.contains('structure')) {
      return true;
    }
    return false;
  }

  static bool isSubMenuMobileReady(UpdateFormSubItem item) {
    final String formId = item.formId.trim();
    if (mobileReadySubFormIds.contains(formId)) {
      return true;
    }

    final String nameKey = _normalize(item.formName);
    final String urlKey = _normalize(
      '${item.webFormUrl ?? ''} ${item.mobileFormUrl ?? ''}',
    );
    if (nameKey.contains('add structure') || urlKey == 'structure') {
      return true;
    }
    // Shown in menu; navigation handled separately (not implemented yet).
    if (nameKey.contains('update structure') ||
        urlKey.contains('structure-form') ||
        urlKey.contains('structureform')) {
      return true;
    }
    return false;
  }
}
