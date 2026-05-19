import 'package:freezed_annotation/freezed_annotation.dart';
import 'dropdown_item.dart';

part 'rfi_draft.freezed.dart';
part 'rfi_draft.g.dart';

@freezed
class RfiDraft with _$RfiDraft {
  const factory RfiDraft({
    // Selections
    DropdownItem? project,
    DropdownItem? work,
    DropdownItem? contract,
    DropdownItem? structureType,
    DropdownItem? structure,
    DropdownItem? component,
    DropdownItem? element,
    DropdownItem? activity,
    DropdownItem? rfiDescription,

    // Step 2 Fields
    @Default(0) int currentStep,
    String? action,
    String? typeOfRfi,
    String? contractorRepresentative,
    String? dateOfSubmission,
    String? timeOfInspection,
    String? dateOfInspection,

    // Step 3 Fields
    @Default([]) List<String> selectedEnclosures,
    String? rfiDescriptionText,

    // Cached Lists
    @Default([]) List<DropdownItem> projects,
    @Default([]) List<DropdownItem> works,
    @Default([]) List<DropdownItem> contracts,
    @Default([]) List<DropdownItem> structureTypes,
    @Default([]) List<DropdownItem> structures,
    @Default([]) List<DropdownItem> components,
    @Default([]) List<DropdownItem> elements,
    @Default([]) List<DropdownItem> activities,
    @Default([]) List<DropdownItem> rfiDescriptions,
    @Default([]) List<DropdownItem> representatives,
  }) = _RfiDraft;

  factory RfiDraft.fromJson(Map<String, dynamic> json) =>
      _$RfiDraftFromJson(json);
}
