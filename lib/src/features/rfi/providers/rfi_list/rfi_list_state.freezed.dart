// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rfi_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RfiListState {
  List<RfiListItem> get allItems => throw _privateConstructorUsedError;
  List<RfiListItem> get filteredItems => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  int get entriesPerPage => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of RfiListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RfiListStateCopyWith<RfiListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RfiListStateCopyWith<$Res> {
  factory $RfiListStateCopyWith(
    RfiListState value,
    $Res Function(RfiListState) then,
  ) = _$RfiListStateCopyWithImpl<$Res, RfiListState>;
  @useResult
  $Res call({
    List<RfiListItem> allItems,
    List<RfiListItem> filteredItems,
    String searchQuery,
    int entriesPerPage,
    int currentPage,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class _$RfiListStateCopyWithImpl<$Res, $Val extends RfiListState>
    implements $RfiListStateCopyWith<$Res> {
  _$RfiListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RfiListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allItems = null,
    Object? filteredItems = null,
    Object? searchQuery = null,
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
                      as List<RfiListItem>,
            filteredItems: null == filteredItems
                ? _value.filteredItems
                : filteredItems // ignore: cast_nullable_to_non_nullable
                      as List<RfiListItem>,
            searchQuery: null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$RfiListStateImplCopyWith<$Res>
    implements $RfiListStateCopyWith<$Res> {
  factory _$$RfiListStateImplCopyWith(
    _$RfiListStateImpl value,
    $Res Function(_$RfiListStateImpl) then,
  ) = __$$RfiListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<RfiListItem> allItems,
    List<RfiListItem> filteredItems,
    String searchQuery,
    int entriesPerPage,
    int currentPage,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class __$$RfiListStateImplCopyWithImpl<$Res>
    extends _$RfiListStateCopyWithImpl<$Res, _$RfiListStateImpl>
    implements _$$RfiListStateImplCopyWith<$Res> {
  __$$RfiListStateImplCopyWithImpl(
    _$RfiListStateImpl _value,
    $Res Function(_$RfiListStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RfiListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allItems = null,
    Object? filteredItems = null,
    Object? searchQuery = null,
    Object? entriesPerPage = null,
    Object? currentPage = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$RfiListStateImpl(
        allItems: null == allItems
            ? _value._allItems
            : allItems // ignore: cast_nullable_to_non_nullable
                  as List<RfiListItem>,
        filteredItems: null == filteredItems
            ? _value._filteredItems
            : filteredItems // ignore: cast_nullable_to_non_nullable
                  as List<RfiListItem>,
        searchQuery: null == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String,
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

class _$RfiListStateImpl extends _RfiListState {
  const _$RfiListStateImpl({
    final List<RfiListItem> allItems = const [],
    final List<RfiListItem> filteredItems = const [],
    this.searchQuery = '',
    this.entriesPerPage = 10,
    this.currentPage = 1,
    this.isLoading = false,
    this.errorMessage,
  }) : _allItems = allItems,
       _filteredItems = filteredItems,
       super._();

  final List<RfiListItem> _allItems;
  @override
  @JsonKey()
  List<RfiListItem> get allItems {
    if (_allItems is EqualUnmodifiableListView) return _allItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allItems);
  }

  final List<RfiListItem> _filteredItems;
  @override
  @JsonKey()
  List<RfiListItem> get filteredItems {
    if (_filteredItems is EqualUnmodifiableListView) return _filteredItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredItems);
  }

  @override
  @JsonKey()
  final String searchQuery;
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
    return 'RfiListState(allItems: $allItems, filteredItems: $filteredItems, searchQuery: $searchQuery, entriesPerPage: $entriesPerPage, currentPage: $currentPage, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RfiListStateImpl &&
            const DeepCollectionEquality().equals(other._allItems, _allItems) &&
            const DeepCollectionEquality().equals(
              other._filteredItems,
              _filteredItems,
            ) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
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
    entriesPerPage,
    currentPage,
    isLoading,
    errorMessage,
  );

  /// Create a copy of RfiListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RfiListStateImplCopyWith<_$RfiListStateImpl> get copyWith =>
      __$$RfiListStateImplCopyWithImpl<_$RfiListStateImpl>(this, _$identity);
}

abstract class _RfiListState extends RfiListState {
  const factory _RfiListState({
    final List<RfiListItem> allItems,
    final List<RfiListItem> filteredItems,
    final String searchQuery,
    final int entriesPerPage,
    final int currentPage,
    final bool isLoading,
    final String? errorMessage,
  }) = _$RfiListStateImpl;
  const _RfiListState._() : super._();

  @override
  List<RfiListItem> get allItems;
  @override
  List<RfiListItem> get filteredItems;
  @override
  String get searchQuery;
  @override
  int get entriesPerPage;
  @override
  int get currentPage;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of RfiListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RfiListStateImplCopyWith<_$RfiListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
