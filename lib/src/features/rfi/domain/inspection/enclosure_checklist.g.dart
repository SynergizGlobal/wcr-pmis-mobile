// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_checklist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChecklistItemImpl _$$ChecklistItemImplFromJson(Map<String, dynamic> json) =>
    _$ChecklistItemImpl(
      checklistDescId: (json['checklistDescId'] as num?)?.toInt(),
      checklistDescription: json['checklistDescription'] as String?,
      contractorStatus: json['contractorStatus'] as String?,
      engineerStatus: json['engineerStatus'] as String?,
      contractorRemarks: json['contractorRemarks'] as String?,
      engineerRemark: json['engineerRemark'] as String?,
      gradeOfConcrete: json['gradeOfConcrete'] as String?,
      enclosureName: json['enclosureName'] as String?,
    );

Map<String, dynamic> _$$ChecklistItemImplToJson(_$ChecklistItemImpl instance) =>
    <String, dynamic>{
      'checklistDescId': instance.checklistDescId,
      'checklistDescription': instance.checklistDescription,
      'contractorStatus': instance.contractorStatus,
      'engineerStatus': instance.engineerStatus,
      'contractorRemarks': instance.contractorRemarks,
      'engineerRemark': instance.engineerRemark,
      'gradeOfConcrete': instance.gradeOfConcrete,
      'enclosureName': instance.enclosureName,
    };

_$SaveChecklistRequestImpl _$$SaveChecklistRequestImplFromJson(
  Map<String, dynamic> json,
) => _$SaveChecklistRequestImpl(
  rfiId: (json['rfiId'] as num).toInt(),
  enclosureName: json['enclosureName'] as String,
  gradeOfConcrete: json['gradeOfConcrete'] as String?,
  uploadedBy: json['uploadedBy'] as String,
  checklistRows: (json['checklistRows'] as List<dynamic>)
      .map((e) => SaveChecklistRow.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$SaveChecklistRequestImplToJson(
  _$SaveChecklistRequestImpl instance,
) => <String, dynamic>{
  'rfiId': instance.rfiId,
  'enclosureName': instance.enclosureName,
  'gradeOfConcrete': instance.gradeOfConcrete,
  'uploadedBy': instance.uploadedBy,
  'checklistRows': instance.checklistRows,
};

_$SaveChecklistRowImpl _$$SaveChecklistRowImplFromJson(
  Map<String, dynamic> json,
) => _$SaveChecklistRowImpl(
  checklistDescriptionId: (json['checklistDescriptionId'] as num).toInt(),
  description: json['description'] as String,
  contractorStatus: json['contractorStatus'] as String?,
  engineerStatus: json['engineerStatus'] as String?,
  contractorRemark: json['contractorRemark'] as String?,
  aeRemark: json['aeRemark'] as String?,
);

Map<String, dynamic> _$$SaveChecklistRowImplToJson(
  _$SaveChecklistRowImpl instance,
) => <String, dynamic>{
  'checklistDescriptionId': instance.checklistDescriptionId,
  'description': instance.description,
  'contractorStatus': instance.contractorStatus,
  'engineerStatus': instance.engineerStatus,
  'contractorRemark': instance.contractorRemark,
  'aeRemark': instance.aeRemark,
};
