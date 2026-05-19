// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_checklist_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EnclosureChecklistItemImpl _$$EnclosureChecklistItemImplFromJson(
  Map<String, dynamic> json,
) => _$EnclosureChecklistItemImpl(
  gradeOfConcrete: json['gradeOfConcrete'] as String?,
  enclosureName: json['enclosureName'] as String?,
  checklistDescId: (json['checklistDescId'] as num?)?.toInt(),
  checklistDescription: json['checklistDescription'] as String?,
  contractorStatus: json['contractorStatus'] as String?,
  engineerStatus: json['engineerStatus'] as String?,
  contractorRemarks: json['contractorRemarks'] as String?,
  engineerRemark: json['engineerRemark'] as String?,
);

Map<String, dynamic> _$$EnclosureChecklistItemImplToJson(
  _$EnclosureChecklistItemImpl instance,
) => <String, dynamic>{
  'gradeOfConcrete': instance.gradeOfConcrete,
  'enclosureName': instance.enclosureName,
  'checklistDescId': instance.checklistDescId,
  'checklistDescription': instance.checklistDescription,
  'contractorStatus': instance.contractorStatus,
  'engineerStatus': instance.engineerStatus,
  'contractorRemarks': instance.contractorRemarks,
  'engineerRemark': instance.engineerRemark,
};
