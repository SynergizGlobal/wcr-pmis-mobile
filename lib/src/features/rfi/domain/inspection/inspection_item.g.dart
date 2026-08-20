// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InspectionDetailImpl _$$InspectionDetailImplFromJson(
  Map<String, dynamic> json,
) => _$InspectionDetailImpl(
  id: (json['id'] as num?)?.toInt(),
  dateOfInspection: json['dateOfInspection'] as String?,
  timeOfInspection: json['timeOfInspection'] as String?,
  location: json['location'] as String?,
  inspectionStatus: json['inspectionStatus'] as String?,
  testInsiteLab: json['testInsiteLab'] as String?,
  uploadedBy: json['uploadedBy'] as String?,
  workStatus: json['workStatus'] as String?,
  chainage: json['chainage'] as String?,
  descriptionEnclosure: json['descriptionEnclosure'] as String?,
  selfiePath: json['selfiePath'] as String?,
  siteImage: json['siteImage'] as String?,
  testSiteDocuments: json['testSiteDocuments'] as String?,
  engineerRemarks: json['engineerRemarks'] as String?,
  postTestType: json['postTestType'] as String?,
  postTestReportPath: json['postTestReportPath'] as String?,
  supportingDocuments: json['supportingDocuments'] as String?,
  documentsDescription: json['documentsDescription'] as String?,
);

Map<String, dynamic> _$$InspectionDetailImplToJson(
  _$InspectionDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'dateOfInspection': instance.dateOfInspection,
  'timeOfInspection': instance.timeOfInspection,
  'location': instance.location,
  'inspectionStatus': instance.inspectionStatus,
  'testInsiteLab': instance.testInsiteLab,
  'uploadedBy': instance.uploadedBy,
  'workStatus': instance.workStatus,
  'chainage': instance.chainage,
  'descriptionEnclosure': instance.descriptionEnclosure,
  'selfiePath': instance.selfiePath,
  'siteImage': instance.siteImage,
  'testSiteDocuments': instance.testSiteDocuments,
  'engineerRemarks': instance.engineerRemarks,
  'postTestType': instance.postTestType,
  'postTestReportPath': instance.postTestReportPath,
  'supportingDocuments': instance.supportingDocuments,
  'documentsDescription': instance.documentsDescription,
};

_$EnclosureImpl _$$EnclosureImplFromJson(Map<String, dynamic> json) =>
    _$EnclosureImpl(
      id: (json['id'] as num?)?.toInt(),
      description: json['description'] as String?,
      enclosureName: json['enclosureName'] as String?,
      uploadedBy: json['uploadedBy'] as String?,
      locked: json['locked'] as bool?,
      enclosureUploadFile: json['enclosureUploadFile'] as String?,
    );

Map<String, dynamic> _$$EnclosureImplToJson(_$EnclosureImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'enclosureName': instance.enclosureName,
      'uploadedBy': instance.uploadedBy,
      'locked': instance.locked,
      'enclosureUploadFile': instance.enclosureUploadFile,
    };

_$MeasurementDetailImpl _$$MeasurementDetailImplFromJson(
  Map<String, dynamic> json,
) => _$MeasurementDetailImpl(
  id: (json['id'] as num?)?.toInt(),
  measurementType: json['measurementType'] as String?,
  length: (json['length'] as num?)?.toDouble(),
  breadth: (json['breadth'] as num?)?.toDouble(),
  height: (json['height'] as num?)?.toDouble(),
  weight: (json['weight'] as num?)?.toDouble(),
  units: json['units'] as String?,
  noOfItems: (json['noOfItems'] as num?)?.toInt(),
  totalQty: (json['totalQty'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$MeasurementDetailImplToJson(
  _$MeasurementDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'measurementType': instance.measurementType,
  'length': instance.length,
  'breadth': instance.breadth,
  'height': instance.height,
  'weight': instance.weight,
  'units': instance.units,
  'noOfItems': instance.noOfItems,
  'totalQty': instance.totalQty,
};

_$InspectionItemImpl _$$InspectionItemImplFromJson(Map<String, dynamic> json) =>
    _$InspectionItemImpl(
      id: (json['id'] as num).toInt(),
      element: json['element'] as String?,
      status: json['status'] as String?,
      imgClient: json['imgClient'] as String?,
      contractId: json['contractId'] as String?,
      contract: json['contract'] as String?,
      structure: json['structure'] as String?,
      assignedPersonClient: json['assignedPersonClient'] as String?,
      action: json['action'] as String?,
      rfiId: json['rfi_Id'] as String?,
      activity: json['activity'] as String?,
      rfiDescription: json['rfiDescription'] as String?,
      description: json['description'] as String?,
      timeOfInspection: json['timeOfInspection'] as String?,
      nameOfRepresentative: json['nameOfRepresentative'] as String?,
      inspectionStatus: json['inspectionStatus'] as String?,
      measurementType: json['measurementType'] as String?,
      totalQty: (json['totalQty'] as num?)?.toDouble(),
      createdBy: json['createdBy'] as String?,
      dateOfInspection: json['dateOfInspection'] as String?,
      project: json['project'] as String?,
      work: json['work'] as String?,
      structureType: json['structureType'] as String?,
      component: json['component'] as String?,
      typeOfRFI: json['typeOfRFI'] as String?,
      approvalStatus: json['approvalStatus'] as String?,
      dateOfSubmission: json['dateOfSubmission'] as String?,
      contractorSubmittedOn: json['contractorSubmittedOn'] as String?,
      engineerSubmittedOn: json['engineerSubmittedOn'] as String?,
      validationStatus: json['validationStatus'] as String?,
      validationRemarks: json['remarks'] as String?,
      validationComments: json['validationComments'] as String?,
      validationAuthor: json['valdationAuth'] as String?,
      validationDate: json['validationDate'] as String?,
      imgContractor: json['imgContractor'] as String?,
      representativeReportingToContractor:
          json['representativeReportingToContractor'] as String?,
      testResCon: json['testResCon'] as String?,
      testResEngg: json['testResEngg'] as String?,
      enclosuresList: (json['enclosuresList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      enclosure: (json['enclosure'] as List<dynamic>?)
          ?.map((e) => Enclosure.fromJson(e as Map<String, dynamic>))
          .toList(),
      inspectionDetails: (json['inspectionDetails'] as List<dynamic>?)
          ?.map((e) => InspectionDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      measurements: json['measurements'] == null
          ? null
          : MeasurementDetail.fromJson(
              json['measurements'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$InspectionItemImplToJson(
  _$InspectionItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'element': instance.element,
  'status': instance.status,
  'imgClient': instance.imgClient,
  'contractId': instance.contractId,
  'contract': instance.contract,
  'structure': instance.structure,
  'assignedPersonClient': instance.assignedPersonClient,
  'action': instance.action,
  'rfi_Id': instance.rfiId,
  'activity': instance.activity,
  'rfiDescription': instance.rfiDescription,
  'description': instance.description,
  'timeOfInspection': instance.timeOfInspection,
  'nameOfRepresentative': instance.nameOfRepresentative,
  'inspectionStatus': instance.inspectionStatus,
  'measurementType': instance.measurementType,
  'totalQty': instance.totalQty,
  'createdBy': instance.createdBy,
  'dateOfInspection': instance.dateOfInspection,
  'project': instance.project,
  'work': instance.work,
  'structureType': instance.structureType,
  'component': instance.component,
  'typeOfRFI': instance.typeOfRFI,
  'approvalStatus': instance.approvalStatus,
  'dateOfSubmission': instance.dateOfSubmission,
  'contractorSubmittedOn': instance.contractorSubmittedOn,
  'engineerSubmittedOn': instance.engineerSubmittedOn,
  'validationStatus': instance.validationStatus,
  'remarks': instance.validationRemarks,
  'validationComments': instance.validationComments,
  'valdationAuth': instance.validationAuthor,
  'validationDate': instance.validationDate,
  'imgContractor': instance.imgContractor,
  'representativeReportingToContractor':
      instance.representativeReportingToContractor,
  'testResCon': instance.testResCon,
  'testResEngg': instance.testResEngg,
  'enclosuresList': instance.enclosuresList,
  'enclosure': instance.enclosure,
  'inspectionDetails': instance.inspectionDetails,
  'measurements': instance.measurements,
};
