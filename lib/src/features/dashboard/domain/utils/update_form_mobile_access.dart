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
    '10', // Contracts/Tenders
    '17', // Design & Drawing
    '40', // Validate Data
  };

  /// Stable [UpdateFormSubItem.formId] values with native mobile screens.
  static const Set<String> mobileReadySubFormIds = <String>{
    '50', // Add Structure (list + add/update flows)
    '52', // Structure Form (contract-wise structure works list)
    '3', // Contract
    '11', // Contractor
    '53', // New Activities Update (Execution & Monitoring)
    '1281', // Structure P6 Updates (Execution & Monitoring)
    '1359', // Modify Actuals (Execution & Monitoring)
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
    if ((nameKey.contains('contract') && nameKey.contains('tender')) ||
        urlKey.contains('contract') ||
        urlKey.contains('tender')) {
      return true;
    }
    if ((nameKey.contains('design') && nameKey.contains('drawing')) ||
        urlKey.contains('design')) {
      return true;
    }
    if (nameKey.contains('validate') && nameKey.contains('data')) {
      return true;
    }
    if (urlKey.contains('validation') || urlKey.contains('validate')) {
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
    if (nameKey.contains('update structure') ||
        urlKey.contains('structure-form') ||
        urlKey.contains('structureform')) {
      return true;
    }
    if (nameKey.contains('contractor') || urlKey.contains('contractor')) {
      return true;
    }
    if (formId == '3' ||
        (urlKey == 'contract' && !urlKey.contains('contractor')) ||
        (nameKey == 'contract' && !nameKey.contains('contractor'))) {
      return true;
    }
    if (urlKey.contains('new-activities-update') ||
        urlKey.contains('newactivitiesupdate') ||
        nameKey.contains('new activit')) {
      return true;
    }
    if (urlKey.contains('p6-new-data') ||
        urlKey.contains('p6newdata') ||
        nameKey.contains('structure p6') ||
        nameKey.contains('p6 update')) {
      return true;
    }
    if (urlKey.contains('modify-actuals') ||
        urlKey.contains('modifyactuals') ||
        nameKey.contains('modify actual')) {
      return true;
    }
    return false;
  }
}
