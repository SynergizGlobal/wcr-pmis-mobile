// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'rfi_detail_model.freezed.dart';
part 'rfi_detail_model.g.dart';

@freezed
class RfiDetailModel with _$RfiDetailModel {
  const factory RfiDetailModel({
    int? id,
    @JsonKey(name: 'rfi_Id') String? rfiId,
    String? project,
    String? work,
    String? contract,
    String? structureType,
    String? structure,
    String? component,
    String? element,
    String? activity,
    String? p6ActivityId,
    String? pmisCalcFk,
    String? reasonForDelete,
    String? rfiDescription,
    String? action,
    String? typeOfRFI,
    String? nameOfRepresentative,
    String? enclosures,
    String? location,
    String? description,
    String? timeOfInspection,
    String? dateOfSubmission,
    String? dateOfInspection,
    String? createdAt,
    String? updatedAt,
    String? createdBy,
    String? emailUser,
    String? status,
    String? assignedPersonClient,
    String? clientDepartment,
    @JsonKey(name: 'txn_id') String? txnId,
    String? assignedPersonContractor,
    String? assignedPersonUserId,
    String? contractId,
    String? dyHodUserId,
    String? rfiValidation,
    List<dynamic>? checklistItems,
    List<dynamic>? enclosure,
    MeasurementModel? measurements,
    @JsonKey(name: 'contractor_submitted_date') String? contractorSubmittedDate,
    @JsonKey(name: 'engineer_submitted_date') String? engineerSubmittedDate,
    bool? contractorEsignDone,
    bool? engineerEsignDone,
    String? closedDate,
    bool? isDeleted,
    String? deletedAt,
    List<dynamic>? attachments,
    String? estatus,
    List<String>? enclosuresList,
  }) = _RfiDetailModel;

  factory RfiDetailModel.fromJson(Map<String, dynamic> json) =>
      _$RfiDetailModelFromJson(json);
}

@freezed
class MeasurementModel with _$MeasurementModel {
  const factory MeasurementModel({
    int? id,
    String? measurementType,
    dynamic length,
    dynamic breadth,
    dynamic height,
    dynamic weight,
    String? units,
    int? noOfItems,
    dynamic totalQty,
    dynamic l,
    dynamic b,
    dynamic h,
    int? no,
  }) = _MeasurementModel;

  factory MeasurementModel.fromJson(Map<String, dynamic> json) =>
      _$MeasurementModelFromJson(json);
}
