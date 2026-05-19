// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'status_counts.freezed.dart';
part 'status_counts.g.dart';

@freezed
class StatusCounts with _$StatusCounts {
  const factory StatusCounts({
    @JsonKey(name: 'INSPECTED_BY_CON') @Default(0) int inspectedByCon,
    @JsonKey(name: 'PENDING') @Default(0) int pending,
    @JsonKey(name: 'APPROVED') @Default(0) int approved,
    @JsonKey(name: 'REJECTED') @Default(0) int rejected,
    @JsonKey(name: 'RESCHEDULED') @Default(0) int rescheduled,
    @JsonKey(name: 'CLOSED') @Default(0) int closed,
    @JsonKey(name: 'CON_INSP_ONGOING') @Default(0) int conInspOngoing,
  }) = _StatusCounts;

  factory StatusCounts.fromJson(Map<String, dynamic> json) =>
      _$StatusCountsFromJson(json);
}
