// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checklist_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChecklistDetail _$ChecklistDetailFromJson(Map<String, dynamic> json) {
  return _ChecklistDetail.fromJson(json);
}

/// @nodoc
mixin _$ChecklistDetail {
  int get id => throw _privateConstructorUsedError;
  String get checklistDescription => throw _privateConstructorUsedError;
  List<RfiChecklistItem> get rfiChecklistItems =>
      throw _privateConstructorUsedError;

  /// Serializes this ChecklistDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChecklistDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChecklistDetailCopyWith<ChecklistDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChecklistDetailCopyWith<$Res> {
  factory $ChecklistDetailCopyWith(
    ChecklistDetail value,
    $Res Function(ChecklistDetail) then,
  ) = _$ChecklistDetailCopyWithImpl<$Res, ChecklistDetail>;
  @useResult
  $Res call({
    int id,
    String checklistDescription,
    List<RfiChecklistItem> rfiChecklistItems,
  });
}

/// @nodoc
class _$ChecklistDetailCopyWithImpl<$Res, $Val extends ChecklistDetail>
    implements $ChecklistDetailCopyWith<$Res> {
  _$ChecklistDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChecklistDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? checklistDescription = null,
    Object? rfiChecklistItems = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            checklistDescription: null == checklistDescription
                ? _value.checklistDescription
                : checklistDescription // ignore: cast_nullable_to_non_nullable
                      as String,
            rfiChecklistItems: null == rfiChecklistItems
                ? _value.rfiChecklistItems
                : rfiChecklistItems // ignore: cast_nullable_to_non_nullable
                      as List<RfiChecklistItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChecklistDetailImplCopyWith<$Res>
    implements $ChecklistDetailCopyWith<$Res> {
  factory _$$ChecklistDetailImplCopyWith(
    _$ChecklistDetailImpl value,
    $Res Function(_$ChecklistDetailImpl) then,
  ) = __$$ChecklistDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String checklistDescription,
    List<RfiChecklistItem> rfiChecklistItems,
  });
}

/// @nodoc
class __$$ChecklistDetailImplCopyWithImpl<$Res>
    extends _$ChecklistDetailCopyWithImpl<$Res, _$ChecklistDetailImpl>
    implements _$$ChecklistDetailImplCopyWith<$Res> {
  __$$ChecklistDetailImplCopyWithImpl(
    _$ChecklistDetailImpl _value,
    $Res Function(_$ChecklistDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChecklistDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? checklistDescription = null,
    Object? rfiChecklistItems = null,
  }) {
    return _then(
      _$ChecklistDetailImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        checklistDescription: null == checklistDescription
            ? _value.checklistDescription
            : checklistDescription // ignore: cast_nullable_to_non_nullable
                  as String,
        rfiChecklistItems: null == rfiChecklistItems
            ? _value._rfiChecklistItems
            : rfiChecklistItems // ignore: cast_nullable_to_non_nullable
                  as List<RfiChecklistItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChecklistDetailImpl implements _ChecklistDetail {
  const _$ChecklistDetailImpl({
    required this.id,
    required this.checklistDescription,
    final List<RfiChecklistItem> rfiChecklistItems = const [],
  }) : _rfiChecklistItems = rfiChecklistItems;

  factory _$ChecklistDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChecklistDetailImplFromJson(json);

  @override
  final int id;
  @override
  final String checklistDescription;
  final List<RfiChecklistItem> _rfiChecklistItems;
  @override
  @JsonKey()
  List<RfiChecklistItem> get rfiChecklistItems {
    if (_rfiChecklistItems is EqualUnmodifiableListView)
      return _rfiChecklistItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rfiChecklistItems);
  }

  @override
  String toString() {
    return 'ChecklistDetail(id: $id, checklistDescription: $checklistDescription, rfiChecklistItems: $rfiChecklistItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChecklistDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.checklistDescription, checklistDescription) ||
                other.checklistDescription == checklistDescription) &&
            const DeepCollectionEquality().equals(
              other._rfiChecklistItems,
              _rfiChecklistItems,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    checklistDescription,
    const DeepCollectionEquality().hash(_rfiChecklistItems),
  );

  /// Create a copy of ChecklistDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChecklistDetailImplCopyWith<_$ChecklistDetailImpl> get copyWith =>
      __$$ChecklistDetailImplCopyWithImpl<_$ChecklistDetailImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChecklistDetailImplToJson(this);
  }
}

abstract class _ChecklistDetail implements ChecklistDetail {
  const factory _ChecklistDetail({
    required final int id,
    required final String checklistDescription,
    final List<RfiChecklistItem> rfiChecklistItems,
  }) = _$ChecklistDetailImpl;

  factory _ChecklistDetail.fromJson(Map<String, dynamic> json) =
      _$ChecklistDetailImpl.fromJson;

  @override
  int get id;
  @override
  String get checklistDescription;
  @override
  List<RfiChecklistItem> get rfiChecklistItems;

  /// Create a copy of ChecklistDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChecklistDetailImplCopyWith<_$ChecklistDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RfiChecklistItem _$RfiChecklistItemFromJson(Map<String, dynamic> json) {
  return _RfiChecklistItem.fromJson(json);
}

/// @nodoc
mixin _$RfiChecklistItem {
  int get id => throw _privateConstructorUsedError;
  String get gradeOfConcrete => throw _privateConstructorUsedError;
  String get contractorStatus => throw _privateConstructorUsedError;
  String? get engineerStatus => throw _privateConstructorUsedError;
  String get contractorRemark => throw _privateConstructorUsedError;
  String get aeRemark => throw _privateConstructorUsedError;
  String get enclosureName => throw _privateConstructorUsedError;
  String get uploadedby => throw _privateConstructorUsedError;

  /// Serializes this RfiChecklistItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RfiChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RfiChecklistItemCopyWith<RfiChecklistItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RfiChecklistItemCopyWith<$Res> {
  factory $RfiChecklistItemCopyWith(
    RfiChecklistItem value,
    $Res Function(RfiChecklistItem) then,
  ) = _$RfiChecklistItemCopyWithImpl<$Res, RfiChecklistItem>;
  @useResult
  $Res call({
    int id,
    String gradeOfConcrete,
    String contractorStatus,
    String? engineerStatus,
    String contractorRemark,
    String aeRemark,
    String enclosureName,
    String uploadedby,
  });
}

/// @nodoc
class _$RfiChecklistItemCopyWithImpl<$Res, $Val extends RfiChecklistItem>
    implements $RfiChecklistItemCopyWith<$Res> {
  _$RfiChecklistItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RfiChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gradeOfConcrete = null,
    Object? contractorStatus = null,
    Object? engineerStatus = freezed,
    Object? contractorRemark = null,
    Object? aeRemark = null,
    Object? enclosureName = null,
    Object? uploadedby = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            gradeOfConcrete: null == gradeOfConcrete
                ? _value.gradeOfConcrete
                : gradeOfConcrete // ignore: cast_nullable_to_non_nullable
                      as String,
            contractorStatus: null == contractorStatus
                ? _value.contractorStatus
                : contractorStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            engineerStatus: freezed == engineerStatus
                ? _value.engineerStatus
                : engineerStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            contractorRemark: null == contractorRemark
                ? _value.contractorRemark
                : contractorRemark // ignore: cast_nullable_to_non_nullable
                      as String,
            aeRemark: null == aeRemark
                ? _value.aeRemark
                : aeRemark // ignore: cast_nullable_to_non_nullable
                      as String,
            enclosureName: null == enclosureName
                ? _value.enclosureName
                : enclosureName // ignore: cast_nullable_to_non_nullable
                      as String,
            uploadedby: null == uploadedby
                ? _value.uploadedby
                : uploadedby // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RfiChecklistItemImplCopyWith<$Res>
    implements $RfiChecklistItemCopyWith<$Res> {
  factory _$$RfiChecklistItemImplCopyWith(
    _$RfiChecklistItemImpl value,
    $Res Function(_$RfiChecklistItemImpl) then,
  ) = __$$RfiChecklistItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String gradeOfConcrete,
    String contractorStatus,
    String? engineerStatus,
    String contractorRemark,
    String aeRemark,
    String enclosureName,
    String uploadedby,
  });
}

/// @nodoc
class __$$RfiChecklistItemImplCopyWithImpl<$Res>
    extends _$RfiChecklistItemCopyWithImpl<$Res, _$RfiChecklistItemImpl>
    implements _$$RfiChecklistItemImplCopyWith<$Res> {
  __$$RfiChecklistItemImplCopyWithImpl(
    _$RfiChecklistItemImpl _value,
    $Res Function(_$RfiChecklistItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RfiChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gradeOfConcrete = null,
    Object? contractorStatus = null,
    Object? engineerStatus = freezed,
    Object? contractorRemark = null,
    Object? aeRemark = null,
    Object? enclosureName = null,
    Object? uploadedby = null,
  }) {
    return _then(
      _$RfiChecklistItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        gradeOfConcrete: null == gradeOfConcrete
            ? _value.gradeOfConcrete
            : gradeOfConcrete // ignore: cast_nullable_to_non_nullable
                  as String,
        contractorStatus: null == contractorStatus
            ? _value.contractorStatus
            : contractorStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        engineerStatus: freezed == engineerStatus
            ? _value.engineerStatus
            : engineerStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        contractorRemark: null == contractorRemark
            ? _value.contractorRemark
            : contractorRemark // ignore: cast_nullable_to_non_nullable
                  as String,
        aeRemark: null == aeRemark
            ? _value.aeRemark
            : aeRemark // ignore: cast_nullable_to_non_nullable
                  as String,
        enclosureName: null == enclosureName
            ? _value.enclosureName
            : enclosureName // ignore: cast_nullable_to_non_nullable
                  as String,
        uploadedby: null == uploadedby
            ? _value.uploadedby
            : uploadedby // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RfiChecklistItemImpl implements _RfiChecklistItem {
  const _$RfiChecklistItemImpl({
    required this.id,
    this.gradeOfConcrete = '',
    this.contractorStatus = '',
    this.engineerStatus,
    this.contractorRemark = '',
    this.aeRemark = '',
    this.enclosureName = '',
    this.uploadedby = '',
  });

  factory _$RfiChecklistItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RfiChecklistItemImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String gradeOfConcrete;
  @override
  @JsonKey()
  final String contractorStatus;
  @override
  final String? engineerStatus;
  @override
  @JsonKey()
  final String contractorRemark;
  @override
  @JsonKey()
  final String aeRemark;
  @override
  @JsonKey()
  final String enclosureName;
  @override
  @JsonKey()
  final String uploadedby;

  @override
  String toString() {
    return 'RfiChecklistItem(id: $id, gradeOfConcrete: $gradeOfConcrete, contractorStatus: $contractorStatus, engineerStatus: $engineerStatus, contractorRemark: $contractorRemark, aeRemark: $aeRemark, enclosureName: $enclosureName, uploadedby: $uploadedby)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RfiChecklistItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gradeOfConcrete, gradeOfConcrete) ||
                other.gradeOfConcrete == gradeOfConcrete) &&
            (identical(other.contractorStatus, contractorStatus) ||
                other.contractorStatus == contractorStatus) &&
            (identical(other.engineerStatus, engineerStatus) ||
                other.engineerStatus == engineerStatus) &&
            (identical(other.contractorRemark, contractorRemark) ||
                other.contractorRemark == contractorRemark) &&
            (identical(other.aeRemark, aeRemark) ||
                other.aeRemark == aeRemark) &&
            (identical(other.enclosureName, enclosureName) ||
                other.enclosureName == enclosureName) &&
            (identical(other.uploadedby, uploadedby) ||
                other.uploadedby == uploadedby));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    gradeOfConcrete,
    contractorStatus,
    engineerStatus,
    contractorRemark,
    aeRemark,
    enclosureName,
    uploadedby,
  );

  /// Create a copy of RfiChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RfiChecklistItemImplCopyWith<_$RfiChecklistItemImpl> get copyWith =>
      __$$RfiChecklistItemImplCopyWithImpl<_$RfiChecklistItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RfiChecklistItemImplToJson(this);
  }
}

abstract class _RfiChecklistItem implements RfiChecklistItem {
  const factory _RfiChecklistItem({
    required final int id,
    final String gradeOfConcrete,
    final String contractorStatus,
    final String? engineerStatus,
    final String contractorRemark,
    final String aeRemark,
    final String enclosureName,
    final String uploadedby,
  }) = _$RfiChecklistItemImpl;

  factory _RfiChecklistItem.fromJson(Map<String, dynamic> json) =
      _$RfiChecklistItemImpl.fromJson;

  @override
  int get id;
  @override
  String get gradeOfConcrete;
  @override
  String get contractorStatus;
  @override
  String? get engineerStatus;
  @override
  String get contractorRemark;
  @override
  String get aeRemark;
  @override
  String get enclosureName;
  @override
  String get uploadedby;

  /// Create a copy of RfiChecklistItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RfiChecklistItemImplCopyWith<_$RfiChecklistItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
