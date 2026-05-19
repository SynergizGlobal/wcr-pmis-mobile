import 'package:freezed_annotation/freezed_annotation.dart';
import 'rfi_detail_model.dart';

part 'rfi_inspection_model.freezed.dart';
part 'rfi_inspection_model.g.dart';

@freezed
class RfiInspectionModel with _$RfiInspectionModel {
  const factory RfiInspectionModel({
    int? id,
    int? rfiId,
    String? dateOfInspection,
    String? timeOfInspection,
    String? location,
    String? chainage,
    String? selfiePath,
    String? siteImage,
    String? testSiteDocuments,
    String? project,
    String? work,
    String? contract,
    String? contractor,
    String? activity,
    String? rfiDescription,
    String? description,
    String? inspectionStatus,
    String? testInsiteLab,
    String? nameOfRepresentative,
    String? engineerRemarks,
    String? workStatus,
    String? uploadedBy,
    String? descriptionEnclosure,
    MeasurementModel? measurements,
    List<dynamic>? supportingDescriptions,
    List<dynamic>? supportingFiles,
    String? stringRfiId,
  }) = _RfiInspectionModel;

  factory RfiInspectionModel.fromJson(Map<String, dynamic> json) =>
      _$RfiInspectionModelFromJson(json);
}
