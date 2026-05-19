import 'package:freezed_annotation/freezed_annotation.dart';

part 'rfi_list_item.freezed.dart';
part 'rfi_list_item.g.dart';

@freezed
class RfiListItem with _$RfiListItem {
  const factory RfiListItem({
    required int rfiId,
    required String rfiNo,
    required String project,
    required String structure,
    required String activity,
    required String status,
    required String dateOfSubmission,
    required String work,
    required String element,
    required String assignedPersonClient,
    required String nameOfRepresentative,
    required String createdBy,
    required String approvalStatus,
    required String totalQty,
    @Default([]) List<String> contractorImages,
    @Default([]) List<String> clientImages,
    // Add other fields from API if needed, handling nulls with defaults or nullable types
    String? contract,
    String? typeOfRFI,
    String? rfiDescription,
    String? measurementType,
    String? validationStatus,
    String? inspectionStatus,
  }) = _RfiListItem;

  factory RfiListItem.fromJson(Map<String, dynamic> json) =>
      _$RfiListItemFromJson(json);
}
