/// How the Inspection list should scope rows after the shared API fetch.
enum InspectionListMode {
  /// More → Inspection: all open (non-closed) rows.
  all,

  /// Dashboard → RFI Scheduled: CREATED, UNDER_CON_RECTIFICATION, CON_INSP_ONGOING.
  created,

  /// Dashboard → RFI Rescheduled: status == RESCHEDULED only.
  rescheduled,

  /// Dashboard → RFI Submitted: INSPECTED_BY_CON / SUBMITTED.
  submitted,
}

extension InspectionListModeX on InspectionListMode {
  String get title {
    switch (this) {
      case InspectionListMode.all:
        return 'RFI INSPECTION LIST';
      case InspectionListMode.created:
        return 'RFI SCHEDULED LIST';
      case InspectionListMode.rescheduled:
        return 'RFI RESCHEDULED LIST';
      case InspectionListMode.submitted:
        return 'RFI SUBMITTED LIST';
    }
  }

  bool get buildsFiltersFromDataset =>
      this == InspectionListMode.created ||
      this == InspectionListMode.rescheduled ||
      this == InspectionListMode.submitted;

  static InspectionListMode fromExtra(Object? extra) {
    if (extra is InspectionListMode) {
      return extra;
    }
    if (extra is Map) {
      final Object? mode = extra['mode'] ?? extra['listMode'];
      if (mode is InspectionListMode) {
        return mode;
      }
      if (mode is String) {
        for (final InspectionListMode value in InspectionListMode.values) {
          if (value.name == mode) {
            return value;
          }
        }
      }
      // Legacy boolean from earlier navigation.
      if (extra['rescheduledOnly'] == true) {
        return InspectionListMode.rescheduled;
      }
    }
    if (extra is bool && extra) {
      return InspectionListMode.rescheduled;
    }
    if (extra is String) {
      for (final InspectionListMode value in InspectionListMode.values) {
        if (value.name == extra) {
          return value;
        }
      }
    }
    return InspectionListMode.all;
  }
}
