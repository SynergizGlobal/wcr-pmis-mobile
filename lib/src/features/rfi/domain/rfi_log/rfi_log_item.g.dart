// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfi_log_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RfiLogItemImpl _$$RfiLogItemImplFromJson(Map<String, dynamic> json) =>
    _$RfiLogItemImpl(
      id: (json['id'] as num).toInt(),
      rfiId: json['rfiId'] as String,
      dateOfSubmission: json['dateOfSubmission'] as String,
      structure: json['structure'] as String,
      rfiDescription: json['rfiDescription'] as String,
      rfiRequestedBy: json['rfiRequestedBy'] as String,
      department: json['department'] as String,
      person: json['person'] as String,
      dateRaised: json['dateRaised'] as String,
      dateResponded: json['dateResponded'] as String?,
      dateRespondedContractor: json['dateRespondedContractor'] as String?,
      dateRespondedEngineer: json['dateRespondedEngineer'] as String?,
      enggApproval: json['enggApproval'] as String?,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      validationStatus: json['validationStatus'] as String?,
      project: json['project'] as String,
      projectId: json['projectId'] as String?,
      work: json['work'] as String,
      contract: json['contract'] as String,
      contractId: json['contractId'] as String?,
      nameOfRepresentative: json['nameOfRepresentative'] as String,
      txnId: json['txnId'] as String?,
      estatus: json['estatus'] as String?,
    );

Map<String, dynamic> _$$RfiLogItemImplToJson(_$RfiLogItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rfiId': instance.rfiId,
      'dateOfSubmission': instance.dateOfSubmission,
      'structure': instance.structure,
      'rfiDescription': instance.rfiDescription,
      'rfiRequestedBy': instance.rfiRequestedBy,
      'department': instance.department,
      'person': instance.person,
      'dateRaised': instance.dateRaised,
      'dateResponded': instance.dateResponded,
      'dateRespondedContractor': instance.dateRespondedContractor,
      'dateRespondedEngineer': instance.dateRespondedEngineer,
      'enggApproval': instance.enggApproval,
      'status': instance.status,
      'notes': instance.notes,
      'validationStatus': instance.validationStatus,
      'project': instance.project,
      'projectId': instance.projectId,
      'work': instance.work,
      'contract': instance.contract,
      'contractId': instance.contractId,
      'nameOfRepresentative': instance.nameOfRepresentative,
      'txnId': instance.txnId,
      'estatus': instance.estatus,
    };
