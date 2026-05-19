import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/dio_provider.dart';
import '../../data/inspection_reference/inspection_reference_api.dart';
import '../../data/inspection_reference/inspection_reference_repository.dart';
import '../../domain/inspection_reference/enclosure_name.dart';
import 'inspection_reference_state.dart';

part 'inspection_reference_provider.g.dart';

@riverpod
InspectionReferenceRepository inspectionReferenceRepository(
    InspectionReferenceRepositoryRef ref) {
  final dio = ref.read(dioProvider);
  return InspectionReferenceRepository(InspectionReferenceApi(dio));
}

@riverpod
class InspectionReferenceNotifier extends _$InspectionReferenceNotifier {
  @override
  InspectionReferenceState build() {
    Future.microtask(() => _loadInitialNames());
    return const InspectionReferenceState();
  }

  Future<void> refresh() async {
    await _loadInitialNames();
    if (state.selectedFormType != null) {
      // Re-trigger the selection logic to refresh the specific form data
      final currentType = state.selectedFormType;
      state = state.copyWith(selectedFormType: null); // Reset to allow re-selection
      await selectFormType(currentType);
    }
  }

  /// Load the initial enclosure names list on screen open
  Future<void> _loadInitialNames() async {
    state = state.copyWith(isLoadingInitial: true);
    try {
      final repo = ref.read(inspectionReferenceRepositoryProvider);
      final names = await repo.getEnclosureNames();
      state =
          state.copyWith(initialEnclosureNames: names, isLoadingInitial: false);
    } catch (_) {
      state =
          state.copyWith(initialEnclosureNames: [], isLoadingInitial: false);
    }
  }

  /// Called when user selects a form type from the dropdown
  Future<void> selectFormType(FormType? formType) async {
    if (formType == state.selectedFormType) return;

    // Reset category data but preserve initial list
    state = InspectionReferenceState(
      selectedFormType: formType,
      initialEnclosureNames: state.initialEnclosureNames,
    );

    if (formType == null) return;

    state = state.copyWith(isLoadingList: true);

    try {
      final repo = ref.read(inspectionReferenceRepositoryProvider);

      switch (formType) {
        case FormType.rfiEnclosureList:
          final list = await repo.getEnclosureList();
          state = state.copyWith(enclosureList: list, isLoadingList: false);
          break;

        case FormType.checklistDescription:
          final subOptions = await repo.getEnclosuresByAction();
          state = state.copyWith(subOptions: subOptions, isLoadingList: false);
          break;

        case FormType.referenceForm:
          final items = await repo.getReferenceForm();
          final enclosures = await repo.getEnclosureList();
          state = state.copyWith(
            referenceFormItems: items,
            enclosureList: enclosures,
            isLoadingList: false,
          );
          break;
      }
    } catch (_) {
      state = state.copyWith(isLoadingList: false);
    }
  }

  /// Called when user selects a sub-option in Checklist Description
  Future<void> selectSubOption(EnclosureName? option) async {
    if (option == null || option.id == state.selectedSubOption?.id) return;

    state = state.copyWith(
      selectedSubOption: option,
      checklistDetails: [],
      isLoadingList: true,
    );

    try {
      final repo = ref.read(inspectionReferenceRepositoryProvider);
      final details = await repo.getChecklistDetails(option.id);
      state = state.copyWith(checklistDetails: details, isLoadingList: false);
    } catch (_) {
      state = state.copyWith(checklistDetails: [], isLoadingList: false);
    }
  }

  /// Reloads the enclosure list after a CRUD operation
  Future<void> reloadEnclosureList() async {
    state = state.copyWith(isLoadingList: true);
    try {
      final repo = ref.read(inspectionReferenceRepositoryProvider);
      final list = await repo.getEnclosureList();
      state = state.copyWith(enclosureList: list, isLoadingList: false);
    } catch (_) {
      state = state.copyWith(isLoadingList: false);
    }
  }

  /// Create a new enclosure
  Future<bool> addEnclosure(String name, String action) async {
    state = state.copyWith(isEnclosureSubmitting: true);
    try {
      final repo = ref.read(inspectionReferenceRepositoryProvider);
      await repo.submitEnclosure(name, action);
      await reloadEnclosureList();
      state = state.copyWith(isEnclosureSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isEnclosureSubmitting: false);
      return false;
    }
  }

  /// Update an existing enclosure
  Future<bool> updateEnclosure(int id, String name, String action) async {
    state = state.copyWith(isEnclosureSubmitting: true);
    try {
      final repo = ref.read(inspectionReferenceRepositoryProvider);
      await repo.updateEnclosure(id, name, action);
      await reloadEnclosureList();
      state = state.copyWith(isEnclosureSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isEnclosureSubmitting: false);
      return false;
    }
  }

  /// Delete an enclosure
  Future<bool> deleteEnclosure(int id) async {
    state = state.copyWith(isEnclosureSubmitting: true);
    try {
      final repo = ref.read(inspectionReferenceRepositoryProvider);
      await repo.deleteEnclosure(id);
      await reloadEnclosureList();
      state = state.copyWith(isEnclosureSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isEnclosureSubmitting: false);
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // Checklist Description Methods
  // ══════════════════════════════════════════════════════════════════════

  Future<void> reloadChecklistDetails() async {
    final subOption = state.selectedSubOption;
    if (subOption == null) return;

    state = state.copyWith(isLoadingList: true);
    try {
      final repo = ref.read(inspectionReferenceRepositoryProvider);
      final details = await repo.getChecklistDetails(subOption.id);
      state = state.copyWith(checklistDetails: details, isLoadingList: false);
    } catch (_) {
      state = state.copyWith(isLoadingList: false);
    }
  }

  Future<bool> addChecklistDescription(String description) async {
    final subOption = state.selectedSubOption;
    if (subOption == null) return false;

    state = state.copyWith(isChecklistSubmitting: true);
    try {
      final repo = ref.read(inspectionReferenceRepositoryProvider);
      await repo.submitChecklistDescription(subOption.id, description);
      await reloadChecklistDetails();
      state = state.copyWith(isChecklistSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isChecklistSubmitting: false);
      return false;
    }
  }

  Future<bool> updateChecklistDescription(int id, String description) async {
    state = state.copyWith(isChecklistSubmitting: true);
    try {
      final repo = ref.read(inspectionReferenceRepositoryProvider);
      await repo.updateChecklistDescription(id, description);
      await reloadChecklistDetails();
      state = state.copyWith(isChecklistSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isChecklistSubmitting: false);
      return false;
    }
  }

  Future<bool> deleteChecklistDescription(int id) async {
    state = state.copyWith(isChecklistSubmitting: true);
    try {
      final repo = ref.read(inspectionReferenceRepositoryProvider);
      await repo.deleteChecklistDescription(id);
      await reloadChecklistDetails();
      state = state.copyWith(isChecklistSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isChecklistSubmitting: false);
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // Reference Form Methods
  // ══════════════════════════════════════════════════════════════════════

  Future<void> reloadReferenceFormItems() async {
    state = state.copyWith(isLoadingList: true);
    try {
      final repo = ref.read(inspectionReferenceRepositoryProvider);
      final items = await repo.getReferenceForm();
      state = state.copyWith(referenceFormItems: items, isLoadingList: false);
    } catch (_) {
      state = state.copyWith(isLoadingList: false);
    }
  }

  Future<bool> addReferenceForm(
      String activity, String rfiDescription, String enclosures) async {
    state = state.copyWith(isReferenceFormSubmitting: true);
    try {
      final repo = ref.read(inspectionReferenceRepositoryProvider);
      await repo.submitReferenceForm(activity, rfiDescription, enclosures);
      await reloadReferenceFormItems();
      state = state.copyWith(isReferenceFormSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isReferenceFormSubmitting: false);
      return false;
    }
  }

  Future<bool> updateReferenceForm(
      int id, String activity, String rfiDescription, String enclosures) async {
    state = state.copyWith(isReferenceFormSubmitting: true);
    try {
      final repo = ref.read(inspectionReferenceRepositoryProvider);
      await repo.updateReferenceForm(id, activity, rfiDescription, enclosures);
      await reloadReferenceFormItems();
      state = state.copyWith(isReferenceFormSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(isReferenceFormSubmitting: false);
      return false;
    }
  }
}
