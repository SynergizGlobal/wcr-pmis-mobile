import 'package:freezed_annotation/freezed_annotation.dart';

part 'executive.freezed.dart';
part 'executive.g.dart';

@freezed
class Executive with _$Executive {
  const factory Executive({
    required String userName,
    required String userId,
    required String department,
    @Default('') String email,
  }) = _Executive;

  factory Executive.fromJson(Map<String, dynamic> json) =>
      _$ExecutiveFromJson(json);
}
