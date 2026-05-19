// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assign_executive_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AssignExecutiveLog _$AssignExecutiveLogFromJson(Map<String, dynamic> json) {
  return _AssignExecutiveLog.fromJson(json);
}

/// @nodoc
mixin _$AssignExecutiveLog {
  int get id => throw _privateConstructorUsedError;
  String get contract => throw _privateConstructorUsedError;
  String get structureType => throw _privateConstructorUsedError;
  String get structure => throw _privateConstructorUsedError;
  String get assignedExecutive => throw _privateConstructorUsedError;

  /// Serializes this AssignExecutiveLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AssignExecutiveLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssignExecutiveLogCopyWith<AssignExecutiveLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignExecutiveLogCopyWith<$Res> {
  factory $AssignExecutiveLogCopyWith(
    AssignExecutiveLog value,
    $Res Function(AssignExecutiveLog) then,
  ) = _$AssignExecutiveLogCopyWithImpl<$Res, AssignExecutiveLog>;
  @useResult
  $Res call({
    int id,
    String contract,
    String structureType,
    String structure,
    String assignedExecutive,
  });
}

/// @nodoc
class _$AssignExecutiveLogCopyWithImpl<$Res, $Val extends AssignExecutiveLog>
    implements $AssignExecutiveLogCopyWith<$Res> {
  _$AssignExecutiveLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssignExecutiveLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contract = null,
    Object? structureType = null,
    Object? structure = null,
    Object? assignedExecutive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            contract: null == contract
                ? _value.contract
                : contract // ignore: cast_nullable_to_non_nullable
                      as String,
            structureType: null == structureType
                ? _value.structureType
                : structureType // ignore: cast_nullable_to_non_nullable
                      as String,
            structure: null == structure
                ? _value.structure
                : structure // ignore: cast_nullable_to_non_nullable
                      as String,
            assignedExecutive: null == assignedExecutive
                ? _value.assignedExecutive
                : assignedExecutive // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AssignExecutiveLogImplCopyWith<$Res>
    implements $AssignExecutiveLogCopyWith<$Res> {
  factory _$$AssignExecutiveLogImplCopyWith(
    _$AssignExecutiveLogImpl value,
    $Res Function(_$AssignExecutiveLogImpl) then,
  ) = __$$AssignExecutiveLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String contract,
    String structureType,
    String structure,
    String assignedExecutive,
  });
}

/// @nodoc
class __$$AssignExecutiveLogImplCopyWithImpl<$Res>
    extends _$AssignExecutiveLogCopyWithImpl<$Res, _$AssignExecutiveLogImpl>
    implements _$$AssignExecutiveLogImplCopyWith<$Res> {
  __$$AssignExecutiveLogImplCopyWithImpl(
    _$AssignExecutiveLogImpl _value,
    $Res Function(_$AssignExecutiveLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignExecutiveLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contract = null,
    Object? structureType = null,
    Object? structure = null,
    Object? assignedExecutive = null,
  }) {
    return _then(
      _$AssignExecutiveLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        contract: null == contract
            ? _value.contract
            : contract // ignore: cast_nullable_to_non_nullable
                  as String,
        structureType: null == structureType
            ? _value.structureType
            : structureType // ignore: cast_nullable_to_non_nullable
                  as String,
        structure: null == structure
            ? _value.structure
            : structure // ignore: cast_nullable_to_non_nullable
                  as String,
        assignedExecutive: null == assignedExecutive
            ? _value.assignedExecutive
            : assignedExecutive // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignExecutiveLogImpl implements _AssignExecutiveLog {
  const _$AssignExecutiveLogImpl({
    required this.id,
    required this.contract,
    required this.structureType,
    required this.structure,
    required this.assignedExecutive,
  });

  factory _$AssignExecutiveLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignExecutiveLogImplFromJson(json);

  @override
  final int id;
  @override
  final String contract;
  @override
  final String structureType;
  @override
  final String structure;
  @override
  final String assignedExecutive;

  @override
  String toString() {
    return 'AssignExecutiveLog(id: $id, contract: $contract, structureType: $structureType, structure: $structure, assignedExecutive: $assignedExecutive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignExecutiveLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.contract, contract) ||
                other.contract == contract) &&
            (identical(other.structureType, structureType) ||
                other.structureType == structureType) &&
            (identical(other.structure, structure) ||
                other.structure == structure) &&
            (identical(other.assignedExecutive, assignedExecutive) ||
                other.assignedExecutive == assignedExecutive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    contract,
    structureType,
    structure,
    assignedExecutive,
  );

  /// Create a copy of AssignExecutiveLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignExecutiveLogImplCopyWith<_$AssignExecutiveLogImpl> get copyWith =>
      __$$AssignExecutiveLogImplCopyWithImpl<_$AssignExecutiveLogImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignExecutiveLogImplToJson(this);
  }
}

abstract class _AssignExecutiveLog implements AssignExecutiveLog {
  const factory _AssignExecutiveLog({
    required final int id,
    required final String contract,
    required final String structureType,
    required final String structure,
    required final String assignedExecutive,
  }) = _$AssignExecutiveLogImpl;

  factory _AssignExecutiveLog.fromJson(Map<String, dynamic> json) =
      _$AssignExecutiveLogImpl.fromJson;

  @override
  int get id;
  @override
  String get contract;
  @override
  String get structureType;
  @override
  String get structure;
  @override
  String get assignedExecutive;

  /// Create a copy of AssignExecutiveLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignExecutiveLogImplCopyWith<_$AssignExecutiveLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
