import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_list_item.dart'
    as wcr;
import 'package:wcr_pmis_mobile/src/features/rfi/domain/rfi_list/rfi_list_item.dart'
    as ported;

ported.RfiListItem toPortedRfiListItem(wcr.RfiListItem item) {
  return ported.RfiListItem(
    rfiId: item.rfiId,
    rfiNo: item.rfiNo,
    project: item.project,
    structure: item.structure,
    activity: item.activity,
    status: item.status,
    dateOfSubmission: item.dateOfSubmission,
    work: item.work,
    element: item.element,
    assignedPersonClient: item.assignedPersonClient,
    nameOfRepresentative: item.nameOfRepresentative,
    createdBy: item.createdBy,
    approvalStatus: item.approvalStatus,
    totalQty: item.totalQty,
    contract: item.contract,
    typeOfRFI: item.typeOfRfi,
    rfiDescription: item.rfiDescription,
    measurementType: item.measurementType,
    validationStatus: item.validationStatus,
    inspectionStatus: item.inspectionStatus,
  );
}

wcr.RfiListItem toWcrRfiListItem(ported.RfiListItem item) {
  return wcr.RfiListItem(
    rfiId: item.rfiId,
    rfiNo: item.rfiNo,
    project: item.project,
    structure: item.structure,
    activity: item.activity,
    status: item.status,
    dateOfSubmission: item.dateOfSubmission,
    work: item.work,
    element: item.element,
    assignedPersonClient: item.assignedPersonClient,
    nameOfRepresentative: item.nameOfRepresentative,
    createdBy: item.createdBy,
    approvalStatus: item.approvalStatus,
    totalQty: item.totalQty,
    contract: item.contract,
    typeOfRfi: item.typeOfRFI,
    rfiDescription: item.rfiDescription,
    measurementType: item.measurementType,
    validationStatus: item.validationStatus,
    inspectionStatus: item.inspectionStatus,
  );
}

wcr.RfiListItem inspectionItemToWcr({
  required int id,
  String? rfiNo,
  String? project,
  String? work,
  String? contract,
  String? structure,
  String? element,
  String? activity,
  String? status,
  String? dateOfSubmission,
  String? assignedPersonClient,
  String? nameOfRepresentative,
  String? createdBy,
  String? approvalStatus,
  String? totalQty,
}) {
  return wcr.RfiListItem(
    rfiId: id,
    rfiNo: rfiNo ?? '',
    project: project ?? '',
    structure: structure ?? '',
    activity: activity ?? '',
    status: status ?? '',
    dateOfSubmission: dateOfSubmission ?? '',
    work: work ?? '',
    element: element ?? '',
    assignedPersonClient: assignedPersonClient ?? '',
    nameOfRepresentative: nameOfRepresentative ?? '',
    createdBy: createdBy ?? '',
    approvalStatus: approvalStatus ?? '',
    totalQty: totalQty ?? '0',
    contract: contract,
  );
}
