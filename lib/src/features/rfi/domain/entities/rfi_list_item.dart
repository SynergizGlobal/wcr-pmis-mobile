class RfiListItem {
  const RfiListItem({
    required this.rfiId,
    required this.rfiNo,
    required this.project,
    required this.structure,
    required this.activity,
    required this.status,
    required this.dateOfSubmission,
    required this.work,
    required this.element,
    required this.assignedPersonClient,
    required this.nameOfRepresentative,
    required this.createdBy,
    required this.approvalStatus,
    required this.totalQty,
    this.contract,
    this.typeOfRfi,
    this.rfiDescription,
    this.measurementType,
    this.validationStatus,
    this.inspectionStatus,
  });

  final int rfiId;
  final String rfiNo;
  final String project;
  final String structure;
  final String activity;
  final String status;
  final String dateOfSubmission;
  final String work;
  final String element;
  final String assignedPersonClient;
  final String nameOfRepresentative;
  final String createdBy;
  final String approvalStatus;
  final String totalQty;
  final String? contract;
  final String? typeOfRfi;
  final String? rfiDescription;
  final String? measurementType;
  final String? validationStatus;
  final String? inspectionStatus;

  factory RfiListItem.fromJson(Map<String, dynamic> json) {
    String str(String key) => json[key]?.toString() ?? '';

    String strFromKeys(List<String> keys) {
      for (final String key in keys) {
        final String value = json[key]?.toString().trim() ?? '';
        if (value.isNotEmpty) {
          return value;
        }
      }
      return '';
    }

    final int parsedId = (json['rfiId'] as num?)?.toInt() ??
        (json['id'] as num?)?.toInt() ??
        int.tryParse(json['id']?.toString() ?? '') ??
        int.tryParse(json['rfiId']?.toString() ?? '') ??
        0;

    return RfiListItem(
      rfiId: parsedId,
      rfiNo: strFromKeys(<String>['rfi_Id', 'rfiNo', 'rfi_id']),
      project: str('project'),
      structure: str('structure'),
      activity: str('activity'),
      status: str('status'),
      dateOfSubmission: str('dateOfSubmission'),
      work: str('work'),
      element: str('element'),
      assignedPersonClient: str('assignedPersonClient'),
      nameOfRepresentative: str('nameOfRepresentative'),
      createdBy: str('createdBy'),
      approvalStatus: str('approvalStatus'),
      totalQty: str('totalQty'),
      contract: json['contract']?.toString(),
      typeOfRfi: json['typeOfRFI']?.toString(),
      rfiDescription: json['rfiDescription']?.toString(),
      measurementType: json['measurementType']?.toString(),
      validationStatus: json['validationStatus']?.toString(),
      inspectionStatus: json['inspectionStatus']?.toString(),
    );
  }

  bool matchesSearch(String query) {
    if (query.isEmpty) {
      return true;
    }
    final String lower = query.toLowerCase();
    final Iterable<String> fields = <String>[
      rfiNo,
      project,
      structure,
      element,
      activity,
      nameOfRepresentative,
      totalQty,
      createdBy,
      assignedPersonClient,
      status,
      dateOfSubmission,
      work,
    ];
    return fields.any((String field) => field.toLowerCase().contains(lower));
  }
}
