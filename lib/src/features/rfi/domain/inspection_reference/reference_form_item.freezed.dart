// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reference_form_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReferenceFormItem _$ReferenceFormItemFromJson(Map<String, dynamic> json) {
  return _ReferenceFormItem.fromJson(json);
}

/// @nodoc
mixin _$ReferenceFormItem {
  int get id => throw _privateConstructorUsedError;
  String get activity => throw _privateConstructorUsedError;
  String get rfiDescription => throw _privateConstructorUsedError;
  String get enclosures => throw _privateConstructorUsedError;

  /// Serializes this ReferenceFormItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReferenceFormItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReferenceFormItemCopyWith<ReferenceFormItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferenceFormItemCopyWith<$Res> {
  factory $ReferenceFormItemCopyWith(
    ReferenceFormItem value,
    $Res Function(ReferenceFormItem) then,
  ) = _$ReferenceFormItemCopyWithImpl<$Res, ReferenceFormItem>;
  @useResult
  $Res call({
    int id,
    String activity,
    String rfiDescription,
    String enclosures,
  });
}

/// @nodoc
class _$ReferenceFormItemCopyWithImpl<$Res, $Val extends ReferenceFormItem>
    implements $ReferenceFormItemCopyWith<$Res> {
  _$ReferenceFormItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReferenceFormItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activity = null,
    Object? rfiDescription = null,
    Object? enclosures = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            activity: null == activity
                ? _value.activity
                : activity // ignore: cast_nullable_to_non_nullable
                      as String,
            rfiDescription: null == rfiDescription
                ? _value.rfiDescription
                : rfiDescription // ignore: cast_nullable_to_non_nullable
                      as String,
            enclosures: null == enclosures
                ? _value.enclosures
                : enclosures // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReferenceFormItemImplCopyWith<$Res>
    implements $ReferenceFormItemCopyWith<$Res> {
  factory _$$ReferenceFormItemImplCopyWith(
    _$ReferenceFormItemImpl value,
    $Res Function(_$ReferenceFormItemImpl) then,
  ) = __$$ReferenceFormItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String activity,
    String rfiDescription,
    String enclosures,
  });
}

/// @nodoc
class __$$ReferenceFormItemImplCopyWithImpl<$Res>
    extends _$ReferenceFormItemCopyWithImpl<$Res, _$ReferenceFormItemImpl>
    implements _$$ReferenceFormItemImplCopyWith<$Res> {
  __$$ReferenceFormItemImplCopyWithImpl(
    _$ReferenceFormItemImpl _value,
    $Res Function(_$ReferenceFormItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReferenceFormItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activity = null,
    Object? rfiDescription = null,
    Object? enclosures = null,
  }) {
    return _then(
      _$ReferenceFormItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        activity: null == activity
            ? _value.activity
            : activity // ignore: cast_nullable_to_non_nullable
                  as String,
        rfiDescription: null == rfiDescription
            ? _value.rfiDescription
            : rfiDescription // ignore: cast_nullable_to_non_nullable
                  as String,
        enclosures: null == enclosures
            ? _value.enclosures
            : enclosures // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferenceFormItemImpl implements _ReferenceFormItem {
  const _$ReferenceFormItemImpl({
    required this.id,
    this.activity = '',
    this.rfiDescription = '',
    this.enclosures = '',
  });

  factory _$ReferenceFormItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferenceFormItemImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String activity;
  @override
  @JsonKey()
  final String rfiDescription;
  @override
  @JsonKey()
  final String enclosures;

  @override
  String toString() {
    return 'ReferenceFormItem(id: $id, activity: $activity, rfiDescription: $rfiDescription, enclosures: $enclosures)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferenceFormItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.activity, activity) ||
                other.activity == activity) &&
            (identical(other.rfiDescription, rfiDescription) ||
                other.rfiDescription == rfiDescription) &&
            (identical(other.enclosures, enclosures) ||
                other.enclosures == enclosures));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, activity, rfiDescription, enclosures);

  /// Create a copy of ReferenceFormItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferenceFormItemImplCopyWith<_$ReferenceFormItemImpl> get copyWith =>
      __$$ReferenceFormItemImplCopyWithImpl<_$ReferenceFormItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferenceFormItemImplToJson(this);
  }
}

abstract class _ReferenceFormItem implements ReferenceFormItem {
  const factory _ReferenceFormItem({
    required final int id,
    final String activity,
    final String rfiDescription,
    final String enclosures,
  }) = _$ReferenceFormItemImpl;

  factory _ReferenceFormItem.fromJson(Map<String, dynamic> json) =
      _$ReferenceFormItemImpl.fromJson;

  @override
  int get id;
  @override
  String get activity;
  @override
  String get rfiDescription;
  @override
  String get enclosures;

  /// Create a copy of ReferenceFormItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReferenceFormItemImplCopyWith<_$ReferenceFormItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
