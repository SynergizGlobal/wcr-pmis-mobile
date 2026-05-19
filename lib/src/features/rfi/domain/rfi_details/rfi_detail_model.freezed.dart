// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rfi_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RfiDetailModel _$RfiDetailModelFromJson(Map<String, dynamic> json) {
  return _RfiDetailModel.fromJson(json);
}

/// @nodoc
mixin _$RfiDetailModel {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'rfi_Id')
  String? get rfiId => throw _privateConstructorUsedError;
  String? get project => throw _privateConstructorUsedError;
  String? get work => throw _privateConstructorUsedError;
  String? get contract => throw _privateConstructorUsedError;
  String? get structureType => throw _privateConstructorUsedError;
  String? get structure => throw _privateConstructorUsedError;
  String? get component => throw _privateConstructorUsedError;
  String? get element => throw _privateConstructorUsedError;
  String? get activity => throw _privateConstructorUsedError;
  String? get p6ActivityId => throw _privateConstructorUsedError;
  String? get pmisCalcFk => throw _privateConstructorUsedError;
  String? get reasonForDelete => throw _privateConstructorUsedError;
  String? get rfiDescription => throw _privateConstructorUsedError;
  String? get action => throw _privateConstructorUsedError;
  String? get typeOfRFI => throw _privateConstructorUsedError;
  String? get nameOfRepresentative => throw _privateConstructorUsedError;
  String? get enclosures => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get timeOfInspection => throw _privateConstructorUsedError;
  String? get dateOfSubmission => throw _privateConstructorUsedError;
  String? get dateOfInspection => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  String? get emailUser => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get assignedPersonClient => throw _privateConstructorUsedError;
  String? get clientDepartment => throw _privateConstructorUsedError;
  @JsonKey(name: 'txn_id')
  String? get txnId => throw _privateConstructorUsedError;
  String? get assignedPersonContractor => throw _privateConstructorUsedError;
  String? get assignedPersonUserId => throw _privateConstructorUsedError;
  String? get contractId => throw _privateConstructorUsedError;
  String? get dyHodUserId => throw _privateConstructorUsedError;
  String? get rfiValidation => throw _privateConstructorUsedError;
  List<dynamic>? get checklistItems => throw _privateConstructorUsedError;
  List<dynamic>? get enclosure => throw _privateConstructorUsedError;
  MeasurementModel? get measurements => throw _privateConstructorUsedError;
  @JsonKey(name: 'contractor_submitted_date')
  String? get contractorSubmittedDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'engineer_submitted_date')
  String? get engineerSubmittedDate => throw _privateConstructorUsedError;
  bool? get contractorEsignDone => throw _privateConstructorUsedError;
  bool? get engineerEsignDone => throw _privateConstructorUsedError;
  String? get closedDate => throw _privateConstructorUsedError;
  bool? get isDeleted => throw _privateConstructorUsedError;
  String? get deletedAt => throw _privateConstructorUsedError;
  List<dynamic>? get attachments => throw _privateConstructorUsedError;
  String? get estatus => throw _privateConstructorUsedError;
  List<String>? get enclosuresList => throw _privateConstructorUsedError;

  /// Serializes this RfiDetailModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RfiDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RfiDetailModelCopyWith<RfiDetailModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RfiDetailModelCopyWith<$Res> {
  factory $RfiDetailModelCopyWith(
    RfiDetailModel value,
    $Res Function(RfiDetailModel) then,
  ) = _$RfiDetailModelCopyWithImpl<$Res, RfiDetailModel>;
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'rfi_Id') String? rfiId,
    String? project,
    String? work,
    String? contract,
    String? structureType,
    String? structure,
    String? component,
    String? element,
    String? activity,
    String? p6ActivityId,
    String? pmisCalcFk,
    String? reasonForDelete,
    String? rfiDescription,
    String? action,
    String? typeOfRFI,
    String? nameOfRepresentative,
    String? enclosures,
    String? location,
    String? description,
    String? timeOfInspection,
    String? dateOfSubmission,
    String? dateOfInspection,
    String? createdAt,
    String? updatedAt,
    String? createdBy,
    String? emailUser,
    String? status,
    String? assignedPersonClient,
    String? clientDepartment,
    @JsonKey(name: 'txn_id') String? txnId,
    String? assignedPersonContractor,
    String? assignedPersonUserId,
    String? contractId,
    String? dyHodUserId,
    String? rfiValidation,
    List<dynamic>? checklistItems,
    List<dynamic>? enclosure,
    MeasurementModel? measurements,
    @JsonKey(name: 'contractor_submitted_date') String? contractorSubmittedDate,
    @JsonKey(name: 'engineer_submitted_date') String? engineerSubmittedDate,
    bool? contractorEsignDone,
    bool? engineerEsignDone,
    String? closedDate,
    bool? isDeleted,
    String? deletedAt,
    List<dynamic>? attachments,
    String? estatus,
    List<String>? enclosuresList,
  });

  $MeasurementModelCopyWith<$Res>? get measurements;
}

/// @nodoc
class _$RfiDetailModelCopyWithImpl<$Res, $Val extends RfiDetailModel>
    implements $RfiDetailModelCopyWith<$Res> {
  _$RfiDetailModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RfiDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? rfiId = freezed,
    Object? project = freezed,
    Object? work = freezed,
    Object? contract = freezed,
    Object? structureType = freezed,
    Object? structure = freezed,
    Object? component = freezed,
    Object? element = freezed,
    Object? activity = freezed,
    Object? p6ActivityId = freezed,
    Object? pmisCalcFk = freezed,
    Object? reasonForDelete = freezed,
    Object? rfiDescription = freezed,
    Object? action = freezed,
    Object? typeOfRFI = freezed,
    Object? nameOfRepresentative = freezed,
    Object? enclosures = freezed,
    Object? location = freezed,
    Object? description = freezed,
    Object? timeOfInspection = freezed,
    Object? dateOfSubmission = freezed,
    Object? dateOfInspection = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
    Object? emailUser = freezed,
    Object? status = freezed,
    Object? assignedPersonClient = freezed,
    Object? clientDepartment = freezed,
    Object? txnId = freezed,
    Object? assignedPersonContractor = freezed,
    Object? assignedPersonUserId = freezed,
    Object? contractId = freezed,
    Object? dyHodUserId = freezed,
    Object? rfiValidation = freezed,
    Object? checklistItems = freezed,
    Object? enclosure = freezed,
    Object? measurements = freezed,
    Object? contractorSubmittedDate = freezed,
    Object? engineerSubmittedDate = freezed,
    Object? contractorEsignDone = freezed,
    Object? engineerEsignDone = freezed,
    Object? closedDate = freezed,
    Object? isDeleted = freezed,
    Object? deletedAt = freezed,
    Object? attachments = freezed,
    Object? estatus = freezed,
    Object? enclosuresList = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            rfiId: freezed == rfiId
                ? _value.rfiId
                : rfiId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            p6ActivityId: freezed == p6ActivityId
                ? _value.p6ActivityId
                : p6ActivityId // ignore: cast_nullable_to_non_nullable
                      as String?,
            pmisCalcFk: freezed == pmisCalcFk
                ? _value.pmisCalcFk
                : pmisCalcFk // ignore: cast_nullable_to_non_nullable
                      as String?,
            reasonForDelete: freezed == reasonForDelete
                ? _value.reasonForDelete
                : reasonForDelete // ignore: cast_nullable_to_non_nullable
                      as String?,
            rfiDescription: freezed == rfiDescription
                ? _value.rfiDescription
                : rfiDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            action: freezed == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String?,
            typeOfRFI: freezed == typeOfRFI
                ? _value.typeOfRFI
                : typeOfRFI // ignore: cast_nullable_to_non_nullable
                      as String?,
            nameOfRepresentative: freezed == nameOfRepresentative
                ? _value.nameOfRepresentative
                : nameOfRepresentative // ignore: cast_nullable_to_non_nullable
                      as String?,
            enclosures: freezed == enclosures
                ? _value.enclosures
                : enclosures // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            timeOfInspection: freezed == timeOfInspection
                ? _value.timeOfInspection
                : timeOfInspection // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateOfSubmission: freezed == dateOfSubmission
                ? _value.dateOfSubmission
                : dateOfSubmission // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateOfInspection: freezed == dateOfInspection
                ? _value.dateOfInspection
                : dateOfInspection // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdBy: freezed == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            emailUser: freezed == emailUser
                ? _value.emailUser
                : emailUser // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedPersonClient: freezed == assignedPersonClient
                ? _value.assignedPersonClient
                : assignedPersonClient // ignore: cast_nullable_to_non_nullable
                      as String?,
            clientDepartment: freezed == clientDepartment
                ? _value.clientDepartment
                : clientDepartment // ignore: cast_nullable_to_non_nullable
                      as String?,
            txnId: freezed == txnId
                ? _value.txnId
                : txnId // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedPersonContractor: freezed == assignedPersonContractor
                ? _value.assignedPersonContractor
                : assignedPersonContractor // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedPersonUserId: freezed == assignedPersonUserId
                ? _value.assignedPersonUserId
                : assignedPersonUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            contractId: freezed == contractId
                ? _value.contractId
                : contractId // ignore: cast_nullable_to_non_nullable
                      as String?,
            dyHodUserId: freezed == dyHodUserId
                ? _value.dyHodUserId
                : dyHodUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            rfiValidation: freezed == rfiValidation
                ? _value.rfiValidation
                : rfiValidation // ignore: cast_nullable_to_non_nullable
                      as String?,
            checklistItems: freezed == checklistItems
                ? _value.checklistItems
                : checklistItems // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
            enclosure: freezed == enclosure
                ? _value.enclosure
                : enclosure // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
            measurements: freezed == measurements
                ? _value.measurements
                : measurements // ignore: cast_nullable_to_non_nullable
                      as MeasurementModel?,
            contractorSubmittedDate: freezed == contractorSubmittedDate
                ? _value.contractorSubmittedDate
                : contractorSubmittedDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            engineerSubmittedDate: freezed == engineerSubmittedDate
                ? _value.engineerSubmittedDate
                : engineerSubmittedDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            contractorEsignDone: freezed == contractorEsignDone
                ? _value.contractorEsignDone
                : contractorEsignDone // ignore: cast_nullable_to_non_nullable
                      as bool?,
            engineerEsignDone: freezed == engineerEsignDone
                ? _value.engineerEsignDone
                : engineerEsignDone // ignore: cast_nullable_to_non_nullable
                      as bool?,
            closedDate: freezed == closedDate
                ? _value.closedDate
                : closedDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            isDeleted: freezed == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as bool?,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            attachments: freezed == attachments
                ? _value.attachments
                : attachments // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
            estatus: freezed == estatus
                ? _value.estatus
                : estatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            enclosuresList: freezed == enclosuresList
                ? _value.enclosuresList
                : enclosuresList // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
          )
          as $Val,
    );
  }

  /// Create a copy of RfiDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MeasurementModelCopyWith<$Res>? get measurements {
    if (_value.measurements == null) {
      return null;
    }

    return $MeasurementModelCopyWith<$Res>(_value.measurements!, (value) {
      return _then(_value.copyWith(measurements: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RfiDetailModelImplCopyWith<$Res>
    implements $RfiDetailModelCopyWith<$Res> {
  factory _$$RfiDetailModelImplCopyWith(
    _$RfiDetailModelImpl value,
    $Res Function(_$RfiDetailModelImpl) then,
  ) = __$$RfiDetailModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'rfi_Id') String? rfiId,
    String? project,
    String? work,
    String? contract,
    String? structureType,
    String? structure,
    String? component,
    String? element,
    String? activity,
    String? p6ActivityId,
    String? pmisCalcFk,
    String? reasonForDelete,
    String? rfiDescription,
    String? action,
    String? typeOfRFI,
    String? nameOfRepresentative,
    String? enclosures,
    String? location,
    String? description,
    String? timeOfInspection,
    String? dateOfSubmission,
    String? dateOfInspection,
    String? createdAt,
    String? updatedAt,
    String? createdBy,
    String? emailUser,
    String? status,
    String? assignedPersonClient,
    String? clientDepartment,
    @JsonKey(name: 'txn_id') String? txnId,
    String? assignedPersonContractor,
    String? assignedPersonUserId,
    String? contractId,
    String? dyHodUserId,
    String? rfiValidation,
    List<dynamic>? checklistItems,
    List<dynamic>? enclosure,
    MeasurementModel? measurements,
    @JsonKey(name: 'contractor_submitted_date') String? contractorSubmittedDate,
    @JsonKey(name: 'engineer_submitted_date') String? engineerSubmittedDate,
    bool? contractorEsignDone,
    bool? engineerEsignDone,
    String? closedDate,
    bool? isDeleted,
    String? deletedAt,
    List<dynamic>? attachments,
    String? estatus,
    List<String>? enclosuresList,
  });

  @override
  $MeasurementModelCopyWith<$Res>? get measurements;
}

/// @nodoc
class __$$RfiDetailModelImplCopyWithImpl<$Res>
    extends _$RfiDetailModelCopyWithImpl<$Res, _$RfiDetailModelImpl>
    implements _$$RfiDetailModelImplCopyWith<$Res> {
  __$$RfiDetailModelImplCopyWithImpl(
    _$RfiDetailModelImpl _value,
    $Res Function(_$RfiDetailModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RfiDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? rfiId = freezed,
    Object? project = freezed,
    Object? work = freezed,
    Object? contract = freezed,
    Object? structureType = freezed,
    Object? structure = freezed,
    Object? component = freezed,
    Object? element = freezed,
    Object? activity = freezed,
    Object? p6ActivityId = freezed,
    Object? pmisCalcFk = freezed,
    Object? reasonForDelete = freezed,
    Object? rfiDescription = freezed,
    Object? action = freezed,
    Object? typeOfRFI = freezed,
    Object? nameOfRepresentative = freezed,
    Object? enclosures = freezed,
    Object? location = freezed,
    Object? description = freezed,
    Object? timeOfInspection = freezed,
    Object? dateOfSubmission = freezed,
    Object? dateOfInspection = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
    Object? emailUser = freezed,
    Object? status = freezed,
    Object? assignedPersonClient = freezed,
    Object? clientDepartment = freezed,
    Object? txnId = freezed,
    Object? assignedPersonContractor = freezed,
    Object? assignedPersonUserId = freezed,
    Object? contractId = freezed,
    Object? dyHodUserId = freezed,
    Object? rfiValidation = freezed,
    Object? checklistItems = freezed,
    Object? enclosure = freezed,
    Object? measurements = freezed,
    Object? contractorSubmittedDate = freezed,
    Object? engineerSubmittedDate = freezed,
    Object? contractorEsignDone = freezed,
    Object? engineerEsignDone = freezed,
    Object? closedDate = freezed,
    Object? isDeleted = freezed,
    Object? deletedAt = freezed,
    Object? attachments = freezed,
    Object? estatus = freezed,
    Object? enclosuresList = freezed,
  }) {
    return _then(
      _$RfiDetailModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        rfiId: freezed == rfiId
            ? _value.rfiId
            : rfiId // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        p6ActivityId: freezed == p6ActivityId
            ? _value.p6ActivityId
            : p6ActivityId // ignore: cast_nullable_to_non_nullable
                  as String?,
        pmisCalcFk: freezed == pmisCalcFk
            ? _value.pmisCalcFk
            : pmisCalcFk // ignore: cast_nullable_to_non_nullable
                  as String?,
        reasonForDelete: freezed == reasonForDelete
            ? _value.reasonForDelete
            : reasonForDelete // ignore: cast_nullable_to_non_nullable
                  as String?,
        rfiDescription: freezed == rfiDescription
            ? _value.rfiDescription
            : rfiDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        action: freezed == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String?,
        typeOfRFI: freezed == typeOfRFI
            ? _value.typeOfRFI
            : typeOfRFI // ignore: cast_nullable_to_non_nullable
                  as String?,
        nameOfRepresentative: freezed == nameOfRepresentative
            ? _value.nameOfRepresentative
            : nameOfRepresentative // ignore: cast_nullable_to_non_nullable
                  as String?,
        enclosures: freezed == enclosures
            ? _value.enclosures
            : enclosures // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        timeOfInspection: freezed == timeOfInspection
            ? _value.timeOfInspection
            : timeOfInspection // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateOfSubmission: freezed == dateOfSubmission
            ? _value.dateOfSubmission
            : dateOfSubmission // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateOfInspection: freezed == dateOfInspection
            ? _value.dateOfInspection
            : dateOfInspection // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdBy: freezed == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        emailUser: freezed == emailUser
            ? _value.emailUser
            : emailUser // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedPersonClient: freezed == assignedPersonClient
            ? _value.assignedPersonClient
            : assignedPersonClient // ignore: cast_nullable_to_non_nullable
                  as String?,
        clientDepartment: freezed == clientDepartment
            ? _value.clientDepartment
            : clientDepartment // ignore: cast_nullable_to_non_nullable
                  as String?,
        txnId: freezed == txnId
            ? _value.txnId
            : txnId // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedPersonContractor: freezed == assignedPersonContractor
            ? _value.assignedPersonContractor
            : assignedPersonContractor // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedPersonUserId: freezed == assignedPersonUserId
            ? _value.assignedPersonUserId
            : assignedPersonUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        contractId: freezed == contractId
            ? _value.contractId
            : contractId // ignore: cast_nullable_to_non_nullable
                  as String?,
        dyHodUserId: freezed == dyHodUserId
            ? _value.dyHodUserId
            : dyHodUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        rfiValidation: freezed == rfiValidation
            ? _value.rfiValidation
            : rfiValidation // ignore: cast_nullable_to_non_nullable
                  as String?,
        checklistItems: freezed == checklistItems
            ? _value._checklistItems
            : checklistItems // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
        enclosure: freezed == enclosure
            ? _value._enclosure
            : enclosure // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
        measurements: freezed == measurements
            ? _value.measurements
            : measurements // ignore: cast_nullable_to_non_nullable
                  as MeasurementModel?,
        contractorSubmittedDate: freezed == contractorSubmittedDate
            ? _value.contractorSubmittedDate
            : contractorSubmittedDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        engineerSubmittedDate: freezed == engineerSubmittedDate
            ? _value.engineerSubmittedDate
            : engineerSubmittedDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        contractorEsignDone: freezed == contractorEsignDone
            ? _value.contractorEsignDone
            : contractorEsignDone // ignore: cast_nullable_to_non_nullable
                  as bool?,
        engineerEsignDone: freezed == engineerEsignDone
            ? _value.engineerEsignDone
            : engineerEsignDone // ignore: cast_nullable_to_non_nullable
                  as bool?,
        closedDate: freezed == closedDate
            ? _value.closedDate
            : closedDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        isDeleted: freezed == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as bool?,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        attachments: freezed == attachments
            ? _value._attachments
            : attachments // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
        estatus: freezed == estatus
            ? _value.estatus
            : estatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        enclosuresList: freezed == enclosuresList
            ? _value._enclosuresList
            : enclosuresList // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RfiDetailModelImpl implements _RfiDetailModel {
  const _$RfiDetailModelImpl({
    this.id,
    @JsonKey(name: 'rfi_Id') this.rfiId,
    this.project,
    this.work,
    this.contract,
    this.structureType,
    this.structure,
    this.component,
    this.element,
    this.activity,
    this.p6ActivityId,
    this.pmisCalcFk,
    this.reasonForDelete,
    this.rfiDescription,
    this.action,
    this.typeOfRFI,
    this.nameOfRepresentative,
    this.enclosures,
    this.location,
    this.description,
    this.timeOfInspection,
    this.dateOfSubmission,
    this.dateOfInspection,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.emailUser,
    this.status,
    this.assignedPersonClient,
    this.clientDepartment,
    @JsonKey(name: 'txn_id') this.txnId,
    this.assignedPersonContractor,
    this.assignedPersonUserId,
    this.contractId,
    this.dyHodUserId,
    this.rfiValidation,
    final List<dynamic>? checklistItems,
    final List<dynamic>? enclosure,
    this.measurements,
    @JsonKey(name: 'contractor_submitted_date') this.contractorSubmittedDate,
    @JsonKey(name: 'engineer_submitted_date') this.engineerSubmittedDate,
    this.contractorEsignDone,
    this.engineerEsignDone,
    this.closedDate,
    this.isDeleted,
    this.deletedAt,
    final List<dynamic>? attachments,
    this.estatus,
    final List<String>? enclosuresList,
  }) : _checklistItems = checklistItems,
       _enclosure = enclosure,
       _attachments = attachments,
       _enclosuresList = enclosuresList;

  factory _$RfiDetailModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RfiDetailModelImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'rfi_Id')
  final String? rfiId;
  @override
  final String? project;
  @override
  final String? work;
  @override
  final String? contract;
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
  final String? p6ActivityId;
  @override
  final String? pmisCalcFk;
  @override
  final String? reasonForDelete;
  @override
  final String? rfiDescription;
  @override
  final String? action;
  @override
  final String? typeOfRFI;
  @override
  final String? nameOfRepresentative;
  @override
  final String? enclosures;
  @override
  final String? location;
  @override
  final String? description;
  @override
  final String? timeOfInspection;
  @override
  final String? dateOfSubmission;
  @override
  final String? dateOfInspection;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final String? createdBy;
  @override
  final String? emailUser;
  @override
  final String? status;
  @override
  final String? assignedPersonClient;
  @override
  final String? clientDepartment;
  @override
  @JsonKey(name: 'txn_id')
  final String? txnId;
  @override
  final String? assignedPersonContractor;
  @override
  final String? assignedPersonUserId;
  @override
  final String? contractId;
  @override
  final String? dyHodUserId;
  @override
  final String? rfiValidation;
  final List<dynamic>? _checklistItems;
  @override
  List<dynamic>? get checklistItems {
    final value = _checklistItems;
    if (value == null) return null;
    if (_checklistItems is EqualUnmodifiableListView) return _checklistItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<dynamic>? _enclosure;
  @override
  List<dynamic>? get enclosure {
    final value = _enclosure;
    if (value == null) return null;
    if (_enclosure is EqualUnmodifiableListView) return _enclosure;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final MeasurementModel? measurements;
  @override
  @JsonKey(name: 'contractor_submitted_date')
  final String? contractorSubmittedDate;
  @override
  @JsonKey(name: 'engineer_submitted_date')
  final String? engineerSubmittedDate;
  @override
  final bool? contractorEsignDone;
  @override
  final bool? engineerEsignDone;
  @override
  final String? closedDate;
  @override
  final bool? isDeleted;
  @override
  final String? deletedAt;
  final List<dynamic>? _attachments;
  @override
  List<dynamic>? get attachments {
    final value = _attachments;
    if (value == null) return null;
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? estatus;
  final List<String>? _enclosuresList;
  @override
  List<String>? get enclosuresList {
    final value = _enclosuresList;
    if (value == null) return null;
    if (_enclosuresList is EqualUnmodifiableListView) return _enclosuresList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'RfiDetailModel(id: $id, rfiId: $rfiId, project: $project, work: $work, contract: $contract, structureType: $structureType, structure: $structure, component: $component, element: $element, activity: $activity, p6ActivityId: $p6ActivityId, pmisCalcFk: $pmisCalcFk, reasonForDelete: $reasonForDelete, rfiDescription: $rfiDescription, action: $action, typeOfRFI: $typeOfRFI, nameOfRepresentative: $nameOfRepresentative, enclosures: $enclosures, location: $location, description: $description, timeOfInspection: $timeOfInspection, dateOfSubmission: $dateOfSubmission, dateOfInspection: $dateOfInspection, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, emailUser: $emailUser, status: $status, assignedPersonClient: $assignedPersonClient, clientDepartment: $clientDepartment, txnId: $txnId, assignedPersonContractor: $assignedPersonContractor, assignedPersonUserId: $assignedPersonUserId, contractId: $contractId, dyHodUserId: $dyHodUserId, rfiValidation: $rfiValidation, checklistItems: $checklistItems, enclosure: $enclosure, measurements: $measurements, contractorSubmittedDate: $contractorSubmittedDate, engineerSubmittedDate: $engineerSubmittedDate, contractorEsignDone: $contractorEsignDone, engineerEsignDone: $engineerEsignDone, closedDate: $closedDate, isDeleted: $isDeleted, deletedAt: $deletedAt, attachments: $attachments, estatus: $estatus, enclosuresList: $enclosuresList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RfiDetailModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rfiId, rfiId) || other.rfiId == rfiId) &&
            (identical(other.project, project) || other.project == project) &&
            (identical(other.work, work) || other.work == work) &&
            (identical(other.contract, contract) ||
                other.contract == contract) &&
            (identical(other.structureType, structureType) ||
                other.structureType == structureType) &&
            (identical(other.structure, structure) ||
                other.structure == structure) &&
            (identical(other.component, component) ||
                other.component == component) &&
            (identical(other.element, element) || other.element == element) &&
            (identical(other.activity, activity) ||
                other.activity == activity) &&
            (identical(other.p6ActivityId, p6ActivityId) ||
                other.p6ActivityId == p6ActivityId) &&
            (identical(other.pmisCalcFk, pmisCalcFk) ||
                other.pmisCalcFk == pmisCalcFk) &&
            (identical(other.reasonForDelete, reasonForDelete) ||
                other.reasonForDelete == reasonForDelete) &&
            (identical(other.rfiDescription, rfiDescription) ||
                other.rfiDescription == rfiDescription) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.typeOfRFI, typeOfRFI) ||
                other.typeOfRFI == typeOfRFI) &&
            (identical(other.nameOfRepresentative, nameOfRepresentative) ||
                other.nameOfRepresentative == nameOfRepresentative) &&
            (identical(other.enclosures, enclosures) ||
                other.enclosures == enclosures) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.timeOfInspection, timeOfInspection) ||
                other.timeOfInspection == timeOfInspection) &&
            (identical(other.dateOfSubmission, dateOfSubmission) ||
                other.dateOfSubmission == dateOfSubmission) &&
            (identical(other.dateOfInspection, dateOfInspection) ||
                other.dateOfInspection == dateOfInspection) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.emailUser, emailUser) ||
                other.emailUser == emailUser) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.assignedPersonClient, assignedPersonClient) ||
                other.assignedPersonClient == assignedPersonClient) &&
            (identical(other.clientDepartment, clientDepartment) ||
                other.clientDepartment == clientDepartment) &&
            (identical(other.txnId, txnId) || other.txnId == txnId) &&
            (identical(
                  other.assignedPersonContractor,
                  assignedPersonContractor,
                ) ||
                other.assignedPersonContractor == assignedPersonContractor) &&
            (identical(other.assignedPersonUserId, assignedPersonUserId) ||
                other.assignedPersonUserId == assignedPersonUserId) &&
            (identical(other.contractId, contractId) ||
                other.contractId == contractId) &&
            (identical(other.dyHodUserId, dyHodUserId) ||
                other.dyHodUserId == dyHodUserId) &&
            (identical(other.rfiValidation, rfiValidation) ||
                other.rfiValidation == rfiValidation) &&
            const DeepCollectionEquality().equals(
              other._checklistItems,
              _checklistItems,
            ) &&
            const DeepCollectionEquality().equals(
              other._enclosure,
              _enclosure,
            ) &&
            (identical(other.measurements, measurements) ||
                other.measurements == measurements) &&
            (identical(
                  other.contractorSubmittedDate,
                  contractorSubmittedDate,
                ) ||
                other.contractorSubmittedDate == contractorSubmittedDate) &&
            (identical(other.engineerSubmittedDate, engineerSubmittedDate) ||
                other.engineerSubmittedDate == engineerSubmittedDate) &&
            (identical(other.contractorEsignDone, contractorEsignDone) ||
                other.contractorEsignDone == contractorEsignDone) &&
            (identical(other.engineerEsignDone, engineerEsignDone) ||
                other.engineerEsignDone == engineerEsignDone) &&
            (identical(other.closedDate, closedDate) ||
                other.closedDate == closedDate) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            const DeepCollectionEquality().equals(
              other._attachments,
              _attachments,
            ) &&
            (identical(other.estatus, estatus) || other.estatus == estatus) &&
            const DeepCollectionEquality().equals(
              other._enclosuresList,
              _enclosuresList,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    rfiId,
    project,
    work,
    contract,
    structureType,
    structure,
    component,
    element,
    activity,
    p6ActivityId,
    pmisCalcFk,
    reasonForDelete,
    rfiDescription,
    action,
    typeOfRFI,
    nameOfRepresentative,
    enclosures,
    location,
    description,
    timeOfInspection,
    dateOfSubmission,
    dateOfInspection,
    createdAt,
    updatedAt,
    createdBy,
    emailUser,
    status,
    assignedPersonClient,
    clientDepartment,
    txnId,
    assignedPersonContractor,
    assignedPersonUserId,
    contractId,
    dyHodUserId,
    rfiValidation,
    const DeepCollectionEquality().hash(_checklistItems),
    const DeepCollectionEquality().hash(_enclosure),
    measurements,
    contractorSubmittedDate,
    engineerSubmittedDate,
    contractorEsignDone,
    engineerEsignDone,
    closedDate,
    isDeleted,
    deletedAt,
    const DeepCollectionEquality().hash(_attachments),
    estatus,
    const DeepCollectionEquality().hash(_enclosuresList),
  ]);

  /// Create a copy of RfiDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RfiDetailModelImplCopyWith<_$RfiDetailModelImpl> get copyWith =>
      __$$RfiDetailModelImplCopyWithImpl<_$RfiDetailModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RfiDetailModelImplToJson(this);
  }
}

abstract class _RfiDetailModel implements RfiDetailModel {
  const factory _RfiDetailModel({
    final int? id,
    @JsonKey(name: 'rfi_Id') final String? rfiId,
    final String? project,
    final String? work,
    final String? contract,
    final String? structureType,
    final String? structure,
    final String? component,
    final String? element,
    final String? activity,
    final String? p6ActivityId,
    final String? pmisCalcFk,
    final String? reasonForDelete,
    final String? rfiDescription,
    final String? action,
    final String? typeOfRFI,
    final String? nameOfRepresentative,
    final String? enclosures,
    final String? location,
    final String? description,
    final String? timeOfInspection,
    final String? dateOfSubmission,
    final String? dateOfInspection,
    final String? createdAt,
    final String? updatedAt,
    final String? createdBy,
    final String? emailUser,
    final String? status,
    final String? assignedPersonClient,
    final String? clientDepartment,
    @JsonKey(name: 'txn_id') final String? txnId,
    final String? assignedPersonContractor,
    final String? assignedPersonUserId,
    final String? contractId,
    final String? dyHodUserId,
    final String? rfiValidation,
    final List<dynamic>? checklistItems,
    final List<dynamic>? enclosure,
    final MeasurementModel? measurements,
    @JsonKey(name: 'contractor_submitted_date')
    final String? contractorSubmittedDate,
    @JsonKey(name: 'engineer_submitted_date')
    final String? engineerSubmittedDate,
    final bool? contractorEsignDone,
    final bool? engineerEsignDone,
    final String? closedDate,
    final bool? isDeleted,
    final String? deletedAt,
    final List<dynamic>? attachments,
    final String? estatus,
    final List<String>? enclosuresList,
  }) = _$RfiDetailModelImpl;

  factory _RfiDetailModel.fromJson(Map<String, dynamic> json) =
      _$RfiDetailModelImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'rfi_Id')
  String? get rfiId;
  @override
  String? get project;
  @override
  String? get work;
  @override
  String? get contract;
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
  String? get p6ActivityId;
  @override
  String? get pmisCalcFk;
  @override
  String? get reasonForDelete;
  @override
  String? get rfiDescription;
  @override
  String? get action;
  @override
  String? get typeOfRFI;
  @override
  String? get nameOfRepresentative;
  @override
  String? get enclosures;
  @override
  String? get location;
  @override
  String? get description;
  @override
  String? get timeOfInspection;
  @override
  String? get dateOfSubmission;
  @override
  String? get dateOfInspection;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  String? get createdBy;
  @override
  String? get emailUser;
  @override
  String? get status;
  @override
  String? get assignedPersonClient;
  @override
  String? get clientDepartment;
  @override
  @JsonKey(name: 'txn_id')
  String? get txnId;
  @override
  String? get assignedPersonContractor;
  @override
  String? get assignedPersonUserId;
  @override
  String? get contractId;
  @override
  String? get dyHodUserId;
  @override
  String? get rfiValidation;
  @override
  List<dynamic>? get checklistItems;
  @override
  List<dynamic>? get enclosure;
  @override
  MeasurementModel? get measurements;
  @override
  @JsonKey(name: 'contractor_submitted_date')
  String? get contractorSubmittedDate;
  @override
  @JsonKey(name: 'engineer_submitted_date')
  String? get engineerSubmittedDate;
  @override
  bool? get contractorEsignDone;
  @override
  bool? get engineerEsignDone;
  @override
  String? get closedDate;
  @override
  bool? get isDeleted;
  @override
  String? get deletedAt;
  @override
  List<dynamic>? get attachments;
  @override
  String? get estatus;
  @override
  List<String>? get enclosuresList;

  /// Create a copy of RfiDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RfiDetailModelImplCopyWith<_$RfiDetailModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MeasurementModel _$MeasurementModelFromJson(Map<String, dynamic> json) {
  return _MeasurementModel.fromJson(json);
}

/// @nodoc
mixin _$MeasurementModel {
  int? get id => throw _privateConstructorUsedError;
  String? get measurementType => throw _privateConstructorUsedError;
  dynamic get length => throw _privateConstructorUsedError;
  dynamic get breadth => throw _privateConstructorUsedError;
  dynamic get height => throw _privateConstructorUsedError;
  dynamic get weight => throw _privateConstructorUsedError;
  String? get units => throw _privateConstructorUsedError;
  int? get noOfItems => throw _privateConstructorUsedError;
  dynamic get totalQty => throw _privateConstructorUsedError;
  dynamic get l => throw _privateConstructorUsedError;
  dynamic get b => throw _privateConstructorUsedError;
  dynamic get h => throw _privateConstructorUsedError;
  int? get no => throw _privateConstructorUsedError;

  /// Serializes this MeasurementModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeasurementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeasurementModelCopyWith<MeasurementModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeasurementModelCopyWith<$Res> {
  factory $MeasurementModelCopyWith(
    MeasurementModel value,
    $Res Function(MeasurementModel) then,
  ) = _$MeasurementModelCopyWithImpl<$Res, MeasurementModel>;
  @useResult
  $Res call({
    int? id,
    String? measurementType,
    dynamic length,
    dynamic breadth,
    dynamic height,
    dynamic weight,
    String? units,
    int? noOfItems,
    dynamic totalQty,
    dynamic l,
    dynamic b,
    dynamic h,
    int? no,
  });
}

/// @nodoc
class _$MeasurementModelCopyWithImpl<$Res, $Val extends MeasurementModel>
    implements $MeasurementModelCopyWith<$Res> {
  _$MeasurementModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeasurementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? measurementType = freezed,
    Object? length = freezed,
    Object? breadth = freezed,
    Object? height = freezed,
    Object? weight = freezed,
    Object? units = freezed,
    Object? noOfItems = freezed,
    Object? totalQty = freezed,
    Object? l = freezed,
    Object? b = freezed,
    Object? h = freezed,
    Object? no = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            measurementType: freezed == measurementType
                ? _value.measurementType
                : measurementType // ignore: cast_nullable_to_non_nullable
                      as String?,
            length: freezed == length
                ? _value.length
                : length // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            breadth: freezed == breadth
                ? _value.breadth
                : breadth // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            weight: freezed == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            units: freezed == units
                ? _value.units
                : units // ignore: cast_nullable_to_non_nullable
                      as String?,
            noOfItems: freezed == noOfItems
                ? _value.noOfItems
                : noOfItems // ignore: cast_nullable_to_non_nullable
                      as int?,
            totalQty: freezed == totalQty
                ? _value.totalQty
                : totalQty // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            l: freezed == l
                ? _value.l
                : l // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            b: freezed == b
                ? _value.b
                : b // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            h: freezed == h
                ? _value.h
                : h // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            no: freezed == no
                ? _value.no
                : no // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MeasurementModelImplCopyWith<$Res>
    implements $MeasurementModelCopyWith<$Res> {
  factory _$$MeasurementModelImplCopyWith(
    _$MeasurementModelImpl value,
    $Res Function(_$MeasurementModelImpl) then,
  ) = __$$MeasurementModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String? measurementType,
    dynamic length,
    dynamic breadth,
    dynamic height,
    dynamic weight,
    String? units,
    int? noOfItems,
    dynamic totalQty,
    dynamic l,
    dynamic b,
    dynamic h,
    int? no,
  });
}

/// @nodoc
class __$$MeasurementModelImplCopyWithImpl<$Res>
    extends _$MeasurementModelCopyWithImpl<$Res, _$MeasurementModelImpl>
    implements _$$MeasurementModelImplCopyWith<$Res> {
  __$$MeasurementModelImplCopyWithImpl(
    _$MeasurementModelImpl _value,
    $Res Function(_$MeasurementModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MeasurementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? measurementType = freezed,
    Object? length = freezed,
    Object? breadth = freezed,
    Object? height = freezed,
    Object? weight = freezed,
    Object? units = freezed,
    Object? noOfItems = freezed,
    Object? totalQty = freezed,
    Object? l = freezed,
    Object? b = freezed,
    Object? h = freezed,
    Object? no = freezed,
  }) {
    return _then(
      _$MeasurementModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        measurementType: freezed == measurementType
            ? _value.measurementType
            : measurementType // ignore: cast_nullable_to_non_nullable
                  as String?,
        length: freezed == length
            ? _value.length
            : length // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        breadth: freezed == breadth
            ? _value.breadth
            : breadth // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        weight: freezed == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        units: freezed == units
            ? _value.units
            : units // ignore: cast_nullable_to_non_nullable
                  as String?,
        noOfItems: freezed == noOfItems
            ? _value.noOfItems
            : noOfItems // ignore: cast_nullable_to_non_nullable
                  as int?,
        totalQty: freezed == totalQty
            ? _value.totalQty
            : totalQty // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        l: freezed == l
            ? _value.l
            : l // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        b: freezed == b
            ? _value.b
            : b // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        h: freezed == h
            ? _value.h
            : h // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        no: freezed == no
            ? _value.no
            : no // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MeasurementModelImpl implements _MeasurementModel {
  const _$MeasurementModelImpl({
    this.id,
    this.measurementType,
    this.length,
    this.breadth,
    this.height,
    this.weight,
    this.units,
    this.noOfItems,
    this.totalQty,
    this.l,
    this.b,
    this.h,
    this.no,
  });

  factory _$MeasurementModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeasurementModelImplFromJson(json);

  @override
  final int? id;
  @override
  final String? measurementType;
  @override
  final dynamic length;
  @override
  final dynamic breadth;
  @override
  final dynamic height;
  @override
  final dynamic weight;
  @override
  final String? units;
  @override
  final int? noOfItems;
  @override
  final dynamic totalQty;
  @override
  final dynamic l;
  @override
  final dynamic b;
  @override
  final dynamic h;
  @override
  final int? no;

  @override
  String toString() {
    return 'MeasurementModel(id: $id, measurementType: $measurementType, length: $length, breadth: $breadth, height: $height, weight: $weight, units: $units, noOfItems: $noOfItems, totalQty: $totalQty, l: $l, b: $b, h: $h, no: $no)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasurementModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.measurementType, measurementType) ||
                other.measurementType == measurementType) &&
            const DeepCollectionEquality().equals(other.length, length) &&
            const DeepCollectionEquality().equals(other.breadth, breadth) &&
            const DeepCollectionEquality().equals(other.height, height) &&
            const DeepCollectionEquality().equals(other.weight, weight) &&
            (identical(other.units, units) || other.units == units) &&
            (identical(other.noOfItems, noOfItems) ||
                other.noOfItems == noOfItems) &&
            const DeepCollectionEquality().equals(other.totalQty, totalQty) &&
            const DeepCollectionEquality().equals(other.l, l) &&
            const DeepCollectionEquality().equals(other.b, b) &&
            const DeepCollectionEquality().equals(other.h, h) &&
            (identical(other.no, no) || other.no == no));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    measurementType,
    const DeepCollectionEquality().hash(length),
    const DeepCollectionEquality().hash(breadth),
    const DeepCollectionEquality().hash(height),
    const DeepCollectionEquality().hash(weight),
    units,
    noOfItems,
    const DeepCollectionEquality().hash(totalQty),
    const DeepCollectionEquality().hash(l),
    const DeepCollectionEquality().hash(b),
    const DeepCollectionEquality().hash(h),
    no,
  );

  /// Create a copy of MeasurementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasurementModelImplCopyWith<_$MeasurementModelImpl> get copyWith =>
      __$$MeasurementModelImplCopyWithImpl<_$MeasurementModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MeasurementModelImplToJson(this);
  }
}

abstract class _MeasurementModel implements MeasurementModel {
  const factory _MeasurementModel({
    final int? id,
    final String? measurementType,
    final dynamic length,
    final dynamic breadth,
    final dynamic height,
    final dynamic weight,
    final String? units,
    final int? noOfItems,
    final dynamic totalQty,
    final dynamic l,
    final dynamic b,
    final dynamic h,
    final int? no,
  }) = _$MeasurementModelImpl;

  factory _MeasurementModel.fromJson(Map<String, dynamic> json) =
      _$MeasurementModelImpl.fromJson;

  @override
  int? get id;
  @override
  String? get measurementType;
  @override
  dynamic get length;
  @override
  dynamic get breadth;
  @override
  dynamic get height;
  @override
  dynamic get weight;
  @override
  String? get units;
  @override
  int? get noOfItems;
  @override
  dynamic get totalQty;
  @override
  dynamic get l;
  @override
  dynamic get b;
  @override
  dynamic get h;
  @override
  int? get no;

  /// Create a copy of MeasurementModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeasurementModelImplCopyWith<_$MeasurementModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
