// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rfi_log_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RfiLogItem _$RfiLogItemFromJson(Map<String, dynamic> json) {
  return _RfiLogItem.fromJson(json);
}

/// @nodoc
mixin _$RfiLogItem {
  int get id => throw _privateConstructorUsedError;
  String get rfiId => throw _privateConstructorUsedError;
  String get dateOfSubmission => throw _privateConstructorUsedError;
  String get structure => throw _privateConstructorUsedError;
  String get rfiDescription => throw _privateConstructorUsedError;
  String get rfiRequestedBy => throw _privateConstructorUsedError;
  String get department => throw _privateConstructorUsedError;
  String get person => throw _privateConstructorUsedError;
  String get dateRaised => throw _privateConstructorUsedError;
  String? get dateResponded => throw _privateConstructorUsedError;
  String? get enggApproval => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get validationStatus => throw _privateConstructorUsedError;
  String get project => throw _privateConstructorUsedError;
  String get work => throw _privateConstructorUsedError;
  String get contract => throw _privateConstructorUsedError;
  String get nameOfRepresentative => throw _privateConstructorUsedError;
  String? get txnId => throw _privateConstructorUsedError;
  String? get estatus => throw _privateConstructorUsedError;

  /// Serializes this RfiLogItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RfiLogItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RfiLogItemCopyWith<RfiLogItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RfiLogItemCopyWith<$Res> {
  factory $RfiLogItemCopyWith(
    RfiLogItem value,
    $Res Function(RfiLogItem) then,
  ) = _$RfiLogItemCopyWithImpl<$Res, RfiLogItem>;
  @useResult
  $Res call({
    int id,
    String rfiId,
    String dateOfSubmission,
    String structure,
    String rfiDescription,
    String rfiRequestedBy,
    String department,
    String person,
    String dateRaised,
    String? dateResponded,
    String? enggApproval,
    String status,
    String? notes,
    String? validationStatus,
    String project,
    String work,
    String contract,
    String nameOfRepresentative,
    String? txnId,
    String? estatus,
  });
}

/// @nodoc
class _$RfiLogItemCopyWithImpl<$Res, $Val extends RfiLogItem>
    implements $RfiLogItemCopyWith<$Res> {
  _$RfiLogItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RfiLogItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rfiId = null,
    Object? dateOfSubmission = null,
    Object? structure = null,
    Object? rfiDescription = null,
    Object? rfiRequestedBy = null,
    Object? department = null,
    Object? person = null,
    Object? dateRaised = null,
    Object? dateResponded = freezed,
    Object? enggApproval = freezed,
    Object? status = null,
    Object? notes = freezed,
    Object? validationStatus = freezed,
    Object? project = null,
    Object? work = null,
    Object? contract = null,
    Object? nameOfRepresentative = null,
    Object? txnId = freezed,
    Object? estatus = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            rfiId: null == rfiId
                ? _value.rfiId
                : rfiId // ignore: cast_nullable_to_non_nullable
                      as String,
            dateOfSubmission: null == dateOfSubmission
                ? _value.dateOfSubmission
                : dateOfSubmission // ignore: cast_nullable_to_non_nullable
                      as String,
            structure: null == structure
                ? _value.structure
                : structure // ignore: cast_nullable_to_non_nullable
                      as String,
            rfiDescription: null == rfiDescription
                ? _value.rfiDescription
                : rfiDescription // ignore: cast_nullable_to_non_nullable
                      as String,
            rfiRequestedBy: null == rfiRequestedBy
                ? _value.rfiRequestedBy
                : rfiRequestedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            department: null == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                      as String,
            person: null == person
                ? _value.person
                : person // ignore: cast_nullable_to_non_nullable
                      as String,
            dateRaised: null == dateRaised
                ? _value.dateRaised
                : dateRaised // ignore: cast_nullable_to_non_nullable
                      as String,
            dateResponded: freezed == dateResponded
                ? _value.dateResponded
                : dateResponded // ignore: cast_nullable_to_non_nullable
                      as String?,
            enggApproval: freezed == enggApproval
                ? _value.enggApproval
                : enggApproval // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            validationStatus: freezed == validationStatus
                ? _value.validationStatus
                : validationStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            project: null == project
                ? _value.project
                : project // ignore: cast_nullable_to_non_nullable
                      as String,
            work: null == work
                ? _value.work
                : work // ignore: cast_nullable_to_non_nullable
                      as String,
            contract: null == contract
                ? _value.contract
                : contract // ignore: cast_nullable_to_non_nullable
                      as String,
            nameOfRepresentative: null == nameOfRepresentative
                ? _value.nameOfRepresentative
                : nameOfRepresentative // ignore: cast_nullable_to_non_nullable
                      as String,
            txnId: freezed == txnId
                ? _value.txnId
                : txnId // ignore: cast_nullable_to_non_nullable
                      as String?,
            estatus: freezed == estatus
                ? _value.estatus
                : estatus // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RfiLogItemImplCopyWith<$Res>
    implements $RfiLogItemCopyWith<$Res> {
  factory _$$RfiLogItemImplCopyWith(
    _$RfiLogItemImpl value,
    $Res Function(_$RfiLogItemImpl) then,
  ) = __$$RfiLogItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String rfiId,
    String dateOfSubmission,
    String structure,
    String rfiDescription,
    String rfiRequestedBy,
    String department,
    String person,
    String dateRaised,
    String? dateResponded,
    String? enggApproval,
    String status,
    String? notes,
    String? validationStatus,
    String project,
    String work,
    String contract,
    String nameOfRepresentative,
    String? txnId,
    String? estatus,
  });
}

/// @nodoc
class __$$RfiLogItemImplCopyWithImpl<$Res>
    extends _$RfiLogItemCopyWithImpl<$Res, _$RfiLogItemImpl>
    implements _$$RfiLogItemImplCopyWith<$Res> {
  __$$RfiLogItemImplCopyWithImpl(
    _$RfiLogItemImpl _value,
    $Res Function(_$RfiLogItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RfiLogItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rfiId = null,
    Object? dateOfSubmission = null,
    Object? structure = null,
    Object? rfiDescription = null,
    Object? rfiRequestedBy = null,
    Object? department = null,
    Object? person = null,
    Object? dateRaised = null,
    Object? dateResponded = freezed,
    Object? enggApproval = freezed,
    Object? status = null,
    Object? notes = freezed,
    Object? validationStatus = freezed,
    Object? project = null,
    Object? work = null,
    Object? contract = null,
    Object? nameOfRepresentative = null,
    Object? txnId = freezed,
    Object? estatus = freezed,
  }) {
    return _then(
      _$RfiLogItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        rfiId: null == rfiId
            ? _value.rfiId
            : rfiId // ignore: cast_nullable_to_non_nullable
                  as String,
        dateOfSubmission: null == dateOfSubmission
            ? _value.dateOfSubmission
            : dateOfSubmission // ignore: cast_nullable_to_non_nullable
                  as String,
        structure: null == structure
            ? _value.structure
            : structure // ignore: cast_nullable_to_non_nullable
                  as String,
        rfiDescription: null == rfiDescription
            ? _value.rfiDescription
            : rfiDescription // ignore: cast_nullable_to_non_nullable
                  as String,
        rfiRequestedBy: null == rfiRequestedBy
            ? _value.rfiRequestedBy
            : rfiRequestedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        department: null == department
            ? _value.department
            : department // ignore: cast_nullable_to_non_nullable
                  as String,
        person: null == person
            ? _value.person
            : person // ignore: cast_nullable_to_non_nullable
                  as String,
        dateRaised: null == dateRaised
            ? _value.dateRaised
            : dateRaised // ignore: cast_nullable_to_non_nullable
                  as String,
        dateResponded: freezed == dateResponded
            ? _value.dateResponded
            : dateResponded // ignore: cast_nullable_to_non_nullable
                  as String?,
        enggApproval: freezed == enggApproval
            ? _value.enggApproval
            : enggApproval // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        validationStatus: freezed == validationStatus
            ? _value.validationStatus
            : validationStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        project: null == project
            ? _value.project
            : project // ignore: cast_nullable_to_non_nullable
                  as String,
        work: null == work
            ? _value.work
            : work // ignore: cast_nullable_to_non_nullable
                  as String,
        contract: null == contract
            ? _value.contract
            : contract // ignore: cast_nullable_to_non_nullable
                  as String,
        nameOfRepresentative: null == nameOfRepresentative
            ? _value.nameOfRepresentative
            : nameOfRepresentative // ignore: cast_nullable_to_non_nullable
                  as String,
        txnId: freezed == txnId
            ? _value.txnId
            : txnId // ignore: cast_nullable_to_non_nullable
                  as String?,
        estatus: freezed == estatus
            ? _value.estatus
            : estatus // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RfiLogItemImpl implements _RfiLogItem {
  const _$RfiLogItemImpl({
    required this.id,
    required this.rfiId,
    required this.dateOfSubmission,
    required this.structure,
    required this.rfiDescription,
    required this.rfiRequestedBy,
    required this.department,
    required this.person,
    required this.dateRaised,
    this.dateResponded,
    this.enggApproval,
    required this.status,
    this.notes,
    this.validationStatus,
    required this.project,
    required this.work,
    required this.contract,
    required this.nameOfRepresentative,
    this.txnId,
    this.estatus,
  });

  factory _$RfiLogItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RfiLogItemImplFromJson(json);

  @override
  final int id;
  @override
  final String rfiId;
  @override
  final String dateOfSubmission;
  @override
  final String structure;
  @override
  final String rfiDescription;
  @override
  final String rfiRequestedBy;
  @override
  final String department;
  @override
  final String person;
  @override
  final String dateRaised;
  @override
  final String? dateResponded;
  @override
  final String? enggApproval;
  @override
  final String status;
  @override
  final String? notes;
  @override
  final String? validationStatus;
  @override
  final String project;
  @override
  final String work;
  @override
  final String contract;
  @override
  final String nameOfRepresentative;
  @override
  final String? txnId;
  @override
  final String? estatus;

  @override
  String toString() {
    return 'RfiLogItem(id: $id, rfiId: $rfiId, dateOfSubmission: $dateOfSubmission, structure: $structure, rfiDescription: $rfiDescription, rfiRequestedBy: $rfiRequestedBy, department: $department, person: $person, dateRaised: $dateRaised, dateResponded: $dateResponded, enggApproval: $enggApproval, status: $status, notes: $notes, validationStatus: $validationStatus, project: $project, work: $work, contract: $contract, nameOfRepresentative: $nameOfRepresentative, txnId: $txnId, estatus: $estatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RfiLogItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rfiId, rfiId) || other.rfiId == rfiId) &&
            (identical(other.dateOfSubmission, dateOfSubmission) ||
                other.dateOfSubmission == dateOfSubmission) &&
            (identical(other.structure, structure) ||
                other.structure == structure) &&
            (identical(other.rfiDescription, rfiDescription) ||
                other.rfiDescription == rfiDescription) &&
            (identical(other.rfiRequestedBy, rfiRequestedBy) ||
                other.rfiRequestedBy == rfiRequestedBy) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.person, person) || other.person == person) &&
            (identical(other.dateRaised, dateRaised) ||
                other.dateRaised == dateRaised) &&
            (identical(other.dateResponded, dateResponded) ||
                other.dateResponded == dateResponded) &&
            (identical(other.enggApproval, enggApproval) ||
                other.enggApproval == enggApproval) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.validationStatus, validationStatus) ||
                other.validationStatus == validationStatus) &&
            (identical(other.project, project) || other.project == project) &&
            (identical(other.work, work) || other.work == work) &&
            (identical(other.contract, contract) ||
                other.contract == contract) &&
            (identical(other.nameOfRepresentative, nameOfRepresentative) ||
                other.nameOfRepresentative == nameOfRepresentative) &&
            (identical(other.txnId, txnId) || other.txnId == txnId) &&
            (identical(other.estatus, estatus) || other.estatus == estatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    rfiId,
    dateOfSubmission,
    structure,
    rfiDescription,
    rfiRequestedBy,
    department,
    person,
    dateRaised,
    dateResponded,
    enggApproval,
    status,
    notes,
    validationStatus,
    project,
    work,
    contract,
    nameOfRepresentative,
    txnId,
    estatus,
  ]);

  /// Create a copy of RfiLogItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RfiLogItemImplCopyWith<_$RfiLogItemImpl> get copyWith =>
      __$$RfiLogItemImplCopyWithImpl<_$RfiLogItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RfiLogItemImplToJson(this);
  }
}

abstract class _RfiLogItem implements RfiLogItem {
  const factory _RfiLogItem({
    required final int id,
    required final String rfiId,
    required final String dateOfSubmission,
    required final String structure,
    required final String rfiDescription,
    required final String rfiRequestedBy,
    required final String department,
    required final String person,
    required final String dateRaised,
    final String? dateResponded,
    final String? enggApproval,
    required final String status,
    final String? notes,
    final String? validationStatus,
    required final String project,
    required final String work,
    required final String contract,
    required final String nameOfRepresentative,
    final String? txnId,
    final String? estatus,
  }) = _$RfiLogItemImpl;

  factory _RfiLogItem.fromJson(Map<String, dynamic> json) =
      _$RfiLogItemImpl.fromJson;

  @override
  int get id;
  @override
  String get rfiId;
  @override
  String get dateOfSubmission;
  @override
  String get structure;
  @override
  String get rfiDescription;
  @override
  String get rfiRequestedBy;
  @override
  String get department;
  @override
  String get person;
  @override
  String get dateRaised;
  @override
  String? get dateResponded;
  @override
  String? get enggApproval;
  @override
  String get status;
  @override
  String? get notes;
  @override
  String? get validationStatus;
  @override
  String get project;
  @override
  String get work;
  @override
  String get contract;
  @override
  String get nameOfRepresentative;
  @override
  String? get txnId;
  @override
  String? get estatus;

  /// Create a copy of RfiLogItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RfiLogItemImplCopyWith<_$RfiLogItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
