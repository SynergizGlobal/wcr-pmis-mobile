import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/dio_provider.dart';
import '../../data/create_rfi/create_rfi_api.dart'; // Reuse the identical API items fetches
import '../../data/create_rfi/create_rfi_repository.dart';
import '../../domain/create_rfi/dropdown_item.dart';
import '../../domain/rfi_list/rfi_list_item.dart';
import 'update_rfi_state.dart';

part 'update_rfi_provider.g.dart';

@riverpod
class UpdateRfiForm extends _$UpdateRfiForm {
  @override
  UpdateRfiState build() {
    return const UpdateRfiState();
  }

  void initialize(RfiListItem item) {
    if (state.initialItem?.rfiId == item.rfiId) return;

    final now = DateTime.now();
    final defaultSubmissionDate =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

    final String projectId = (item.projectId ?? '').trim().isNotEmpty
        ? item.projectId!.trim()
        : item.project;
    final String contractId = (item.contractId ?? '').trim().isNotEmpty
        ? item.contractId!.trim()
        : (item.contract ?? '');

    state = state.copyWith(
      initialItem: item,

      selectedProject: DropdownItem(id: projectId, name: item.project),
      selectedWork: DropdownItem(id: item.work, name: item.work),
      selectedContract:
          DropdownItem(id: contractId, name: item.contract ?? ''),
      selectedStructureType: DropdownItem(
          id: 'Unknown', name: 'Unknown'), // Not explicitly provided
      selectedStructure: DropdownItem(id: item.structure, name: item.structure),
      selectedComponent: DropdownItem(
          id: 'Unknown', name: 'Unknown'), // Not explicitly provided
      selectedElement: DropdownItem(id: item.element, name: item.element),
      selectedActivity: DropdownItem(id: item.activity, name: item.activity),
      selectedRfiDescription: DropdownItem(
          id: item.rfiDescription ?? '', name: item.rfiDescription ?? ''),

      typeOfRfi: item.typeOfRFI ?? 'SPOT RFI',
      action:
          null, // User strictly selects one of: Reschedule, Update, Reassign
      contractorRepresentative:
          item.nameOfRepresentative, // Initialize from API
      dateOfSubmission: item.dateOfSubmission,
      dateOfInspection: defaultSubmissionDate, // By default allow selection
      timeOfInspection:
          null, // Let stream handle TimeOfDay.now() locally like create

      rfiDescriptionText: 'ok', // Standard fallback based on payload
      selectedEnclosures: [
        'Level Sheet'
      ], // Optional fallback from payload based on user
    );

    _fetchRegularUsers();
    _fetchRfiDescriptions(item.activity);
  }

  Future<void> _fetchRegularUsers() async {
    try {
      state = state.copyWith(isLoadingItems: true);
      final repo = CreateRfiRepository(CreateRfiApi(ref.read(dioProvider)));
      final list = await repo.getRegularUsers();
      state = state.copyWith(representatives: list, isLoadingItems: false);
    } catch (_) {
      state = state.copyWith(representatives: [], isLoadingItems: false);
    }
  }

  Future<void> _fetchRfiDescriptions(String activityName) async {
    try {
      state = state.copyWith(isLoadingItems: true);
      final repo = CreateRfiRepository(CreateRfiApi(ref.read(dioProvider)));
      final list = await repo.getRfiDescriptions(activityName);
      state = state.copyWith(rfiDescriptions: list, isLoadingItems: false);
    } catch (_) {
      state = state.copyWith(rfiDescriptions: [], isLoadingItems: false);
    }
  }


  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }


  void setAction(String? val) {
    state = state.copyWith(action: val);
  }

  void setTypeOfRfi(String? val) {
    state = state.copyWith(typeOfRfi: val);
  }

  void setContractorRepresentative(String? val) {
    state = state.copyWith(contractorRepresentative: val);
  }

  void setTimeOfInspection(String? val) {
    state = state.copyWith(timeOfInspection: val);
  }

  void setDateOfInspection(String? val) {
    state = state.copyWith(dateOfInspection: val);
  }

  void setDateOfSubmission(String? val) {
    state = state.copyWith(dateOfSubmission: val);
  }

  void toggleEnclosure(String enclosure) {
    final current = List<String>.from(state.selectedEnclosures);
    if (current.contains(enclosure)) {
      current.remove(enclosure);
    } else {
      current.add(enclosure);
    }
    state = state.copyWith(selectedEnclosures: current);
  }

  void setRfiDescriptionText(String text) {
    state = state.copyWith(rfiDescriptionText: text);
  }

  Future<bool> updateRfi() async {
    if (state.initialItem == null) return false;
    if (state.action == null) return false;

    state = state.copyWith(isSubmitting: true);

    try {
      final dio = ref.read(dioProvider);

      String formatToYMD(String? dmyDate) {
        if (dmyDate == null || dmyDate.isEmpty) return "";
        try {
          final parts = dmyDate.split('-');
          if (parts.length == 3) {
            return "${parts[2]}-${parts[1]}-${parts[0]}";
          }
        } catch (_) {}
        return dmyDate;
      }

      final now = DateTime.now();
      final defaultTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      List<String> asDtoStringList(String? value) {
        final String trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) {
          return const <String>[];
        }
        return <String>[trimmed];
      }

      String mapTypeOfRfiForApi(String? ui) {
        return switch (ui?.trim()) {
          'Spot RFI' => 'SPOT RFI',
          'Regular RFI' => 'REGULAR RFI',
          _ => ui?.trim() ?? '',
        };
      }

      final String dateOfSubmission = formatToYMD(state.dateOfSubmission);
      final String dateOfInspection = formatToYMD(state.dateOfInspection);

      // RFI_DTO: element/activity/rfiDescription/p6/pmis are List<String>;
      // LocalDate fields must not be "".
      final data = <String, dynamic>{
        "project": state.selectedProject?.name ?? "",
        "projectId": state.selectedProject?.id ?? "",
        "work": state.selectedWork?.name ?? "",
        "contract": state.selectedContract?.name ?? "",
        "contractId": state.selectedContract?.id ?? "",
        "structureType": state.selectedStructureType?.name ?? "",
        "structure": state.selectedStructure?.name ?? "",
        "component": state.selectedComponent?.name ?? "",
        "element": asDtoStringList(state.selectedElement?.name),
        "activity": asDtoStringList(state.selectedActivity?.name),
        "rfiDescription": asDtoStringList(state.selectedRfiDescription?.name),
        "action": state.action ?? "",
        "typeOfRFI": mapTypeOfRfiForApi(state.typeOfRfi),
        "nameOfRepresentative": state.contractorRepresentative ?? "",
        "timeOfInspection": (state.timeOfInspection?.isNotEmpty == true)
            ? state.timeOfInspection!
            : defaultTime,
        "rfi_Id": state.initialItem!.rfiNo,
        if (dateOfSubmission.isNotEmpty) "dateOfSubmission": dateOfSubmission,
        if (dateOfInspection.isNotEmpty) "dateOfInspection": dateOfInspection,
        "enclosures": state.selectedEnclosures,
        "location": "",
        "description": state.rfiDescriptionText ?? "ok",
      };

      final response = await dio
          .put("/rfiSystem/rfi/update/${state.initialItem!.rfiId}", data: data);
      state = state.copyWith(isSubmitting: false);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}
