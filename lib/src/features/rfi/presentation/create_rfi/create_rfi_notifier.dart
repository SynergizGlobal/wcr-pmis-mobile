import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/data/repositories/rfi_repository_impl.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_dropdown_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/create_rfi/create_rfi_state.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/providers/rfi_providers.dart';

final createRfiNotifierProvider =
    StateNotifierProvider.autoDispose<CreateRfiNotifier, CreateRfiState>((ref) {
  return CreateRfiNotifier(ref);
});

class CreateRfiNotifier extends StateNotifier<CreateRfiState> {
  CreateRfiNotifier(this._ref) : super(const CreateRfiState()) {
    Future<void>.microtask(_bootstrap);
  }

  final Ref _ref;
  int _activeLoadRequests = 0;

  RfiRepository get _repository => _ref.read(rfiRepositoryProvider);

  String get _draftKey {
    final String userId =
        _ref.read(authControllerProvider).valueOrNull?.userId ?? 'unknown';
    return 'wcr_rfi_create_draft_$userId';
  }

  Future<void> _bootstrap() async {
    await Future.wait(<Future<void>>[
      _fetchProjects(initial: true),
      _fetchRepresentatives(),
    ]);
    await _loadDraft();
    await _restoreListsAfterDraft();
  }

  Future<void> _restoreListsAfterDraft() async {
    final RfiDropdownItem? project = state.selectedProject;
    if (project == null) {
      return;
    }
    try {
      final List<RfiDropdownItem> contracts =
          await _repository.fetchCreateContracts(project.id);
      state = state.copyWith(contracts: contracts);
    } catch (_) {}

    final RfiDropdownItem? contract = state.selectedContract;
    if (contract == null) {
      return;
    }
    try {
      final List<RfiDropdownItem> structureTypes =
          await _repository.fetchCreateStructureTypes(contract.id);
      state = state.copyWith(structureTypes: structureTypes);
    } catch (_) {}

    final RfiDropdownItem? structureType = state.selectedStructureType;
    final RfiDropdownItem? structure = state.selectedStructure;
    if (structureType != null) {
      try {
        final List<RfiDropdownItem> structures =
            await _repository.fetchCreateStructures(
          structureType: structureType.name,
          contractId: contract.id,
        );
        state = state.copyWith(structures: structures);
      } catch (_) {}
    }

    final RfiDropdownItem? component = state.selectedComponent;
    if (structureType != null && structure != null) {
      try {
        final List<RfiDropdownItem> components =
            await _repository.fetchCreateComponents(
          structureType: structureType.name,
          contractId: contract.id,
          structureName: structure.name,
        );
        state = state.copyWith(components: components);
      } catch (_) {}
    }

    final RfiDropdownItem? element = state.selectedElement;
    if (structureType != null && structure != null && component != null) {
      try {
        final List<RfiDropdownItem> elements =
            await _repository.fetchCreateElements(
          contractId: contract.id,
          structureType: structureType.name,
          structureName: structure.name,
          componentName: component.name,
        );
        state = state.copyWith(elements: elements);
      } catch (_) {}
    }

    final RfiDropdownItem? activity = state.selectedActivity;
    if (structureType != null && structure != null && component != null) {
      final String componentId =
          element?.id.isNotEmpty == true ? element!.id : component.id;
      try {
        final List<RfiDropdownItem> activities =
            await _repository.fetchCreateActivities(
          structureType: structureType.name,
          structureName: structure.name,
          componentName: component.name,
          componentId: componentId,
        );
        state = state.copyWith(activities: activities);
      } catch (_) {}
    }

    if (activity != null) {
      try {
        final List<RfiDropdownItem> descriptions =
            await _repository.fetchCreateRfiDescriptions(activity.name);
        state = state.copyWith(rfiDescriptions: descriptions);
      } catch (_) {}
    }
  }

  void _beginLoading() {
    _activeLoadRequests += 1;
    if (!state.isLoadingItems) {
      state = state.copyWith(isLoadingItems: true);
    }
  }

  void _endLoading() {
    if (_activeLoadRequests > 0) {
      _activeLoadRequests -= 1;
    }
    if (_activeLoadRequests == 0 && state.isLoadingItems) {
      state = state.copyWith(isLoadingItems: false);
    }
  }

  Future<T> _withLoading<T>(Future<T> Function() run) async {
    _beginLoading();
    try {
      return await run();
    } finally {
      _endLoading();
    }
  }

  Future<void> retryInitialLoad() async {
    state = state.copyWith(clearInitialLoadError: true);
    await Future.wait(<Future<void>>[
      _fetchProjects(initial: true),
      _fetchRepresentatives(),
    ]);
  }

  Future<void> _fetchProjects({bool initial = false}) async {
    try {
      await _withLoading(() async {
        final List<RfiDropdownItem> list = await _repository.fetchCreateProjects();
        state = state.copyWith(
          projects: list,
          clearInitialLoadError: true,
        );
      });
    } catch (_) {
      state = state.copyWith(
        projects: const <RfiDropdownItem>[],
        initialLoadError: initial
            ? 'Could not load Create RFI data. Please retry.'
            : state.initialLoadError,
      );
    }
  }

  Future<void> _fetchRepresentatives() async {
    try {
      await _withLoading(() async {
        final List<RfiDropdownItem> list =
            await _repository.fetchCreateRepresentatives();
        state = state.copyWith(representatives: list);
      });
    } catch (_) {
      state = state.copyWith(representatives: const <RfiDropdownItem>[]);
    }
  }

  Future<void> selectProject(RfiDropdownItem? project) async {
    if (state.selectedProject?.id == project?.id) {
      return;
    }
    state = state.copyWith(
      clearErrorMessage: true,
      selectedProject: project,
      clearSelectedContract: true,
      contracts: const <RfiDropdownItem>[],
      clearSelectedStructureType: true,
      structureTypes: const <RfiDropdownItem>[],
      clearSelectedStructure: true,
      structures: const <RfiDropdownItem>[],
      clearSelectedComponent: true,
      components: const <RfiDropdownItem>[],
      clearSelectedElement: true,
      elements: const <RfiDropdownItem>[],
      clearSelectedActivity: true,
      activities: const <RfiDropdownItem>[],
      clearSelectedRfiDescription: true,
      rfiDescriptions: const <RfiDropdownItem>[],
    );
    if (project == null || project.id.isEmpty) {
      return;
    }
    try {
      await _withLoading(() async {
        final List<RfiDropdownItem> list =
            await _repository.fetchCreateContracts(project.id);
        state = state.copyWith(contracts: list);
      });
    } catch (_) {
      state = state.copyWith(contracts: const <RfiDropdownItem>[]);
    }
  }

  Future<void> selectContract(RfiDropdownItem? contract) async {
    if (state.selectedContract?.id == contract?.id) {
      return;
    }
    state = state.copyWith(
      clearErrorMessage: true,
      selectedContract: contract,
      clearSelectedStructureType: true,
      structureTypes: const <RfiDropdownItem>[],
      clearSelectedStructure: true,
      structures: const <RfiDropdownItem>[],
      clearSelectedComponent: true,
      components: const <RfiDropdownItem>[],
      clearSelectedElement: true,
      elements: const <RfiDropdownItem>[],
      clearSelectedActivity: true,
      activities: const <RfiDropdownItem>[],
      clearSelectedRfiDescription: true,
      rfiDescriptions: const <RfiDropdownItem>[],
    );
    if (contract == null || contract.id.isEmpty) {
      return;
    }
    try {
      await _withLoading(() async {
        final List<RfiDropdownItem> list =
            await _repository.fetchCreateStructureTypes(contract.id);
        state = state.copyWith(structureTypes: list);
      });
    } catch (_) {
      state = state.copyWith(structureTypes: const <RfiDropdownItem>[]);
    }
  }

  Future<void> selectStructureType(RfiDropdownItem? type) async {
    if (state.selectedStructureType?.id == type?.id) {
      return;
    }
    state = state.copyWith(
      clearErrorMessage: true,
      selectedStructureType: type,
      clearSelectedStructure: true,
      structures: const <RfiDropdownItem>[],
      clearSelectedComponent: true,
      components: const <RfiDropdownItem>[],
      clearSelectedElement: true,
      elements: const <RfiDropdownItem>[],
      clearSelectedActivity: true,
      activities: const <RfiDropdownItem>[],
      clearSelectedRfiDescription: true,
      rfiDescriptions: const <RfiDropdownItem>[],
    );
    final RfiDropdownItem? contract = state.selectedContract;
    if (type == null || contract == null) {
      return;
    }
    try {
      await _withLoading(() async {
        final List<RfiDropdownItem> list = await _repository.fetchCreateStructures(
          structureType: type.name,
          contractId: contract.id,
        );
        state = state.copyWith(structures: list);
      });
    } catch (_) {
      state = state.copyWith(structures: const <RfiDropdownItem>[]);
    }
  }

  Future<void> selectStructure(RfiDropdownItem? structure) async {
    if (state.selectedStructure?.id == structure?.id) {
      return;
    }
    state = state.copyWith(
      clearErrorMessage: true,
      selectedStructure: structure,
      clearSelectedComponent: true,
      components: const <RfiDropdownItem>[],
      clearSelectedElement: true,
      elements: const <RfiDropdownItem>[],
      clearSelectedActivity: true,
      activities: const <RfiDropdownItem>[],
      clearSelectedRfiDescription: true,
      rfiDescriptions: const <RfiDropdownItem>[],
    );
    final RfiDropdownItem? type = state.selectedStructureType;
    final RfiDropdownItem? contract = state.selectedContract;
    if (structure == null || type == null || contract == null) {
      return;
    }
    try {
      await _withLoading(() async {
        final List<RfiDropdownItem> list =
            await _repository.fetchCreateComponents(
          structureType: type.name,
          contractId: contract.id,
          structureName: structure.name,
        );
        state = state.copyWith(components: list);
      });
    } catch (_) {
      state = state.copyWith(components: const <RfiDropdownItem>[]);
    }
  }

  Future<void> selectComponent(RfiDropdownItem? component) async {
    if (state.selectedComponent?.id == component?.id) {
      return;
    }
    state = state.copyWith(
      clearErrorMessage: true,
      selectedComponent: component,
      clearSelectedElement: true,
      elements: const <RfiDropdownItem>[],
      clearSelectedActivity: true,
      activities: const <RfiDropdownItem>[],
      clearSelectedRfiDescription: true,
      rfiDescriptions: const <RfiDropdownItem>[],
    );
    final RfiDropdownItem? type = state.selectedStructureType;
    final RfiDropdownItem? contract = state.selectedContract;
    final RfiDropdownItem? structure = state.selectedStructure;
    if (component == null || type == null || contract == null || structure == null) {
      return;
    }
    try {
      await _withLoading(() async {
        final List<RfiDropdownItem> list = await _repository.fetchCreateElements(
          contractId: contract.id,
          structureType: type.name,
          structureName: structure.name,
          componentName: component.name,
        );
        state = state.copyWith(elements: list);
      });
    } catch (_) {
      state = state.copyWith(elements: const <RfiDropdownItem>[]);
    }
  }

  Future<void> selectElement(RfiDropdownItem? element) async {
    if (state.selectedElement?.id == element?.id) {
      return;
    }
    state = state.copyWith(
      clearErrorMessage: true,
      selectedElement: element,
      clearSelectedActivity: true,
      activities: const <RfiDropdownItem>[],
      clearSelectedRfiDescription: true,
      rfiDescriptions: const <RfiDropdownItem>[],
    );
    final RfiDropdownItem? type = state.selectedStructureType;
    final RfiDropdownItem? structure = state.selectedStructure;
    final RfiDropdownItem? component = state.selectedComponent;
    if (element == null || type == null || structure == null || component == null) {
      return;
    }
    final String componentId =
        element.id.isNotEmpty ? element.id : component.id;
    try {
      await _withLoading(() async {
        final List<RfiDropdownItem> list =
            await _repository.fetchCreateActivities(
          structureType: type.name,
          structureName: structure.name,
          componentName: component.name,
          componentId: componentId,
        );
        state = state.copyWith(activities: list);
      });
    } catch (_) {
      state = state.copyWith(activities: const <RfiDropdownItem>[]);
    }
  }

  Future<void> selectActivity(RfiDropdownItem? activity) async {
    if (state.selectedActivity?.id == activity?.id) {
      return;
    }
    state = state.copyWith(
      clearErrorMessage: true,
      selectedActivity: activity,
      clearSelectedRfiDescription: true,
      rfiDescriptions: const <RfiDropdownItem>[],
      selectedEnclosures: const <String>[],
    );
    if (activity == null) {
      return;
    }
    try {
      await _withLoading(() async {
        final List<RfiDropdownItem> list =
            await _repository.fetchCreateRfiDescriptions(activity.name);
        state = state.copyWith(rfiDescriptions: list);
      });
    } catch (_) {
      state = state.copyWith(rfiDescriptions: const <RfiDropdownItem>[]);
    }
  }

  void selectRfiDescription(RfiDropdownItem? description) {
    state = state.copyWith(
      clearErrorMessage: true,
      selectedRfiDescription: description,
      selectedEnclosures: const <String>[],
    );
  }

  void setAction(String? value) {
    state = state.copyWith(action: value, clearErrorMessage: true);
  }

  void setTypeOfRfi(String? value) {
    state = state.copyWith(
      typeOfRfi: value,
      clearErrorMessage: true,
      dateOfInspection: null,
      timeOfInspection: null,
    );
  }

  void setContractorRepresentative(String? value) {
    state = state.copyWith(
      contractorRepresentative: value,
      clearErrorMessage: true,
    );
  }

  void setDateOfSubmission(String? value) {
    state = state.copyWith(dateOfSubmission: value, clearErrorMessage: true);
  }

  void setTimeOfInspection(String? value) {
    state = state.copyWith(timeOfInspection: value, clearErrorMessage: true);
  }

  void setDateOfInspection(String? value) {
    state = state.copyWith(dateOfInspection: value, clearErrorMessage: true);
  }

  void toggleEnclosure(String enclosure) {
    final List<String> current = List<String>.from(state.selectedEnclosures);
    if (current.contains(enclosure)) {
      current.remove(enclosure);
    } else {
      current.add(enclosure);
    }
    state = state.copyWith(
      selectedEnclosures: current,
      clearErrorMessage: true,
    );
  }

  void setRfiDescriptionText(String value) {
    state = state.copyWith(
      rfiDescriptionText: value,
      clearErrorMessage: true,
    );
  }

  void advanceStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        clearErrorMessage: true,
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        clearErrorMessage: true,
      );
    }
  }

  String? validationBlockerForPrimaryAction() {
    switch (state.currentStep) {
      case 0:
        return _validateScope();
      case 1:
        return _validateInspectionPlan();
      case 2:
        return _validateScope() ??
            _validateInspectionPlan() ??
            _validateEnclosures();
      default:
        return null;
    }
  }

  String? _validateScope() {
    if (state.selectedProject == null) {
      return 'Please select Project';
    }
    if (state.selectedContract == null) {
      return 'Please select Contract';
    }
    if (state.selectedStructureType == null) {
      return 'Please select Structure Type';
    }
    if (state.selectedStructure == null) {
      return 'Please select Structure';
    }
    if (state.selectedComponent == null) {
      return 'Please select Component';
    }
    if (state.selectedElement == null) {
      return 'Please select Element';
    }
    if (state.selectedActivity == null) {
      return 'Please select Activity';
    }
    if (state.selectedRfiDescription == null) {
      return 'Please select RFI Description';
    }
    return null;
  }

  String? _validateInspectionPlan() {
    if (state.typeOfRfi == null || state.typeOfRfi!.trim().isEmpty) {
      return 'Please select Type of RFI';
    }
    if (state.contractorRepresentative == null ||
        state.contractorRepresentative!.trim().isEmpty) {
      return 'Please select Name of Contractor\'s Representative';
    }
    if (state.dateOfInspection == null ||
        state.dateOfInspection!.trim().isEmpty) {
      return 'Please select Date of Inspection';
    }
    if (state.timeOfInspection == null ||
        state.timeOfInspection!.trim().isEmpty) {
      return 'Please select Time of Inspection';
    }
    if (state.typeOfRfi == 'Regular RFI') {
      return _validateRegularRfi48HourWindow();
    }
    return null;
  }

  String? _validateEnclosures() {
    final List<String> enclosures =
        state.selectedRfiDescription?.enclosures ?? const <String>[];
    for (final String enclosure in enclosures) {
      if (!state.selectedEnclosures.contains(enclosure)) {
        return 'Please select all required enclosures';
      }
    }
    return null;
  }

  DateTime? _parseInspectionDateTime() {
    try {
      final List<String> dateParts = state.dateOfInspection!.split('-');
      if (dateParts.length != 3) {
        return null;
      }
      final int day = int.parse(dateParts[0]);
      final int month = int.parse(dateParts[1]);
      final int year = int.parse(dateParts[2]);
      final String timeStr = state.timeOfInspection!.trim();
      int hour = 0;
      int minute = 0;
      if (timeStr.toUpperCase().contains('AM') ||
          timeStr.toUpperCase().contains('PM')) {
        final List<String> parts = timeStr.split(RegExp(r'\s+'));
        if (parts.length < 2) {
          return null;
        }
        final List<String> timeParts = parts[0].split(':');
        hour = int.parse(timeParts[0]);
        minute = int.parse(timeParts[1]);
        final String ampm = parts[1].toUpperCase();
        if (ampm == 'PM' && hour < 12) {
          hour += 12;
        }
        if (ampm == 'AM' && hour == 12) {
          hour = 0;
        }
      } else {
        final List<String> timeParts = timeStr.split(':');
        hour = int.parse(timeParts[0]);
        minute = int.parse(timeParts[1]);
      }
      return DateTime(year, month, day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  String? _validateRegularRfi48HourWindow() {
    final DateTime? selected = _parseInspectionDateTime();
    if (selected == null) {
      return 'Please use a valid Date of Inspection and Time of Inspection';
    }
    final DateTime minAllowed = DateTime.now().add(const Duration(hours: 48));
    if (selected.isBefore(minAllowed)) {
      return 'For Regular RFI, inspection must be scheduled at least 48 hours in advance.';
    }
    return null;
  }

  Future<String?> submitRfi() async {
    final String? scopeError = _validateScope();
    if (scopeError != null) {
      return scopeError;
    }
    final String? planError = _validateInspectionPlan();
    if (planError != null) {
      return planError;
    }
    final String? enclosureError = _validateEnclosures();
    if (enclosureError != null) {
      return enclosureError;
    }

    int? p6Id = state.selectedActivity?.p6ActivityIdFk;
    final String activityId = state.selectedActivity?.id ?? '';
    if (p6Id == null && RegExp(r'^\d+$').hasMatch(activityId.trim())) {
      p6Id = int.tryParse(activityId.trim());
    }
    if (p6Id == null) {
      return 'Missing activity schedule id (P6). Please re-select Activity.';
    }

    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);
    try {
      final AuthSession? session =
          _ref.read(authControllerProvider).valueOrNull;
      final String userId = session?.userId ?? 'UNKNOWN';
      final String dyHodUserId = userId;

      final DateTime now = DateTime.now();
      final String defaultSubmissionDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final String defaultTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final String pmis =
          state.selectedActivity?.pmisCalcFk?.trim().isNotEmpty == true
              ? state.selectedActivity!.pmisCalcFk!.trim()
              : 'No';

      final Map<String, dynamic> body = <String, dynamic>{
        'project': state.selectedProject?.name ?? '',
        'work': '',
        'contract': state.selectedContract?.name ?? '',
        'contractId': state.selectedContract?.id ?? '',
        'structureType': state.selectedStructureType?.name ?? '',
        'structure': state.selectedStructure?.name ?? '',
        'component': state.selectedComponent?.name ?? '',
        'element': state.selectedElement?.name ?? '',
        'activity': state.selectedActivity?.name ?? '',
        'p6ActivityIdFk': p6Id,
        'pmisCalcFk': pmis,
        'rfiDescription': state.selectedRfiDescription?.name ?? '',
        'action': state.action ?? '',
        'typeOfRFI': _mapTypeOfRfiForApi(state.typeOfRfi),
        'nameOfRepresentative': state.contractorRepresentative ?? '',
        'timeOfInspection':
            _formatTimeForApi(state.timeOfInspection, defaultTime),
        'rfi_Id': '',
        'dateOfSubmission': state.dateOfSubmission?.isNotEmpty == true
            ? _formatToYmd(state.dateOfSubmission)
            : defaultSubmissionDate,
        'dateOfInspection': _formatToYmd(state.dateOfInspection),
        'enclosures': state.selectedEnclosures,
        'location': '',
        'description': state.rfiDescriptionText ?? '',
        'dyHodUserId': dyHodUserId,
        'projectId': state.selectedProject?.id ?? '',
      };

      await _repository.submitCreateRfi(body);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);
      _ref.invalidate(rfiDashboardProvider);
      _ref.invalidate(rfiHandoffProvider);
      state = state.copyWith(isSubmitting: false);
      return null;
    } on DioException catch (error) {
      state = state.copyWith(isSubmitting: false);
      return _messageFromDio(error);
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      return 'Failed to submit RFI. Please try again.';
    }
  }

  Future<void> saveDraft() async {
    state = state.copyWith(isDraftSaving: true);
    try {
      final Map<String, dynamic> draft = <String, dynamic>{
        'currentStep': state.currentStep,
        'action': state.action,
        'typeOfRfi': state.typeOfRfi,
        'contractorRepresentative': state.contractorRepresentative,
        'dateOfSubmission': state.dateOfSubmission,
        'timeOfInspection': state.timeOfInspection,
        'dateOfInspection': state.dateOfInspection,
        'selectedEnclosures': state.selectedEnclosures,
        'rfiDescriptionText': state.rfiDescriptionText,
        'selectedProject': _itemToJson(state.selectedProject),
        'selectedContract': _itemToJson(state.selectedContract),
        'selectedStructureType': _itemToJson(state.selectedStructureType),
        'selectedStructure': _itemToJson(state.selectedStructure),
        'selectedComponent': _itemToJson(state.selectedComponent),
        'selectedElement': _itemToJson(state.selectedElement),
        'selectedActivity': _itemToJson(state.selectedActivity),
        'selectedRfiDescription': _itemToJson(state.selectedRfiDescription),
      };
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_draftKey, jsonEncode(draft));
      state = state.copyWith(isDraftSaving: false);
    } catch (_) {
      state = state.copyWith(isDraftSaving: false);
    }
  }

  Future<void> resetForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
    final List<RfiDropdownItem> projects = state.projects;
    final List<RfiDropdownItem> representatives = state.representatives;
    state = CreateRfiState(
      projects: projects,
      representatives: representatives,
    );
  }

  bool hasPersistedDraft() {
    // sync check not available; use async in UI via flag - skip for now
    return false;
  }

  Future<void> _loadDraft() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_draftKey);
      if (raw == null || raw.isEmpty) {
        return;
      }
      final Map<String, dynamic> draft =
          jsonDecode(raw) as Map<String, dynamic>;
      state = state.copyWith(
        currentStep: draft['currentStep'] as int? ?? 0,
        action: draft['action'] as String?,
        typeOfRfi: draft['typeOfRfi'] as String?,
        contractorRepresentative: draft['contractorRepresentative'] as String?,
        dateOfSubmission: draft['dateOfSubmission'] as String?,
        timeOfInspection: draft['timeOfInspection'] as String?,
        dateOfInspection: draft['dateOfInspection'] as String?,
        selectedEnclosures: (draft['selectedEnclosures'] as List<dynamic>?)
                ?.map((dynamic e) => e.toString())
                .toList() ??
            const <String>[],
        rfiDescriptionText: draft['rfiDescriptionText'] as String?,
        selectedProject: _itemFromJson(draft['selectedProject']),
        selectedContract: _itemFromJson(draft['selectedContract']),
        selectedStructureType: _itemFromJson(draft['selectedStructureType']),
        selectedStructure: _itemFromJson(draft['selectedStructure']),
        selectedComponent: _itemFromJson(draft['selectedComponent']),
        selectedElement: _itemFromJson(draft['selectedElement']),
        selectedActivity: _itemFromJson(draft['selectedActivity']),
        selectedRfiDescription: _itemFromJson(draft['selectedRfiDescription']),
      );
    } catch (_) {
      // ignore corrupted draft
    }
  }

  Map<String, dynamic>? _itemToJson(RfiDropdownItem? item) {
    if (item == null) {
      return null;
    }
    return <String, dynamic>{
      'id': item.id,
      'name': item.name,
      'enclosures': item.enclosures,
      'p6ActivityIdFk': item.p6ActivityIdFk,
      'pmisCalcFk': item.pmisCalcFk,
    };
  }

  RfiDropdownItem? _itemFromJson(dynamic raw) {
    if (raw is! Map) {
      return null;
    }
    final Map<String, dynamic> json = Map<String, dynamic>.from(raw);
    return RfiDropdownItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      enclosures: (json['enclosures'] as List<dynamic>?)
              ?.map((dynamic e) => e.toString())
              .toList() ??
          const <String>[],
      p6ActivityIdFk: json['p6ActivityIdFk'] as int?,
      pmisCalcFk: json['pmisCalcFk'] as String?,
    );
  }

  String _mapTypeOfRfiForApi(String? ui) {
    return switch (ui?.trim()) {
      'Spot RFI' => 'SPOT RFI',
      'Regular RFI' => 'REGULAR RFI',
      _ => ui?.trim() ?? '',
    };
  }

  String _formatTimeForApi(String? timeStr, String defaultHHmm) {
    if (timeStr == null || timeStr.trim().isEmpty) {
      return defaultHHmm;
    }
    final String t = timeStr.trim();
    try {
      if (t.toUpperCase().contains('AM') || t.toUpperCase().contains('PM')) {
        final List<String> parts = t.split(RegExp(r'\s+'));
        if (parts.length < 2) {
          return defaultHHmm;
        }
        final List<String> timeParts = parts[0].split(':');
        var hour = int.parse(timeParts[0]);
        final int minute = int.parse(timeParts[1]);
        final String ampm = parts[1].toUpperCase();
        if (ampm == 'PM' && hour < 12) {
          hour += 12;
        }
        if (ampm == 'AM' && hour == 12) {
          hour = 0;
        }
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
      final List<String> timeParts = t.split(':');
      if (timeParts.length >= 2) {
        final int hour = int.parse(timeParts[0]);
        final int minute = int.parse(timeParts[1]);
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    return defaultHHmm;
  }

  String _formatToYmd(String? dmyDate) {
    if (dmyDate == null || dmyDate.isEmpty) {
      return '';
    }
    try {
      final List<String> parts = dmyDate.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    } catch (_) {}
    return dmyDate;
  }

  String _messageFromDio(DioException error) {
    final dynamic responseData = error.response?.data;
    if (responseData is Map && responseData.containsKey('error')) {
      return responseData['error'].toString();
    }
    if (responseData is Map && responseData.containsKey('message')) {
      return responseData['message'].toString();
    }
    if (responseData is Map && responseData.containsKey('status')) {
      return responseData['status'].toString();
    }
    if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }
    final int? code = error.response?.statusCode;
    if (code != null) {
      return 'Could not submit RFI (HTTP $code). Please review your data and try again.';
    }
    return 'Failed to submit RFI. Please try again.';
  }
}
