import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/create_rfi/dropdown_item.dart';
import '../../domain/rfi_list/rfi_list_item.dart';

part 'update_rfi_state.freezed.dart';

@freezed
class UpdateRfiState with _$UpdateRfiState {
  const factory UpdateRfiState({
    // Initial Item
    RfiListItem? initialItem,

    // Loading State
    @Default(false) bool isLoadingItems,

    // Step 1 Read-Only Fields (Populated from initialItem)
    DropdownItem? selectedProject,
    DropdownItem? selectedWork,
    DropdownItem? selectedContract,
    DropdownItem? selectedStructureType,
    DropdownItem? selectedStructure,
    DropdownItem? selectedComponent,
    DropdownItem? selectedElement,
    DropdownItem? selectedActivity,
    DropdownItem? selectedRfiDescription,

    // Step 2 Fields
    @Default(0) int currentStep,
    String? action,
    String? typeOfRfi,
    String? contractorRepresentative,
    String? timeOfInspection,
    String? dateOfInspection,
    String? dateOfSubmission,

    // Step 3 Fields
    @Default([]) List<String> selectedEnclosures,
    String? rfiDescriptionText,

    // Lists of Available Options (For Step 2 & 3 dynamic dropdowns)
    @Default([]) List<DropdownItem> representatives,
    @Default([]) List<DropdownItem> rfiDescriptions, // for step 3 enclosures

    // Submit State
    @Default(false) bool isSubmitting,
  }) = _UpdateRfiState;
}
