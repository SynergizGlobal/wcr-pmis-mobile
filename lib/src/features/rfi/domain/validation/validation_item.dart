import 'package:freezed_annotation/freezed_annotation.dart';

part 'validation_item.freezed.dart';
part 'validation_item.g.dart';

@freezed
class ValidationItem with _$ValidationItem {
  const factory ValidationItem({
    required String stringRfiId,
    required int longRfiId,
    required int longRfiValidateId,
    String? status,
    String? remarks,
    String? valdationAuth,
    String? comment,
    String? txnId,
  }) = _ValidationItem;

  factory ValidationItem.fromJson(Map<String, dynamic> json) =>
      _$ValidationItemFromJson(json);
}
