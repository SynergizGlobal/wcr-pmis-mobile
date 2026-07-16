/// Dashboard metric → RFI Log list filter (WCR only).
enum RfiLogDashboardFilter {
  none,
  approved,
  rejected,
  closed,
}

extension RfiLogDashboardFilterX on RfiLogDashboardFilter {
  String get title {
    switch (this) {
      case RfiLogDashboardFilter.none:
        return 'REQUEST FOR INSPECTION LOG-(RFI LOG)';
      case RfiLogDashboardFilter.approved:
        return 'Approved RFI Log';
      case RfiLogDashboardFilter.rejected:
        return 'Rejected RFI Log';
      case RfiLogDashboardFilter.closed:
        return 'Closed RFI Log';
    }
  }

  static RfiLogDashboardFilter? fromExtra(Object? extra) {
    if (extra is RfiLogDashboardFilter) {
      return extra;
    }
    if (extra is String) {
      for (final RfiLogDashboardFilter value in RfiLogDashboardFilter.values) {
        if (value.name == extra) {
          return value;
        }
      }
    }
    return null;
  }
}
