// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChecklistDetailImpl _$$ChecklistDetailImplFromJson(
  Map<String, dynamic> json,
) => _$ChecklistDetailImpl(
  id: (json['id'] as num).toInt(),
  checklistDescription: json['checklistDescription'] as String,
  rfiChecklistItems:
      (json['rfiChecklistItems'] as List<dynamic>?)
          ?.map((e) => RfiChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ChecklistDetailImplToJson(
  _$ChecklistDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'checklistDescription': instance.checklistDescription,
  'rfiChecklistItems': instance.rfiChecklistItems,
};

_$RfiChecklistItemImpl _$$RfiChecklistItemImplFromJson(
  Map<String, dynamic> json,
) => _$RfiChecklistItemImpl(
  id: (json['id'] as num).toInt(),
  gradeOfConcrete: json['gradeOfConcrete'] as String? ?? '',
  contractorStatus: json['contractorStatus'] as String? ?? '',
  engineerStatus: json['engineerStatus'] as String?,
  contractorRemark: json['contractorRemark'] as String? ?? '',
  aeRemark: json['aeRemark'] as String? ?? '',
  enclosureName: json['enclosureName'] as String? ?? '',
  uploadedby: json['uploadedby'] as String? ?? '',
);

Map<String, dynamic> _$$RfiChecklistItemImplToJson(
  _$RfiChecklistItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'gradeOfConcrete': instance.gradeOfConcrete,
  'contractorStatus': instance.contractorStatus,
  'engineerStatus': instance.engineerStatus,
  'contractorRemark': instance.contractorRemark,
  'aeRemark': instance.aeRemark,
  'enclosureName': instance.enclosureName,
  'uploadedby': instance.uploadedby,
};
