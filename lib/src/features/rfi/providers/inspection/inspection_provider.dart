import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/inspection/inspection_repository.dart';
import '../../domain/common/filter_option.dart';
import '../../domain/inspection/inspection_item.dart';
import '../../domain/inspection/inspection_list_mode.dart';
import 'inspection_state.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';

final inspectionProvider =
    StateNotifierProvider<InspectionNotifier, InspectionState>((ref) {
  final repository = ref.watch(inspectionRepositoryProvider);
  return InspectionNotifier(repository);
});

String inspectionProjectFilterId(InspectionItem item) {
  final String id = (item.projectId ?? '').trim();
  if (id.isNotEmpty) return id;
  return (item.project ?? '').trim();
}

String inspectionContractFilterId(InspectionItem item) {
  final String id = (item.contractId ?? '').trim();
  if (id.isNotEmpty) return id;
  return (item.contract ?? '').trim();
}

class InspectionNotifier extends StateNotifier<InspectionState> {
  final InspectionRepository _repository;

  InspectionNotifier(this._repository) : super(const InspectionState()) {
    fetchInspections();
  }

  Future<void> configure({required InspectionListMode listMode}) async {
    if (state.listMode == listMode && state.allItems.isNotEmpty) {
      _reapplyFilters();
      return;
    }
    state = state.copyWith(
      listMode: listMode,
      projectFilter: '',
      contractFilter: '',
      searchQuery: '',
      currentPage: 1,
    );
    await fetchInspections();
  }

  Future<void> fetchInspections() async {
    try {
      state = state.copyWith(
        isLoading: true,
        isLoadingFilters: true,
        error: null,
      );
      final List<InspectionItem> items = await _repository.getInspectionList();
      final List<InspectionItem> openItems = items
          .where(
            (InspectionItem item) =>
                (item.status ?? '').toUpperCase() != 'INSPECTION_DONE',
          )
          .toList();

      List<FilterOption> projects = const <FilterOption>[];
      List<FilterOption> contracts = const <FilterOption>[];
      if (state.listMode.buildsFiltersFromDataset) {
        final List<InspectionItem> base = _statusScoped(openItems);
        projects = FilterOption.uniqueFromPairs(
          base.map(
            (InspectionItem e) => (e.projectId, e.project),
          ),
        );
        contracts = FilterOption.uniqueFromPairs(
          base.map(
            (InspectionItem e) => (e.contractId, e.contract),
          ),
        );
      } else {
        try {
          projects = await _repository.getFilterProjects();
          contracts = await _repository.getFilterContracts(
            project: state.projectFilter,
          );
        } catch (_) {
          projects = FilterOption.uniqueFromPairs(
            openItems.map(
              (InspectionItem e) => (e.projectId, e.project),
            ),
          );
          contracts = FilterOption.uniqueFromPairs(
            openItems.map(
              (InspectionItem e) => (e.contractId, e.contract),
            ),
          );
        }
      }

      state = state.copyWith(
        allItems: openItems,
        availableProjects: projects,
        availableContracts: contracts,
        isLoading: false,
        isLoadingFilters: false,
      );
      _reapplyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingFilters: false,
        error: userFriendlyErrorMessage(e),
      );
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
    _reapplyFilters();
  }

  Future<void> setProjectFilter(String? projectId) async {
    final String value = projectId ?? '';
    state = state.copyWith(
      projectFilter: value,
      contractFilter: '',
      currentPage: 1,
    );

    if (!state.listMode.buildsFiltersFromDataset) {
      state = state.copyWith(isLoadingFilters: true);
      try {
        final List<FilterOption> contracts =
            await _repository.getFilterContracts(project: value);
        state = state.copyWith(
          isLoadingFilters: false,
          availableContracts: contracts,
        );
      } catch (_) {
        state = state.copyWith(isLoadingFilters: false);
      }
    } else {
      final List<InspectionItem> base = _statusScoped(state.allItems);
      final List<InspectionItem> forContracts = value.isEmpty
          ? base
          : base
              .where(
                (InspectionItem item) =>
                    inspectionProjectFilterId(item) == value,
              )
              .toList();
      state = state.copyWith(
        availableContracts: FilterOption.uniqueFromPairs(
          forContracts.map(
            (InspectionItem e) => (e.contractId, e.contract),
          ),
        ),
      );
    }
    _reapplyFilters();
  }

  void setContractFilter(String? contractId) {
    state = state.copyWith(
      contractFilter: contractId ?? '',
      currentPage: 1,
    );
    _reapplyFilters();
  }

  void clearFilters() {
    state = state.copyWith(
      projectFilter: '',
      contractFilter: '',
      searchQuery: '',
      currentPage: 1,
    );
    if (state.listMode.buildsFiltersFromDataset) {
      final List<InspectionItem> base = _statusScoped(state.allItems);
      state = state.copyWith(
        availableProjects: FilterOption.uniqueFromPairs(
          base.map((InspectionItem e) => (e.projectId, e.project)),
        ),
        availableContracts: FilterOption.uniqueFromPairs(
          base.map((InspectionItem e) => (e.contractId, e.contract)),
        ),
      );
    } else {
      fetchInspections();
      return;
    }
    _reapplyFilters();
  }

  void updateRowsPerPage(int rows) {
    state = state.copyWith(
      rowsPerPage: rows,
      currentPage: 1,
    );
  }

  void updatePage(int page) {
    state = state.copyWith(currentPage: page);
  }

  List<InspectionItem> _statusScoped(List<InspectionItem> items) {
    switch (state.listMode) {
      case InspectionListMode.all:
        return items;
      case InspectionListMode.created:
        const Set<String> scheduledStatuses = <String>{
          'CREATED',
          'UNDER_CON_RECTIFICATION',
          'CON_INSP_ONGOING',
        };
        return items
            .where(
              (InspectionItem item) => scheduledStatuses.contains(
                (item.status ?? '').toUpperCase(),
              ),
            )
            .toList();
      case InspectionListMode.rescheduled:
        return items
            .where(
              (InspectionItem item) =>
                  (item.status ?? '').toUpperCase() == 'RESCHEDULED',
            )
            .toList();
      case InspectionListMode.submitted:
        const Set<String> submittedStatuses = <String>{
          'INSPECTED_BY_CON',
          'SUBMITTED',
        };
        return items
            .where(
              (InspectionItem item) => submittedStatuses.contains(
                (item.status ?? '').toUpperCase(),
              ),
            )
            .toList();
    }
  }

  void _reapplyFilters() {
    Iterable<InspectionItem> filtered = _statusScoped(state.allItems);

    if (state.projectFilter.isNotEmpty) {
      filtered = filtered.where(
        (InspectionItem item) =>
            inspectionProjectFilterId(item) == state.projectFilter,
      );
    }
    if (state.contractFilter.isNotEmpty) {
      filtered = filtered.where(
        (InspectionItem item) =>
            inspectionContractFilterId(item) == state.contractFilter,
      );
    }

    final String query = state.searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((InspectionItem item) {
        return (item.rfiId?.toLowerCase().contains(query) ?? false) ||
            (item.structure?.toLowerCase().contains(query) ?? false) ||
            (item.element?.toLowerCase().contains(query) ?? false) ||
            (item.activity?.toLowerCase().contains(query) ?? false) ||
            (item.rfiDescription?.toLowerCase().contains(query) ?? false) ||
            (item.assignedPersonClient?.toLowerCase().contains(query) ??
                false) ||
            (item.createdBy?.toLowerCase().contains(query) ?? false) ||
            (item.project?.toLowerCase().contains(query) ?? false) ||
            (item.contract?.toLowerCase().contains(query) ?? false) ||
            (item.projectId?.toLowerCase().contains(query) ?? false) ||
            (item.contractId?.toLowerCase().contains(query) ?? false);
      });
    }

    state = state.copyWith(filteredItems: filtered.toList());
  }

  Future<void> sendForValidation(int rfiId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.sendForValidation(rfiId);
      await fetchInspections();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<String> uploadAttachment({
    required int rfiId,
    required String description,
    required PlatformFile file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'rfiId': rfiId,
        'description': description,
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      final message = await _repository.uploadAttachment(formData);
      return message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadTestReport({
    required int rfiId,
    required String testType,
    required PlatformFile file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'rfiId': rfiId,
        'testType': testType,
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      final message = await _repository.uploadTestReport(formData);
      return message;
    } catch (e) {
      rethrow;
    }
  }
}
