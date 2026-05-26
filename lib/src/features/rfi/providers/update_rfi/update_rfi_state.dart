import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/create_rfi/dropdown_item.dart';
import '../../domain/rfi_list/rfi_list_item.dart';

part 'update_rfi_state.freezed.dart';

@freezed
class UpdateRfiState with _$UpdateRfiState {
  const factory UpdateRfiState({
    RfiListItem? initialItem,

    @Default(false) bool isLoadingItems,

    DropdownItem? selectedProject,
    DropdownItem? selectedWork,
    DropdownItem? selectedContract,
    DropdownItem? selectedStructureType,
    DropdownItem? selectedStructure,
    DropdownItem? selectedComponent,
    DropdownItem? selectedElement,
    DropdownItem? selectedActivity,
    DropdownItem? selectedRfiDescription,

    @Default(0) int currentStep,
    String? action,
    String? typeOfRfi,
    String? contractorRepresentative,
    String? timeOfInspection,
    String? dateOfInspection,
    String? dateOfSubmission,

    @Default([]) List<String> selectedEnclosures,
    String? rfiDescriptionText,

    @Default([]) List<DropdownItem> representatives,
    @Default([]) List<DropdownItem> rfiDescriptions, // for step 3 enclosures

    @Default(false) bool isSubmitting,
  }) = _UpdateRfiState;
}
