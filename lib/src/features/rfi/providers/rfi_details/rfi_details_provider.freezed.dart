// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rfi_details_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RfiDetailsState {
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  RfiDetailModel? get detailModel => throw _privateConstructorUsedError;
  List<RfiInspectionModel> get inspections =>
      throw _privateConstructorUsedError;
  Map<String, List<EnclosureChecklistItem>> get enclosureChecklists =>
      throw _privateConstructorUsedError;
  Set<String> get enclosuresWithNoChecklist =>
      throw _privateConstructorUsedError;

  /// Create a copy of RfiDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RfiDetailsStateCopyWith<RfiDetailsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RfiDetailsStateCopyWith<$Res> {
  factory $RfiDetailsStateCopyWith(
    RfiDetailsState value,
    $Res Function(RfiDetailsState) then,
  ) = _$RfiDetailsStateCopyWithImpl<$Res, RfiDetailsState>;
  @useResult
  $Res call({
    bool isLoading,
    String? errorMessage,
    RfiDetailModel? detailModel,
    List<RfiInspectionModel> inspections,
    Map<String, List<EnclosureChecklistItem>> enclosureChecklists,
    Set<String> enclosuresWithNoChecklist,
  });

  $RfiDetailModelCopyWith<$Res>? get detailModel;
}

/// @nodoc
class _$RfiDetailsStateCopyWithImpl<$Res, $Val extends RfiDetailsState>
    implements $RfiDetailsStateCopyWith<$Res> {
  _$RfiDetailsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RfiDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? detailModel = freezed,
    Object? inspections = null,
    Object? enclosureChecklists = null,
    Object? enclosuresWithNoChecklist = null,
  }) {
    return _then(
      _value.copyWith(
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            detailModel: freezed == detailModel
                ? _value.detailModel
                : detailModel // ignore: cast_nullable_to_non_nullable
                      as RfiDetailModel?,
            inspections: null == inspections
                ? _value.inspections
                : inspections // ignore: cast_nullable_to_non_nullable
                      as List<RfiInspectionModel>,
            enclosureChecklists: null == enclosureChecklists
                ? _value.enclosureChecklists
                : enclosureChecklists // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<EnclosureChecklistItem>>,
            enclosuresWithNoChecklist: null == enclosuresWithNoChecklist
                ? _value.enclosuresWithNoChecklist
                : enclosuresWithNoChecklist // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of RfiDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RfiDetailModelCopyWith<$Res>? get detailModel {
    if (_value.detailModel == null) {
      return null;
    }

    return $RfiDetailModelCopyWith<$Res>(_value.detailModel!, (value) {
      return _then(_value.copyWith(detailModel: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RfiDetailsStateImplCopyWith<$Res>
    implements $RfiDetailsStateCopyWith<$Res> {
  factory _$$RfiDetailsStateImplCopyWith(
    _$RfiDetailsStateImpl value,
    $Res Function(_$RfiDetailsStateImpl) then,
  ) = __$$RfiDetailsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isLoading,
    String? errorMessage,
    RfiDetailModel? detailModel,
    List<RfiInspectionModel> inspections,
    Map<String, List<EnclosureChecklistItem>> enclosureChecklists,
    Set<String> enclosuresWithNoChecklist,
  });

  @override
  $RfiDetailModelCopyWith<$Res>? get detailModel;
}

/// @nodoc
class __$$RfiDetailsStateImplCopyWithImpl<$Res>
    extends _$RfiDetailsStateCopyWithImpl<$Res, _$RfiDetailsStateImpl>
    implements _$$RfiDetailsStateImplCopyWith<$Res> {
  __$$RfiDetailsStateImplCopyWithImpl(
    _$RfiDetailsStateImpl _value,
    $Res Function(_$RfiDetailsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RfiDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? detailModel = freezed,
    Object? inspections = null,
    Object? enclosureChecklists = null,
    Object? enclosuresWithNoChecklist = null,
  }) {
    return _then(
      _$RfiDetailsStateImpl(
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        detailModel: freezed == detailModel
            ? _value.detailModel
            : detailModel // ignore: cast_nullable_to_non_nullable
                  as RfiDetailModel?,
        inspections: null == inspections
            ? _value._inspections
            : inspections // ignore: cast_nullable_to_non_nullable
                  as List<RfiInspectionModel>,
        enclosureChecklists: null == enclosureChecklists
            ? _value._enclosureChecklists
            : enclosureChecklists // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<EnclosureChecklistItem>>,
        enclosuresWithNoChecklist: null == enclosuresWithNoChecklist
            ? _value._enclosuresWithNoChecklist
            : enclosuresWithNoChecklist // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
      ),
    );
  }
}

/// @nodoc

class _$RfiDetailsStateImpl implements _RfiDetailsState {
  const _$RfiDetailsStateImpl({
    this.isLoading = true,
    this.errorMessage,
    this.detailModel,
    final List<RfiInspectionModel> inspections = const [],
    final Map<String, List<EnclosureChecklistItem>> enclosureChecklists =
        const {},
    final Set<String> enclosuresWithNoChecklist = const {},
  }) : _inspections = inspections,
       _enclosureChecklists = enclosureChecklists,
       _enclosuresWithNoChecklist = enclosuresWithNoChecklist;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;
  @override
  final RfiDetailModel? detailModel;
  final List<RfiInspectionModel> _inspections;
  @override
  @JsonKey()
  List<RfiInspectionModel> get inspections {
    if (_inspections is EqualUnmodifiableListView) return _inspections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_inspections);
  }

  final Map<String, List<EnclosureChecklistItem>> _enclosureChecklists;
  @override
  @JsonKey()
  Map<String, List<EnclosureChecklistItem>> get enclosureChecklists {
    if (_enclosureChecklists is EqualUnmodifiableMapView)
      return _enclosureChecklists;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_enclosureChecklists);
  }

  final Set<String> _enclosuresWithNoChecklist;
  @override
  @JsonKey()
  Set<String> get enclosuresWithNoChecklist {
    if (_enclosuresWithNoChecklist is EqualUnmodifiableSetView)
      return _enclosuresWithNoChecklist;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_enclosuresWithNoChecklist);
  }

  @override
  String toString() {
    return 'RfiDetailsState(isLoading: $isLoading, errorMessage: $errorMessage, detailModel: $detailModel, inspections: $inspections, enclosureChecklists: $enclosureChecklists, enclosuresWithNoChecklist: $enclosuresWithNoChecklist)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RfiDetailsStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.detailModel, detailModel) ||
                other.detailModel == detailModel) &&
            const DeepCollectionEquality().equals(
              other._inspections,
              _inspections,
            ) &&
            const DeepCollectionEquality().equals(
              other._enclosureChecklists,
              _enclosureChecklists,
            ) &&
            const DeepCollectionEquality().equals(
              other._enclosuresWithNoChecklist,
              _enclosuresWithNoChecklist,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    errorMessage,
    detailModel,
    const DeepCollectionEquality().hash(_inspections),
    const DeepCollectionEquality().hash(_enclosureChecklists),
    const DeepCollectionEquality().hash(_enclosuresWithNoChecklist),
  );

  /// Create a copy of RfiDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RfiDetailsStateImplCopyWith<_$RfiDetailsStateImpl> get copyWith =>
      __$$RfiDetailsStateImplCopyWithImpl<_$RfiDetailsStateImpl>(
        this,
        _$identity,
      );
}

abstract class _RfiDetailsState implements RfiDetailsState {
  const factory _RfiDetailsState({
    final bool isLoading,
    final String? errorMessage,
    final RfiDetailModel? detailModel,
    final List<RfiInspectionModel> inspections,
    final Map<String, List<EnclosureChecklistItem>> enclosureChecklists,
    final Set<String> enclosuresWithNoChecklist,
  }) = _$RfiDetailsStateImpl;

  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  RfiDetailModel? get detailModel;
  @override
  List<RfiInspectionModel> get inspections;
  @override
  Map<String, List<EnclosureChecklistItem>> get enclosureChecklists;
  @override
  Set<String> get enclosuresWithNoChecklist;

  /// Create a copy of RfiDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RfiDetailsStateImplCopyWith<_$RfiDetailsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
