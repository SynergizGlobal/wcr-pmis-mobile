import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../data/validation/validation_repository.dart';
import '../../domain/validation/validation_item.dart';
import 'validation_state.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';

part 'validation_provider.g.dart';

String validationProjectFilterId(ValidationItem item) {
  final String id = (item.projectId ?? '').trim();
  if (id.isNotEmpty) return id;
  return (item.project ?? '').trim();
}

String validationContractFilterId(ValidationItem item) {
  final String id = (item.contractId ?? '').trim();
  if (id.isNotEmpty) return id;
  return (item.contract ?? '').trim();
}

@riverpod
class ValidationNotifier extends _$ValidationNotifier {
  @override
  ValidationState build() {
    Future.microtask(fetchValidations);
    return const ValidationState();
  }

  Future<void> fetchFilterLists() async {
    state = state.copyWith(isLoadingFilters: true);
    try {
      final repository = ref.read(validationRepositoryProvider);
      final projects = await repository.getFilterProjects(
        contract: state.contractFilter,
      );
      final contracts = await repository.getFilterContracts(
        project: state.projectFilter,
      );
      state = state.copyWith(
        isLoadingFilters: false,
        availableProjects: projects,
        availableContracts: contracts,
      );
    } catch (_) {
      state = state.copyWith(isLoadingFilters: false);
    }
  }

  Future<void> fetchValidations() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingFilters: true,
      errorMessage: null,
    );
    try {
      final repository = ref.read(validationRepositoryProvider);
      final items = await repository.getRfiValidations();

      state = state.copyWith(
        allItems: items,
        filteredItems: _applyFilters(items),
      );
      await fetchFilterLists();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingFilters: false,
        errorMessage: userFriendlyErrorMessage(e),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 1,
      filteredItems: _applyFilters(state.allItems, searchOverride: query),
    );
  }

  Future<void> setProjectFilter(String? projectId) async {
    final String value = projectId ?? '';
    state = state.copyWith(
      projectFilter: value,
      contractFilter: '',
      currentPage: 1,
      isLoadingFilters: true,
    );
    try {
      final repository = ref.read(validationRepositoryProvider);
      final contracts = await repository.getFilterContracts(project: value);
      final projects = await repository.getFilterProjects(contract: '');
      state = state.copyWith(
        isLoadingFilters: false,
        availableProjects: projects,
        availableContracts: contracts,
        filteredItems: _applyFilters(state.allItems),
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingFilters: false,
        filteredItems: _applyFilters(state.allItems),
      );
    }
  }

  Future<void> setContractFilter(String? contractId) async {
    final String value = contractId ?? '';
    state = state.copyWith(
      contractFilter: value,
      currentPage: 1,
      isLoadingFilters: true,
    );
    try {
      final repository = ref.read(validationRepositoryProvider);
      final projects = await repository.getFilterProjects(
        project: state.projectFilter,
        contract: value,
      );
      final contracts = await repository.getFilterContracts(
        project: state.projectFilter,
        contract: value,
      );
      state = state.copyWith(
        isLoadingFilters: false,
        availableProjects: projects,
        availableContracts: contracts,
        filteredItems: _applyFilters(state.allItems),
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingFilters: false,
        filteredItems: _applyFilters(state.allItems),
      );
    }
  }

  Future<void> clearFilters() async {
    state = state.copyWith(
      projectFilter: '',
      contractFilter: '',
      searchQuery: '',
      currentPage: 1,
    );
    await fetchFilterLists();
    state = state.copyWith(
      filteredItems: _applyFilters(state.allItems),
    );
  }

  List<ValidationItem> _applyFilters(
    List<ValidationItem> items, {
    String? searchOverride,
  }) {
    final String project = state.projectFilter;
    final String contract = state.contractFilter;
    Iterable<ValidationItem> filtered = items;
    if (project.isNotEmpty) {
      filtered = filtered.where(
        (ValidationItem item) => validationProjectFilterId(item) == project,
      );
    }
    if (contract.isNotEmpty) {
      filtered = filtered.where(
        (ValidationItem item) => validationContractFilterId(item) == contract,
      );
    }
    return _applySearch(
      filtered.toList(),
      searchOverride ?? state.searchQuery,
    );
  }

  List<ValidationItem> _applySearch(List<ValidationItem> items, String query) {
    if (query.isEmpty) return items;
    final lowerQuery = query.toLowerCase();

    return items.where((item) {
      return item.stringRfiId.toLowerCase().contains(lowerQuery) ||
          (item.status?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.remarks?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.comment?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.valdationAuth?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.project?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.contract?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.projectId?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.contractId?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  void setPage(int page) {
    if (page > 0 && page <= state.totalPages) {
      state = state.copyWith(currentPage: page);
    }
  }

  void setEntriesPerPage(int entries) {
    state = state.copyWith(entriesPerPage: entries, currentPage: 1);
  }

  void updatePendingRemarks(int rfiId, String remarks) {
    state = state.copyWith(
      pendingRemarks: {...state.pendingRemarks, rfiId: remarks},
    );
  }

  void updatePendingComment(int rfiId, String comment) {
    state = state.copyWith(
      pendingComments: {...state.pendingComments, rfiId: comment},
    );
  }

  Future<bool> validateItem(
    int longRfiId,
    int longRfiValidateId,
    String action,
  ) async {
    final remarks = state.pendingRemarks[longRfiId] ?? 'Select';
    final comment = state.pendingComments[longRfiId] ?? '';

    if (remarks == 'Select' || comment.isEmpty) {
      state = state.copyWith(
        actionErrorMessage: 'Remarks and Comments are mandatory',
      );
      return false;
    }

    state = state.copyWith(isValidating: true, actionErrorMessage: null);
    try {
      final repository = ref.read(validationRepositoryProvider);
      await repository.validateRfi({
        'long_rfi_id': longRfiId,
        'long_rfi_validate_id': longRfiValidateId,
        'remarks': remarks,
        'action': action,
        'comment': comment,
      });

      final newRemarks = Map<int, String>.from(state.pendingRemarks);
      newRemarks.remove(longRfiId);
      final newComments = Map<int, String>.from(state.pendingComments);
      newComments.remove(longRfiId);

      state = state.copyWith(
        isValidating: false,
        actionErrorMessage: null,
        pendingRemarks: newRemarks,
        pendingComments: newComments,
      );

      await fetchValidations();
      return true;
    } catch (e) {
      String msg;
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['error'] != null) {
          msg = data['error'].toString();
        } else if (data is Map && data['message'] != null) {
          msg = data['message'].toString();
        } else if (data is String && data.isNotEmpty) {
          msg = data;
        } else {
          msg = e.message ?? 'Validation failed';
        }
      } else {
        msg = userFriendlyErrorMessage(e);
      }
      if (msg.startsWith('Exception: ')) {
        msg = msg.substring(11);
      }
      state = state.copyWith(
        isValidating: false,
        actionErrorMessage: msg,
      );
      return false;
    }
  }

  void clearActionError() {
    state = state.copyWith(actionErrorMessage: null);
  }
}
