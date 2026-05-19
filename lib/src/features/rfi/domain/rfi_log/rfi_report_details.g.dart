// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfi_report_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RfiReportDetailsDataImpl _$$RfiReportDetailsDataImplFromJson(
  Map<String, dynamic> json,
) => _$RfiReportDetailsDataImpl(
  reportDetails: ReportDetailsInfo.fromJson(
    json['reportDetails'] as Map<String, dynamic>,
  ),
  checklistItems:
      (json['checklistItems'] as List<dynamic>?)
          ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  enclosures:
      (json['enclosures'] as List<dynamic>?)
          ?.map((e) => EnclosureInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  measurementDetails: json['measurementDetails'] == null
      ? null
      : MeasurementDetails.fromJson(
          json['measurementDetails'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$RfiReportDetailsDataImplToJson(
  _$RfiReportDetailsDataImpl instance,
) => <String, dynamic>{
  'reportDetails': instance.reportDetails,
  'checklistItems': instance.checklistItems,
  'enclosures': instance.enclosures,
  'measurementDetails': instance.measurementDetails,
};

_$ReportDetailsInfoImpl _$$ReportDetailsInfoImplFromJson(
  Map<String, dynamic> json,
) => _$ReportDetailsInfoImpl(
  project: json['project'] as String?,
  work: json['work'] as String?,
  contract: json['contract'] as String?,
  contractId: json['contractId'] as String?,
  structureType: json['structureType'] as String?,
  structure: json['structure'] as String?,
  component: json['component'] as String?,
  element: json['element'] as String?,
  activity: json['activity'] as String?,
  rfiDescription: json['rfiDescription'] as String?,
  action: json['action'] as String?,
  typeOfRfi: json['typeOfRfi'] as String?,
  contractorRepresentative: json['contractorRepresentative'] as String?,
  contractor: json['contractor'] as String?,
  enclosures: json['enclosures'] as String?,
  rfiId: json['rfiId'] as String?,
  rfiStatus: json['rfiStatus'] as String?,
  descriptionByContractor: json['descriptionByContractor'] as String?,
  dateOfCreation: json['dateOfCreation'] as String?,
  conInspDate: json['conInspDate'] as String?,
  proposedDateOfInspection: json['proposedDateOfInspection'] as String?,
  actualDateOfInspection: json['actualDateOfInspection'] as String?,
  proposedInspectionTime: json['proposedInspectionTime'] as String?,
  actualInspectionTime: json['actualInspectionTime'] as String?,
  dyHodUserId: json['dyHodUserId'] as String?,
  clientRepresentative: json['clientRepresentative'] as String?,
  clientDepartment: json['clientDepartment'] as String?,
  conLocation: json['conLocation'] as String?,
  clientLocation: json['clientLocation'] as String?,
  chainage: json['chainage'] as String?,
  validationStatus: json['validationStatus'] as String?,
  remarks: json['remarks'] as String?,
  validationComments: json['validationComments'] as String?,
  selfieClient: json['selfieClient'] as String?,
  selfieContractor: json['selfieContractor'] as String?,
  imagesUploadedByClient: json['imagesUploadedByClient'] as String?,
  imagesUploadedByContractor: json['imagesUploadedByContractor'] as String?,
  typeOfTest: json['typeOfTest'] as String?,
  testStatus: json['testStatus'] as String?,
  engineerRemarks: json['engineerRemarks'] as String?,
  testSiteDocumentsContractor: json['testSiteDocumentsContractor'] as String?,
  testResultContractor: json['testResultContractor'] as String?,
  testResultEngineer: json['testResultEngineer'] as String?,
  dyHodUserName: json['dyHodUserName'] as String?,
  conSupportFilePaths: json['conSupportFilePaths'] as String?,
  enggSupportFilePaths: json['enggSupportFilePaths'] as String?,
  attachmentData: json['attachmentData'] as String?,
  attachments: json['attachments'] as List<dynamic>? ?? const [],
);

Map<String, dynamic> _$$ReportDetailsInfoImplToJson(
  _$ReportDetailsInfoImpl instance,
) => <String, dynamic>{
  'project': instance.project,
  'work': instance.work,
  'contract': instance.contract,
  'contractId': instance.contractId,
  'structureType': instance.structureType,
  'structure': instance.structure,
  'component': instance.component,
  'element': instance.element,
  'activity': instance.activity,
  'rfiDescription': instance.rfiDescription,
  'action': instance.action,
  'typeOfRfi': instance.typeOfRfi,
  'contractorRepresentative': instance.contractorRepresentative,
  'contractor': instance.contractor,
  'enclosures': instance.enclosures,
  'rfiId': instance.rfiId,
  'rfiStatus': instance.rfiStatus,
  'descriptionByContractor': instance.descriptionByContractor,
  'dateOfCreation': instance.dateOfCreation,
  'conInspDate': instance.conInspDate,
  'proposedDateOfInspection': instance.proposedDateOfInspection,
  'actualDateOfInspection': instance.actualDateOfInspection,
  'proposedInspectionTime': instance.proposedInspectionTime,
  'actualInspectionTime': instance.actualInspectionTime,
  'dyHodUserId': instance.dyHodUserId,
  'clientRepresentative': instance.clientRepresentative,
  'clientDepartment': instance.clientDepartment,
  'conLocation': instance.conLocation,
  'clientLocation': instance.clientLocation,
  'chainage': instance.chainage,
  'validationStatus': instance.validationStatus,
  'remarks': instance.remarks,
  'validationComments': instance.validationComments,
  'selfieClient': instance.selfieClient,
  'selfieContractor': instance.selfieContractor,
  'imagesUploadedByClient': instance.imagesUploadedByClient,
  'imagesUploadedByContractor': instance.imagesUploadedByContractor,
  'typeOfTest': instance.typeOfTest,
  'testStatus': instance.testStatus,
  'engineerRemarks': instance.engineerRemarks,
  'testSiteDocumentsContractor': instance.testSiteDocumentsContractor,
  'testResultContractor': instance.testResultContractor,
  'testResultEngineer': instance.testResultEngineer,
  'dyHodUserName': instance.dyHodUserName,
  'conSupportFilePaths': instance.conSupportFilePaths,
  'enggSupportFilePaths': instance.enggSupportFilePaths,
  'attachmentData': instance.attachmentData,
  'attachments': instance.attachments,
};

_$ChecklistItemImpl _$$ChecklistItemImplFromJson(Map<String, dynamic> json) =>
    _$ChecklistItemImpl(
      enclosureName: json['enclosureName'] as String?,
      checklistDescription: json['checklistDescription'] as String?,
      contractorRemark: json['contractorRemark'] as String?,
      aeRemark: json['aeRemark'] as String?,
      conStatus: json['conStatus'] as String?,
      aeStatus: json['aeStatus'] as String?,
    );

Map<String, dynamic> _$$ChecklistItemImplToJson(_$ChecklistItemImpl instance) =>
    <String, dynamic>{
      'enclosureName': instance.enclosureName,
      'checklistDescription': instance.checklistDescription,
      'contractorRemark': instance.contractorRemark,
      'aeRemark': instance.aeRemark,
      'conStatus': instance.conStatus,
      'aeStatus': instance.aeStatus,
    };

_$EnclosureInfoImpl _$$EnclosureInfoImplFromJson(Map<String, dynamic> json) =>
    _$EnclosureInfoImpl(
      enclosureName: json['enclosureName'] as String?,
      file: json['file'] as String?,
    );

Map<String, dynamic> _$$EnclosureInfoImplToJson(_$EnclosureInfoImpl instance) =>
    <String, dynamic>{
      'enclosureName': instance.enclosureName,
      'file': instance.file,
    };

_$MeasurementDetailsImpl _$$MeasurementDetailsImplFromJson(
  Map<String, dynamic> json,
) => _$MeasurementDetailsImpl(
  measurementType: json['measurementType'] as String?,
  weight: json['weight'],
  totalQty: (json['totalQty'] as num?)?.toDouble(),
  b: json['b'],
  l: json['l'],
  h: json['h'],
  no: (json['no'] as num?)?.toInt(),
  units: json['units'] as String?,
);

Map<String, dynamic> _$$MeasurementDetailsImplToJson(
  _$MeasurementDetailsImpl instance,
) => <String, dynamic>{
  'measurementType': instance.measurementType,
  'weight': instance.weight,
  'totalQty': instance.totalQty,
  'b': instance.b,
  'l': instance.l,
  'h': instance.h,
  'no': instance.no,
  'units': instance.units,
};
