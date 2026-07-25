import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/dio_provider.dart';
import '../../data/assign_executive/assign_executive_api.dart';
import '../../data/assign_executive/assign_executive_repository.dart';
import '../../data/create_rfi/create_rfi_api.dart';
import '../../data/create_rfi/create_rfi_repository.dart';
import '../../domain/create_rfi/dropdown_item.dart';
import '../../domain/executives/executive.dart';

import 'assign_executive_state.dart';

part 'assign_executive_provider.g.dart';

@riverpod
AssignExecutiveRepository assignExecutiveRepository(
    AssignExecutiveRepositoryRef ref) {
  final dio = ref.read(dioProvider);
  return AssignExecutiveRepository(AssignExecutiveApi(dio));
}

@riverpod
CreateRfiRepository assignExecCreateRfiRepository(
    AssignExecCreateRfiRepositoryRef ref) {
  final dio = ref.read(dioProvider);
  return CreateRfiRepository(CreateRfiApi(dio));
}

@riverpod
class AssignExecutiveForm extends _$AssignExecutiveForm {
  @override
  AssignExecutiveState build() {
    Future.microtask(() {
      _fetchProjects();
      _fetchLogs();
    });
    return const AssignExecutiveState();
  }

  Future<void> refresh() async {
    await Future.wait([
      _fetchProjects(),
      _fetchLogs(),
    ]);
  }

  Future<void> _fetchLogs() async {
    try {
      state = state.copyWith(isLoadingLogs: true);
      final repo = ref.read(assignExecutiveRepositoryProvider);
      final logs = await repo.getAssignedExecutiveLogs();
      state = state.copyWith(logs: logs, isLoadingLogs: false);
    } catch (_) {
      state = state.copyWith(logs: [], isLoadingLogs: false);
    }
  }

  Future<void> _fetchProjects() async {
    try {
      state = state.copyWith(isLoadingItems: true);
      final repo = ref.read(assignExecCreateRfiRepositoryProvider);
      final list = await repo.getProjectNames();
      state = state.copyWith(projects: list, isLoadingItems: false);
    } catch (_) {
      state = state.copyWith(projects: [], isLoadingItems: false);
    }
  }

  void selectProject(DropdownItem? project) {
    if (state.selectedProject?.id == project?.id) return;
    state = state.copyWith(
      selectedProject: project,
      selectedWork: null,
      works: [],
      selectedContract: null,
      contracts: [],
      selectedStructureType: null,
      structureTypes: [],
      selectedStructure: null,
      structures: [],
      selectedExecutive: null,
      executives: [],
    );
    if (project != null) _fetchContracts(project.id);
  }

  Future<void> _fetchContracts(String projectId) async {
    try {
      state = state.copyWith(isLoadingItems: true);
      final repo = ref.read(assignExecCreateRfiRepositoryProvider);
      final list = await repo.getContractNamesForProject(projectId);
      state = state.copyWith(contracts: list, isLoadingItems: false);
    } catch (_) {
      state = state.copyWith(contracts: [], isLoadingItems: false);
    }
  }

  void selectContract(DropdownItem? contract) {
    if (state.selectedContract?.id == contract?.id) return;
    state = state.copyWith(
      selectedContract: contract,
      selectedStructureType: null,
      structureTypes: [],
      selectedStructure: null,
      structures: [],
      selectedExecutive: null,
      executives: [],
    );
    if (contract != null) {
      _fetchStructureTypes(contract.id);
      _fetchExecutives(contract.id);
    }
  }

  Future<void> _fetchStructureTypes(String contractId) async {
    try {
      state = state.copyWith(isLoadingItems: true);
      final repo = ref.read(assignExecCreateRfiRepositoryProvider);
      final list = await repo.getStructureTypes(contractId);
      state = state.copyWith(structureTypes: list, isLoadingItems: false);
    } catch (_) {
      state = state.copyWith(structureTypes: [], isLoadingItems: false);
    }
  }

  Future<void> _fetchExecutives(String contractId) async {
    try {
      final repo = ref.read(assignExecutiveRepositoryProvider);
      final list = await repo.getExecutivesList(contractId);
      state = state.copyWith(executives: list);
    } catch (_) {
      state = state.copyWith(executives: []);
    }
  }

  void selectStructureType(DropdownItem? type) {
    if (state.selectedStructureType?.id == type?.id) return;
    state = state.copyWith(
      selectedStructureType: type,
      selectedStructure: null,
      structures: [],
    );
    if (type != null && state.selectedContract != null) {
      _fetchStructures(state.selectedContract!.id, type.name);
    }
  }

  Future<void> _fetchStructures(String contractId, String structureType) async {
    try {
      state = state.copyWith(isLoadingItems: true);
      final repo = ref.read(assignExecutiveRepositoryProvider);
      final list = await repo.getStructures(contractId, structureType);
      state = state.copyWith(structures: list, isLoadingItems: false);
    } catch (_) {
      state = state.copyWith(structures: [], isLoadingItems: false);
    }
  }

  void selectStructure(DropdownItem? structure) {
    state = state.copyWith(selectedStructure: structure);
  }

  void selectExecutive(Executive? executive) {
    state = state.copyWith(selectedExecutive: executive);
  }

  Future<bool> submit() async {
    final s = state;
    if (s.selectedContract == null ||
        s.selectedStructureType == null ||
        s.selectedStructure == null ||
        s.selectedExecutive == null) {
      return false;
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final repo = ref.read(assignExecutiveRepositoryProvider);
      await repo.assignExecutive({
        "contract": s.selectedContract!.name,
        "contractId": s.selectedContract!.id,
        "structureType": s.selectedStructureType!.name,
        "structure": s.selectedStructure!.name,
        "assignedPersonClient": s.selectedExecutive!.userName,
        "department": s.selectedExecutive!.department,
        "userId": s.selectedExecutive!.userId,
        "email": s.selectedExecutive!.email,
      });

      state = state.copyWith(
        isSubmitting: false,
        selectedProject: null,
        works: [],
        selectedWork: null,
        contracts: [],
        selectedContract: null,
        structureTypes: [],
        selectedStructureType: null,
        structures: [],
        selectedStructure: null,
        executives: [],
        selectedExecutive: null,
      );

      await _fetchLogs();
      return true;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }

  Future<bool> deleteAssignment(int id) async {
    try {
      final repo = ref.read(assignExecutiveRepositoryProvider);
      await repo.deleteAssignment(id);
      await _fetchLogs();
      return true;
    } catch (_) {
      return false;
    }
  }
}
