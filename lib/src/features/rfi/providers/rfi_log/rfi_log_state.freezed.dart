// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rfi_log_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RfiLogState {
  List<RfiLogItem> get allItems => throw _privateConstructorUsedError;
  List<RfiLogItem> get filteredItems => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  String get projectFilter => throw _privateConstructorUsedError;
  String get workFilter => throw _privateConstructorUsedError;
  String get contractFilter => throw _privateConstructorUsedError;
  List<String> get availableProjects => throw _privateConstructorUsedError;
  List<String> get availableWorks => throw _privateConstructorUsedError;
  List<String> get availableContracts => throw _privateConstructorUsedError;
  RfiLogDashboardFilter get dashboardFilter =>
      throw _privateConstructorUsedError;
  int get entriesPerPage => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of RfiLogState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RfiLogStateCopyWith<RfiLogState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RfiLogStateCopyWith<$Res> {
  factory $RfiLogStateCopyWith(
    RfiLogState value,
    $Res Function(RfiLogState) then,
  ) = _$RfiLogStateCopyWithImpl<$Res, RfiLogState>;
  @useResult
  $Res call({
    List<RfiLogItem> allItems,
    List<RfiLogItem> filteredItems,
    String searchQuery,
    String projectFilter,
    String workFilter,
    String contractFilter,
    List<String> availableProjects,
    List<String> availableWorks,
    List<String> availableContracts,
    RfiLogDashboardFilter dashboardFilter,
    int entriesPerPage,
    int currentPage,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class _$RfiLogStateCopyWithImpl<$Res, $Val extends RfiLogState>
    implements $RfiLogStateCopyWith<$Res> {
  _$RfiLogStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RfiLogState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allItems = null,
    Object? filteredItems = null,
    Object? searchQuery = null,
    Object? projectFilter = null,
    Object? workFilter = null,
    Object? contractFilter = null,
    Object? availableProjects = null,
    Object? availableWorks = null,
    Object? availableContracts = null,
    Object? dashboardFilter = null,
    Object? entriesPerPage = null,
    Object? currentPage = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            allItems: null == allItems
                ? _value.allItems
                : allItems // ignore: cast_nullable_to_non_nullable
                      as List<RfiLogItem>,
            filteredItems: null == filteredItems
                ? _value.filteredItems
                : filteredItems // ignore: cast_nullable_to_non_nullable
                      as List<RfiLogItem>,
            searchQuery: null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String,
            projectFilter: null == projectFilter
                ? _value.projectFilter
                : projectFilter // ignore: cast_nullable_to_non_nullable
                      as String,
            workFilter: null == workFilter
                ? _value.workFilter
                : workFilter // ignore: cast_nullable_to_non_nullable
                      as String,
            contractFilter: null == contractFilter
                ? _value.contractFilter
                : contractFilter // ignore: cast_nullable_to_non_nullable
                      as String,
            availableProjects: null == availableProjects
                ? _value.availableProjects
                : availableProjects // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            availableWorks: null == availableWorks
                ? _value.availableWorks
                : availableWorks // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            availableContracts: null == availableContracts
                ? _value.availableContracts
                : availableContracts // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            dashboardFilter: null == dashboardFilter
                ? _value.dashboardFilter
                : dashboardFilter // ignore: cast_nullable_to_non_nullable
                      as RfiLogDashboardFilter,
            entriesPerPage: null == entriesPerPage
                ? _value.entriesPerPage
                : entriesPerPage // ignore: cast_nullable_to_non_nullable
                      as int,
            currentPage: null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                      as int,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RfiLogStateImplCopyWith<$Res>
    implements $RfiLogStateCopyWith<$Res> {
  factory _$$RfiLogStateImplCopyWith(
    _$RfiLogStateImpl value,
    $Res Function(_$RfiLogStateImpl) then,
  ) = __$$RfiLogStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<RfiLogItem> allItems,
    List<RfiLogItem> filteredItems,
    String searchQuery,
    String projectFilter,
    String workFilter,
    String contractFilter,
    List<String> availableProjects,
    List<String> availableWorks,
    List<String> availableContracts,
    RfiLogDashboardFilter dashboardFilter,
    int entriesPerPage,
    int currentPage,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class __$$RfiLogStateImplCopyWithImpl<$Res>
    extends _$RfiLogStateCopyWithImpl<$Res, _$RfiLogStateImpl>
    implements _$$RfiLogStateImplCopyWith<$Res> {
  __$$RfiLogStateImplCopyWithImpl(
    _$RfiLogStateImpl _value,
    $Res Function(_$RfiLogStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RfiLogState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allItems = null,
    Object? filteredItems = null,
    Object? searchQuery = null,
    Object? projectFilter = null,
    Object? workFilter = null,
    Object? contractFilter = null,
    Object? availableProjects = null,
    Object? availableWorks = null,
    Object? availableContracts = null,
    Object? dashboardFilter = null,
    Object? entriesPerPage = null,
    Object? currentPage = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$RfiLogStateImpl(
        allItems: null == allItems
            ? _value._allItems
            : allItems // ignore: cast_nullable_to_non_nullable
                  as List<RfiLogItem>,
        filteredItems: null == filteredItems
            ? _value._filteredItems
            : filteredItems // ignore: cast_nullable_to_non_nullable
                  as List<RfiLogItem>,
        searchQuery: null == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String,
        projectFilter: null == projectFilter
            ? _value.projectFilter
            : projectFilter // ignore: cast_nullable_to_non_nullable
                  as String,
        workFilter: null == workFilter
            ? _value.workFilter
            : workFilter // ignore: cast_nullable_to_non_nullable
                  as String,
        contractFilter: null == contractFilter
            ? _value.contractFilter
            : contractFilter // ignore: cast_nullable_to_non_nullable
                  as String,
        availableProjects: null == availableProjects
            ? _value._availableProjects
            : availableProjects // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        availableWorks: null == availableWorks
            ? _value._availableWorks
            : availableWorks // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        availableContracts: null == availableContracts
            ? _value._availableContracts
            : availableContracts // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        dashboardFilter: null == dashboardFilter
            ? _value.dashboardFilter
            : dashboardFilter // ignore: cast_nullable_to_non_nullable
                  as RfiLogDashboardFilter,
        entriesPerPage: null == entriesPerPage
            ? _value.entriesPerPage
            : entriesPerPage // ignore: cast_nullable_to_non_nullable
                  as int,
        currentPage: null == currentPage
            ? _value.currentPage
            : currentPage // ignore: cast_nullable_to_non_nullable
                  as int,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$RfiLogStateImpl extends _RfiLogState {
  const _$RfiLogStateImpl({
    final List<RfiLogItem> allItems = const [],
    final List<RfiLogItem> filteredItems = const [],
    this.searchQuery = '',
    this.projectFilter = '',
    this.workFilter = '',
    this.contractFilter = '',
    final List<String> availableProjects = const [],
    final List<String> availableWorks = const [],
    final List<String> availableContracts = const [],
    this.dashboardFilter = RfiLogDashboardFilter.none,
    this.entriesPerPage = 10,
    this.currentPage = 1,
    this.isLoading = false,
    this.errorMessage,
  }) : _allItems = allItems,
       _filteredItems = filteredItems,
       _availableProjects = availableProjects,
       _availableWorks = availableWorks,
       _availableContracts = availableContracts,
       super._();

  final List<RfiLogItem> _allItems;
  @override
  @JsonKey()
  List<RfiLogItem> get allItems {
    if (_allItems is EqualUnmodifiableListView) return _allItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allItems);
  }

  final List<RfiLogItem> _filteredItems;
  @override
  @JsonKey()
  List<RfiLogItem> get filteredItems {
    if (_filteredItems is EqualUnmodifiableListView) return _filteredItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredItems);
  }

  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final String projectFilter;
  @override
  @JsonKey()
  final String workFilter;
  @override
  @JsonKey()
  final String contractFilter;
  final List<String> _availableProjects;
  @override
  @JsonKey()
  List<String> get availableProjects {
    if (_availableProjects is EqualUnmodifiableListView)
      return _availableProjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableProjects);
  }

  final List<String> _availableWorks;
  @override
  @JsonKey()
  List<String> get availableWorks {
    if (_availableWorks is EqualUnmodifiableListView) return _availableWorks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableWorks);
  }

  final List<String> _availableContracts;
  @override
  @JsonKey()
  List<String> get availableContracts {
    if (_availableContracts is EqualUnmodifiableListView)
      return _availableContracts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableContracts);
  }

  @override
  @JsonKey()
  final RfiLogDashboardFilter dashboardFilter;
  @override
  @JsonKey()
  final int entriesPerPage;
  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'RfiLogState(allItems: $allItems, filteredItems: $filteredItems, searchQuery: $searchQuery, projectFilter: $projectFilter, workFilter: $workFilter, contractFilter: $contractFilter, availableProjects: $availableProjects, availableWorks: $availableWorks, availableContracts: $availableContracts, dashboardFilter: $dashboardFilter, entriesPerPage: $entriesPerPage, currentPage: $currentPage, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RfiLogStateImpl &&
            const DeepCollectionEquality().equals(other._allItems, _allItems) &&
            const DeepCollectionEquality().equals(
              other._filteredItems,
              _filteredItems,
            ) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.projectFilter, projectFilter) ||
                other.projectFilter == projectFilter) &&
            (identical(other.workFilter, workFilter) ||
                other.workFilter == workFilter) &&
            (identical(other.contractFilter, contractFilter) ||
                other.contractFilter == contractFilter) &&
            const DeepCollectionEquality().equals(
              other._availableProjects,
              _availableProjects,
            ) &&
            const DeepCollectionEquality().equals(
              other._availableWorks,
              _availableWorks,
            ) &&
            const DeepCollectionEquality().equals(
              other._availableContracts,
              _availableContracts,
            ) &&
            (identical(other.dashboardFilter, dashboardFilter) ||
                other.dashboardFilter == dashboardFilter) &&
            (identical(other.entriesPerPage, entriesPerPage) ||
                other.entriesPerPage == entriesPerPage) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_allItems),
    const DeepCollectionEquality().hash(_filteredItems),
    searchQuery,
    projectFilter,
    workFilter,
    contractFilter,
    const DeepCollectionEquality().hash(_availableProjects),
    const DeepCollectionEquality().hash(_availableWorks),
    const DeepCollectionEquality().hash(_availableContracts),
    dashboardFilter,
    entriesPerPage,
    currentPage,
    isLoading,
    errorMessage,
  );

  /// Create a copy of RfiLogState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RfiLogStateImplCopyWith<_$RfiLogStateImpl> get copyWith =>
      __$$RfiLogStateImplCopyWithImpl<_$RfiLogStateImpl>(this, _$identity);
}

abstract class _RfiLogState extends RfiLogState {
  const factory _RfiLogState({
    final List<RfiLogItem> allItems,
    final List<RfiLogItem> filteredItems,
    final String searchQuery,
    final String projectFilter,
    final String workFilter,
    final String contractFilter,
    final List<String> availableProjects,
    final List<String> availableWorks,
    final List<String> availableContracts,
    final RfiLogDashboardFilter dashboardFilter,
    final int entriesPerPage,
    final int currentPage,
    final bool isLoading,
    final String? errorMessage,
  }) = _$RfiLogStateImpl;
  const _RfiLogState._() : super._();

  @override
  List<RfiLogItem> get allItems;
  @override
  List<RfiLogItem> get filteredItems;
  @override
  String get searchQuery;
  @override
  String get projectFilter;
  @override
  String get workFilter;
  @override
  String get contractFilter;
  @override
  List<String> get availableProjects;
  @override
  List<String> get availableWorks;
  @override
  List<String> get availableContracts;
  @override
  RfiLogDashboardFilter get dashboardFilter;
  @override
  int get entriesPerPage;
  @override
  int get currentPage;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of RfiLogState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RfiLogStateImplCopyWith<_$RfiLogStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
