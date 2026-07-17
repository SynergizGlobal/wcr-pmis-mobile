import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/inspection/inspection_repository.dart';
import '../../domain/inspection/inspection_item.dart';
import '../../domain/inspection/inspection_list_mode.dart';
import 'inspection_state.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';

final inspectionProvider =
    StateNotifierProvider<InspectionNotifier, InspectionState>((ref) {
  final repository = ref.watch(inspectionRepositoryProvider);
  return InspectionNotifier(repository);
});

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
      state = state.copyWith(isLoading: true, error: null);
      final List<InspectionItem> items = await _repository.getInspectionList();
      // Base grid: exclude Closed (INSPECTION_DONE).
      final List<InspectionItem> openItems = items
          .where(
            (InspectionItem item) =>
                (item.status ?? '').toUpperCase() != 'INSPECTION_DONE',
          )
          .toList();

      List<String> projects = const <String>[];
      List<String> contracts = const <String>[];
      if (state.listMode.buildsFiltersFromDataset) {
        final List<InspectionItem> base = _statusScoped(openItems);
        projects = _uniqueNonEmpty(base.map((InspectionItem e) => e.project));
        contracts = _uniqueNonEmpty(base.map((InspectionItem e) => e.contract));
      } else {
        try {
          projects = await _repository.getFilterProjects();
          contracts = await _repository.getFilterContracts();
        } catch (_) {
          projects =
              _uniqueNonEmpty(openItems.map((InspectionItem e) => e.project));
          contracts =
              _uniqueNonEmpty(openItems.map((InspectionItem e) => e.contract));
        }
      }

      state = state.copyWith(
        allItems: openItems,
        availableProjects: projects,
        availableContracts: contracts,
        isLoading: false,
      );
      _reapplyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: userFriendlyErrorMessage(e),
      );
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
    _reapplyFilters();
  }

  Future<void> setProjectFilter(String? project) async {
    final String value = project ?? '';
    state = state.copyWith(
      projectFilter: value,
      contractFilter: '',
      currentPage: 1,
    );

    if (!state.listMode.buildsFiltersFromDataset) {
      try {
        final List<String> contracts =
            await _repository.getFilterContracts(project: value);
        state = state.copyWith(availableContracts: contracts);
      } catch (_) {
        // Keep existing contracts on failure.
      }
    } else {
      final List<InspectionItem> base = _statusScoped(state.allItems);
      final List<InspectionItem> forContracts = value.isEmpty
          ? base
          : base
              .where(
                (InspectionItem item) => (item.project ?? '').trim() == value,
              )
              .toList();
      state = state.copyWith(
        availableContracts: _uniqueNonEmpty(
          forContracts.map((InspectionItem e) => e.contract),
        ),
      );
    }
    _reapplyFilters();
  }

  void setContractFilter(String? contract) {
    state = state.copyWith(
      contractFilter: contract ?? '',
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
        availableProjects:
            _uniqueNonEmpty(base.map((InspectionItem e) => e.project)),
        availableContracts:
            _uniqueNonEmpty(base.map((InspectionItem e) => e.contract)),
      );
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
        // Web Scheduled list: CREATED + ongoing/rectification.
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
        // Web Submitted list: contractor-submitted inspection rows.
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
            (item.project ?? '').trim() == state.projectFilter,
      );
    }
    if (state.contractFilter.isNotEmpty) {
      filtered = filtered.where(
        (InspectionItem item) =>
            (item.contract ?? '').trim() == state.contractFilter,
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
            (item.contract?.toLowerCase().contains(query) ?? false);
      });
    }

    state = state.copyWith(filteredItems: filtered.toList());
  }

  List<String> _uniqueNonEmpty(Iterable<String?> values) {
    final Set<String> unique = <String>{};
    for (final String? value in values) {
      final String trimmed = (value ?? '').trim();
      if (trimmed.isNotEmpty) {
        unique.add(trimmed);
      }
    }
    final List<String> sorted = unique.toList()..sort();
    return sorted;
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
