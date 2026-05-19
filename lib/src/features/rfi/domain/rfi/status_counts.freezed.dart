// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status_counts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StatusCounts _$StatusCountsFromJson(Map<String, dynamic> json) {
  return _StatusCounts.fromJson(json);
}

/// @nodoc
mixin _$StatusCounts {
  @JsonKey(name: 'INSPECTED_BY_CON')
  int get inspectedByCon => throw _privateConstructorUsedError;
  @JsonKey(name: 'PENDING')
  int get pending => throw _privateConstructorUsedError;
  @JsonKey(name: 'APPROVED')
  int get approved => throw _privateConstructorUsedError;
  @JsonKey(name: 'REJECTED')
  int get rejected => throw _privateConstructorUsedError;
  @JsonKey(name: 'RESCHEDULED')
  int get rescheduled => throw _privateConstructorUsedError;
  @JsonKey(name: 'CLOSED')
  int get closed => throw _privateConstructorUsedError;
  @JsonKey(name: 'CON_INSP_ONGOING')
  int get conInspOngoing => throw _privateConstructorUsedError;

  /// Serializes this StatusCounts to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatusCounts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatusCountsCopyWith<StatusCounts> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatusCountsCopyWith<$Res> {
  factory $StatusCountsCopyWith(
    StatusCounts value,
    $Res Function(StatusCounts) then,
  ) = _$StatusCountsCopyWithImpl<$Res, StatusCounts>;
  @useResult
  $Res call({
    @JsonKey(name: 'INSPECTED_BY_CON') int inspectedByCon,
    @JsonKey(name: 'PENDING') int pending,
    @JsonKey(name: 'APPROVED') int approved,
    @JsonKey(name: 'REJECTED') int rejected,
    @JsonKey(name: 'RESCHEDULED') int rescheduled,
    @JsonKey(name: 'CLOSED') int closed,
    @JsonKey(name: 'CON_INSP_ONGOING') int conInspOngoing,
  });
}

/// @nodoc
class _$StatusCountsCopyWithImpl<$Res, $Val extends StatusCounts>
    implements $StatusCountsCopyWith<$Res> {
  _$StatusCountsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatusCounts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inspectedByCon = null,
    Object? pending = null,
    Object? approved = null,
    Object? rejected = null,
    Object? rescheduled = null,
    Object? closed = null,
    Object? conInspOngoing = null,
  }) {
    return _then(
      _value.copyWith(
            inspectedByCon: null == inspectedByCon
                ? _value.inspectedByCon
                : inspectedByCon // ignore: cast_nullable_to_non_nullable
                      as int,
            pending: null == pending
                ? _value.pending
                : pending // ignore: cast_nullable_to_non_nullable
                      as int,
            approved: null == approved
                ? _value.approved
                : approved // ignore: cast_nullable_to_non_nullable
                      as int,
            rejected: null == rejected
                ? _value.rejected
                : rejected // ignore: cast_nullable_to_non_nullable
                      as int,
            rescheduled: null == rescheduled
                ? _value.rescheduled
                : rescheduled // ignore: cast_nullable_to_non_nullable
                      as int,
            closed: null == closed
                ? _value.closed
                : closed // ignore: cast_nullable_to_non_nullable
                      as int,
            conInspOngoing: null == conInspOngoing
                ? _value.conInspOngoing
                : conInspOngoing // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StatusCountsImplCopyWith<$Res>
    implements $StatusCountsCopyWith<$Res> {
  factory _$$StatusCountsImplCopyWith(
    _$StatusCountsImpl value,
    $Res Function(_$StatusCountsImpl) then,
  ) = __$$StatusCountsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'INSPECTED_BY_CON') int inspectedByCon,
    @JsonKey(name: 'PENDING') int pending,
    @JsonKey(name: 'APPROVED') int approved,
    @JsonKey(name: 'REJECTED') int rejected,
    @JsonKey(name: 'RESCHEDULED') int rescheduled,
    @JsonKey(name: 'CLOSED') int closed,
    @JsonKey(name: 'CON_INSP_ONGOING') int conInspOngoing,
  });
}

/// @nodoc
class __$$StatusCountsImplCopyWithImpl<$Res>
    extends _$StatusCountsCopyWithImpl<$Res, _$StatusCountsImpl>
    implements _$$StatusCountsImplCopyWith<$Res> {
  __$$StatusCountsImplCopyWithImpl(
    _$StatusCountsImpl _value,
    $Res Function(_$StatusCountsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StatusCounts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inspectedByCon = null,
    Object? pending = null,
    Object? approved = null,
    Object? rejected = null,
    Object? rescheduled = null,
    Object? closed = null,
    Object? conInspOngoing = null,
  }) {
    return _then(
      _$StatusCountsImpl(
        inspectedByCon: null == inspectedByCon
            ? _value.inspectedByCon
            : inspectedByCon // ignore: cast_nullable_to_non_nullable
                  as int,
        pending: null == pending
            ? _value.pending
            : pending // ignore: cast_nullable_to_non_nullable
                  as int,
        approved: null == approved
            ? _value.approved
            : approved // ignore: cast_nullable_to_non_nullable
                  as int,
        rejected: null == rejected
            ? _value.rejected
            : rejected // ignore: cast_nullable_to_non_nullable
                  as int,
        rescheduled: null == rescheduled
            ? _value.rescheduled
            : rescheduled // ignore: cast_nullable_to_non_nullable
                  as int,
        closed: null == closed
            ? _value.closed
            : closed // ignore: cast_nullable_to_non_nullable
                  as int,
        conInspOngoing: null == conInspOngoing
            ? _value.conInspOngoing
            : conInspOngoing // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StatusCountsImpl implements _StatusCounts {
  const _$StatusCountsImpl({
    @JsonKey(name: 'INSPECTED_BY_CON') this.inspectedByCon = 0,
    @JsonKey(name: 'PENDING') this.pending = 0,
    @JsonKey(name: 'APPROVED') this.approved = 0,
    @JsonKey(name: 'REJECTED') this.rejected = 0,
    @JsonKey(name: 'RESCHEDULED') this.rescheduled = 0,
    @JsonKey(name: 'CLOSED') this.closed = 0,
    @JsonKey(name: 'CON_INSP_ONGOING') this.conInspOngoing = 0,
  });

  factory _$StatusCountsImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatusCountsImplFromJson(json);

  @override
  @JsonKey(name: 'INSPECTED_BY_CON')
  final int inspectedByCon;
  @override
  @JsonKey(name: 'PENDING')
  final int pending;
  @override
  @JsonKey(name: 'APPROVED')
  final int approved;
  @override
  @JsonKey(name: 'REJECTED')
  final int rejected;
  @override
  @JsonKey(name: 'RESCHEDULED')
  final int rescheduled;
  @override
  @JsonKey(name: 'CLOSED')
  final int closed;
  @override
  @JsonKey(name: 'CON_INSP_ONGOING')
  final int conInspOngoing;

  @override
  String toString() {
    return 'StatusCounts(inspectedByCon: $inspectedByCon, pending: $pending, approved: $approved, rejected: $rejected, rescheduled: $rescheduled, closed: $closed, conInspOngoing: $conInspOngoing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatusCountsImpl &&
            (identical(other.inspectedByCon, inspectedByCon) ||
                other.inspectedByCon == inspectedByCon) &&
            (identical(other.pending, pending) || other.pending == pending) &&
            (identical(other.approved, approved) ||
                other.approved == approved) &&
            (identical(other.rejected, rejected) ||
                other.rejected == rejected) &&
            (identical(other.rescheduled, rescheduled) ||
                other.rescheduled == rescheduled) &&
            (identical(other.closed, closed) || other.closed == closed) &&
            (identical(other.conInspOngoing, conInspOngoing) ||
                other.conInspOngoing == conInspOngoing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    inspectedByCon,
    pending,
    approved,
    rejected,
    rescheduled,
    closed,
    conInspOngoing,
  );

  /// Create a copy of StatusCounts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatusCountsImplCopyWith<_$StatusCountsImpl> get copyWith =>
      __$$StatusCountsImplCopyWithImpl<_$StatusCountsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatusCountsImplToJson(this);
  }
}

abstract class _StatusCounts implements StatusCounts {
  const factory _StatusCounts({
    @JsonKey(name: 'INSPECTED_BY_CON') final int inspectedByCon,
    @JsonKey(name: 'PENDING') final int pending,
    @JsonKey(name: 'APPROVED') final int approved,
    @JsonKey(name: 'REJECTED') final int rejected,
    @JsonKey(name: 'RESCHEDULED') final int rescheduled,
    @JsonKey(name: 'CLOSED') final int closed,
    @JsonKey(name: 'CON_INSP_ONGOING') final int conInspOngoing,
  }) = _$StatusCountsImpl;

  factory _StatusCounts.fromJson(Map<String, dynamic> json) =
      _$StatusCountsImpl.fromJson;

  @override
  @JsonKey(name: 'INSPECTED_BY_CON')
  int get inspectedByCon;
  @override
  @JsonKey(name: 'PENDING')
  int get pending;
  @override
  @JsonKey(name: 'APPROVED')
  int get approved;
  @override
  @JsonKey(name: 'REJECTED')
  int get rejected;
  @override
  @JsonKey(name: 'RESCHEDULED')
  int get rescheduled;
  @override
  @JsonKey(name: 'CLOSED')
  int get closed;
  @override
  @JsonKey(name: 'CON_INSP_ONGOING')
  int get conInspOngoing;

  /// Create a copy of StatusCounts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatusCountsImplCopyWith<_$StatusCountsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
