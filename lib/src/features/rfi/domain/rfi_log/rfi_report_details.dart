import 'package:freezed_annotation/freezed_annotation.dart';

part 'rfi_report_details.freezed.dart';
part 'rfi_report_details.g.dart';

@freezed
class RfiReportDetailsData with _$RfiReportDetailsData {
  const factory RfiReportDetailsData({
    required ReportDetailsInfo reportDetails,
    @Default([]) List<ChecklistItem> checklistItems,
    @Default([]) List<EnclosureInfo> enclosures,
    MeasurementDetails? measurementDetails,
  }) = _RfiReportDetailsData;

  factory RfiReportDetailsData.fromJson(Map<String, dynamic> json) =>
      _$RfiReportDetailsDataFromJson(json);
}

@freezed
class ReportDetailsInfo with _$ReportDetailsInfo {
  const factory ReportDetailsInfo({
    String? project,
    String? work,
    String? contract,
    String? contractId,
    String? structureType,
    String? structure,
    String? component,
    String? element,
    String? activity,
    String? rfiDescription,
    String? action,
    String? typeOfRfi,
    String? contractorRepresentative,
    String? contractor,
    String? enclosures,
    String? rfiId,
    String? rfiStatus,
    String? descriptionByContractor,
    String? dateOfCreation,
    String? conInspDate,
    String? proposedDateOfInspection,
    String? actualDateOfInspection,
    String? proposedInspectionTime,
    String? actualInspectionTime,
    String? dyHodUserId,
    String? clientRepresentative,
    String? clientDepartment,
    String? conLocation,
    String? clientLocation,
    String? chainage,
    String? validationStatus,
    String? remarks,
    String? validationComments,
    String? selfieClient,
    String? selfieContractor,
    String? imagesUploadedByClient,
    String? imagesUploadedByContractor,
    String? typeOfTest,
    String? testStatus,
    String? engineerRemarks,
    String? testSiteDocumentsContractor,
    String? testResultContractor,
    String? testResultEngineer,
    String? dyHodUserName,
    String? conSupportFilePaths,
    String? enggSupportFilePaths,
    String? attachmentData,
    @Default([]) List<dynamic> attachments,
  }) = _ReportDetailsInfo;

  factory ReportDetailsInfo.fromJson(Map<String, dynamic> json) =>
      _$ReportDetailsInfoFromJson(json);
}

@freezed
class ChecklistItem with _$ChecklistItem {
  const factory ChecklistItem({
    String? enclosureName,
    String? checklistDescription,
    String? contractorRemark,
    String? aeRemark,
    String? conStatus,
    String? aeStatus,
  }) = _ChecklistItem;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$ChecklistItemFromJson(json);
}

@freezed
class EnclosureInfo with _$EnclosureInfo {
  const factory EnclosureInfo({
    String? enclosureName,
    String? file,
  }) = _EnclosureInfo;

  factory EnclosureInfo.fromJson(Map<String, dynamic> json) =>
      _$EnclosureInfoFromJson(json);
}

@freezed
class MeasurementDetails with _$MeasurementDetails {
  const factory MeasurementDetails({
    String? measurementType,
    dynamic weight,
    double? totalQty,
    dynamic b,
    dynamic l,
    dynamic h,
    int? no,
    String? units,
  }) = _MeasurementDetails;

  factory MeasurementDetails.fromJson(Map<String, dynamic> json) =>
      _$MeasurementDetailsFromJson(json);
}
