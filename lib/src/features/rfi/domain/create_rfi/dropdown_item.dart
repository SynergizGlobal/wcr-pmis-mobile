import 'package:freezed_annotation/freezed_annotation.dart';

part 'dropdown_item.freezed.dart';
part 'dropdown_item.g.dart';

@freezed
class DropdownItem with _$DropdownItem {
  const factory DropdownItem({
    required String id,
    required String name,
    List<String>? enclosures,
    int? p6ActivityIdFk,
    String? pmisCalcFk,
  }) = _DropdownItem;

  factory DropdownItem.fromJson(Map<String, dynamic> json) =>
      _$DropdownItemFromJson(json);
}
