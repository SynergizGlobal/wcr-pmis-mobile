// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_reference_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$InspectionReferenceState {
  FormType? get selectedFormType => throw _privateConstructorUsedError;
  bool get isLoadingInitial => throw _privateConstructorUsedError;
  bool get isLoadingList => throw _privateConstructorUsedError;
  List<EnclosureName> get initialEnclosureNames =>
      throw _privateConstructorUsedError;
  List<EnclosureName> get enclosureList => throw _privateConstructorUsedError;
  List<EnclosureName> get subOptions => throw _privateConstructorUsedError;
  EnclosureName? get selectedSubOption => throw _privateConstructorUsedError;
  List<ChecklistDetail> get checklistDetails =>
      throw _privateConstructorUsedError;
  List<ReferenceFormItem> get referenceFormItems =>
      throw _privateConstructorUsedError;
  bool get isEnclosureSubmitting => throw _privateConstructorUsedError;
  bool get isChecklistSubmitting => throw _privateConstructorUsedError;
  bool get isReferenceFormSubmitting => throw _privateConstructorUsedError;

  /// Create a copy of InspectionReferenceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InspectionReferenceStateCopyWith<InspectionReferenceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InspectionReferenceStateCopyWith<$Res> {
  factory $InspectionReferenceStateCopyWith(
    InspectionReferenceState value,
    $Res Function(InspectionReferenceState) then,
  ) = _$InspectionReferenceStateCopyWithImpl<$Res, InspectionReferenceState>;
  @useResult
  $Res call({
    FormType? selectedFormType,
    bool isLoadingInitial,
    bool isLoadingList,
    List<EnclosureName> initialEnclosureNames,
    List<EnclosureName> enclosureList,
    List<EnclosureName> subOptions,
    EnclosureName? selectedSubOption,
    List<ChecklistDetail> checklistDetails,
    List<ReferenceFormItem> referenceFormItems,
    bool isEnclosureSubmitting,
    bool isChecklistSubmitting,
    bool isReferenceFormSubmitting,
  });

  $EnclosureNameCopyWith<$Res>? get selectedSubOption;
}

/// @nodoc
class _$InspectionReferenceStateCopyWithImpl<
  $Res,
  $Val extends InspectionReferenceState
>
    implements $InspectionReferenceStateCopyWith<$Res> {
  _$InspectionReferenceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InspectionReferenceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedFormType = freezed,
    Object? isLoadingInitial = null,
    Object? isLoadingList = null,
    Object? initialEnclosureNames = null,
    Object? enclosureList = null,
    Object? subOptions = null,
    Object? selectedSubOption = freezed,
    Object? checklistDetails = null,
    Object? referenceFormItems = null,
    Object? isEnclosureSubmitting = null,
    Object? isChecklistSubmitting = null,
    Object? isReferenceFormSubmitting = null,
  }) {
    return _then(
      _value.copyWith(
            selectedFormType: freezed == selectedFormType
                ? _value.selectedFormType
                : selectedFormType // ignore: cast_nullable_to_non_nullable
                      as FormType?,
            isLoadingInitial: null == isLoadingInitial
                ? _value.isLoadingInitial
                : isLoadingInitial // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingList: null == isLoadingList
                ? _value.isLoadingList
                : isLoadingList // ignore: cast_nullable_to_non_nullable
                      as bool,
            initialEnclosureNames: null == initialEnclosureNames
                ? _value.initialEnclosureNames
                : initialEnclosureNames // ignore: cast_nullable_to_non_nullable
                      as List<EnclosureName>,
            enclosureList: null == enclosureList
                ? _value.enclosureList
                : enclosureList // ignore: cast_nullable_to_non_nullable
                      as List<EnclosureName>,
            subOptions: null == subOptions
                ? _value.subOptions
                : subOptions // ignore: cast_nullable_to_non_nullable
                      as List<EnclosureName>,
            selectedSubOption: freezed == selectedSubOption
                ? _value.selectedSubOption
                : selectedSubOption // ignore: cast_nullable_to_non_nullable
                      as EnclosureName?,
            checklistDetails: null == checklistDetails
                ? _value.checklistDetails
                : checklistDetails // ignore: cast_nullable_to_non_nullable
                      as List<ChecklistDetail>,
            referenceFormItems: null == referenceFormItems
                ? _value.referenceFormItems
                : referenceFormItems // ignore: cast_nullable_to_non_nullable
                      as List<ReferenceFormItem>,
            isEnclosureSubmitting: null == isEnclosureSubmitting
                ? _value.isEnclosureSubmitting
                : isEnclosureSubmitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            isChecklistSubmitting: null == isChecklistSubmitting
                ? _value.isChecklistSubmitting
                : isChecklistSubmitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            isReferenceFormSubmitting: null == isReferenceFormSubmitting
                ? _value.isReferenceFormSubmitting
                : isReferenceFormSubmitting // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of InspectionReferenceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EnclosureNameCopyWith<$Res>? get selectedSubOption {
    if (_value.selectedSubOption == null) {
      return null;
    }

    return $EnclosureNameCopyWith<$Res>(_value.selectedSubOption!, (value) {
      return _then(_value.copyWith(selectedSubOption: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$InspectionReferenceStateImplCopyWith<$Res>
    implements $InspectionReferenceStateCopyWith<$Res> {
  factory _$$InspectionReferenceStateImplCopyWith(
    _$InspectionReferenceStateImpl value,
    $Res Function(_$InspectionReferenceStateImpl) then,
  ) = __$$InspectionReferenceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    FormType? selectedFormType,
    bool isLoadingInitial,
    bool isLoadingList,
    List<EnclosureName> initialEnclosureNames,
    List<EnclosureName> enclosureList,
    List<EnclosureName> subOptions,
    EnclosureName? selectedSubOption,
    List<ChecklistDetail> checklistDetails,
    List<ReferenceFormItem> referenceFormItems,
    bool isEnclosureSubmitting,
    bool isChecklistSubmitting,
    bool isReferenceFormSubmitting,
  });

  @override
  $EnclosureNameCopyWith<$Res>? get selectedSubOption;
}

/// @nodoc
class __$$InspectionReferenceStateImplCopyWithImpl<$Res>
    extends
        _$InspectionReferenceStateCopyWithImpl<
          $Res,
          _$InspectionReferenceStateImpl
        >
    implements _$$InspectionReferenceStateImplCopyWith<$Res> {
  __$$InspectionReferenceStateImplCopyWithImpl(
    _$InspectionReferenceStateImpl _value,
    $Res Function(_$InspectionReferenceStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InspectionReferenceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedFormType = freezed,
    Object? isLoadingInitial = null,
    Object? isLoadingList = null,
    Object? initialEnclosureNames = null,
    Object? enclosureList = null,
    Object? subOptions = null,
    Object? selectedSubOption = freezed,
    Object? checklistDetails = null,
    Object? referenceFormItems = null,
    Object? isEnclosureSubmitting = null,
    Object? isChecklistSubmitting = null,
    Object? isReferenceFormSubmitting = null,
  }) {
    return _then(
      _$InspectionReferenceStateImpl(
        selectedFormType: freezed == selectedFormType
            ? _value.selectedFormType
            : selectedFormType // ignore: cast_nullable_to_non_nullable
                  as FormType?,
        isLoadingInitial: null == isLoadingInitial
            ? _value.isLoadingInitial
            : isLoadingInitial // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingList: null == isLoadingList
            ? _value.isLoadingList
            : isLoadingList // ignore: cast_nullable_to_non_nullable
                  as bool,
        initialEnclosureNames: null == initialEnclosureNames
            ? _value._initialEnclosureNames
            : initialEnclosureNames // ignore: cast_nullable_to_non_nullable
                  as List<EnclosureName>,
        enclosureList: null == enclosureList
            ? _value._enclosureList
            : enclosureList // ignore: cast_nullable_to_non_nullable
                  as List<EnclosureName>,
        subOptions: null == subOptions
            ? _value._subOptions
            : subOptions // ignore: cast_nullable_to_non_nullable
                  as List<EnclosureName>,
        selectedSubOption: freezed == selectedSubOption
            ? _value.selectedSubOption
            : selectedSubOption // ignore: cast_nullable_to_non_nullable
                  as EnclosureName?,
        checklistDetails: null == checklistDetails
            ? _value._checklistDetails
            : checklistDetails // ignore: cast_nullable_to_non_nullable
                  as List<ChecklistDetail>,
        referenceFormItems: null == referenceFormItems
            ? _value._referenceFormItems
            : referenceFormItems // ignore: cast_nullable_to_non_nullable
                  as List<ReferenceFormItem>,
        isEnclosureSubmitting: null == isEnclosureSubmitting
            ? _value.isEnclosureSubmitting
            : isEnclosureSubmitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        isChecklistSubmitting: null == isChecklistSubmitting
            ? _value.isChecklistSubmitting
            : isChecklistSubmitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        isReferenceFormSubmitting: null == isReferenceFormSubmitting
            ? _value.isReferenceFormSubmitting
            : isReferenceFormSubmitting // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$InspectionReferenceStateImpl implements _InspectionReferenceState {
  const _$InspectionReferenceStateImpl({
    this.selectedFormType,
    this.isLoadingInitial = false,
    this.isLoadingList = false,
    final List<EnclosureName> initialEnclosureNames = const [],
    final List<EnclosureName> enclosureList = const [],
    final List<EnclosureName> subOptions = const [],
    this.selectedSubOption,
    final List<ChecklistDetail> checklistDetails = const [],
    final List<ReferenceFormItem> referenceFormItems = const [],
    this.isEnclosureSubmitting = false,
    this.isChecklistSubmitting = false,
    this.isReferenceFormSubmitting = false,
  }) : _initialEnclosureNames = initialEnclosureNames,
       _enclosureList = enclosureList,
       _subOptions = subOptions,
       _checklistDetails = checklistDetails,
       _referenceFormItems = referenceFormItems;

  @override
  final FormType? selectedFormType;
  @override
  @JsonKey()
  final bool isLoadingInitial;
  @override
  @JsonKey()
  final bool isLoadingList;
  final List<EnclosureName> _initialEnclosureNames;
  @override
  @JsonKey()
  List<EnclosureName> get initialEnclosureNames {
    if (_initialEnclosureNames is EqualUnmodifiableListView)
      return _initialEnclosureNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_initialEnclosureNames);
  }

  final List<EnclosureName> _enclosureList;
  @override
  @JsonKey()
  List<EnclosureName> get enclosureList {
    if (_enclosureList is EqualUnmodifiableListView) return _enclosureList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_enclosureList);
  }

  final List<EnclosureName> _subOptions;
  @override
  @JsonKey()
  List<EnclosureName> get subOptions {
    if (_subOptions is EqualUnmodifiableListView) return _subOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subOptions);
  }

  @override
  final EnclosureName? selectedSubOption;
  final List<ChecklistDetail> _checklistDetails;
  @override
  @JsonKey()
  List<ChecklistDetail> get checklistDetails {
    if (_checklistDetails is EqualUnmodifiableListView)
      return _checklistDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_checklistDetails);
  }

  final List<ReferenceFormItem> _referenceFormItems;
  @override
  @JsonKey()
  List<ReferenceFormItem> get referenceFormItems {
    if (_referenceFormItems is EqualUnmodifiableListView)
      return _referenceFormItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_referenceFormItems);
  }

  @override
  @JsonKey()
  final bool isEnclosureSubmitting;
  @override
  @JsonKey()
  final bool isChecklistSubmitting;
  @override
  @JsonKey()
  final bool isReferenceFormSubmitting;

  @override
  String toString() {
    return 'InspectionReferenceState(selectedFormType: $selectedFormType, isLoadingInitial: $isLoadingInitial, isLoadingList: $isLoadingList, initialEnclosureNames: $initialEnclosureNames, enclosureList: $enclosureList, subOptions: $subOptions, selectedSubOption: $selectedSubOption, checklistDetails: $checklistDetails, referenceFormItems: $referenceFormItems, isEnclosureSubmitting: $isEnclosureSubmitting, isChecklistSubmitting: $isChecklistSubmitting, isReferenceFormSubmitting: $isReferenceFormSubmitting)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InspectionReferenceStateImpl &&
            (identical(other.selectedFormType, selectedFormType) ||
                other.selectedFormType == selectedFormType) &&
            (identical(other.isLoadingInitial, isLoadingInitial) ||
                other.isLoadingInitial == isLoadingInitial) &&
            (identical(other.isLoadingList, isLoadingList) ||
                other.isLoadingList == isLoadingList) &&
            const DeepCollectionEquality().equals(
              other._initialEnclosureNames,
              _initialEnclosureNames,
            ) &&
            const DeepCollectionEquality().equals(
              other._enclosureList,
              _enclosureList,
            ) &&
            const DeepCollectionEquality().equals(
              other._subOptions,
              _subOptions,
            ) &&
            (identical(other.selectedSubOption, selectedSubOption) ||
                other.selectedSubOption == selectedSubOption) &&
            const DeepCollectionEquality().equals(
              other._checklistDetails,
              _checklistDetails,
            ) &&
            const DeepCollectionEquality().equals(
              other._referenceFormItems,
              _referenceFormItems,
            ) &&
            (identical(other.isEnclosureSubmitting, isEnclosureSubmitting) ||
                other.isEnclosureSubmitting == isEnclosureSubmitting) &&
            (identical(other.isChecklistSubmitting, isChecklistSubmitting) ||
                other.isChecklistSubmitting == isChecklistSubmitting) &&
            (identical(
                  other.isReferenceFormSubmitting,
                  isReferenceFormSubmitting,
                ) ||
                other.isReferenceFormSubmitting == isReferenceFormSubmitting));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    selectedFormType,
    isLoadingInitial,
    isLoadingList,
    const DeepCollectionEquality().hash(_initialEnclosureNames),
    const DeepCollectionEquality().hash(_enclosureList),
    const DeepCollectionEquality().hash(_subOptions),
    selectedSubOption,
    const DeepCollectionEquality().hash(_checklistDetails),
    const DeepCollectionEquality().hash(_referenceFormItems),
    isEnclosureSubmitting,
    isChecklistSubmitting,
    isReferenceFormSubmitting,
  );

  /// Create a copy of InspectionReferenceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InspectionReferenceStateImplCopyWith<_$InspectionReferenceStateImpl>
  get copyWith =>
      __$$InspectionReferenceStateImplCopyWithImpl<
        _$InspectionReferenceStateImpl
      >(this, _$identity);
}

abstract class _InspectionReferenceState implements InspectionReferenceState {
  const factory _InspectionReferenceState({
    final FormType? selectedFormType,
    final bool isLoadingInitial,
    final bool isLoadingList,
    final List<EnclosureName> initialEnclosureNames,
    final List<EnclosureName> enclosureList,
    final List<EnclosureName> subOptions,
    final EnclosureName? selectedSubOption,
    final List<ChecklistDetail> checklistDetails,
    final List<ReferenceFormItem> referenceFormItems,
    final bool isEnclosureSubmitting,
    final bool isChecklistSubmitting,
    final bool isReferenceFormSubmitting,
  }) = _$InspectionReferenceStateImpl;

  @override
  FormType? get selectedFormType;
  @override
  bool get isLoadingInitial;
  @override
  bool get isLoadingList;
  @override
  List<EnclosureName> get initialEnclosureNames;
  @override
  List<EnclosureName> get enclosureList;
  @override
  List<EnclosureName> get subOptions;
  @override
  EnclosureName? get selectedSubOption;
  @override
  List<ChecklistDetail> get checklistDetails;
  @override
  List<ReferenceFormItem> get referenceFormItems;
  @override
  bool get isEnclosureSubmitting;
  @override
  bool get isChecklistSubmitting;
  @override
  bool get isReferenceFormSubmitting;

  /// Create a copy of InspectionReferenceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InspectionReferenceStateImplCopyWith<_$InspectionReferenceStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
