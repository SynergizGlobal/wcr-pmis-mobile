import 'package:freezed_annotation/freezed_annotation.dart';

part 'checklist_detail.freezed.dart';
part 'checklist_detail.g.dart';

@freezed
class ChecklistDetail with _$ChecklistDetail {
  const factory ChecklistDetail({
    required int id,
    required String checklistDescription,
    @Default([]) List<RfiChecklistItem> rfiChecklistItems,
  }) = _ChecklistDetail;

  factory ChecklistDetail.fromJson(Map<String, dynamic> json) =>
      _$ChecklistDetailFromJson(json);
}

@freezed
class RfiChecklistItem with _$RfiChecklistItem {
  const factory RfiChecklistItem({
    required int id,
    @Default('') String gradeOfConcrete,
    @Default('') String contractorStatus,
    String? engineerStatus,
    @Default('') String contractorRemark,
    @Default('') String aeRemark,
    @Default('') String enclosureName,
    @Default('') String uploadedby,
  }) = _RfiChecklistItem;

  factory RfiChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$RfiChecklistItemFromJson(json);
}
