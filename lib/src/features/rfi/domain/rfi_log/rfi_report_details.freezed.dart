// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rfi_report_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RfiReportDetailsData _$RfiReportDetailsDataFromJson(Map<String, dynamic> json) {
  return _RfiReportDetailsData.fromJson(json);
}

/// @nodoc
mixin _$RfiReportDetailsData {
  ReportDetailsInfo get reportDetails => throw _privateConstructorUsedError;
  List<ChecklistItem> get checklistItems => throw _privateConstructorUsedError;
  List<EnclosureInfo> get enclosures => throw _privateConstructorUsedError;
  MeasurementDetails? get measurementDetails =>
      throw _privateConstructorUsedError;

  /// Serializes this RfiReportDetailsData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RfiReportDetailsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RfiReportDetailsDataCopyWith<RfiReportDetailsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RfiReportDetailsDataCopyWith<$Res> {
  factory $RfiReportDetailsDataCopyWith(
    RfiReportDetailsData value,
    $Res Function(RfiReportDetailsData) then,
  ) = _$RfiReportDetailsDataCopyWithImpl<$Res, RfiReportDetailsData>;
  @useResult
  $Res call({
    ReportDetailsInfo reportDetails,
    List<ChecklistItem> checklistItems,
    List<EnclosureInfo> enclosures,
    MeasurementDetails? measurementDetails,
  });

  $ReportDetailsInfoCopyWith<$Res> get reportDetails;
  $MeasurementDetailsCopyWith<$Res>? get measurementDetails;
}

/// @nodoc
class _$RfiReportDetailsDataCopyWithImpl<
  $Res,
  $Val extends RfiReportDetailsData
>
    implements $RfiReportDetailsDataCopyWith<$Res> {
  _$RfiReportDetailsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RfiReportDetailsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reportDetails = null,
    Object? checklistItems = null,
    Object? enclosures = null,
    Object? measurementDetails = freezed,
  }) {
    return _then(
      _value.copyWith(
            reportDetails: null == reportDetails
                ? _value.reportDetails
                : reportDetails // ignore: cast_nullable_to_non_nullable
                      as ReportDetailsInfo,
            checklistItems: null == checklistItems
                ? _value.checklistItems
                : checklistItems // ignore: cast_nullable_to_non_nullable
                      as List<ChecklistItem>,
            enclosures: null == enclosures
                ? _value.enclosures
                : enclosures // ignore: cast_nullable_to_non_nullable
                      as List<EnclosureInfo>,
            measurementDetails: freezed == measurementDetails
                ? _value.measurementDetails
                : measurementDetails // ignore: cast_nullable_to_non_nullable
                      as MeasurementDetails?,
          )
          as $Val,
    );
  }

  /// Create a copy of RfiReportDetailsData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReportDetailsInfoCopyWith<$Res> get reportDetails {
    return $ReportDetailsInfoCopyWith<$Res>(_value.reportDetails, (value) {
      return _then(_value.copyWith(reportDetails: value) as $Val);
    });
  }

  /// Create a copy of RfiReportDetailsData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MeasurementDetailsCopyWith<$Res>? get measurementDetails {
    if (_value.measurementDetails == null) {
      return null;
    }

    return $MeasurementDetailsCopyWith<$Res>(_value.measurementDetails!, (
      value,
    ) {
      return _then(_value.copyWith(measurementDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RfiReportDetailsDataImplCopyWith<$Res>
    implements $RfiReportDetailsDataCopyWith<$Res> {
  factory _$$RfiReportDetailsDataImplCopyWith(
    _$RfiReportDetailsDataImpl value,
    $Res Function(_$RfiReportDetailsDataImpl) then,
  ) = __$$RfiReportDetailsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ReportDetailsInfo reportDetails,
    List<ChecklistItem> checklistItems,
    List<EnclosureInfo> enclosures,
    MeasurementDetails? measurementDetails,
  });

  @override
  $ReportDetailsInfoCopyWith<$Res> get reportDetails;
  @override
  $MeasurementDetailsCopyWith<$Res>? get measurementDetails;
}

/// @nodoc
class __$$RfiReportDetailsDataImplCopyWithImpl<$Res>
    extends _$RfiReportDetailsDataCopyWithImpl<$Res, _$RfiReportDetailsDataImpl>
    implements _$$RfiReportDetailsDataImplCopyWith<$Res> {
  __$$RfiReportDetailsDataImplCopyWithImpl(
    _$RfiReportDetailsDataImpl _value,
    $Res Function(_$RfiReportDetailsDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RfiReportDetailsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reportDetails = null,
    Object? checklistItems = null,
    Object? enclosures = null,
    Object? measurementDetails = freezed,
  }) {
    return _then(
      _$RfiReportDetailsDataImpl(
        reportDetails: null == reportDetails
            ? _value.reportDetails
            : reportDetails // ignore: cast_nullable_to_non_nullable
                  as ReportDetailsInfo,
        checklistItems: null == checklistItems
            ? _value._checklistItems
            : checklistItems // ignore: cast_nullable_to_non_nullable
                  as List<ChecklistItem>,
        enclosures: null == enclosures
            ? _value._enclosures
            : enclosures // ignore: cast_nullable_to_non_nullable
                  as List<EnclosureInfo>,
        measurementDetails: freezed == measurementDetails
            ? _value.measurementDetails
            : measurementDetails // ignore: cast_nullable_to_non_nullable
                  as MeasurementDetails?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RfiReportDetailsDataImpl implements _RfiReportDetailsData {
  const _$RfiReportDetailsDataImpl({
    required this.reportDetails,
    final List<ChecklistItem> checklistItems = const [],
    final List<EnclosureInfo> enclosures = const [],
    this.measurementDetails,
  }) : _checklistItems = checklistItems,
       _enclosures = enclosures;

  factory _$RfiReportDetailsDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$RfiReportDetailsDataImplFromJson(json);

  @override
  final ReportDetailsInfo reportDetails;
  final List<ChecklistItem> _checklistItems;
  @override
  @JsonKey()
  List<ChecklistItem> get checklistItems {
    if (_checklistItems is EqualUnmodifiableListView) return _checklistItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_checklistItems);
  }

  final List<EnclosureInfo> _enclosures;
  @override
  @JsonKey()
  List<EnclosureInfo> get enclosures {
    if (_enclosures is EqualUnmodifiableListView) return _enclosures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_enclosures);
  }

  @override
  final MeasurementDetails? measurementDetails;

  @override
  String toString() {
    return 'RfiReportDetailsData(reportDetails: $reportDetails, checklistItems: $checklistItems, enclosures: $enclosures, measurementDetails: $measurementDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RfiReportDetailsDataImpl &&
            (identical(other.reportDetails, reportDetails) ||
                other.reportDetails == reportDetails) &&
            const DeepCollectionEquality().equals(
              other._checklistItems,
              _checklistItems,
            ) &&
            const DeepCollectionEquality().equals(
              other._enclosures,
              _enclosures,
            ) &&
            (identical(other.measurementDetails, measurementDetails) ||
                other.measurementDetails == measurementDetails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    reportDetails,
    const DeepCollectionEquality().hash(_checklistItems),
    const DeepCollectionEquality().hash(_enclosures),
    measurementDetails,
  );

  /// Create a copy of RfiReportDetailsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RfiReportDetailsDataImplCopyWith<_$RfiReportDetailsDataImpl>
  get copyWith =>
      __$$RfiReportDetailsDataImplCopyWithImpl<_$RfiReportDetailsDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RfiReportDetailsDataImplToJson(this);
  }
}

abstract class _RfiReportDetailsData implements RfiReportDetailsData {
  const factory _RfiReportDetailsData({
    required final ReportDetailsInfo reportDetails,
    final List<ChecklistItem> checklistItems,
    final List<EnclosureInfo> enclosures,
    final MeasurementDetails? measurementDetails,
  }) = _$RfiReportDetailsDataImpl;

  factory _RfiReportDetailsData.fromJson(Map<String, dynamic> json) =
      _$RfiReportDetailsDataImpl.fromJson;

  @override
  ReportDetailsInfo get reportDetails;
  @override
  List<ChecklistItem> get checklistItems;
  @override
  List<EnclosureInfo> get enclosures;
  @override
  MeasurementDetails? get measurementDetails;

  /// Create a copy of RfiReportDetailsData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RfiReportDetailsDataImplCopyWith<_$RfiReportDetailsDataImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ReportDetailsInfo _$ReportDetailsInfoFromJson(Map<String, dynamic> json) {
  return _ReportDetailsInfo.fromJson(json);
}

/// @nodoc
mixin _$ReportDetailsInfo {
  String? get project => throw _privateConstructorUsedError;
  String? get work => throw _privateConstructorUsedError;
  String? get contract => throw _privateConstructorUsedError;
  String? get contractId => throw _privateConstructorUsedError;
  String? get structureType => throw _privateConstructorUsedError;
  String? get structure => throw _privateConstructorUsedError;
  String? get component => throw _privateConstructorUsedError;
  String? get element => throw _privateConstructorUsedError;
  String? get activity => throw _privateConstructorUsedError;
  String? get rfiDescription => throw _privateConstructorUsedError;
  String? get action => throw _privateConstructorUsedError;
  String? get typeOfRfi => throw _privateConstructorUsedError;
  String? get contractorRepresentative => throw _privateConstructorUsedError;
  String? get contractor => throw _privateConstructorUsedError;
  String? get enclosures => throw _privateConstructorUsedError;
  String? get rfiId => throw _privateConstructorUsedError;
  String? get rfiStatus => throw _privateConstructorUsedError;
  String? get descriptionByContractor => throw _privateConstructorUsedError;
  String? get dateOfCreation => throw _privateConstructorUsedError;
  String? get conInspDate => throw _privateConstructorUsedError;
  String? get proposedDateOfInspection => throw _privateConstructorUsedError;
  String? get actualDateOfInspection => throw _privateConstructorUsedError;
  String? get proposedInspectionTime => throw _privateConstructorUsedError;
  String? get actualInspectionTime => throw _privateConstructorUsedError;
  String? get dyHodUserId => throw _privateConstructorUsedError;
  String? get clientRepresentative => throw _privateConstructorUsedError;
  String? get clientDepartment => throw _privateConstructorUsedError;
  String? get conLocation => throw _privateConstructorUsedError;
  String? get clientLocation => throw _privateConstructorUsedError;
  String? get chainage => throw _privateConstructorUsedError;
  String? get validationStatus => throw _privateConstructorUsedError;
  String? get remarks => throw _privateConstructorUsedError;
  String? get validationComments => throw _privateConstructorUsedError;
  String? get selfieClient => throw _privateConstructorUsedError;
  String? get selfieContractor => throw _privateConstructorUsedError;
  String? get imagesUploadedByClient => throw _privateConstructorUsedError;
  String? get imagesUploadedByContractor => throw _privateConstructorUsedError;
  String? get typeOfTest => throw _privateConstructorUsedError;
  String? get testStatus => throw _privateConstructorUsedError;
  String? get engineerRemarks => throw _privateConstructorUsedError;
  String? get testSiteDocumentsContractor => throw _privateConstructorUsedError;
  String? get testResultContractor => throw _privateConstructorUsedError;
  String? get testResultEngineer => throw _privateConstructorUsedError;
  String? get dyHodUserName => throw _privateConstructorUsedError;
  String? get conSupportFilePaths => throw _privateConstructorUsedError;
  String? get enggSupportFilePaths => throw _privateConstructorUsedError;
  String? get attachmentData => throw _privateConstructorUsedError;
  List<dynamic> get attachments => throw _privateConstructorUsedError;

  /// Serializes this ReportDetailsInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportDetailsInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportDetailsInfoCopyWith<ReportDetailsInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportDetailsInfoCopyWith<$Res> {
  factory $ReportDetailsInfoCopyWith(
    ReportDetailsInfo value,
    $Res Function(ReportDetailsInfo) then,
  ) = _$ReportDetailsInfoCopyWithImpl<$Res, ReportDetailsInfo>;
  @useResult
  $Res call({
    String? project,
    String? work,
    String? contract,
    String? contractId,
    String? structureType,
    String? structure,
    String? component,
    String? element,
    String? activity,
    String? rfiDescription,
    String? action,
    String? typeOfRfi,
    String? contractorRepresentative,
    String? contractor,
    String? enclosures,
    String? rfiId,
    String? rfiStatus,
    String? descriptionByContractor,
    String? dateOfCreation,
    String? conInspDate,
    String? proposedDateOfInspection,
    String? actualDateOfInspection,
    String? proposedInspectionTime,
    String? actualInspectionTime,
    String? dyHodUserId,
    String? clientRepresentative,
    String? clientDepartment,
    String? conLocation,
    String? clientLocation,
    String? chainage,
    String? validationStatus,
    String? remarks,
    String? validationComments,
    String? selfieClient,
    String? selfieContractor,
    String? imagesUploadedByClient,
    String? imagesUploadedByContractor,
    String? typeOfTest,
    String? testStatus,
    String? engineerRemarks,
    String? testSiteDocumentsContractor,
    String? testResultContractor,
    String? testResultEngineer,
    String? dyHodUserName,
    String? conSupportFilePaths,
    String? enggSupportFilePaths,
    String? attachmentData,
    List<dynamic> attachments,
  });
}

/// @nodoc
class _$ReportDetailsInfoCopyWithImpl<$Res, $Val extends ReportDetailsInfo>
    implements $ReportDetailsInfoCopyWith<$Res> {
  _$ReportDetailsInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportDetailsInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? project = freezed,
    Object? work = freezed,
    Object? contract = freezed,
    Object? contractId = freezed,
    Object? structureType = freezed,
    Object? structure = freezed,
    Object? component = freezed,
    Object? element = freezed,
    Object? activity = freezed,
    Object? rfiDescription = freezed,
    Object? action = freezed,
    Object? typeOfRfi = freezed,
    Object? contractorRepresentative = freezed,
    Object? contractor = freezed,
    Object? enclosures = freezed,
    Object? rfiId = freezed,
    Object? rfiStatus = freezed,
    Object? descriptionByContractor = freezed,
    Object? dateOfCreation = freezed,
    Object? conInspDate = freezed,
    Object? proposedDateOfInspection = freezed,
    Object? actualDateOfInspection = freezed,
    Object? proposedInspectionTime = freezed,
    Object? actualInspectionTime = freezed,
    Object? dyHodUserId = freezed,
    Object? clientRepresentative = freezed,
    Object? clientDepartment = freezed,
    Object? conLocation = freezed,
    Object? clientLocation = freezed,
    Object? chainage = freezed,
    Object? validationStatus = freezed,
    Object? remarks = freezed,
    Object? validationComments = freezed,
    Object? selfieClient = freezed,
    Object? selfieContractor = freezed,
    Object? imagesUploadedByClient = freezed,
    Object? imagesUploadedByContractor = freezed,
    Object? typeOfTest = freezed,
    Object? testStatus = freezed,
    Object? engineerRemarks = freezed,
    Object? testSiteDocumentsContractor = freezed,
    Object? testResultContractor = freezed,
    Object? testResultEngineer = freezed,
    Object? dyHodUserName = freezed,
    Object? conSupportFilePaths = freezed,
    Object? enggSupportFilePaths = freezed,
    Object? attachmentData = freezed,
    Object? attachments = null,
  }) {
    return _then(
      _value.copyWith(
            project: freezed == project
                ? _value.project
                : project // ignore: cast_nullable_to_non_nullable
                      as String?,
            work: freezed == work
                ? _value.work
                : work // ignore: cast_nullable_to_non_nullable
                      as String?,
            contract: freezed == contract
                ? _value.contract
                : contract // ignore: cast_nullable_to_non_nullable
                      as String?,
            contractId: freezed == contractId
                ? _value.contractId
                : contractId // ignore: cast_nullable_to_non_nullable
                      as String?,
            structureType: freezed == structureType
                ? _value.structureType
                : structureType // ignore: cast_nullable_to_non_nullable
                      as String?,
            structure: freezed == structure
                ? _value.structure
                : structure // ignore: cast_nullable_to_non_nullable
                      as String?,
            component: freezed == component
                ? _value.component
                : component // ignore: cast_nullable_to_non_nullable
                      as String?,
            element: freezed == element
                ? _value.element
                : element // ignore: cast_nullable_to_non_nullable
                      as String?,
            activity: freezed == activity
                ? _value.activity
                : activity // ignore: cast_nullable_to_non_nullable
                      as String?,
            rfiDescription: freezed == rfiDescription
                ? _value.rfiDescription
                : rfiDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            action: freezed == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String?,
            typeOfRfi: freezed == typeOfRfi
                ? _value.typeOfRfi
                : typeOfRfi // ignore: cast_nullable_to_non_nullable
                      as String?,
            contractorRepresentative: freezed == contractorRepresentative
                ? _value.contractorRepresentative
                : contractorRepresentative // ignore: cast_nullable_to_non_nullable
                      as String?,
            contractor: freezed == contractor
                ? _value.contractor
                : contractor // ignore: cast_nullable_to_non_nullable
                      as String?,
            enclosures: freezed == enclosures
                ? _value.enclosures
                : enclosures // ignore: cast_nullable_to_non_nullable
                      as String?,
            rfiId: freezed == rfiId
                ? _value.rfiId
                : rfiId // ignore: cast_nullable_to_non_nullable
                      as String?,
            rfiStatus: freezed == rfiStatus
                ? _value.rfiStatus
                : rfiStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            descriptionByContractor: freezed == descriptionByContractor
                ? _value.descriptionByContractor
                : descriptionByContractor // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateOfCreation: freezed == dateOfCreation
                ? _value.dateOfCreation
                : dateOfCreation // ignore: cast_nullable_to_non_nullable
                      as String?,
            conInspDate: freezed == conInspDate
                ? _value.conInspDate
                : conInspDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            proposedDateOfInspection: freezed == proposedDateOfInspection
                ? _value.proposedDateOfInspection
                : proposedDateOfInspection // ignore: cast_nullable_to_non_nullable
                      as String?,
            actualDateOfInspection: freezed == actualDateOfInspection
                ? _value.actualDateOfInspection
                : actualDateOfInspection // ignore: cast_nullable_to_non_nullable
                      as String?,
            proposedInspectionTime: freezed == proposedInspectionTime
                ? _value.proposedInspectionTime
                : proposedInspectionTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            actualInspectionTime: freezed == actualInspectionTime
                ? _value.actualInspectionTime
                : actualInspectionTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            dyHodUserId: freezed == dyHodUserId
                ? _value.dyHodUserId
                : dyHodUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            clientRepresentative: freezed == clientRepresentative
                ? _value.clientRepresentative
                : clientRepresentative // ignore: cast_nullable_to_non_nullable
                      as String?,
            clientDepartment: freezed == clientDepartment
                ? _value.clientDepartment
                : clientDepartment // ignore: cast_nullable_to_non_nullable
                      as String?,
            conLocation: freezed == conLocation
                ? _value.conLocation
                : conLocation // ignore: cast_nullable_to_non_nullable
                      as String?,
            clientLocation: freezed == clientLocation
                ? _value.clientLocation
                : clientLocation // ignore: cast_nullable_to_non_nullable
                      as String?,
            chainage: freezed == chainage
                ? _value.chainage
                : chainage // ignore: cast_nullable_to_non_nullable
                      as String?,
            validationStatus: freezed == validationStatus
                ? _value.validationStatus
                : validationStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            remarks: freezed == remarks
                ? _value.remarks
                : remarks // ignore: cast_nullable_to_non_nullable
                      as String?,
            validationComments: freezed == validationComments
                ? _value.validationComments
                : validationComments // ignore: cast_nullable_to_non_nullable
                      as String?,
            selfieClient: freezed == selfieClient
                ? _value.selfieClient
                : selfieClient // ignore: cast_nullable_to_non_nullable
                      as String?,
            selfieContractor: freezed == selfieContractor
                ? _value.selfieContractor
                : selfieContractor // ignore: cast_nullable_to_non_nullable
                      as String?,
            imagesUploadedByClient: freezed == imagesUploadedByClient
                ? _value.imagesUploadedByClient
                : imagesUploadedByClient // ignore: cast_nullable_to_non_nullable
                      as String?,
            imagesUploadedByContractor: freezed == imagesUploadedByContractor
                ? _value.imagesUploadedByContractor
                : imagesUploadedByContractor // ignore: cast_nullable_to_non_nullable
                      as String?,
            typeOfTest: freezed == typeOfTest
                ? _value.typeOfTest
                : typeOfTest // ignore: cast_nullable_to_non_nullable
                      as String?,
            testStatus: freezed == testStatus
                ? _value.testStatus
                : testStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            engineerRemarks: freezed == engineerRemarks
                ? _value.engineerRemarks
                : engineerRemarks // ignore: cast_nullable_to_non_nullable
                      as String?,
            testSiteDocumentsContractor: freezed == testSiteDocumentsContractor
                ? _value.testSiteDocumentsContractor
                : testSiteDocumentsContractor // ignore: cast_nullable_to_non_nullable
                      as String?,
            testResultContractor: freezed == testResultContractor
                ? _value.testResultContractor
                : testResultContractor // ignore: cast_nullable_to_non_nullable
                      as String?,
            testResultEngineer: freezed == testResultEngineer
                ? _value.testResultEngineer
                : testResultEngineer // ignore: cast_nullable_to_non_nullable
                      as String?,
            dyHodUserName: freezed == dyHodUserName
                ? _value.dyHodUserName
                : dyHodUserName // ignore: cast_nullable_to_non_nullable
                      as String?,
            conSupportFilePaths: freezed == conSupportFilePaths
                ? _value.conSupportFilePaths
                : conSupportFilePaths // ignore: cast_nullable_to_non_nullable
                      as String?,
            enggSupportFilePaths: freezed == enggSupportFilePaths
                ? _value.enggSupportFilePaths
                : enggSupportFilePaths // ignore: cast_nullable_to_non_nullable
                      as String?,
            attachmentData: freezed == attachmentData
                ? _value.attachmentData
                : attachmentData // ignore: cast_nullable_to_non_nullable
                      as String?,
            attachments: null == attachments
                ? _value.attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReportDetailsInfoImplCopyWith<$Res>
    implements $ReportDetailsInfoCopyWith<$Res> {
  factory _$$ReportDetailsInfoImplCopyWith(
    _$ReportDetailsInfoImpl value,
    $Res Function(_$ReportDetailsInfoImpl) then,
  ) = __$$ReportDetailsInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? project,
    String? work,
    String? contract,
    String? contractId,
    String? structureType,
    String? structure,
    String? component,
    String? element,
    String? activity,
    String? rfiDescription,
    String? action,
    String? typeOfRfi,
    String? contractorRepresentative,
    String? contractor,
    String? enclosures,
    String? rfiId,
    String? rfiStatus,
    String? descriptionByContractor,
    String? dateOfCreation,
    String? conInspDate,
    String? proposedDateOfInspection,
    String? actualDateOfInspection,
    String? proposedInspectionTime,
    String? actualInspectionTime,
    String? dyHodUserId,
    String? clientRepresentative,
    String? clientDepartment,
    String? conLocation,
    String? clientLocation,
    String? chainage,
    String? validationStatus,
    String? remarks,
    String? validationComments,
    String? selfieClient,
    String? selfieContractor,
    String? imagesUploadedByClient,
    String? imagesUploadedByContractor,
    String? typeOfTest,
    String? testStatus,
    String? engineerRemarks,
    String? testSiteDocumentsContractor,
    String? testResultContractor,
    String? testResultEngineer,
    String? dyHodUserName,
    String? conSupportFilePaths,
    String? enggSupportFilePaths,
    String? attachmentData,
    List<dynamic> attachments,
  });
}

/// @nodoc
class __$$ReportDetailsInfoImplCopyWithImpl<$Res>
    extends _$ReportDetailsInfoCopyWithImpl<$Res, _$ReportDetailsInfoImpl>
    implements _$$ReportDetailsInfoImplCopyWith<$Res> {
  __$$ReportDetailsInfoImplCopyWithImpl(
    _$ReportDetailsInfoImpl _value,
    $Res Function(_$ReportDetailsInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReportDetailsInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? project = freezed,
    Object? work = freezed,
    Object? contract = freezed,
    Object? contractId = freezed,
    Object? structureType = freezed,
    Object? structure = freezed,
    Object? component = freezed,
    Object? element = freezed,
    Object? activity = freezed,
    Object? rfiDescription = freezed,
    Object? action = freezed,
    Object? typeOfRfi = freezed,
    Object? contractorRepresentative = freezed,
    Object? contractor = freezed,
    Object? enclosures = freezed,
    Object? rfiId = freezed,
    Object? rfiStatus = freezed,
    Object? descriptionByContractor = freezed,
    Object? dateOfCreation = freezed,
    Object? conInspDate = freezed,
    Object? proposedDateOfInspection = freezed,
    Object? actualDateOfInspection = freezed,
    Object? proposedInspectionTime = freezed,
    Object? actualInspectionTime = freezed,
    Object? dyHodUserId = freezed,
    Object? clientRepresentative = freezed,
    Object? clientDepartment = freezed,
    Object? conLocation = freezed,
    Object? clientLocation = freezed,
    Object? chainage = freezed,
    Object? validationStatus = freezed,
    Object? remarks = freezed,
    Object? validationComments = freezed,
    Object? selfieClient = freezed,
    Object? selfieContractor = freezed,
    Object? imagesUploadedByClient = freezed,
    Object? imagesUploadedByContractor = freezed,
    Object? typeOfTest = freezed,
    Object? testStatus = freezed,
    Object? engineerRemarks = freezed,
    Object? testSiteDocumentsContractor = freezed,
    Object? testResultContractor = freezed,
    Object? testResultEngineer = freezed,
    Object? dyHodUserName = freezed,
    Object? conSupportFilePaths = freezed,
    Object? enggSupportFilePaths = freezed,
    Object? attachmentData = freezed,
    Object? attachments = null,
  }) {
    return _then(
      _$ReportDetailsInfoImpl(
        project: freezed == project
            ? _value.project
            : project // ignore: cast_nullable_to_non_nullable
                  as String?,
        work: freezed == work
            ? _value.work
            : work // ignore: cast_nullable_to_non_nullable
                  as String?,
        contract: freezed == contract
            ? _value.contract
            : contract // ignore: cast_nullable_to_non_nullable
                  as String?,
        contractId: freezed == contractId
            ? _value.contractId
            : contractId // ignore: cast_nullable_to_non_nullable
                  as String?,
        structureType: freezed == structureType
            ? _value.structureType
            : structureType // ignore: cast_nullable_to_non_nullable
                  as String?,
        structure: freezed == structure
            ? _value.structure
            : structure // ignore: cast_nullable_to_non_nullable
                  as String?,
        component: freezed == component
            ? _value.component
            : component // ignore: cast_nullable_to_non_nullable
                  as String?,
        element: freezed == element
            ? _value.element
            : element // ignore: cast_nullable_to_non_nullable
                  as String?,
        activity: freezed == activity
            ? _value.activity
            : activity // ignore: cast_nullable_to_non_nullable
                  as String?,
        rfiDescription: freezed == rfiDescription
            ? _value.rfiDescription
            : rfiDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        action: freezed == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String?,
        typeOfRfi: freezed == typeOfRfi
            ? _value.typeOfRfi
            : typeOfRfi // ignore: cast_nullable_to_non_nullable
                  as String?,
        contractorRepresentative: freezed == contractorRepresentative
            ? _value.contractorRepresentative
            : contractorRepresentative // ignore: cast_nullable_to_non_nullable
                  as String?,
        contractor: freezed == contractor
            ? _value.contractor
            : contractor // ignore: cast_nullable_to_non_nullable
                  as String?,
        enclosures: freezed == enclosures
            ? _value.enclosures
            : enclosures // ignore: cast_nullable_to_non_nullable
                  as String?,
        rfiId: freezed == rfiId
            ? _value.rfiId
            : rfiId // ignore: cast_nullable_to_non_nullable
                  as String?,
        rfiStatus: freezed == rfiStatus
            ? _value.rfiStatus
            : rfiStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        descriptionByContractor: freezed == descriptionByContractor
            ? _value.descriptionByContractor
            : descriptionByContractor // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateOfCreation: freezed == dateOfCreation
            ? _value.dateOfCreation
            : dateOfCreation // ignore: cast_nullable_to_non_nullable
                  as String?,
        conInspDate: freezed == conInspDate
            ? _value.conInspDate
            : conInspDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        proposedDateOfInspection: freezed == proposedDateOfInspection
            ? _value.proposedDateOfInspection
            : proposedDateOfInspection // ignore: cast_nullable_to_non_nullable
                  as String?,
        actualDateOfInspection: freezed == actualDateOfInspection
            ? _value.actualDateOfInspection
            : actualDateOfInspection // ignore: cast_nullable_to_non_nullable
                  as String?,
        proposedInspectionTime: freezed == proposedInspectionTime
            ? _value.proposedInspectionTime
            : proposedInspectionTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        actualInspectionTime: freezed == actualInspectionTime
            ? _value.actualInspectionTime
            : actualInspectionTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        dyHodUserId: freezed == dyHodUserId
            ? _value.dyHodUserId
            : dyHodUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        clientRepresentative: freezed == clientRepresentative
            ? _value.clientRepresentative
            : clientRepresentative // ignore: cast_nullable_to_non_nullable
                  as String?,
        clientDepartment: freezed == clientDepartment
            ? _value.clientDepartment
            : clientDepartment // ignore: cast_nullable_to_non_nullable
                  as String?,
        conLocation: freezed == conLocation
            ? _value.conLocation
            : conLocation // ignore: cast_nullable_to_non_nullable
                  as String?,
        clientLocation: freezed == clientLocation
            ? _value.clientLocation
            : clientLocation // ignore: cast_nullable_to_non_nullable
                  as String?,
        chainage: freezed == chainage
            ? _value.chainage
            : chainage // ignore: cast_nullable_to_non_nullable
                  as String?,
        validationStatus: freezed == validationStatus
            ? _value.validationStatus
            : validationStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        remarks: freezed == remarks
            ? _value.remarks
            : remarks // ignore: cast_nullable_to_non_nullable
                  as String?,
        validationComments: freezed == validationComments
            ? _value.validationComments
            : validationComments // ignore: cast_nullable_to_non_nullable
                  as String?,
        selfieClient: freezed == selfieClient
            ? _value.selfieClient
            : selfieClient // ignore: cast_nullable_to_non_nullable
                  as String?,
        selfieContractor: freezed == selfieContractor
            ? _value.selfieContractor
            : selfieContractor // ignore: cast_nullable_to_non_nullable
                  as String?,
        imagesUploadedByClient: freezed == imagesUploadedByClient
            ? _value.imagesUploadedByClient
            : imagesUploadedByClient // ignore: cast_nullable_to_non_nullable
                  as String?,
        imagesUploadedByContractor: freezed == imagesUploadedByContractor
            ? _value.imagesUploadedByContractor
            : imagesUploadedByContractor // ignore: cast_nullable_to_non_nullable
                  as String?,
        typeOfTest: freezed == typeOfTest
            ? _value.typeOfTest
            : typeOfTest // ignore: cast_nullable_to_non_nullable
                  as String?,
        testStatus: freezed == testStatus
            ? _value.testStatus
            : testStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        engineerRemarks: freezed == engineerRemarks
            ? _value.engineerRemarks
            : engineerRemarks // ignore: cast_nullable_to_non_nullable
                  as String?,
        testSiteDocumentsContractor: freezed == testSiteDocumentsContractor
            ? _value.testSiteDocumentsContractor
            : testSiteDocumentsContractor // ignore: cast_nullable_to_non_nullable
                  as String?,
        testResultContractor: freezed == testResultContractor
            ? _value.testResultContractor
            : testResultContractor // ignore: cast_nullable_to_non_nullable
                  as String?,
        testResultEngineer: freezed == testResultEngineer
            ? _value.testResultEngineer
            : testResultEngineer // ignore: cast_nullable_to_non_nullable
                  as String?,
        dyHodUserName: freezed == dyHodUserName
            ? _value.dyHodUserName
            : dyHodUserName // ignore: cast_nullable_to_non_nullable
                  as String?,
        conSupportFilePaths: freezed == conSupportFilePaths
            ? _value.conSupportFilePaths
            : conSupportFilePaths // ignore: cast_nullable_to_non_nullable
                  as String?,
        enggSupportFilePaths: freezed == enggSupportFilePaths
            ? _value.enggSupportFilePaths
            : enggSupportFilePaths // ignore: cast_nullable_to_non_nullable
                  as String?,
        attachmentData: freezed == attachmentData
            ? _value.attachmentData
            : attachmentData // ignore: cast_nullable_to_non_nullable
                  as String?,
        attachments: null == attachments
            ? _value._attachments
            : attachments // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportDetailsInfoImpl implements _ReportDetailsInfo {
  const _$ReportDetailsInfoImpl({
    this.project,
    this.work,
    this.contract,
    this.contractId,
    this.structureType,
    this.structure,
    this.component,
    this.element,
    this.activity,
    this.rfiDescription,
    this.action,
    this.typeOfRfi,
    this.contractorRepresentative,
    this.contractor,
    this.enclosures,
    this.rfiId,
    this.rfiStatus,
    this.descriptionByContractor,
    this.dateOfCreation,
    this.conInspDate,
    this.proposedDateOfInspection,
    this.actualDateOfInspection,
    this.proposedInspectionTime,
    this.actualInspectionTime,
    this.dyHodUserId,
    this.clientRepresentative,
    this.clientDepartment,
    this.conLocation,
    this.clientLocation,
    this.chainage,
    this.validationStatus,
    this.remarks,
    this.validationComments,
    this.selfieClient,
    this.selfieContractor,
    this.imagesUploadedByClient,
    this.imagesUploadedByContractor,
    this.typeOfTest,
    this.testStatus,
    this.engineerRemarks,
    this.testSiteDocumentsContractor,
    this.testResultContractor,
    this.testResultEngineer,
    this.dyHodUserName,
    this.conSupportFilePaths,
    this.enggSupportFilePaths,
    this.attachmentData,
    final List<dynamic> attachments = const [],
  }) : _attachments = attachments;

  factory _$ReportDetailsInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportDetailsInfoImplFromJson(json);

  @override
  final String? project;
  @override
  final String? work;
  @override
  final String? contract;
  @override
  final String? contractId;
  @override
  final String? structureType;
  @override
  final String? structure;
  @override
  final String? component;
  @override
  final String? element;
  @override
  final String? activity;
  @override
  final String? rfiDescription;
  @override
  final String? action;
  @override
  final String? typeOfRfi;
  @override
  final String? contractorRepresentative;
  @override
  final String? contractor;
  @override
  final String? enclosures;
  @override
  final String? rfiId;
  @override
  final String? rfiStatus;
  @override
  final String? descriptionByContractor;
  @override
  final String? dateOfCreation;
  @override
  final String? conInspDate;
  @override
  final String? proposedDateOfInspection;
  @override
  final String? actualDateOfInspection;
  @override
  final String? proposedInspectionTime;
  @override
  final String? actualInspectionTime;
  @override
  final String? dyHodUserId;
  @override
  final String? clientRepresentative;
  @override
  final String? clientDepartment;
  @override
  final String? conLocation;
  @override
  final String? clientLocation;
  @override
  final String? chainage;
  @override
  final String? validationStatus;
  @override
  final String? remarks;
  @override
  final String? validationComments;
  @override
  final String? selfieClient;
  @override
  final String? selfieContractor;
  @override
  final String? imagesUploadedByClient;
  @override
  final String? imagesUploadedByContractor;
  @override
  final String? typeOfTest;
  @override
  final String? testStatus;
  @override
  final String? engineerRemarks;
  @override
  final String? testSiteDocumentsContractor;
  @override
  final String? testResultContractor;
  @override
  final String? testResultEngineer;
  @override
  final String? dyHodUserName;
  @override
  final String? conSupportFilePaths;
  @override
  final String? enggSupportFilePaths;
  @override
  final String? attachmentData;
  final List<dynamic> _attachments;
  @override
  @JsonKey()
  List<dynamic> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  String toString() {
    return 'ReportDetailsInfo(project: $project, work: $work, contract: $contract, contractId: $contractId, structureType: $structureType, structure: $structure, component: $component, element: $element, activity: $activity, rfiDescription: $rfiDescription, action: $action, typeOfRfi: $typeOfRfi, contractorRepresentative: $contractorRepresentative, contractor: $contractor, enclosures: $enclosures, rfiId: $rfiId, rfiStatus: $rfiStatus, descriptionByContractor: $descriptionByContractor, dateOfCreation: $dateOfCreation, conInspDate: $conInspDate, proposedDateOfInspection: $proposedDateOfInspection, actualDateOfInspection: $actualDateOfInspection, proposedInspectionTime: $proposedInspectionTime, actualInspectionTime: $actualInspectionTime, dyHodUserId: $dyHodUserId, clientRepresentative: $clientRepresentative, clientDepartment: $clientDepartment, conLocation: $conLocation, clientLocation: $clientLocation, chainage: $chainage, validationStatus: $validationStatus, remarks: $remarks, validationComments: $validationComments, selfieClient: $selfieClient, selfieContractor: $selfieContractor, imagesUploadedByClient: $imagesUploadedByClient, imagesUploadedByContractor: $imagesUploadedByContractor, typeOfTest: $typeOfTest, testStatus: $testStatus, engineerRemarks: $engineerRemarks, testSiteDocumentsContractor: $testSiteDocumentsContractor, testResultContractor: $testResultContractor, testResultEngineer: $testResultEngineer, dyHodUserName: $dyHodUserName, conSupportFilePaths: $conSupportFilePaths, enggSupportFilePaths: $enggSupportFilePaths, attachmentData: $attachmentData, attachments: $attachments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportDetailsInfoImpl &&
            (identical(other.project, project) || other.project == project) &&
            (identical(other.work, work) || other.work == work) &&
            (identical(other.contract, contract) ||
                other.contract == contract) &&
            (identical(other.contractId, contractId) ||
                other.contractId == contractId) &&
            (identical(other.structureType, structureType) ||
                other.structureType == structureType) &&
            (identical(other.structure, structure) ||
                other.structure == structure) &&
            (identical(other.component, component) ||
                other.component == component) &&
            (identical(other.element, element) || other.element == element) &&
            (identical(other.activity, activity) ||
                other.activity == activity) &&
            (identical(other.rfiDescription, rfiDescription) ||
                other.rfiDescription == rfiDescription) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.typeOfRfi, typeOfRfi) ||
                other.typeOfRfi == typeOfRfi) &&
            (identical(
                  other.contractorRepresentative,
                  contractorRepresentative,
                ) ||
                other.contractorRepresentative == contractorRepresentative) &&
            (identical(other.contractor, contractor) ||
                other.contractor == contractor) &&
            (identical(other.enclosures, enclosures) ||
                other.enclosures == enclosures) &&
            (identical(other.rfiId, rfiId) || other.rfiId == rfiId) &&
            (identical(other.rfiStatus, rfiStatus) ||
                other.rfiStatus == rfiStatus) &&
            (identical(
                  other.descriptionByContractor,
                  descriptionByContractor,
                ) ||
                other.descriptionByContractor == descriptionByContractor) &&
            (identical(other.dateOfCreation, dateOfCreation) ||
                other.dateOfCreation == dateOfCreation) &&
            (identical(other.conInspDate, conInspDate) ||
                other.conInspDate == conInspDate) &&
            (identical(
                  other.proposedDateOfInspection,
                  proposedDateOfInspection,
                ) ||
                other.proposedDateOfInspection == proposedDateOfInspection) &&
            (identical(other.actualDateOfInspection, actualDateOfInspection) ||
                other.actualDateOfInspection == actualDateOfInspection) &&
            (identical(other.proposedInspectionTime, proposedInspectionTime) ||
                other.proposedInspectionTime == proposedInspectionTime) &&
            (identical(other.actualInspectionTime, actualInspectionTime) ||
                other.actualInspectionTime == actualInspectionTime) &&
            (identical(other.dyHodUserId, dyHodUserId) ||
                other.dyHodUserId == dyHodUserId) &&
            (identical(other.clientRepresentative, clientRepresentative) ||
                other.clientRepresentative == clientRepresentative) &&
            (identical(other.clientDepartment, clientDepartment) ||
                other.clientDepartment == clientDepartment) &&
            (identical(other.conLocation, conLocation) ||
                other.conLocation == conLocation) &&
            (identical(other.clientLocation, clientLocation) ||
                other.clientLocation == clientLocation) &&
            (identical(other.chainage, chainage) ||
                other.chainage == chainage) &&
            (identical(other.validationStatus, validationStatus) ||
                other.validationStatus == validationStatus) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.validationComments, validationComments) ||
                other.validationComments == validationComments) &&
            (identical(other.selfieClient, selfieClient) ||
                other.selfieClient == selfieClient) &&
            (identical(other.selfieContractor, selfieContractor) ||
                other.selfieContractor == selfieContractor) &&
            (identical(other.imagesUploadedByClient, imagesUploadedByClient) ||
                other.imagesUploadedByClient == imagesUploadedByClient) &&
            (identical(
                  other.imagesUploadedByContractor,
                  imagesUploadedByContractor,
                ) ||
                other.imagesUploadedByContractor ==
                    imagesUploadedByContractor) &&
            (identical(other.typeOfTest, typeOfTest) ||
                other.typeOfTest == typeOfTest) &&
            (identical(other.testStatus, testStatus) ||
                other.testStatus == testStatus) &&
            (identical(other.engineerRemarks, engineerRemarks) ||
                other.engineerRemarks == engineerRemarks) &&
            (identical(
                  other.testSiteDocumentsContractor,
                  testSiteDocumentsContractor,
                ) ||
                other.testSiteDocumentsContractor ==
                    testSiteDocumentsContractor) &&
            (identical(other.testResultContractor, testResultContractor) ||
                other.testResultContractor == testResultContractor) &&
            (identical(other.testResultEngineer, testResultEngineer) ||
                other.testResultEngineer == testResultEngineer) &&
            (identical(other.dyHodUserName, dyHodUserName) ||
                other.dyHodUserName == dyHodUserName) &&
            (identical(other.conSupportFilePaths, conSupportFilePaths) ||
                other.conSupportFilePaths == conSupportFilePaths) &&
            (identical(other.enggSupportFilePaths, enggSupportFilePaths) ||
                other.enggSupportFilePaths == enggSupportFilePaths) &&
            (identical(other.attachmentData, attachmentData) ||
                other.attachmentData == attachmentData) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    project,
    work,
    contract,
    contractId,
    structureType,
    structure,
    component,
    element,
    activity,
    rfiDescription,
    action,
    typeOfRfi,
    contractorRepresentative,
    contractor,
    enclosures,
    rfiId,
    rfiStatus,
    descriptionByContractor,
    dateOfCreation,
    conInspDate,
    proposedDateOfInspection,
    actualDateOfInspection,
    proposedInspectionTime,
    actualInspectionTime,
    dyHodUserId,
    clientRepresentative,
    clientDepartment,
    conLocation,
    clientLocation,
    chainage,
    validationStatus,
    remarks,
    validationComments,
    selfieClient,
    selfieContractor,
    imagesUploadedByClient,
    imagesUploadedByContractor,
    typeOfTest,
    testStatus,
    engineerRemarks,
    testSiteDocumentsContractor,
    testResultContractor,
    testResultEngineer,
    dyHodUserName,
    conSupportFilePaths,
    enggSupportFilePaths,
    attachmentData,
    const DeepCollectionEquality().hash(_attachments),
  ]);

  /// Create a copy of ReportDetailsInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportDetailsInfoImplCopyWith<_$ReportDetailsInfoImpl> get copyWith =>
      __$$ReportDetailsInfoImplCopyWithImpl<_$ReportDetailsInfoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportDetailsInfoImplToJson(this);
  }
}

abstract class _ReportDetailsInfo implements ReportDetailsInfo {
  const factory _ReportDetailsInfo({
    final String? project,
    final String? work,
    final String? contract,
    final String? contractId,
    final String? structureType,
    final String? structure,
    final String? component,
    final String? element,
    final String? activity,
    final String? rfiDescription,
    final String? action,
    final String? typeOfRfi,
    final String? contractorRepresentative,
    final String? contractor,
    final String? enclosures,
    final String? rfiId,
    final String? rfiStatus,
    final String? descriptionByContractor,
    final String? dateOfCreation,
    final String? conInspDate,
    final String? proposedDateOfInspection,
    final String? actualDateOfInspection,
    final String? proposedInspectionTime,
    final String? actualInspectionTime,
    final String? dyHodUserId,
    final String? clientRepresentative,
    final String? clientDepartment,
    final String? conLocation,
    final String? clientLocation,
    final String? chainage,
    final String? validationStatus,
    final String? remarks,
    final String? validationComments,
    final String? selfieClient,
    final String? selfieContractor,
    final String? imagesUploadedByClient,
    final String? imagesUploadedByContractor,
    final String? typeOfTest,
    final String? testStatus,
    final String? engineerRemarks,
    final String? testSiteDocumentsContractor,
    final String? testResultContractor,
    final String? testResultEngineer,
    final String? dyHodUserName,
    final String? conSupportFilePaths,
    final String? enggSupportFilePaths,
    final String? attachmentData,
    final List<dynamic> attachments,
  }) = _$ReportDetailsInfoImpl;

  factory _ReportDetailsInfo.fromJson(Map<String, dynamic> json) =
      _$ReportDetailsInfoImpl.fromJson;

  @override
  String? get project;
  @override
  String? get work;
  @override
  String? get contract;
  @override
  String? get contractId;
  @override
  String? get structureType;
  @override
  String? get structure;
  @override
  String? get component;
  @override
  String? get element;
  @override
  String? get activity;
  @override
  String? get rfiDescription;
  @override
  String? get action;
  @override
  String? get typeOfRfi;
  @override
  String? get contractorRepresentative;
  @override
  String? get contractor;
  @override
  String? get enclosures;
  @override
  String? get rfiId;
  @override
  String? get rfiStatus;
  @override
  String? get descriptionByContractor;
  @override
  String? get dateOfCreation;
  @override
  String? get conInspDate;
  @override
  String? get proposedDateOfInspection;
  @override
  String? get actualDateOfInspection;
  @override
  String? get proposedInspectionTime;
  @override
  String? get actualInspectionTime;
  @override
  String? get dyHodUserId;
  @override
  String? get clientRepresentative;
  @override
  String? get clientDepartment;
  @override
  String? get conLocation;
  @override
  String? get clientLocation;
  @override
  String? get chainage;
  @override
  String? get validationStatus;
  @override
  String? get remarks;
  @override
  String? get validationComments;
  @override
  String? get selfieClient;
  @override
  String? get selfieContractor;
  @override
  String? get imagesUploadedByClient;
  @override
  String? get imagesUploadedByContractor;
  @override
  String? get typeOfTest;
  @override
  String? get testStatus;
  @override
  String? get engineerRemarks;
  @override
  String? get testSiteDocumentsContractor;
  @override
  String? get testResultContractor;
  @override
  String? get testResultEngineer;
  @override
  String? get dyHodUserName;
  @override
  String? get conSupportFilePaths;
  @override
  String? get enggSupportFilePaths;
  @override
  String? get attachmentData;
  @override
  List<dynamic> get attachments;

  /// Create a copy of ReportDetailsInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportDetailsInfoImplCopyWith<_$ReportDetailsInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChecklistItem _$ChecklistItemFromJson(Map<String, dynamic> json) {
  return _ChecklistItem.fromJson(json);
}

/// @nodoc
mixin _$ChecklistItem {
  String? get enclosureName => throw _privateConstructorUsedError;
  String? get checklistDescription => throw _privateConstructorUsedError;
  String? get contractorRemark => throw _privateConstructorUsedError;
  String? get aeRemark => throw _privateConstructorUsedError;
  String? get conStatus => throw _privateConstructorUsedError;
  String? get aeStatus => throw _privateConstructorUsedError;

  /// Serializes this ChecklistItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChecklistItemCopyWith<ChecklistItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChecklistItemCopyWith<$Res> {
  factory $ChecklistItemCopyWith(
    ChecklistItem value,
    $Res Function(ChecklistItem) then,
  ) = _$ChecklistItemCopyWithImpl<$Res, ChecklistItem>;
  @useResult
  $Res call({
    String? enclosureName,
    String? checklistDescription,
    String? contractorRemark,
    String? aeRemark,
    String? conStatus,
    String? aeStatus,
  });
}

/// @nodoc
class _$ChecklistItemCopyWithImpl<$Res, $Val extends ChecklistItem>
    implements $ChecklistItemCopyWith<$Res> {
  _$ChecklistItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enclosureName = freezed,
    Object? checklistDescription = freezed,
    Object? contractorRemark = freezed,
    Object? aeRemark = freezed,
    Object? conStatus = freezed,
    Object? aeStatus = freezed,
  }) {
    return _then(
      _value.copyWith(
            enclosureName: freezed == enclosureName
                ? _value.enclosureName
                : enclosureName // ignore: cast_nullable_to_non_nullable
                      as String?,
            checklistDescription: freezed == checklistDescription
                ? _value.checklistDescription
                : checklistDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            contractorRemark: freezed == contractorRemark
                ? _value.contractorRemark
                : contractorRemark // ignore: cast_nullable_to_non_nullable
                      as String?,
            aeRemark: freezed == aeRemark
                ? _value.aeRemark
                : aeRemark // ignore: cast_nullable_to_non_nullable
                      as String?,
            conStatus: freezed == conStatus
                ? _value.conStatus
                : conStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            aeStatus: freezed == aeStatus
                ? _value.aeStatus
                : aeStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChecklistItemImplCopyWith<$Res>
    implements $ChecklistItemCopyWith<$Res> {
  factory _$$ChecklistItemImplCopyWith(
    _$ChecklistItemImpl value,
    $Res Function(_$ChecklistItemImpl) then,
  ) = __$$ChecklistItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? enclosureName,
    String? checklistDescription,
    String? contractorRemark,
    String? aeRemark,
    String? conStatus,
    String? aeStatus,
  });
}

/// @nodoc
class __$$ChecklistItemImplCopyWithImpl<$Res>
    extends _$ChecklistItemCopyWithImpl<$Res, _$ChecklistItemImpl>
    implements _$$ChecklistItemImplCopyWith<$Res> {
  __$$ChecklistItemImplCopyWithImpl(
    _$ChecklistItemImpl _value,
    $Res Function(_$ChecklistItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enclosureName = freezed,
    Object? checklistDescription = freezed,
    Object? contractorRemark = freezed,
    Object? aeRemark = freezed,
    Object? conStatus = freezed,
    Object? aeStatus = freezed,
  }) {
    return _then(
      _$ChecklistItemImpl(
        enclosureName: freezed == enclosureName
            ? _value.enclosureName
            : enclosureName // ignore: cast_nullable_to_non_nullable
                  as String?,
        checklistDescription: freezed == checklistDescription
            ? _value.checklistDescription
            : checklistDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        contractorRemark: freezed == contractorRemark
            ? _value.contractorRemark
            : contractorRemark // ignore: cast_nullable_to_non_nullable
                  as String?,
        aeRemark: freezed == aeRemark
            ? _value.aeRemark
            : aeRemark // ignore: cast_nullable_to_non_nullable
                  as String?,
        conStatus: freezed == conStatus
            ? _value.conStatus
            : conStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        aeStatus: freezed == aeStatus
            ? _value.aeStatus
            : aeStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChecklistItemImpl implements _ChecklistItem {
  const _$ChecklistItemImpl({
    this.enclosureName,
    this.checklistDescription,
    this.contractorRemark,
    this.aeRemark,
    this.conStatus,
    this.aeStatus,
  });

  factory _$ChecklistItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChecklistItemImplFromJson(json);

  @override
  final String? enclosureName;
  @override
  final String? checklistDescription;
  @override
  final String? contractorRemark;
  @override
  final String? aeRemark;
  @override
  final String? conStatus;
  @override
  final String? aeStatus;

  @override
  String toString() {
    return 'ChecklistItem(enclosureName: $enclosureName, checklistDescription: $checklistDescription, contractorRemark: $contractorRemark, aeRemark: $aeRemark, conStatus: $conStatus, aeStatus: $aeStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChecklistItemImpl &&
            (identical(other.enclosureName, enclosureName) ||
                other.enclosureName == enclosureName) &&
            (identical(other.checklistDescription, checklistDescription) ||
                other.checklistDescription == checklistDescription) &&
            (identical(other.contractorRemark, contractorRemark) ||
                other.contractorRemark == contractorRemark) &&
            (identical(other.aeRemark, aeRemark) ||
                other.aeRemark == aeRemark) &&
            (identical(other.conStatus, conStatus) ||
                other.conStatus == conStatus) &&
            (identical(other.aeStatus, aeStatus) ||
                other.aeStatus == aeStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    enclosureName,
    checklistDescription,
    contractorRemark,
    aeRemark,
    conStatus,
    aeStatus,
  );

  /// Create a copy of ChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChecklistItemImplCopyWith<_$ChecklistItemImpl> get copyWith =>
      __$$ChecklistItemImplCopyWithImpl<_$ChecklistItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChecklistItemImplToJson(this);
  }
}

abstract class _ChecklistItem implements ChecklistItem {
  const factory _ChecklistItem({
    final String? enclosureName,
    final String? checklistDescription,
    final String? contractorRemark,
    final String? aeRemark,
    final String? conStatus,
    final String? aeStatus,
  }) = _$ChecklistItemImpl;

  factory _ChecklistItem.fromJson(Map<String, dynamic> json) =
      _$ChecklistItemImpl.fromJson;

  @override
  String? get enclosureName;
  @override
  String? get checklistDescription;
  @override
  String? get contractorRemark;
  @override
  String? get aeRemark;
  @override
  String? get conStatus;
  @override
  String? get aeStatus;

  /// Create a copy of ChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChecklistItemImplCopyWith<_$ChecklistItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EnclosureInfo _$EnclosureInfoFromJson(Map<String, dynamic> json) {
  return _EnclosureInfo.fromJson(json);
}

/// @nodoc
mixin _$EnclosureInfo {
  String? get enclosureName => throw _privateConstructorUsedError;
  String? get file => throw _privateConstructorUsedError;

  /// Serializes this EnclosureInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EnclosureInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EnclosureInfoCopyWith<EnclosureInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnclosureInfoCopyWith<$Res> {
  factory $EnclosureInfoCopyWith(
    EnclosureInfo value,
    $Res Function(EnclosureInfo) then,
  ) = _$EnclosureInfoCopyWithImpl<$Res, EnclosureInfo>;
  @useResult
  $Res call({String? enclosureName, String? file});
}

/// @nodoc
class _$EnclosureInfoCopyWithImpl<$Res, $Val extends EnclosureInfo>
    implements $EnclosureInfoCopyWith<$Res> {
  _$EnclosureInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EnclosureInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? enclosureName = freezed, Object? file = freezed}) {
    return _then(
      _value.copyWith(
            enclosureName: freezed == enclosureName
                ? _value.enclosureName
                : enclosureName // ignore: cast_nullable_to_non_nullable
                      as String?,
            file: freezed == file
                ? _value.file
                : file // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EnclosureInfoImplCopyWith<$Res>
    implements $EnclosureInfoCopyWith<$Res> {
  factory _$$EnclosureInfoImplCopyWith(
    _$EnclosureInfoImpl value,
    $Res Function(_$EnclosureInfoImpl) then,
  ) = __$$EnclosureInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? enclosureName, String? file});
}

/// @nodoc
class __$$EnclosureInfoImplCopyWithImpl<$Res>
    extends _$EnclosureInfoCopyWithImpl<$Res, _$EnclosureInfoImpl>
    implements _$$EnclosureInfoImplCopyWith<$Res> {
  __$$EnclosureInfoImplCopyWithImpl(
    _$EnclosureInfoImpl _value,
    $Res Function(_$EnclosureInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EnclosureInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? enclosureName = freezed, Object? file = freezed}) {
    return _then(
      _$EnclosureInfoImpl(
        enclosureName: freezed == enclosureName
            ? _value.enclosureName
            : enclosureName // ignore: cast_nullable_to_non_nullable
                  as String?,
        file: freezed == file
            ? _value.file
            : file // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EnclosureInfoImpl implements _EnclosureInfo {
  const _$EnclosureInfoImpl({this.enclosureName, this.file});

  factory _$EnclosureInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$EnclosureInfoImplFromJson(json);

  @override
  final String? enclosureName;
  @override
  final String? file;

  @override
  String toString() {
    return 'EnclosureInfo(enclosureName: $enclosureName, file: $file)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnclosureInfoImpl &&
            (identical(other.enclosureName, enclosureName) ||
                other.enclosureName == enclosureName) &&
            (identical(other.file, file) || other.file == file));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, enclosureName, file);

  /// Create a copy of EnclosureInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EnclosureInfoImplCopyWith<_$EnclosureInfoImpl> get copyWith =>
      __$$EnclosureInfoImplCopyWithImpl<_$EnclosureInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EnclosureInfoImplToJson(this);
  }
}

abstract class _EnclosureInfo implements EnclosureInfo {
  const factory _EnclosureInfo({
    final String? enclosureName,
    final String? file,
  }) = _$EnclosureInfoImpl;

  factory _EnclosureInfo.fromJson(Map<String, dynamic> json) =
      _$EnclosureInfoImpl.fromJson;

  @override
  String? get enclosureName;
  @override
  String? get file;

  /// Create a copy of EnclosureInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnclosureInfoImplCopyWith<_$EnclosureInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MeasurementDetails _$MeasurementDetailsFromJson(Map<String, dynamic> json) {
  return _MeasurementDetails.fromJson(json);
}

/// @nodoc
mixin _$MeasurementDetails {
  String? get measurementType => throw _privateConstructorUsedError;
  dynamic get weight => throw _privateConstructorUsedError;
  double? get totalQty => throw _privateConstructorUsedError;
  dynamic get b => throw _privateConstructorUsedError;
  dynamic get l => throw _privateConstructorUsedError;
  dynamic get h => throw _privateConstructorUsedError;
  int? get no => throw _privateConstructorUsedError;
  String? get units => throw _privateConstructorUsedError;

  /// Serializes this MeasurementDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeasurementDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeasurementDetailsCopyWith<MeasurementDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeasurementDetailsCopyWith<$Res> {
  factory $MeasurementDetailsCopyWith(
    MeasurementDetails value,
    $Res Function(MeasurementDetails) then,
  ) = _$MeasurementDetailsCopyWithImpl<$Res, MeasurementDetails>;
  @useResult
  $Res call({
    String? measurementType,
    dynamic weight,
    double? totalQty,
    dynamic b,
    dynamic l,
    dynamic h,
    int? no,
    String? units,
  });
}

/// @nodoc
class _$MeasurementDetailsCopyWithImpl<$Res, $Val extends MeasurementDetails>
    implements $MeasurementDetailsCopyWith<$Res> {
  _$MeasurementDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeasurementDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? measurementType = freezed,
    Object? weight = freezed,
    Object? totalQty = freezed,
    Object? b = freezed,
    Object? l = freezed,
    Object? h = freezed,
    Object? no = freezed,
    Object? units = freezed,
  }) {
    return _then(
      _value.copyWith(
            measurementType: freezed == measurementType
                ? _value.measurementType
                : measurementType // ignore: cast_nullable_to_non_nullable
                      as String?,
            weight: freezed == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            totalQty: freezed == totalQty
                ? _value.totalQty
                : totalQty // ignore: cast_nullable_to_non_nullable
                      as double?,
            b: freezed == b
                ? _value.b
                : b // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            l: freezed == l
                ? _value.l
                : l // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            h: freezed == h
                ? _value.h
                : h // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            no: freezed == no
                ? _value.no
                : no // ignore: cast_nullable_to_non_nullable
                      as int?,
            units: freezed == units
                ? _value.units
                : units // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MeasurementDetailsImplCopyWith<$Res>
    implements $MeasurementDetailsCopyWith<$Res> {
  factory _$$MeasurementDetailsImplCopyWith(
    _$MeasurementDetailsImpl value,
    $Res Function(_$MeasurementDetailsImpl) then,
  ) = __$$MeasurementDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? measurementType,
    dynamic weight,
    double? totalQty,
    dynamic b,
    dynamic l,
    dynamic h,
    int? no,
    String? units,
  });
}

/// @nodoc
class __$$MeasurementDetailsImplCopyWithImpl<$Res>
    extends _$MeasurementDetailsCopyWithImpl<$Res, _$MeasurementDetailsImpl>
    implements _$$MeasurementDetailsImplCopyWith<$Res> {
  __$$MeasurementDetailsImplCopyWithImpl(
    _$MeasurementDetailsImpl _value,
    $Res Function(_$MeasurementDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MeasurementDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? measurementType = freezed,
    Object? weight = freezed,
    Object? totalQty = freezed,
    Object? b = freezed,
    Object? l = freezed,
    Object? h = freezed,
    Object? no = freezed,
    Object? units = freezed,
  }) {
    return _then(
      _$MeasurementDetailsImpl(
        measurementType: freezed == measurementType
            ? _value.measurementType
            : measurementType // ignore: cast_nullable_to_non_nullable
                  as String?,
        weight: freezed == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        totalQty: freezed == totalQty
            ? _value.totalQty
            : totalQty // ignore: cast_nullable_to_non_nullable
                  as double?,
        b: freezed == b
            ? _value.b
            : b // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        l: freezed == l
            ? _value.l
            : l // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        h: freezed == h
            ? _value.h
            : h // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        no: freezed == no
            ? _value.no
            : no // ignore: cast_nullable_to_non_nullable
                  as int?,
        units: freezed == units
            ? _value.units
            : units // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MeasurementDetailsImpl implements _MeasurementDetails {
  const _$MeasurementDetailsImpl({
    this.measurementType,
    this.weight,
    this.totalQty,
    this.b,
    this.l,
    this.h,
    this.no,
    this.units,
  });

  factory _$MeasurementDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeasurementDetailsImplFromJson(json);

  @override
  final String? measurementType;
  @override
  final dynamic weight;
  @override
  final double? totalQty;
  @override
  final dynamic b;
  @override
  final dynamic l;
  @override
  final dynamic h;
  @override
  final int? no;
  @override
  final String? units;

  @override
  String toString() {
    return 'MeasurementDetails(measurementType: $measurementType, weight: $weight, totalQty: $totalQty, b: $b, l: $l, h: $h, no: $no, units: $units)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasurementDetailsImpl &&
            (identical(other.measurementType, measurementType) ||
                other.measurementType == measurementType) &&
            const DeepCollectionEquality().equals(other.weight, weight) &&
            (identical(other.totalQty, totalQty) ||
                other.totalQty == totalQty) &&
            const DeepCollectionEquality().equals(other.b, b) &&
            const DeepCollectionEquality().equals(other.l, l) &&
            const DeepCollectionEquality().equals(other.h, h) &&
            (identical(other.no, no) || other.no == no) &&
            (identical(other.units, units) || other.units == units));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    measurementType,
    const DeepCollectionEquality().hash(weight),
    totalQty,
    const DeepCollectionEquality().hash(b),
    const DeepCollectionEquality().hash(l),
    const DeepCollectionEquality().hash(h),
    no,
    units,
  );

  /// Create a copy of MeasurementDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasurementDetailsImplCopyWith<_$MeasurementDetailsImpl> get copyWith =>
      __$$MeasurementDetailsImplCopyWithImpl<_$MeasurementDetailsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MeasurementDetailsImplToJson(this);
  }
}

abstract class _MeasurementDetails implements MeasurementDetails {
  const factory _MeasurementDetails({
    final String? measurementType,
    final dynamic weight,
    final double? totalQty,
    final dynamic b,
    final dynamic l,
    final dynamic h,
    final int? no,
    final String? units,
  }) = _$MeasurementDetailsImpl;

  factory _MeasurementDetails.fromJson(Map<String, dynamic> json) =
      _$MeasurementDetailsImpl.fromJson;

  @override
  String? get measurementType;
  @override
  dynamic get weight;
  @override
  double? get totalQty;
  @override
  dynamic get b;
  @override
  dynamic get l;
  @override
  dynamic get h;
  @override
  int? get no;
  @override
  String? get units;

  /// Create a copy of MeasurementDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeasurementDetailsImplCopyWith<_$MeasurementDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
