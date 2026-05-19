import 'package:freezed_annotation/freezed_annotation.dart';

part 'rfi_log_item.freezed.dart';
part 'rfi_log_item.g.dart';

@freezed
class RfiLogItem with _$RfiLogItem {
  const factory RfiLogItem({
    required int id,
    required String rfiId,
    required String dateOfSubmission,
    required String structure,
    required String rfiDescription,
    required String rfiRequestedBy,
    required String department,
    required String person,
    required String dateRaised,
    String? dateResponded,
    String? enggApproval,
    required String status,
    String? notes,
    String? validationStatus,
    required String project,
    required String work,
    required String contract,
    required String nameOfRepresentative,
    String? txnId,
    String? estatus,
  }) = _RfiLogItem;

  factory RfiLogItem.fromJson(Map<String, dynamic> json) =>
      _$RfiLogItemFromJson(json);
}
