// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfi_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RfiListItemImpl _$$RfiListItemImplFromJson(Map<String, dynamic> json) =>
    _$RfiListItemImpl(
      rfiId: (json['rfiId'] as num).toInt(),
      rfiNo: json['rfiNo'] as String,
      project: json['project'] as String,
      structure: json['structure'] as String,
      activity: json['activity'] as String,
      status: json['status'] as String,
      dateOfSubmission: json['dateOfSubmission'] as String,
      work: json['work'] as String,
      element: json['element'] as String,
      assignedPersonClient: json['assignedPersonClient'] as String,
      nameOfRepresentative: json['nameOfRepresentative'] as String,
      createdBy: json['createdBy'] as String,
      approvalStatus: json['approvalStatus'] as String,
      totalQty: json['totalQty'] as String,
      contractorImages:
          (json['contractorImages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      clientImages:
          (json['clientImages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      contract: json['contract'] as String?,
      typeOfRFI: json['typeOfRFI'] as String?,
      rfiDescription: json['rfiDescription'] as String?,
      measurementType: json['measurementType'] as String?,
      validationStatus: json['validationStatus'] as String?,
      inspectionStatus: json['inspectionStatus'] as String?,
    );

Map<String, dynamic> _$$RfiListItemImplToJson(_$RfiListItemImpl instance) =>
    <String, dynamic>{
      'rfiId': instance.rfiId,
      'rfiNo': instance.rfiNo,
      'project': instance.project,
      'structure': instance.structure,
      'activity': instance.activity,
      'status': instance.status,
      'dateOfSubmission': instance.dateOfSubmission,
      'work': instance.work,
      'element': instance.element,
      'assignedPersonClient': instance.assignedPersonClient,
      'nameOfRepresentative': instance.nameOfRepresentative,
      'createdBy': instance.createdBy,
      'approvalStatus': instance.approvalStatus,
      'totalQty': instance.totalQty,
      'contractorImages': instance.contractorImages,
      'clientImages': instance.clientImages,
      'contract': instance.contract,
      'typeOfRFI': instance.typeOfRFI,
      'rfiDescription': instance.rfiDescription,
      'measurementType': instance.measurementType,
      'validationStatus': instance.validationStatus,
      'inspectionStatus': instance.inspectionStatus,
    };
