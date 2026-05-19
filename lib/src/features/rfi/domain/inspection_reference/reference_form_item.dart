import 'package:freezed_annotation/freezed_annotation.dart';

part 'reference_form_item.freezed.dart';
part 'reference_form_item.g.dart';

@freezed
class ReferenceFormItem with _$ReferenceFormItem {
  const factory ReferenceFormItem({
    required int id,
    @Default('') String activity,
    @Default('') String rfiDescription,
    @Default('') String enclosures,
  }) = _ReferenceFormItem;

  factory ReferenceFormItem.fromJson(Map<String, dynamic> json) =>
      _$ReferenceFormItemFromJson(json);
}
