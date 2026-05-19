import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/inspection_reference/enclosure_name.dart';
import '../../domain/inspection_reference/checklist_detail.dart';
import '../../domain/inspection_reference/reference_form_item.dart';

part 'inspection_reference_state.freezed.dart';

/// The three form variants available in the Select Form dropdown
enum FormType {
  rfiEnclosureList,
  checklistDescription,
  referenceForm,
}

@freezed
class InspectionReferenceState with _$InspectionReferenceState {
  const factory InspectionReferenceState({
    // Selected form type
    FormType? selectedFormType,

    // Loading flags
    @Default(false) bool isLoadingInitial,
    @Default(false) bool isLoadingList,

    // Initial enclosure names list (loaded on screen open)
    @Default([]) List<EnclosureName> initialEnclosureNames,

    // RFI Enclosure List data
    @Default([]) List<EnclosureName> enclosureList,

    // Checklist Description data
    @Default([]) List<EnclosureName> subOptions,
    EnclosureName? selectedSubOption,
    @Default([]) List<ChecklistDetail> checklistDetails,

    // Reference Form data
    @Default([]) List<ReferenceFormItem> referenceFormItems,
    @Default(false) bool isEnclosureSubmitting,
    @Default(false) bool isChecklistSubmitting,
    @Default(false) bool isReferenceFormSubmitting,
  }) = _InspectionReferenceState;
}
