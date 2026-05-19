// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'enclosure_name.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EnclosureName _$EnclosureNameFromJson(Map<String, dynamic> json) {
  return _EnclosureName.fromJson(json);
}

/// @nodoc
mixin _$EnclosureName {
  int get id => throw _privateConstructorUsedError;
  String get encloserName => throw _privateConstructorUsedError;
  String? get checkListTitle => throw _privateConstructorUsedError;
  String? get action => throw _privateConstructorUsedError;

  /// Serializes this EnclosureName to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EnclosureName
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EnclosureNameCopyWith<EnclosureName> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnclosureNameCopyWith<$Res> {
  factory $EnclosureNameCopyWith(
    EnclosureName value,
    $Res Function(EnclosureName) then,
  ) = _$EnclosureNameCopyWithImpl<$Res, EnclosureName>;
  @useResult
  $Res call({
    int id,
    String encloserName,
    String? checkListTitle,
    String? action,
  });
}

/// @nodoc
class _$EnclosureNameCopyWithImpl<$Res, $Val extends EnclosureName>
    implements $EnclosureNameCopyWith<$Res> {
  _$EnclosureNameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EnclosureName
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? encloserName = null,
    Object? checkListTitle = freezed,
    Object? action = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            encloserName: null == encloserName
                ? _value.encloserName
                : encloserName // ignore: cast_nullable_to_non_nullable
                      as String,
            checkListTitle: freezed == checkListTitle
                ? _value.checkListTitle
                : checkListTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            action: freezed == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EnclosureNameImplCopyWith<$Res>
    implements $EnclosureNameCopyWith<$Res> {
  factory _$$EnclosureNameImplCopyWith(
    _$EnclosureNameImpl value,
    $Res Function(_$EnclosureNameImpl) then,
  ) = __$$EnclosureNameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String encloserName,
    String? checkListTitle,
    String? action,
  });
}

/// @nodoc
class __$$EnclosureNameImplCopyWithImpl<$Res>
    extends _$EnclosureNameCopyWithImpl<$Res, _$EnclosureNameImpl>
    implements _$$EnclosureNameImplCopyWith<$Res> {
  __$$EnclosureNameImplCopyWithImpl(
    _$EnclosureNameImpl _value,
    $Res Function(_$EnclosureNameImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EnclosureName
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? encloserName = null,
    Object? checkListTitle = freezed,
    Object? action = freezed,
  }) {
    return _then(
      _$EnclosureNameImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        encloserName: null == encloserName
            ? _value.encloserName
            : encloserName // ignore: cast_nullable_to_non_nullable
                  as String,
        checkListTitle: freezed == checkListTitle
            ? _value.checkListTitle
            : checkListTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        action: freezed == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EnclosureNameImpl implements _EnclosureName {
  const _$EnclosureNameImpl({
    required this.id,
    required this.encloserName,
    this.checkListTitle,
    this.action,
  });

  factory _$EnclosureNameImpl.fromJson(Map<String, dynamic> json) =>
      _$$EnclosureNameImplFromJson(json);

  @override
  final int id;
  @override
  final String encloserName;
  @override
  final String? checkListTitle;
  @override
  final String? action;

  @override
  String toString() {
    return 'EnclosureName(id: $id, encloserName: $encloserName, checkListTitle: $checkListTitle, action: $action)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnclosureNameImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.encloserName, encloserName) ||
                other.encloserName == encloserName) &&
            (identical(other.checkListTitle, checkListTitle) ||
                other.checkListTitle == checkListTitle) &&
            (identical(other.action, action) || other.action == action));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, encloserName, checkListTitle, action);

  /// Create a copy of EnclosureName
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EnclosureNameImplCopyWith<_$EnclosureNameImpl> get copyWith =>
      __$$EnclosureNameImplCopyWithImpl<_$EnclosureNameImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EnclosureNameImplToJson(this);
  }
}

abstract class _EnclosureName implements EnclosureName {
  const factory _EnclosureName({
    required final int id,
    required final String encloserName,
    final String? checkListTitle,
    final String? action,
  }) = _$EnclosureNameImpl;

  factory _EnclosureName.fromJson(Map<String, dynamic> json) =
      _$EnclosureNameImpl.fromJson;

  @override
  int get id;
  @override
  String get encloserName;
  @override
  String? get checkListTitle;
  @override
  String? get action;

  /// Create a copy of EnclosureName
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnclosureNameImplCopyWith<_$EnclosureNameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
