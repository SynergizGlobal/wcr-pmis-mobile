import 'package:freezed_annotation/freezed_annotation.dart';

part 'enclosure_name.freezed.dart';
part 'enclosure_name.g.dart';

@freezed
class EnclosureName with _$EnclosureName {
  const factory EnclosureName({
    required int id,
    required String encloserName,
    String? checkListTitle,
    String? action,
  }) = _EnclosureName;

  factory EnclosureName.fromJson(Map<String, dynamic> json) =>
      _$EnclosureNameFromJson(json);
}
