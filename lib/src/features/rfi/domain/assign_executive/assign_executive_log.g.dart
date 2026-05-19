// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assign_executive_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssignExecutiveLogImpl _$$AssignExecutiveLogImplFromJson(
  Map<String, dynamic> json,
) => _$AssignExecutiveLogImpl(
  id: (json['id'] as num).toInt(),
  contract: json['contract'] as String,
  structureType: json['structureType'] as String,
  structure: json['structure'] as String,
  assignedExecutive: json['assignedExecutive'] as String,
);

Map<String, dynamic> _$$AssignExecutiveLogImplToJson(
  _$AssignExecutiveLogImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'contract': instance.contract,
  'structureType': instance.structureType,
  'structure': instance.structure,
  'assignedExecutive': instance.assignedExecutive,
};
