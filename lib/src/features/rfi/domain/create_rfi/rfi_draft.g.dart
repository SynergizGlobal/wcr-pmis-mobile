// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfi_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RfiDraftImpl _$$RfiDraftImplFromJson(
  Map<String, dynamic> json,
) => _$RfiDraftImpl(
  project: json['project'] == null
      ? null
      : DropdownItem.fromJson(json['project'] as Map<String, dynamic>),
  work: json['work'] == null
      ? null
      : DropdownItem.fromJson(json['work'] as Map<String, dynamic>),
  contract: json['contract'] == null
      ? null
      : DropdownItem.fromJson(json['contract'] as Map<String, dynamic>),
  structureType: json['structureType'] == null
      ? null
      : DropdownItem.fromJson(json['structureType'] as Map<String, dynamic>),
  structure: json['structure'] == null
      ? null
      : DropdownItem.fromJson(json['structure'] as Map<String, dynamic>),
  component: json['component'] == null
      ? null
      : DropdownItem.fromJson(json['component'] as Map<String, dynamic>),
  element: json['element'] == null
      ? null
      : DropdownItem.fromJson(json['element'] as Map<String, dynamic>),
  activity: json['activity'] == null
      ? null
      : DropdownItem.fromJson(json['activity'] as Map<String, dynamic>),
  rfiDescription: json['rfiDescription'] == null
      ? null
      : DropdownItem.fromJson(json['rfiDescription'] as Map<String, dynamic>),
  currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
  action: json['action'] as String?,
  typeOfRfi: json['typeOfRfi'] as String?,
  contractorRepresentative: json['contractorRepresentative'] as String?,
  dateOfSubmission: json['dateOfSubmission'] as String?,
  timeOfInspection: json['timeOfInspection'] as String?,
  dateOfInspection: json['dateOfInspection'] as String?,
  selectedEnclosures:
      (json['selectedEnclosures'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  rfiDescriptionText: json['rfiDescriptionText'] as String?,
  projects:
      (json['projects'] as List<dynamic>?)
          ?.map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  works:
      (json['works'] as List<dynamic>?)
          ?.map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  contracts:
      (json['contracts'] as List<dynamic>?)
          ?.map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  structureTypes:
      (json['structureTypes'] as List<dynamic>?)
          ?.map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  structures:
      (json['structures'] as List<dynamic>?)
          ?.map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  components:
      (json['components'] as List<dynamic>?)
          ?.map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  elements:
      (json['elements'] as List<dynamic>?)
          ?.map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  activities:
      (json['activities'] as List<dynamic>?)
          ?.map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  rfiDescriptions:
      (json['rfiDescriptions'] as List<dynamic>?)
          ?.map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  representatives:
      (json['representatives'] as List<dynamic>?)
          ?.map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$RfiDraftImplToJson(_$RfiDraftImpl instance) =>
    <String, dynamic>{
      'project': instance.project,
      'work': instance.work,
      'contract': instance.contract,
      'structureType': instance.structureType,
      'structure': instance.structure,
      'component': instance.component,
      'element': instance.element,
      'activity': instance.activity,
      'rfiDescription': instance.rfiDescription,
      'currentStep': instance.currentStep,
      'action': instance.action,
      'typeOfRfi': instance.typeOfRfi,
      'contractorRepresentative': instance.contractorRepresentative,
      'dateOfSubmission': instance.dateOfSubmission,
      'timeOfInspection': instance.timeOfInspection,
      'dateOfInspection': instance.dateOfInspection,
      'selectedEnclosures': instance.selectedEnclosures,
      'rfiDescriptionText': instance.rfiDescriptionText,
      'projects': instance.projects,
      'works': instance.works,
      'contracts': instance.contracts,
      'structureTypes': instance.structureTypes,
      'structures': instance.structures,
      'components': instance.components,
      'elements': instance.elements,
      'activities': instance.activities,
      'rfiDescriptions': instance.rfiDescriptions,
      'representatives': instance.representatives,
    };
