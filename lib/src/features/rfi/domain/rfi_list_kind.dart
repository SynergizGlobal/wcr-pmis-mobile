import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_list_item.dart';

enum RfiListKind {
  created,
  updated,
  scheduled,
  rescheduled,
  submitted,
  approved,
  rejected,
  closed,
}

extension RfiListKindX on RfiListKind {
  String get title {
    switch (this) {
      case RfiListKind.created:
        return 'Created RFI List';
      case RfiListKind.updated:
        return 'Updated RFI List';
      case RfiListKind.scheduled:
        return 'Scheduled RFI List';
      case RfiListKind.rescheduled:
        return 'Rescheduled RFI List';
      case RfiListKind.submitted:
        return 'Submitted RFI List';
      case RfiListKind.approved:
        return 'Approved RFI List';
      case RfiListKind.rejected:
        return 'Rejected RFI List';
      case RfiListKind.closed:
        return 'Closed RFI List';
    }
  }

  String get routeSegment => name;

  static RfiListKind? fromRouteSegment(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    for (final RfiListKind kind in RfiListKind.values) {
      if (kind.name == value) {
        return kind;
      }
    }
    return null;
  }

  List<RfiListItem> filter(List<RfiListItem> items) {
    switch (this) {
      case RfiListKind.created:
        return items;
      case RfiListKind.updated:
        return items
            .where(
              (RfiListItem item) =>
                  item.status == 'UPDATED' || item.status == 'REASSIGNED',
            )
            .toList();
      case RfiListKind.scheduled:
        return items
            .where(
              (RfiListItem item) =>
                  item.status == 'CREATED' ||
                  item.status == 'UPDATED' ||
                  item.status == 'CON_INSP_ONGOING' ||
                  item.status == 'UNDER_CON_RECTIFICATION',
            )
            .toList();
      case RfiListKind.rescheduled:
        return items.where((RfiListItem item) => item.status == 'RESCHEDULED').toList();
      case RfiListKind.submitted:
        return items
            .where((RfiListItem item) => item.status == 'INSPECTED_BY_CON')
            .toList();
      case RfiListKind.approved:
        return items
            .where(
              (RfiListItem item) =>
                  item.status == 'INSPECTION_DONE' &&
                  item.approvalStatus == 'Accepted' &&
                  item.validationStatus != 'REJECTED',
            )
            .toList();
      case RfiListKind.rejected:
        return items
            .where(
              (RfiListItem item) =>
                  item.status == 'INSPECTION_DONE' &&
                  (item.approvalStatus == 'Rejected' ||
                      item.validationStatus == 'REJECTED'),
            )
            .toList();
      case RfiListKind.closed:
        return items
            .where((RfiListItem item) => item.status == 'INSPECTION_DONE')
            .toList();
    }
  }
}
