import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/rfi_log/rfi_log_repository.dart';
import '../../domain/rfi_log/rfi_log_item.dart';
import 'rfi_log_state.dart';

part 'rfi_log_provider.g.dart';

@riverpod
class RfiLogNotifier extends _$RfiLogNotifier {
  @override
  RfiLogState build() {
    Future.microtask(() {
      fetchFilterLists();
      fetchRfiLogs();
    });
    return const RfiLogState();
  }

  Future<void> fetchFilterLists() async {
    try {
      final logRepo = ref.read(rfiLogRepositoryProvider);
      final filters = await logRepo.getFilterList();
      
      state = state.copyWith(
        availableProjects: List<String>.from(filters['projects'] ?? []),
        availableWorks: List<String>.from(filters['works'] ?? []),
        availableContracts: List<String>.from(filters['contracts'] ?? []),
      );
    } catch (e) {
    }
  }

  Future<void> fetchRfiLogs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(rfiLogRepositoryProvider);
      final body = {
        "project": state.projectFilter,
        "work": state.workFilter,
        "contract": state.contractFilter,
      };
      final items = await repository.getAllRfiLogDetails(body);

      state = state.copyWith(
        isLoading: false,
        allItems: items,
        filteredItems: _applySearch(items, state.searchQuery),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 1,
      filteredItems: _applySearch(state.allItems, query),
    );
  }

  void setProjectFilter(String? project) {
    state = state.copyWith(
      projectFilter: project ?? '',
      workFilter: '',
      contractFilter: '',
      currentPage: 1,
    );
    fetchRfiLogs();
  }

  void setWorkFilter(String? work) {
    state = state.copyWith(
      workFilter: work ?? '',
      contractFilter: '',
      currentPage: 1,
    );
    fetchRfiLogs();
  }

  void setContractFilter(String? contract) {
    state = state.copyWith(
      contractFilter: contract ?? '',
      currentPage: 1,
    );
    fetchRfiLogs();
  }

  void clearFilters() {
    state = state.copyWith(
      projectFilter: '',
      workFilter: '',
      contractFilter: '',
      searchQuery: '',
      currentPage: 1,
    );
    fetchRfiLogs();
  }


  List<RfiLogItem> _applySearch(List<RfiLogItem> items, String query) {
    if (query.isEmpty) return items;
    final lowerQuery = query.toLowerCase();

    return items.where((item) {
      return item.rfiId.toLowerCase().contains(lowerQuery) ||
          item.structure.toLowerCase().contains(lowerQuery) ||
          item.rfiDescription.toLowerCase().contains(lowerQuery) ||
          item.rfiRequestedBy.toLowerCase().contains(lowerQuery) ||
          item.department.toLowerCase().contains(lowerQuery) ||
          item.person.toLowerCase().contains(lowerQuery) ||
          item.status.toLowerCase().contains(lowerQuery) ||
          item.project.toLowerCase().contains(lowerQuery) ||
          item.work.toLowerCase().contains(lowerQuery) ||
          item.contract.toLowerCase().contains(lowerQuery) ||
          item.nameOfRepresentative.toLowerCase().contains(lowerQuery) ||
          item.dateOfSubmission.toLowerCase().contains(lowerQuery) ||
          item.dateRaised.toLowerCase().contains(lowerQuery) ||
          (item.dateResponded?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.notes?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.validationStatus?.toLowerCase().contains(lowerQuery) ??
              false) ||
          (item.txnId?.toLowerCase().contains(lowerQuery) ?? false);
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
}
