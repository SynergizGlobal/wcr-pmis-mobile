// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rfi_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RfiDraft _$RfiDraftFromJson(Map<String, dynamic> json) {
  return _RfiDraft.fromJson(json);
}

/// @nodoc
mixin _$RfiDraft {
  // Selections
  DropdownItem? get project => throw _privateConstructorUsedError;
  DropdownItem? get work => throw _privateConstructorUsedError;
  DropdownItem? get contract => throw _privateConstructorUsedError;
  DropdownItem? get structureType => throw _privateConstructorUsedError;
  DropdownItem? get structure => throw _privateConstructorUsedError;
  DropdownItem? get component => throw _privateConstructorUsedError;
  DropdownItem? get element => throw _privateConstructorUsedError;
  DropdownItem? get activity => throw _privateConstructorUsedError;
  DropdownItem? get rfiDescription =>
      throw _privateConstructorUsedError; // Step 2 Fields
  int get currentStep => throw _privateConstructorUsedError;
  String? get action => throw _privateConstructorUsedError;
  String? get typeOfRfi => throw _privateConstructorUsedError;
  String? get contractorRepresentative => throw _privateConstructorUsedError;
  String? get dateOfSubmission => throw _privateConstructorUsedError;
  String? get timeOfInspection => throw _privateConstructorUsedError;
  String? get dateOfInspection =>
      throw _privateConstructorUsedError; // Step 3 Fields
  List<String> get selectedEnclosures => throw _privateConstructorUsedError;
  String? get rfiDescriptionText =>
      throw _privateConstructorUsedError; // Cached Lists
  List<DropdownItem> get projects => throw _privateConstructorUsedError;
  List<DropdownItem> get works => throw _privateConstructorUsedError;
  List<DropdownItem> get contracts => throw _privateConstructorUsedError;
  List<DropdownItem> get structureTypes => throw _privateConstructorUsedError;
  List<DropdownItem> get structures => throw _privateConstructorUsedError;
  List<DropdownItem> get components => throw _privateConstructorUsedError;
  List<DropdownItem> get elements => throw _privateConstructorUsedError;
  List<DropdownItem> get activities => throw _privateConstructorUsedError;
  List<DropdownItem> get rfiDescriptions => throw _privateConstructorUsedError;
  List<DropdownItem> get representatives => throw _privateConstructorUsedError;

  /// Serializes this RfiDraft to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RfiDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RfiDraftCopyWith<RfiDraft> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RfiDraftCopyWith<$Res> {
  factory $RfiDraftCopyWith(RfiDraft value, $Res Function(RfiDraft) then) =
      _$RfiDraftCopyWithImpl<$Res, RfiDraft>;
  @useResult
  $Res call({
    DropdownItem? project,
    DropdownItem? work,
    DropdownItem? contract,
    DropdownItem? structureType,
    DropdownItem? structure,
    DropdownItem? component,
    DropdownItem? element,
    DropdownItem? activity,
    DropdownItem? rfiDescription,
    int currentStep,
    String? action,
    String? typeOfRfi,
    String? contractorRepresentative,
    String? dateOfSubmission,
    String? timeOfInspection,
    String? dateOfInspection,
    List<String> selectedEnclosures,
    String? rfiDescriptionText,
    List<DropdownItem> projects,
    List<DropdownItem> works,
    List<DropdownItem> contracts,
    List<DropdownItem> structureTypes,
    List<DropdownItem> structures,
    List<DropdownItem> components,
    List<DropdownItem> elements,
    List<DropdownItem> activities,
    List<DropdownItem> rfiDescriptions,
    List<DropdownItem> representatives,
  });

  $DropdownItemCopyWith<$Res>? get project;
  $DropdownItemCopyWith<$Res>? get work;
  $DropdownItemCopyWith<$Res>? get contract;
  $DropdownItemCopyWith<$Res>? get structureType;
  $DropdownItemCopyWith<$Res>? get structure;
  $DropdownItemCopyWith<$Res>? get component;
  $DropdownItemCopyWith<$Res>? get element;
  $DropdownItemCopyWith<$Res>? get activity;
  $DropdownItemCopyWith<$Res>? get rfiDescription;
}

/// @nodoc
class _$RfiDraftCopyWithImpl<$Res, $Val extends RfiDraft>
    implements $RfiDraftCopyWith<$Res> {
  _$RfiDraftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RfiDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? project = freezed,
    Object? work = freezed,
    Object? contract = freezed,
    Object? structureType = freezed,
    Object? structure = freezed,
    Object? component = freezed,
    Object? element = freezed,
    Object? activity = freezed,
    Object? rfiDescription = freezed,
    Object? currentStep = null,
    Object? action = freezed,
    Object? typeOfRfi = freezed,
    Object? contractorRepresentative = freezed,
    Object? dateOfSubmission = freezed,
    Object? timeOfInspection = freezed,
    Object? dateOfInspection = freezed,
    Object? selectedEnclosures = null,
    Object? rfiDescriptionText = freezed,
    Object? projects = null,
    Object? works = null,
    Object? contracts = null,
    Object? structureTypes = null,
    Object? structures = null,
    Object? components = null,
    Object? elements = null,
    Object? activities = null,
    Object? rfiDescriptions = null,
    Object? representatives = null,
  }) {
    return _then(
      _value.copyWith(
            project: freezed == project
                ? _value.project
                : project // ignore: cast_nullable_to_non_nullable
                      as DropdownItem?,
            work: freezed == work
                ? _value.work
                : work // ignore: cast_nullable_to_non_nullable
                      as DropdownItem?,
            contract: freezed == contract
                ? _value.contract
                : contract // ignore: cast_nullable_to_non_nullable
                      as DropdownItem?,
            structureType: freezed == structureType
                ? _value.structureType
                : structureType // ignore: cast_nullable_to_non_nullable
                      as DropdownItem?,
            structure: freezed == structure
                ? _value.structure
                : structure // ignore: cast_nullable_to_non_nullable
                      as DropdownItem?,
            component: freezed == component
                ? _value.component
                : component // ignore: cast_nullable_to_non_nullable
                      as DropdownItem?,
            element: freezed == element
                ? _value.element
                : element // ignore: cast_nullable_to_non_nullable
                      as DropdownItem?,
            activity: freezed == activity
                ? _value.activity
                : activity // ignore: cast_nullable_to_non_nullable
                      as DropdownItem?,
            rfiDescription: freezed == rfiDescription
                ? _value.rfiDescription
                : rfiDescription // ignore: cast_nullable_to_non_nullable
                      as DropdownItem?,
            currentStep: null == currentStep
                ? _value.currentStep
                : currentStep // ignore: cast_nullable_to_non_nullable
                      as int,
            action: freezed == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String?,
            typeOfRfi: freezed == typeOfRfi
                ? _value.typeOfRfi
                : typeOfRfi // ignore: cast_nullable_to_non_nullable
                      as String?,
            contractorRepresentative: freezed == contractorRepresentative
                ? _value.contractorRepresentative
                : contractorRepresentative // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateOfSubmission: freezed == dateOfSubmission
                ? _value.dateOfSubmission
                : dateOfSubmission // ignore: cast_nullable_to_non_nullable
                      as String?,
            timeOfInspection: freezed == timeOfInspection
                ? _value.timeOfInspection
                : timeOfInspection // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateOfInspection: freezed == dateOfInspection
                ? _value.dateOfInspection
                : dateOfInspection // ignore: cast_nullable_to_non_nullable
                      as String?,
            selectedEnclosures: null == selectedEnclosures
                ? _value.selectedEnclosures
                : selectedEnclosures // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            rfiDescriptionText: freezed == rfiDescriptionText
                ? _value.rfiDescriptionText
                : rfiDescriptionText // ignore: cast_nullable_to_non_nullable
                      as String?,
            projects: null == projects
                ? _value.projects
                : projects // ignore: cast_nullable_to_non_nullable
                      as List<DropdownItem>,
            works: null == works
                ? _value.works
                : works // ignore: cast_nullable_to_non_nullable
                      as List<DropdownItem>,
            contracts: null == contracts
                ? _value.contracts
                : contracts // ignore: cast_nullable_to_non_nullable
                      as List<DropdownItem>,
            structureTypes: null == structureTypes
                ? _value.structureTypes
                : structureTypes // ignore: cast_nullable_to_non_nullable
                      as List<DropdownItem>,
            structures: null == structures
                ? _value.structures
                : structures // ignore: cast_nullable_to_non_nullable
                      as List<DropdownItem>,
            components: null == components
                ? _value.components
                : components // ignore: cast_nullable_to_non_nullable
                      as List<DropdownItem>,
            elements: null == elements
                ? _value.elements
                : elements // ignore: cast_nullable_to_non_nullable
                      as List<DropdownItem>,
            activities: null == activities
                ? _value.activities
                : activities // ignore: cast_nullable_to_non_nullable
                      as List<DropdownItem>,
            rfiDescriptions: null == rfiDescriptions
                ? _value.rfiDescriptions
                : rfiDescriptions // ignore: cast_nullable_to_non_nullable
                      as List<DropdownItem>,
            representatives: null == representatives
                ? _value.representatives
                : representatives // ignore: cast_nullable_to_non_nullable
                      as List<DropdownItem>,
          )
          as $Val,
    );
  }

  /// Create a copy of RfiDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DropdownItemCopyWith<$Res>? get project {
    if (_value.project == null) {
      return null;
    }

    return $DropdownItemCopyWith<$Res>(_value.project!, (value) {
      return _then(_value.copyWith(project: value) as $Val);
    });
  }

  /// Create a copy of RfiDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DropdownItemCopyWith<$Res>? get work {
    if (_value.work == null) {
      return null;
    }

    return $DropdownItemCopyWith<$Res>(_value.work!, (value) {
      return _then(_value.copyWith(work: value) as $Val);
    });
  }

  /// Create a copy of RfiDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DropdownItemCopyWith<$Res>? get contract {
    if (_value.contract == null) {
      return null;
    }

    return $DropdownItemCopyWith<$Res>(_value.contract!, (value) {
      return _then(_value.copyWith(contract: value) as $Val);
    });
  }

  /// Create a copy of RfiDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DropdownItemCopyWith<$Res>? get structureType {
    if (_value.structureType == null) {
      return null;
    }

    return $DropdownItemCopyWith<$Res>(_value.structureType!, (value) {
      return _then(_value.copyWith(structureType: value) as $Val);
    });
  }

  /// Create a copy of RfiDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DropdownItemCopyWith<$Res>? get structure {
    if (_value.structure == null) {
      return null;
    }

    return $DropdownItemCopyWith<$Res>(_value.structure!, (value) {
      return _then(_value.copyWith(structure: value) as $Val);
    });
  }

  /// Create a copy of RfiDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DropdownItemCopyWith<$Res>? get component {
    if (_value.component == null) {
      return null;
    }

    return $DropdownItemCopyWith<$Res>(_value.component!, (value) {
      return _then(_value.copyWith(component: value) as $Val);
    });
  }

  /// Create a copy of RfiDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DropdownItemCopyWith<$Res>? get element {
    if (_value.element == null) {
      return null;
    }

    return $DropdownItemCopyWith<$Res>(_value.element!, (value) {
      return _then(_value.copyWith(element: value) as $Val);
    });
  }

  /// Create a copy of RfiDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DropdownItemCopyWith<$Res>? get activity {
    if (_value.activity == null) {
      return null;
    }

    return $DropdownItemCopyWith<$Res>(_value.activity!, (value) {
      return _then(_value.copyWith(activity: value) as $Val);
    });
  }

  /// Create a copy of RfiDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DropdownItemCopyWith<$Res>? get rfiDescription {
    if (_value.rfiDescription == null) {
      return null;
    }

    return $DropdownItemCopyWith<$Res>(_value.rfiDescription!, (value) {
      return _then(_value.copyWith(rfiDescription: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RfiDraftImplCopyWith<$Res>
    implements $RfiDraftCopyWith<$Res> {
  factory _$$RfiDraftImplCopyWith(
    _$RfiDraftImpl value,
    $Res Function(_$RfiDraftImpl) then,
  ) = __$$RfiDraftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DropdownItem? project,
    DropdownItem? work,
    DropdownItem? contract,
    DropdownItem? structureType,
    DropdownItem? structure,
    DropdownItem? component,
    DropdownItem? element,
    DropdownItem? activity,
    DropdownItem? rfiDescription,
    int currentStep,
    String? action,
    String? typeOfRfi,
    String? contractorRepresentative,
    String? dateOfSubmission,
    String? timeOfInspection,
    String? dateOfInspection,
    List<String> selectedEnclosures,
    String? rfiDescriptionText,
    List<DropdownItem> projects,
    List<DropdownItem> works,
    List<DropdownItem> contracts,
    List<DropdownItem> structureTypes,
    List<DropdownItem> structures,
    List<DropdownItem> components,
    List<DropdownItem> elements,
    List<DropdownItem> activities,
    List<DropdownItem> rfiDescriptions,
    List<DropdownItem> representatives,
  });

  @override
  $DropdownItemCopyWith<$Res>? get project;
  @override
  $DropdownItemCopyWith<$Res>? get work;
  @override
  $DropdownItemCopyWith<$Res>? get contract;
  @override
  $DropdownItemCopyWith<$Res>? get structureType;
  @override
  $DropdownItemCopyWith<$Res>? get structure;
  @override
  $DropdownItemCopyWith<$Res>? get component;
  @override
  $DropdownItemCopyWith<$Res>? get element;
  @override
  $DropdownItemCopyWith<$Res>? get activity;
  @override
  $DropdownItemCopyWith<$Res>? get rfiDescription;
}

/// @nodoc
class __$$RfiDraftImplCopyWithImpl<$Res>
    extends _$RfiDraftCopyWithImpl<$Res, _$RfiDraftImpl>
    implements _$$RfiDraftImplCopyWith<$Res> {
  __$$RfiDraftImplCopyWithImpl(
    _$RfiDraftImpl _value,
    $Res Function(_$RfiDraftImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RfiDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? project = freezed,
    Object? work = freezed,
    Object? contract = freezed,
    Object? structureType = freezed,
    Object? structure = freezed,
    Object? component = freezed,
    Object? element = freezed,
    Object? activity = freezed,
    Object? rfiDescription = freezed,
    Object? currentStep = null,
    Object? action = freezed,
    Object? typeOfRfi = freezed,
    Object? contractorRepresentative = freezed,
    Object? dateOfSubmission = freezed,
    Object? timeOfInspection = freezed,
    Object? dateOfInspection = freezed,
    Object? selectedEnclosures = null,
    Object? rfiDescriptionText = freezed,
    Object? projects = null,
    Object? works = null,
    Object? contracts = null,
    Object? structureTypes = null,
    Object? structures = null,
    Object? components = null,
    Object? elements = null,
    Object? activities = null,
    Object? rfiDescriptions = null,
    Object? representatives = null,
  }) {
    return _then(
      _$RfiDraftImpl(
        project: freezed == project
            ? _value.project
            : project // ignore: cast_nullable_to_non_nullable
                  as DropdownItem?,
        work: freezed == work
            ? _value.work
            : work // ignore: cast_nullable_to_non_nullable
                  as DropdownItem?,
        contract: freezed == contract
            ? _value.contract
            : contract // ignore: cast_nullable_to_non_nullable
                  as DropdownItem?,
        structureType: freezed == structureType
            ? _value.structureType
            : structureType // ignore: cast_nullable_to_non_nullable
                  as DropdownItem?,
        structure: freezed == structure
            ? _value.structure
            : structure // ignore: cast_nullable_to_non_nullable
                  as DropdownItem?,
        component: freezed == component
            ? _value.component
            : component // ignore: cast_nullable_to_non_nullable
                  as DropdownItem?,
        element: freezed == element
            ? _value.element
            : element // ignore: cast_nullable_to_non_nullable
                  as DropdownItem?,
        activity: freezed == activity
            ? _value.activity
            : activity // ignore: cast_nullable_to_non_nullable
                  as DropdownItem?,
        rfiDescription: freezed == rfiDescription
            ? _value.rfiDescription
            : rfiDescription // ignore: cast_nullable_to_non_nullable
                  as DropdownItem?,
        currentStep: null == currentStep
            ? _value.currentStep
            : currentStep // ignore: cast_nullable_to_non_nullable
                  as int,
        action: freezed == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String?,
        typeOfRfi: freezed == typeOfRfi
            ? _value.typeOfRfi
            : typeOfRfi // ignore: cast_nullable_to_non_nullable
                  as String?,
        contractorRepresentative: freezed == contractorRepresentative
            ? _value.contractorRepresentative
            : contractorRepresentative // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateOfSubmission: freezed == dateOfSubmission
            ? _value.dateOfSubmission
            : dateOfSubmission // ignore: cast_nullable_to_non_nullable
                  as String?,
        timeOfInspection: freezed == timeOfInspection
            ? _value.timeOfInspection
            : timeOfInspection // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateOfInspection: freezed == dateOfInspection
            ? _value.dateOfInspection
            : dateOfInspection // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedEnclosures: null == selectedEnclosures
            ? _value._selectedEnclosures
            : selectedEnclosures // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        rfiDescriptionText: freezed == rfiDescriptionText
            ? _value.rfiDescriptionText
            : rfiDescriptionText // ignore: cast_nullable_to_non_nullable
                  as String?,
        projects: null == projects
            ? _value._projects
            : projects // ignore: cast_nullable_to_non_nullable
                  as List<DropdownItem>,
        works: null == works
            ? _value._works
            : works // ignore: cast_nullable_to_non_nullable
                  as List<DropdownItem>,
        contracts: null == contracts
            ? _value._contracts
            : contracts // ignore: cast_nullable_to_non_nullable
                  as List<DropdownItem>,
        structureTypes: null == structureTypes
            ? _value._structureTypes
            : structureTypes // ignore: cast_nullable_to_non_nullable
                  as List<DropdownItem>,
        structures: null == structures
            ? _value._structures
            : structures // ignore: cast_nullable_to_non_nullable
                  as List<DropdownItem>,
        components: null == components
            ? _value._components
            : components // ignore: cast_nullable_to_non_nullable
                  as List<DropdownItem>,
        elements: null == elements
            ? _value._elements
            : elements // ignore: cast_nullable_to_non_nullable
                  as List<DropdownItem>,
        activities: null == activities
            ? _value._activities
            : activities // ignore: cast_nullable_to_non_nullable
                  as List<DropdownItem>,
        rfiDescriptions: null == rfiDescriptions
            ? _value._rfiDescriptions
            : rfiDescriptions // ignore: cast_nullable_to_non_nullable
                  as List<DropdownItem>,
        representatives: null == representatives
            ? _value._representatives
            : representatives // ignore: cast_nullable_to_non_nullable
                  as List<DropdownItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RfiDraftImpl implements _RfiDraft {
  const _$RfiDraftImpl({
    this.project,
    this.work,
    this.contract,
    this.structureType,
    this.structure,
    this.component,
    this.element,
    this.activity,
    this.rfiDescription,
    this.currentStep = 0,
    this.action,
    this.typeOfRfi,
    this.contractorRepresentative,
    this.dateOfSubmission,
    this.timeOfInspection,
    this.dateOfInspection,
    final List<String> selectedEnclosures = const [],
    this.rfiDescriptionText,
    final List<DropdownItem> projects = const [],
    final List<DropdownItem> works = const [],
    final List<DropdownItem> contracts = const [],
    final List<DropdownItem> structureTypes = const [],
    final List<DropdownItem> structures = const [],
    final List<DropdownItem> components = const [],
    final List<DropdownItem> elements = const [],
    final List<DropdownItem> activities = const [],
    final List<DropdownItem> rfiDescriptions = const [],
    final List<DropdownItem> representatives = const [],
  }) : _selectedEnclosures = selectedEnclosures,
       _projects = projects,
       _works = works,
       _contracts = contracts,
       _structureTypes = structureTypes,
       _structures = structures,
       _components = components,
       _elements = elements,
       _activities = activities,
       _rfiDescriptions = rfiDescriptions,
       _representatives = representatives;

  factory _$RfiDraftImpl.fromJson(Map<String, dynamic> json) =>
      _$$RfiDraftImplFromJson(json);

  // Selections
  @override
  final DropdownItem? project;
  @override
  final DropdownItem? work;
  @override
  final DropdownItem? contract;
  @override
  final DropdownItem? structureType;
  @override
  final DropdownItem? structure;
  @override
  final DropdownItem? component;
  @override
  final DropdownItem? element;
  @override
  final DropdownItem? activity;
  @override
  final DropdownItem? rfiDescription;
  // Step 2 Fields
  @override
  @JsonKey()
  final int currentStep;
  @override
  final String? action;
  @override
  final String? typeOfRfi;
  @override
  final String? contractorRepresentative;
  @override
  final String? dateOfSubmission;
  @override
  final String? timeOfInspection;
  @override
  final String? dateOfInspection;
  // Step 3 Fields
  final List<String> _selectedEnclosures;
  // Step 3 Fields
  @override
  @JsonKey()
  List<String> get selectedEnclosures {
    if (_selectedEnclosures is EqualUnmodifiableListView)
      return _selectedEnclosures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedEnclosures);
  }

  @override
  final String? rfiDescriptionText;
  // Cached Lists
  final List<DropdownItem> _projects;
  // Cached Lists
  @override
  @JsonKey()
  List<DropdownItem> get projects {
    if (_projects is EqualUnmodifiableListView) return _projects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_projects);
  }

  final List<DropdownItem> _works;
  @override
  @JsonKey()
  List<DropdownItem> get works {
    if (_works is EqualUnmodifiableListView) return _works;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_works);
  }

  final List<DropdownItem> _contracts;
  @override
  @JsonKey()
  List<DropdownItem> get contracts {
    if (_contracts is EqualUnmodifiableListView) return _contracts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contracts);
  }

  final List<DropdownItem> _structureTypes;
  @override
  @JsonKey()
  List<DropdownItem> get structureTypes {
    if (_structureTypes is EqualUnmodifiableListView) return _structureTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_structureTypes);
  }

  final List<DropdownItem> _structures;
  @override
  @JsonKey()
  List<DropdownItem> get structures {
    if (_structures is EqualUnmodifiableListView) return _structures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_structures);
  }

  final List<DropdownItem> _components;
  @override
  @JsonKey()
  List<DropdownItem> get components {
    if (_components is EqualUnmodifiableListView) return _components;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_components);
  }

  final List<DropdownItem> _elements;
  @override
  @JsonKey()
  List<DropdownItem> get elements {
    if (_elements is EqualUnmodifiableListView) return _elements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_elements);
  }

  final List<DropdownItem> _activities;
  @override
  @JsonKey()
  List<DropdownItem> get activities {
    if (_activities is EqualUnmodifiableListView) return _activities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activities);
  }

  final List<DropdownItem> _rfiDescriptions;
  @override
  @JsonKey()
  List<DropdownItem> get rfiDescriptions {
    if (_rfiDescriptions is EqualUnmodifiableListView) return _rfiDescriptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rfiDescriptions);
  }

  final List<DropdownItem> _representatives;
  @override
  @JsonKey()
  List<DropdownItem> get representatives {
    if (_representatives is EqualUnmodifiableListView) return _representatives;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_representatives);
  }

  @override
  String toString() {
    return 'RfiDraft(project: $project, work: $work, contract: $contract, structureType: $structureType, structure: $structure, component: $component, element: $element, activity: $activity, rfiDescription: $rfiDescription, currentStep: $currentStep, action: $action, typeOfRfi: $typeOfRfi, contractorRepresentative: $contractorRepresentative, dateOfSubmission: $dateOfSubmission, timeOfInspection: $timeOfInspection, dateOfInspection: $dateOfInspection, selectedEnclosures: $selectedEnclosures, rfiDescriptionText: $rfiDescriptionText, projects: $projects, works: $works, contracts: $contracts, structureTypes: $structureTypes, structures: $structures, components: $components, elements: $elements, activities: $activities, rfiDescriptions: $rfiDescriptions, representatives: $representatives)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RfiDraftImpl &&
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
            (identical(other.rfiDescription, rfiDescription) ||
                other.rfiDescription == rfiDescription) &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.typeOfRfi, typeOfRfi) ||
                other.typeOfRfi == typeOfRfi) &&
            (identical(
                  other.contractorRepresentative,
                  contractorRepresentative,
                ) ||
                other.contractorRepresentative == contractorRepresentative) &&
            (identical(other.dateOfSubmission, dateOfSubmission) ||
                other.dateOfSubmission == dateOfSubmission) &&
            (identical(other.timeOfInspection, timeOfInspection) ||
                other.timeOfInspection == timeOfInspection) &&
            (identical(other.dateOfInspection, dateOfInspection) ||
                other.dateOfInspection == dateOfInspection) &&
            const DeepCollectionEquality().equals(
              other._selectedEnclosures,
              _selectedEnclosures,
            ) &&
            (identical(other.rfiDescriptionText, rfiDescriptionText) ||
                other.rfiDescriptionText == rfiDescriptionText) &&
            const DeepCollectionEquality().equals(other._projects, _projects) &&
            const DeepCollectionEquality().equals(other._works, _works) &&
            const DeepCollectionEquality().equals(
              other._contracts,
              _contracts,
            ) &&
            const DeepCollectionEquality().equals(
              other._structureTypes,
              _structureTypes,
            ) &&
            const DeepCollectionEquality().equals(
              other._structures,
              _structures,
            ) &&
            const DeepCollectionEquality().equals(
              other._components,
              _components,
            ) &&
            const DeepCollectionEquality().equals(other._elements, _elements) &&
            const DeepCollectionEquality().equals(
              other._activities,
              _activities,
            ) &&
            const DeepCollectionEquality().equals(
              other._rfiDescriptions,
              _rfiDescriptions,
            ) &&
            const DeepCollectionEquality().equals(
              other._representatives,
              _representatives,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    project,
    work,
    contract,
    structureType,
    structure,
    component,
    element,
    activity,
    rfiDescription,
    currentStep,
    action,
    typeOfRfi,
    contractorRepresentative,
    dateOfSubmission,
    timeOfInspection,
    dateOfInspection,
    const DeepCollectionEquality().hash(_selectedEnclosures),
    rfiDescriptionText,
    const DeepCollectionEquality().hash(_projects),
    const DeepCollectionEquality().hash(_works),
    const DeepCollectionEquality().hash(_contracts),
    const DeepCollectionEquality().hash(_structureTypes),
    const DeepCollectionEquality().hash(_structures),
    const DeepCollectionEquality().hash(_components),
    const DeepCollectionEquality().hash(_elements),
    const DeepCollectionEquality().hash(_activities),
    const DeepCollectionEquality().hash(_rfiDescriptions),
    const DeepCollectionEquality().hash(_representatives),
  ]);

  /// Create a copy of RfiDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RfiDraftImplCopyWith<_$RfiDraftImpl> get copyWith =>
      __$$RfiDraftImplCopyWithImpl<_$RfiDraftImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RfiDraftImplToJson(this);
  }
}

abstract class _RfiDraft implements RfiDraft {
  const factory _RfiDraft({
    final DropdownItem? project,
    final DropdownItem? work,
    final DropdownItem? contract,
    final DropdownItem? structureType,
    final DropdownItem? structure,
    final DropdownItem? component,
    final DropdownItem? element,
    final DropdownItem? activity,
    final DropdownItem? rfiDescription,
    final int currentStep,
    final String? action,
    final String? typeOfRfi,
    final String? contractorRepresentative,
    final String? dateOfSubmission,
    final String? timeOfInspection,
    final String? dateOfInspection,
    final List<String> selectedEnclosures,
    final String? rfiDescriptionText,
    final List<DropdownItem> projects,
    final List<DropdownItem> works,
    final List<DropdownItem> contracts,
    final List<DropdownItem> structureTypes,
    final List<DropdownItem> structures,
    final List<DropdownItem> components,
    final List<DropdownItem> elements,
    final List<DropdownItem> activities,
    final List<DropdownItem> rfiDescriptions,
    final List<DropdownItem> representatives,
  }) = _$RfiDraftImpl;

  factory _RfiDraft.fromJson(Map<String, dynamic> json) =
      _$RfiDraftImpl.fromJson;

  // Selections
  @override
  DropdownItem? get project;
  @override
  DropdownItem? get work;
  @override
  DropdownItem? get contract;
  @override
  DropdownItem? get structureType;
  @override
  DropdownItem? get structure;
  @override
  DropdownItem? get component;
  @override
  DropdownItem? get element;
  @override
  DropdownItem? get activity;
  @override
  DropdownItem? get rfiDescription; // Step 2 Fields
  @override
  int get currentStep;
  @override
  String? get action;
  @override
  String? get typeOfRfi;
  @override
  String? get contractorRepresentative;
  @override
  String? get dateOfSubmission;
  @override
  String? get timeOfInspection;
  @override
  String? get dateOfInspection; // Step 3 Fields
  @override
  List<String> get selectedEnclosures;
  @override
  String? get rfiDescriptionText; // Cached Lists
  @override
  List<DropdownItem> get projects;
  @override
  List<DropdownItem> get works;
  @override
  List<DropdownItem> get contracts;
  @override
  List<DropdownItem> get structureTypes;
  @override
  List<DropdownItem> get structures;
  @override
  List<DropdownItem> get components;
  @override
  List<DropdownItem> get elements;
  @override
  List<DropdownItem> get activities;
  @override
  List<DropdownItem> get rfiDescriptions;
  @override
  List<DropdownItem> get representatives;

  /// Create a copy of RfiDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RfiDraftImplCopyWith<_$RfiDraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
