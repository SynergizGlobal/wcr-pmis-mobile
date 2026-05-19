import 'package:freezed_annotation/freezed_annotation.dart';

part 'assign_executive_log.freezed.dart';
part 'assign_executive_log.g.dart';

@freezed
class AssignExecutiveLog with _$AssignExecutiveLog {
  const factory AssignExecutiveLog({
    required int id,
    required String contract,
    required String structureType,
    required String structure,
    required String assignedExecutive,
  }) = _AssignExecutiveLog;

  factory AssignExecutiveLog.fromJson(Map<String, dynamic> json) =>
      _$AssignExecutiveLogFromJson(json);
}
