// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'validation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ValidationState {
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  List<ValidationItem> get allItems => throw _privateConstructorUsedError;
  List<ValidationItem> get filteredItems => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get entriesPerPage => throw _privateConstructorUsedError;
  Map<int, String> get pendingRemarks => throw _privateConstructorUsedError;
  Map<int, String> get pendingComments => throw _privateConstructorUsedError;
  bool get isValidating => throw _privateConstructorUsedError;
  String? get actionErrorMessage => throw _privateConstructorUsedError;

  /// Create a copy of ValidationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ValidationStateCopyWith<ValidationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidationStateCopyWith<$Res> {
  factory $ValidationStateCopyWith(
    ValidationState value,
    $Res Function(ValidationState) then,
  ) = _$ValidationStateCopyWithImpl<$Res, ValidationState>;
  @useResult
  $Res call({
    bool isLoading,
    String? errorMessage,
    List<ValidationItem> allItems,
    List<ValidationItem> filteredItems,
    String searchQuery,
    int currentPage,
    int entriesPerPage,
    Map<int, String> pendingRemarks,
    Map<int, String> pendingComments,
    bool isValidating,
    String? actionErrorMessage,
  });
}

/// @nodoc
class _$ValidationStateCopyWithImpl<$Res, $Val extends ValidationState>
    implements $ValidationStateCopyWith<$Res> {
  _$ValidationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ValidationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? allItems = null,
    Object? filteredItems = null,
    Object? searchQuery = null,
    Object? currentPage = null,
    Object? entriesPerPage = null,
    Object? pendingRemarks = null,
    Object? pendingComments = null,
    Object? isValidating = null,
    Object? actionErrorMessage = freezed,
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
            allItems: null == allItems
                ? _value.allItems
                : allItems // ignore: cast_nullable_to_non_nullable
                      as List<ValidationItem>,
            filteredItems: null == filteredItems
                ? _value.filteredItems
                : filteredItems // ignore: cast_nullable_to_non_nullable
                      as List<ValidationItem>,
            searchQuery: null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String,
            currentPage: null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                      as int,
            entriesPerPage: null == entriesPerPage
                ? _value.entriesPerPage
                : entriesPerPage // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingRemarks: null == pendingRemarks
                ? _value.pendingRemarks
                : pendingRemarks // ignore: cast_nullable_to_non_nullable
                      as Map<int, String>,
            pendingComments: null == pendingComments
                ? _value.pendingComments
                : pendingComments // ignore: cast_nullable_to_non_nullable
                      as Map<int, String>,
            isValidating: null == isValidating
                ? _value.isValidating
                : isValidating // ignore: cast_nullable_to_non_nullable
                      as bool,
            actionErrorMessage: freezed == actionErrorMessage
                ? _value.actionErrorMessage
                : actionErrorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ValidationStateImplCopyWith<$Res>
    implements $ValidationStateCopyWith<$Res> {
  factory _$$ValidationStateImplCopyWith(
    _$ValidationStateImpl value,
    $Res Function(_$ValidationStateImpl) then,
  ) = __$$ValidationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isLoading,
    String? errorMessage,
    List<ValidationItem> allItems,
    List<ValidationItem> filteredItems,
    String searchQuery,
    int currentPage,
    int entriesPerPage,
    Map<int, String> pendingRemarks,
    Map<int, String> pendingComments,
    bool isValidating,
    String? actionErrorMessage,
  });
}

/// @nodoc
class __$$ValidationStateImplCopyWithImpl<$Res>
    extends _$ValidationStateCopyWithImpl<$Res, _$ValidationStateImpl>
    implements _$$ValidationStateImplCopyWith<$Res> {
  __$$ValidationStateImplCopyWithImpl(
    _$ValidationStateImpl _value,
    $Res Function(_$ValidationStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ValidationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? allItems = null,
    Object? filteredItems = null,
    Object? searchQuery = null,
    Object? currentPage = null,
    Object? entriesPerPage = null,
    Object? pendingRemarks = null,
    Object? pendingComments = null,
    Object? isValidating = null,
    Object? actionErrorMessage = freezed,
  }) {
    return _then(
      _$ValidationStateImpl(
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        allItems: null == allItems
            ? _value._allItems
            : allItems // ignore: cast_nullable_to_non_nullable
                  as List<ValidationItem>,
        filteredItems: null == filteredItems
            ? _value._filteredItems
            : filteredItems // ignore: cast_nullable_to_non_nullable
                  as List<ValidationItem>,
        searchQuery: null == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String,
        currentPage: null == currentPage
            ? _value.currentPage
            : currentPage // ignore: cast_nullable_to_non_nullable
                  as int,
        entriesPerPage: null == entriesPerPage
            ? _value.entriesPerPage
            : entriesPerPage // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingRemarks: null == pendingRemarks
            ? _value._pendingRemarks
            : pendingRemarks // ignore: cast_nullable_to_non_nullable
                  as Map<int, String>,
        pendingComments: null == pendingComments
            ? _value._pendingComments
            : pendingComments // ignore: cast_nullable_to_non_nullable
                  as Map<int, String>,
        isValidating: null == isValidating
            ? _value.isValidating
            : isValidating // ignore: cast_nullable_to_non_nullable
                  as bool,
        actionErrorMessage: freezed == actionErrorMessage
            ? _value.actionErrorMessage
            : actionErrorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ValidationStateImpl extends _ValidationState {
  const _$ValidationStateImpl({
    this.isLoading = false,
    this.errorMessage,
    final List<ValidationItem> allItems = const [],
    final List<ValidationItem> filteredItems = const [],
    this.searchQuery = "",
    this.currentPage = 1,
    this.entriesPerPage = 5,
    final Map<int, String> pendingRemarks = const {},
    final Map<int, String> pendingComments = const {},
    this.isValidating = false,
    this.actionErrorMessage,
  }) : _allItems = allItems,
       _filteredItems = filteredItems,
       _pendingRemarks = pendingRemarks,
       _pendingComments = pendingComments,
       super._();

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;
  final List<ValidationItem> _allItems;
  @override
  @JsonKey()
  List<ValidationItem> get allItems {
    if (_allItems is EqualUnmodifiableListView) return _allItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allItems);
  }

  final List<ValidationItem> _filteredItems;
  @override
  @JsonKey()
  List<ValidationItem> get filteredItems {
    if (_filteredItems is EqualUnmodifiableListView) return _filteredItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredItems);
  }

  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final int entriesPerPage;
  final Map<int, String> _pendingRemarks;
  @override
  @JsonKey()
  Map<int, String> get pendingRemarks {
    if (_pendingRemarks is EqualUnmodifiableMapView) return _pendingRemarks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_pendingRemarks);
  }

  final Map<int, String> _pendingComments;
  @override
  @JsonKey()
  Map<int, String> get pendingComments {
    if (_pendingComments is EqualUnmodifiableMapView) return _pendingComments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_pendingComments);
  }

  @override
  @JsonKey()
  final bool isValidating;
  @override
  final String? actionErrorMessage;

  @override
  String toString() {
    return 'ValidationState(isLoading: $isLoading, errorMessage: $errorMessage, allItems: $allItems, filteredItems: $filteredItems, searchQuery: $searchQuery, currentPage: $currentPage, entriesPerPage: $entriesPerPage, pendingRemarks: $pendingRemarks, pendingComments: $pendingComments, isValidating: $isValidating, actionErrorMessage: $actionErrorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            const DeepCollectionEquality().equals(other._allItems, _allItems) &&
            const DeepCollectionEquality().equals(
              other._filteredItems,
              _filteredItems,
            ) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.entriesPerPage, entriesPerPage) ||
                other.entriesPerPage == entriesPerPage) &&
            const DeepCollectionEquality().equals(
              other._pendingRemarks,
              _pendingRemarks,
            ) &&
            const DeepCollectionEquality().equals(
              other._pendingComments,
              _pendingComments,
            ) &&
            (identical(other.isValidating, isValidating) ||
                other.isValidating == isValidating) &&
            (identical(other.actionErrorMessage, actionErrorMessage) ||
                other.actionErrorMessage == actionErrorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    errorMessage,
    const DeepCollectionEquality().hash(_allItems),
    const DeepCollectionEquality().hash(_filteredItems),
    searchQuery,
    currentPage,
    entriesPerPage,
    const DeepCollectionEquality().hash(_pendingRemarks),
    const DeepCollectionEquality().hash(_pendingComments),
    isValidating,
    actionErrorMessage,
  );

  /// Create a copy of ValidationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationStateImplCopyWith<_$ValidationStateImpl> get copyWith =>
      __$$ValidationStateImplCopyWithImpl<_$ValidationStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ValidationState extends ValidationState {
  const factory _ValidationState({
    final bool isLoading,
    final String? errorMessage,
    final List<ValidationItem> allItems,
    final List<ValidationItem> filteredItems,
    final String searchQuery,
    final int currentPage,
    final int entriesPerPage,
    final Map<int, String> pendingRemarks,
    final Map<int, String> pendingComments,
    final bool isValidating,
    final String? actionErrorMessage,
  }) = _$ValidationStateImpl;
  const _ValidationState._() : super._();

  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  List<ValidationItem> get allItems;
  @override
  List<ValidationItem> get filteredItems;
  @override
  String get searchQuery;
  @override
  int get currentPage;
  @override
  int get entriesPerPage;
  @override
  Map<int, String> get pendingRemarks;
  @override
  Map<int, String> get pendingComments;
  @override
  bool get isValidating;
  @override
  String? get actionErrorMessage;

  /// Create a copy of ValidationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationStateImplCopyWith<_$ValidationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
