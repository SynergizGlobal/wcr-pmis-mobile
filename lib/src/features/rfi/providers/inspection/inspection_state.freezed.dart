// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$InspectionState {
  List<InspectionItem> get allItems => throw _privateConstructorUsedError;
  List<InspectionItem> get filteredItems => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get rowsPerPage => throw _privateConstructorUsedError;

  /// Create a copy of InspectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InspectionStateCopyWith<InspectionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InspectionStateCopyWith<$Res> {
  factory $InspectionStateCopyWith(
    InspectionState value,
    $Res Function(InspectionState) then,
  ) = _$InspectionStateCopyWithImpl<$Res, InspectionState>;
  @useResult
  $Res call({
    List<InspectionItem> allItems,
    List<InspectionItem> filteredItems,
    bool isLoading,
    String? error,
    String searchQuery,
    int currentPage,
    int rowsPerPage,
  });
}

/// @nodoc
class _$InspectionStateCopyWithImpl<$Res, $Val extends InspectionState>
    implements $InspectionStateCopyWith<$Res> {
  _$InspectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InspectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allItems = null,
    Object? filteredItems = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? searchQuery = null,
    Object? currentPage = null,
    Object? rowsPerPage = null,
  }) {
    return _then(
      _value.copyWith(
            allItems: null == allItems
                ? _value.allItems
                : allItems // ignore: cast_nullable_to_non_nullable
                      as List<InspectionItem>,
            filteredItems: null == filteredItems
                ? _value.filteredItems
                : filteredItems // ignore: cast_nullable_to_non_nullable
                      as List<InspectionItem>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            searchQuery: null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String,
            currentPage: null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                      as int,
            rowsPerPage: null == rowsPerPage
                ? _value.rowsPerPage
                : rowsPerPage // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InspectionStateImplCopyWith<$Res>
    implements $InspectionStateCopyWith<$Res> {
  factory _$$InspectionStateImplCopyWith(
    _$InspectionStateImpl value,
    $Res Function(_$InspectionStateImpl) then,
  ) = __$$InspectionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<InspectionItem> allItems,
    List<InspectionItem> filteredItems,
    bool isLoading,
    String? error,
    String searchQuery,
    int currentPage,
    int rowsPerPage,
  });
}

/// @nodoc
class __$$InspectionStateImplCopyWithImpl<$Res>
    extends _$InspectionStateCopyWithImpl<$Res, _$InspectionStateImpl>
    implements _$$InspectionStateImplCopyWith<$Res> {
  __$$InspectionStateImplCopyWithImpl(
    _$InspectionStateImpl _value,
    $Res Function(_$InspectionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InspectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allItems = null,
    Object? filteredItems = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? searchQuery = null,
    Object? currentPage = null,
    Object? rowsPerPage = null,
  }) {
    return _then(
      _$InspectionStateImpl(
        allItems: null == allItems
            ? _value._allItems
            : allItems // ignore: cast_nullable_to_non_nullable
                  as List<InspectionItem>,
        filteredItems: null == filteredItems
            ? _value._filteredItems
            : filteredItems // ignore: cast_nullable_to_non_nullable
                  as List<InspectionItem>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        searchQuery: null == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String,
        currentPage: null == currentPage
            ? _value.currentPage
            : currentPage // ignore: cast_nullable_to_non_nullable
                  as int,
        rowsPerPage: null == rowsPerPage
            ? _value.rowsPerPage
            : rowsPerPage // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$InspectionStateImpl implements _InspectionState {
  const _$InspectionStateImpl({
    final List<InspectionItem> allItems = const [],
    final List<InspectionItem> filteredItems = const [],
    this.isLoading = true,
    this.error,
    this.searchQuery = '',
    this.currentPage = 1,
    this.rowsPerPage = 5,
  }) : _allItems = allItems,
       _filteredItems = filteredItems;

  final List<InspectionItem> _allItems;
  @override
  @JsonKey()
  List<InspectionItem> get allItems {
    if (_allItems is EqualUnmodifiableListView) return _allItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allItems);
  }

  final List<InspectionItem> _filteredItems;
  @override
  @JsonKey()
  List<InspectionItem> get filteredItems {
    if (_filteredItems is EqualUnmodifiableListView) return _filteredItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredItems);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final int rowsPerPage;

  @override
  String toString() {
    return 'InspectionState(allItems: $allItems, filteredItems: $filteredItems, isLoading: $isLoading, error: $error, searchQuery: $searchQuery, currentPage: $currentPage, rowsPerPage: $rowsPerPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InspectionStateImpl &&
            const DeepCollectionEquality().equals(other._allItems, _allItems) &&
            const DeepCollectionEquality().equals(
              other._filteredItems,
              _filteredItems,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.rowsPerPage, rowsPerPage) ||
                other.rowsPerPage == rowsPerPage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_allItems),
    const DeepCollectionEquality().hash(_filteredItems),
    isLoading,
    error,
    searchQuery,
    currentPage,
    rowsPerPage,
  );

  /// Create a copy of InspectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InspectionStateImplCopyWith<_$InspectionStateImpl> get copyWith =>
      __$$InspectionStateImplCopyWithImpl<_$InspectionStateImpl>(
        this,
        _$identity,
      );
}

abstract class _InspectionState implements InspectionState {
  const factory _InspectionState({
    final List<InspectionItem> allItems,
    final List<InspectionItem> filteredItems,
    final bool isLoading,
    final String? error,
    final String searchQuery,
    final int currentPage,
    final int rowsPerPage,
  }) = _$InspectionStateImpl;

  @override
  List<InspectionItem> get allItems;
  @override
  List<InspectionItem> get filteredItems;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  String get searchQuery;
  @override
  int get currentPage;
  @override
  int get rowsPerPage;

  /// Create a copy of InspectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InspectionStateImplCopyWith<_$InspectionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
