import 'package:freezed_annotation/freezed_annotation.dart';

part 'enclosure_checklist.freezed.dart';
part 'enclosure_checklist.g.dart';

@freezed
class ChecklistItem with _$ChecklistItem {
  const factory ChecklistItem({
    int? checklistDescId,
    String? checklistDescription,
    String? contractorStatus,
    String? engineerStatus,
    String? contractorRemarks,
    String? engineerRemark,
    String? gradeOfConcrete,
    String? enclosureName,
  }) = _ChecklistItem;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$ChecklistItemFromJson(json);
}

@freezed
class SaveChecklistRequest with _$SaveChecklistRequest {
  const factory SaveChecklistRequest({
    required int rfiId,
    required String enclosureName,
    String? gradeOfConcrete,
    required String uploadedBy,
    required List<SaveChecklistRow> checklistRows,
  }) = _SaveChecklistRequest;

  factory SaveChecklistRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveChecklistRequestFromJson(json);
}

@freezed
class SaveChecklistRow with _$SaveChecklistRow {
  const factory SaveChecklistRow({
    required int checklistDescriptionId,
    required String description,
    String? contractorStatus,
    String? engineerStatus,
    String? contractorRemark,
    String? aeRemark,
  }) = _SaveChecklistRow;

  factory SaveChecklistRow.fromJson(Map<String, dynamic> json) =>
      _$SaveChecklistRowFromJson(json);
}
