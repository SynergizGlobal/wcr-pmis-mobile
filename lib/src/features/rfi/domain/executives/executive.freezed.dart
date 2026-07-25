// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'executive.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Executive _$ExecutiveFromJson(Map<String, dynamic> json) {
  return _Executive.fromJson(json);
}

/// @nodoc
mixin _$Executive {
  String get userName => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get department => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;

  /// Serializes this Executive to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Executive
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExecutiveCopyWith<Executive> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExecutiveCopyWith<$Res> {
  factory $ExecutiveCopyWith(Executive value, $Res Function(Executive) then) =
      _$ExecutiveCopyWithImpl<$Res, Executive>;
  @useResult
  $Res call({String userName, String userId, String department, String email});
}

/// @nodoc
class _$ExecutiveCopyWithImpl<$Res, $Val extends Executive>
    implements $ExecutiveCopyWith<$Res> {
  _$ExecutiveCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Executive
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userName = null,
    Object? userId = null,
    Object? department = null,
    Object? email = null,
  }) {
    return _then(
      _value.copyWith(
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            department: null == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExecutiveImplCopyWith<$Res>
    implements $ExecutiveCopyWith<$Res> {
  factory _$$ExecutiveImplCopyWith(
    _$ExecutiveImpl value,
    $Res Function(_$ExecutiveImpl) then,
  ) = __$$ExecutiveImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userName, String userId, String department, String email});
}

/// @nodoc
class __$$ExecutiveImplCopyWithImpl<$Res>
    extends _$ExecutiveCopyWithImpl<$Res, _$ExecutiveImpl>
    implements _$$ExecutiveImplCopyWith<$Res> {
  __$$ExecutiveImplCopyWithImpl(
    _$ExecutiveImpl _value,
    $Res Function(_$ExecutiveImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Executive
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userName = null,
    Object? userId = null,
    Object? department = null,
    Object? email = null,
  }) {
    return _then(
      _$ExecutiveImpl(
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        department: null == department
            ? _value.department
            : department // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExecutiveImpl implements _Executive {
  const _$ExecutiveImpl({
    required this.userName,
    required this.userId,
    required this.department,
    this.email = '',
  });

  factory _$ExecutiveImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExecutiveImplFromJson(json);

  @override
  final String userName;
  @override
  final String userId;
  @override
  final String department;
  @override
  @JsonKey()
  final String email;

  @override
  String toString() {
    return 'Executive(userName: $userName, userId: $userId, department: $department, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExecutiveImpl &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userName, userId, department, email);

  /// Create a copy of Executive
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExecutiveImplCopyWith<_$ExecutiveImpl> get copyWith =>
      __$$ExecutiveImplCopyWithImpl<_$ExecutiveImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExecutiveImplToJson(this);
  }
}

abstract class _Executive implements Executive {
  const factory _Executive({
    required final String userName,
    required final String userId,
    required final String department,
    final String email,
  }) = _$ExecutiveImpl;

  factory _Executive.fromJson(Map<String, dynamic> json) =
      _$ExecutiveImpl.fromJson;

  @override
  String get userName;
  @override
  String get userId;
  @override
  String get department;
  @override
  String get email;

  /// Create a copy of Executive
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExecutiveImplCopyWith<_$ExecutiveImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
