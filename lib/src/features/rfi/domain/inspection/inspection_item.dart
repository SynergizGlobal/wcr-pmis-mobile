// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection_item.freezed.dart';
part 'inspection_item.g.dart';

@freezed
class InspectionDetail with _$InspectionDetail {
  const factory InspectionDetail({
    int? id,
    String? dateOfInspection,
    String? timeOfInspection,
    String? location,
    String? inspectionStatus,
    String? testInsiteLab,
    String? uploadedBy,
    String? workStatus,
    String? chainage,
    String? descriptionEnclosure,
    String? selfiePath,
    String? siteImage,
    String? testSiteDocuments,
    String? engineerRemarks,
    String? postTestType,
    String? postTestReportPath,
    String? supportingDocuments,
    String? documentsDescription,
  }) = _InspectionDetail;

  factory InspectionDetail.fromJson(Map<String, dynamic> json) =>
      _$InspectionDetailFromJson(json);
}

@freezed
class Enclosure with _$Enclosure {
  const factory Enclosure({
    int? id,
    String? description,
    String? enclosureName,
    String? uploadedBy,
    bool? locked,
    String? enclosureUploadFile,
  }) = _Enclosure;

  factory Enclosure.fromJson(Map<String, dynamic> json) =>
      _$EnclosureFromJson(json);
}

@freezed
class MeasurementDetail with _$MeasurementDetail {
  const factory MeasurementDetail({
    int? id,
    String? measurementType,
    double? length,
    double? breadth,
    double? height,
    double? weight,
    String? units,
    int? noOfItems,
    double? totalQty,
  }) = _MeasurementDetail;

  factory MeasurementDetail.fromJson(Map<String, dynamic> json) =>
      _$MeasurementDetailFromJson(json);
}

@freezed
class InspectionItem with _$InspectionItem {
  const factory InspectionItem({
    required int id,
    String? element,
    String? status,
    String? imgClient,
    String? contractId,
    String? contract,
    String? structure,
    String? assignedPersonClient,
    String? action,
    @JsonKey(name: 'rfi_Id') String? rfiId,
    String? activity,
    String? rfiDescription,
    String? description,
    String? timeOfInspection,
    String? nameOfRepresentative,
    String? inspectionStatus,
    String? measurementType,
    double? totalQty,
    String? createdBy,
    String? dateOfInspection,
    String? project,
    String? work,
    String? structureType,
    String? component,
    String? typeOfRFI,
    String? approvalStatus,
    String? dateOfSubmission,
    String? contractorSubmittedOn,
    String? engineerSubmittedOn,
    String? validationStatus,
    @JsonKey(name: 'remarks') String? validationRemarks,
    String? validationComments,
    @JsonKey(name: 'valdationAuth') String? validationAuthor,
    String? validationDate,
    String? imgContractor,
    String? representativeReportingToContractor,
    String? testResCon,
    String? testResEngg,
    List<String>? enclosuresList,
    List<Enclosure>? enclosure,
    List<InspectionDetail>? inspectionDetails,
    MeasurementDetail? measurements,
  }) = _InspectionItem;

  factory InspectionItem.fromJson(Map<String, dynamic> json) =>
      _$InspectionItemFromJson(json);
}
