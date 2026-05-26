import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/inspection_reference/enclosure_name.dart';
import '../../domain/inspection_reference/checklist_detail.dart';
import '../../domain/inspection_reference/reference_form_item.dart';

part 'inspection_reference_state.freezed.dart';

enum FormType {
  rfiEnclosureList,
  checklistDescription,
  referenceForm,
}

@freezed
class InspectionReferenceState with _$InspectionReferenceState {
  const factory InspectionReferenceState({
    FormType? selectedFormType,

    @Default(false) bool isLoadingInitial,
    @Default(false) bool isLoadingList,

    @Default([]) List<EnclosureName> initialEnclosureNames,

    @Default([]) List<EnclosureName> enclosureList,

    @Default([]) List<EnclosureName> subOptions,
    EnclosureName? selectedSubOption,
    @Default([]) List<ChecklistDetail> checklistDetails,

    @Default([]) List<ReferenceFormItem> referenceFormItems,
    @Default(false) bool isEnclosureSubmitting,
    @Default(false) bool isChecklistSubmitting,
    @Default(false) bool isReferenceFormSubmitting,
  }) = _InspectionReferenceState;
}
