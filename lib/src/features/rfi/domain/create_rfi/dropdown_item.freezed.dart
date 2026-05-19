// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dropdown_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DropdownItem _$DropdownItemFromJson(Map<String, dynamic> json) {
  return _DropdownItem.fromJson(json);
}

/// @nodoc
mixin _$DropdownItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<String>? get enclosures => throw _privateConstructorUsedError;
  int? get p6ActivityIdFk => throw _privateConstructorUsedError;
  String? get pmisCalcFk => throw _privateConstructorUsedError;

  /// Serializes this DropdownItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DropdownItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DropdownItemCopyWith<DropdownItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DropdownItemCopyWith<$Res> {
  factory $DropdownItemCopyWith(
    DropdownItem value,
    $Res Function(DropdownItem) then,
  ) = _$DropdownItemCopyWithImpl<$Res, DropdownItem>;
  @useResult
  $Res call({
    String id,
    String name,
    List<String>? enclosures,
    int? p6ActivityIdFk,
    String? pmisCalcFk,
  });
}

/// @nodoc
class _$DropdownItemCopyWithImpl<$Res, $Val extends DropdownItem>
    implements $DropdownItemCopyWith<$Res> {
  _$DropdownItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DropdownItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? enclosures = freezed,
    Object? p6ActivityIdFk = freezed,
    Object? pmisCalcFk = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            enclosures: freezed == enclosures
                ? _value.enclosures
                : enclosures // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            p6ActivityIdFk: freezed == p6ActivityIdFk
                ? _value.p6ActivityIdFk
                : p6ActivityIdFk // ignore: cast_nullable_to_non_nullable
                      as int?,
            pmisCalcFk: freezed == pmisCalcFk
                ? _value.pmisCalcFk
                : pmisCalcFk // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DropdownItemImplCopyWith<$Res>
    implements $DropdownItemCopyWith<$Res> {
  factory _$$DropdownItemImplCopyWith(
    _$DropdownItemImpl value,
    $Res Function(_$DropdownItemImpl) then,
  ) = __$$DropdownItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    List<String>? enclosures,
    int? p6ActivityIdFk,
    String? pmisCalcFk,
  });
}

/// @nodoc
class __$$DropdownItemImplCopyWithImpl<$Res>
    extends _$DropdownItemCopyWithImpl<$Res, _$DropdownItemImpl>
    implements _$$DropdownItemImplCopyWith<$Res> {
  __$$DropdownItemImplCopyWithImpl(
    _$DropdownItemImpl _value,
    $Res Function(_$DropdownItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DropdownItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? enclosures = freezed,
    Object? p6ActivityIdFk = freezed,
    Object? pmisCalcFk = freezed,
  }) {
    return _then(
      _$DropdownItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        enclosures: freezed == enclosures
            ? _value._enclosures
            : enclosures // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        p6ActivityIdFk: freezed == p6ActivityIdFk
            ? _value.p6ActivityIdFk
            : p6ActivityIdFk // ignore: cast_nullable_to_non_nullable
                  as int?,
        pmisCalcFk: freezed == pmisCalcFk
            ? _value.pmisCalcFk
            : pmisCalcFk // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DropdownItemImpl implements _DropdownItem {
  const _$DropdownItemImpl({
    required this.id,
    required this.name,
    final List<String>? enclosures,
    this.p6ActivityIdFk,
    this.pmisCalcFk,
  }) : _enclosures = enclosures;

  factory _$DropdownItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$DropdownItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<String>? _enclosures;
  @override
  List<String>? get enclosures {
    final value = _enclosures;
    if (value == null) return null;
    if (_enclosures is EqualUnmodifiableListView) return _enclosures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? p6ActivityIdFk;
  @override
  final String? pmisCalcFk;

  @override
  String toString() {
    return 'DropdownItem(id: $id, name: $name, enclosures: $enclosures, p6ActivityIdFk: $p6ActivityIdFk, pmisCalcFk: $pmisCalcFk)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DropdownItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._enclosures,
              _enclosures,
            ) &&
            (identical(other.p6ActivityIdFk, p6ActivityIdFk) ||
                other.p6ActivityIdFk == p6ActivityIdFk) &&
            (identical(other.pmisCalcFk, pmisCalcFk) ||
                other.pmisCalcFk == pmisCalcFk));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_enclosures),
    p6ActivityIdFk,
    pmisCalcFk,
  );

  /// Create a copy of DropdownItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DropdownItemImplCopyWith<_$DropdownItemImpl> get copyWith =>
      __$$DropdownItemImplCopyWithImpl<_$DropdownItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DropdownItemImplToJson(this);
  }
}

abstract class _DropdownItem implements DropdownItem {
  const factory _DropdownItem({
    required final String id,
    required final String name,
    final List<String>? enclosures,
    final int? p6ActivityIdFk,
    final String? pmisCalcFk,
  }) = _$DropdownItemImpl;

  factory _DropdownItem.fromJson(Map<String, dynamic> json) =
      _$DropdownItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<String>? get enclosures;
  @override
  int? get p6ActivityIdFk;
  @override
  String? get pmisCalcFk;

  /// Create a copy of DropdownItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DropdownItemImplCopyWith<_$DropdownItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
