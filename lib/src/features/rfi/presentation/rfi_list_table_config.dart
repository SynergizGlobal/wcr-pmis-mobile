import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_list_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/rfi_list_kind.dart';

class RfiTableColumn {
  const RfiTableColumn({
    required this.label,
    required this.width,
    required this.value,
  });

  final String label;
  final double width;
  final String Function(RfiListItem item) value;
}

class RfiListTableConfig {
  const RfiListTableConfig._();

  static const double actionWidth = 160;

  static List<RfiTableColumn> columnsFor(RfiListKind kind) {
    switch (kind) {
      case RfiListKind.created:
      case RfiListKind.updated:
        return _createdColumns;
      case RfiListKind.scheduled:
      case RfiListKind.rescheduled:
      case RfiListKind.submitted:
      case RfiListKind.approved:
      case RfiListKind.rejected:
      case RfiListKind.closed:
        return _workflowColumns;
    }
  }

  static final List<RfiTableColumn> _createdColumns = <RfiTableColumn>[
    RfiTableColumn(label: 'RFI ID', width: 180, value: (RfiListItem i) => i.rfiNo),
    RfiTableColumn(label: 'Project', width: 150, value: (RfiListItem i) => i.project),
    RfiTableColumn(
      label: 'Structure',
      width: 150,
      value: (RfiListItem i) => i.structure,
    ),
    RfiTableColumn(label: 'Element', width: 180, value: (RfiListItem i) => i.element),
    RfiTableColumn(
      label: 'Activity',
      width: 150,
      value: (RfiListItem i) => i.activity,
    ),
    RfiTableColumn(
      label: 'Assigned Contractor',
      width: 180,
      value: (RfiListItem i) => i.createdBy,
    ),
    RfiTableColumn(
      label: 'Submission Date',
      width: 160,
      value: (RfiListItem i) => i.dateOfSubmission,
    ),
    RfiTableColumn(
      label: 'Assigned Person Client',
      width: 180,
      value: (RfiListItem i) => i.assignedPersonClient,
    ),
    RfiTableColumn(label: 'Status', width: 160, value: (RfiListItem i) => i.status),
  ];

  static final List<RfiTableColumn> _workflowColumns = <RfiTableColumn>[
    RfiTableColumn(label: 'RFI ID', width: 180, value: (RfiListItem i) => i.rfiNo),
    RfiTableColumn(
      label: 'Raised Date',
      width: 140,
      value: (RfiListItem i) => i.dateOfSubmission,
    ),
    RfiTableColumn(
      label: 'Structure',
      width: 150,
      value: (RfiListItem i) => i.structure,
    ),
    RfiTableColumn(label: 'Element', width: 180, value: (RfiListItem i) => i.element),
    RfiTableColumn(
      label: 'Activity',
      width: 150,
      value: (RfiListItem i) => i.activity,
    ),
    RfiTableColumn(
      label: 'RFI Description',
      width: 180,
      value: (RfiListItem i) => i.rfiDescription ?? '',
    ),
    RfiTableColumn(
      label: 'Assigned Contractor',
      width: 180,
      value: (RfiListItem i) => i.createdBy,
    ),
    RfiTableColumn(
      label: "Assigned Employer's Engineer",
      width: 200,
      value: (RfiListItem i) => i.assignedPersonClient,
    ),
    RfiTableColumn(
      label: 'Measurement Type',
      width: 150,
      value: (RfiListItem i) => i.measurementType ?? '',
    ),
    RfiTableColumn(
      label: 'Total Qty',
      width: 100,
      value: (RfiListItem i) => i.totalQty,
    ),
    RfiTableColumn(
      label: 'Inspection Status',
      width: 160,
      value: (RfiListItem i) => i.inspectionStatus ?? i.status,
    ),
  ];
}
