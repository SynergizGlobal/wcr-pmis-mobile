// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfi_inspection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RfiInspectionModelImpl _$$RfiInspectionModelImplFromJson(
  Map<String, dynamic> json,
) => _$RfiInspectionModelImpl(
  id: (json['id'] as num?)?.toInt(),
  rfiId: (json['rfiId'] as num?)?.toInt(),
  dateOfInspection: json['dateOfInspection'] as String?,
  timeOfInspection: json['timeOfInspection'] as String?,
  location: json['location'] as String?,
  chainage: json['chainage'] as String?,
  selfiePath: json['selfiePath'] as String?,
  siteImage: json['siteImage'] as String?,
  testSiteDocuments: json['testSiteDocuments'] as String?,
  project: json['project'] as String?,
  work: json['work'] as String?,
  contract: json['contract'] as String?,
  contractor: json['contractor'] as String?,
  activity: json['activity'] as String?,
  rfiDescription: json['rfiDescription'] as String?,
  description: json['description'] as String?,
  inspectionStatus: json['inspectionStatus'] as String?,
  testInsiteLab: json['testInsiteLab'] as String?,
  nameOfRepresentative: json['nameOfRepresentative'] as String?,
  engineerRemarks: json['engineerRemarks'] as String?,
  workStatus: json['workStatus'] as String?,
  uploadedBy: json['uploadedBy'] as String?,
  descriptionEnclosure: json['descriptionEnclosure'] as String?,
  measurements: json['measurements'] == null
      ? null
      : MeasurementModel.fromJson(json['measurements'] as Map<String, dynamic>),
  supportingDescriptions: json['supportingDescriptions'] as List<dynamic>?,
  supportingFiles: json['supportingFiles'] as List<dynamic>?,
  stringRfiId: json['stringRfiId'] as String?,
);

Map<String, dynamic> _$$RfiInspectionModelImplToJson(
  _$RfiInspectionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'rfiId': instance.rfiId,
  'dateOfInspection': instance.dateOfInspection,
  'timeOfInspection': instance.timeOfInspection,
  'location': instance.location,
  'chainage': instance.chainage,
  'selfiePath': instance.selfiePath,
  'siteImage': instance.siteImage,
  'testSiteDocuments': instance.testSiteDocuments,
  'project': instance.project,
  'work': instance.work,
  'contract': instance.contract,
  'contractor': instance.contractor,
  'activity': instance.activity,
  'rfiDescription': instance.rfiDescription,
  'description': instance.description,
  'inspectionStatus': instance.inspectionStatus,
  'testInsiteLab': instance.testInsiteLab,
  'nameOfRepresentative': instance.nameOfRepresentative,
  'engineerRemarks': instance.engineerRemarks,
  'workStatus': instance.workStatus,
  'uploadedBy': instance.uploadedBy,
  'descriptionEnclosure': instance.descriptionEnclosure,
  'measurements': instance.measurements,
  'supportingDescriptions': instance.supportingDescriptions,
  'supportingFiles': instance.supportingFiles,
  'stringRfiId': instance.stringRfiId,
};
