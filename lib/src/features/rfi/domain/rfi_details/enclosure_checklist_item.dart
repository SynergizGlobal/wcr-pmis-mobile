import 'package:freezed_annotation/freezed_annotation.dart';

part 'enclosure_checklist_item.freezed.dart';
part 'enclosure_checklist_item.g.dart';

@freezed
class EnclosureChecklistItem with _$EnclosureChecklistItem {
  const factory EnclosureChecklistItem({
    String? gradeOfConcrete,
    String? enclosureName,
    int? checklistDescId,
    String? checklistDescription,
    String? contractorStatus,
    String? engineerStatus,
    String? contractorRemarks,
    String? engineerRemark,
  }) = _EnclosureChecklistItem;

  factory EnclosureChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$EnclosureChecklistItemFromJson(json);
}
