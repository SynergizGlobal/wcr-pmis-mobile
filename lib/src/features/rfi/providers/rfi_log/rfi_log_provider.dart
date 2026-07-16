import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/rfi_log/rfi_log_repository.dart';
import '../../domain/rfi_log/rfi_log_dashboard_filter.dart';
import '../../domain/rfi_log/rfi_log_item.dart';
import 'rfi_log_state.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';

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

  Future<void> applyDashboardFilter(RfiLogDashboardFilter filter) async {
    state = state.copyWith(
      dashboardFilter: filter,
      projectFilter: '',
      workFilter: '',
      contractFilter: '',
      searchQuery: '',
      currentPage: 1,
    );
    if (filter == RfiLogDashboardFilter.none) {
      await fetchFilterLists();
    }
    await fetchRfiLogs();
  }

  Future<void> fetchFilterLists() async {
    if (state.filtersFromDataset) {
      return;
    }
    try {
      final logRepo = ref.read(rfiLogRepositoryProvider);
      final filters = await logRepo.getFilterList();

      state = state.copyWith(
        availableProjects: List<String>.from(filters['projects'] ?? []),
        availableWorks: List<String>.from(filters['works'] ?? []),
        availableContracts: List<String>.from(filters['contracts'] ?? []),
      );
    } catch (e) {
      // Keep previous filter lists on failure.
    }
  }

  Future<void> fetchRfiLogs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(rfiLogRepositoryProvider);
      final Map<String, dynamic> body = state.filtersFromDataset
          ? <String, dynamic>{
              'project': '',
              'work': '',
              'contract': '',
            }
          : <String, dynamic>{
              'project': state.projectFilter,
              'work': state.workFilter,
              'contract': state.contractFilter,
            };
      final List<RfiLogItem> rawItems =
          await repository.getAllRfiLogDetails(body);
      final List<RfiLogItem> scoped = _applyDashboardStatusFilter(rawItems);

      if (state.filtersFromDataset) {
        state = state.copyWith(
          isLoading: false,
          allItems: scoped,
          availableProjects: _uniqueSorted(
            scoped.map((RfiLogItem e) => e.project),
          ),
          availableWorks: _uniqueSorted(scoped.map((RfiLogItem e) => e.work)),
          availableContracts: _uniqueSorted(
            scoped.map((RfiLogItem e) => e.contract),
          ),
          filteredItems: _applyClientDatasetFilters(scoped),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          allItems: scoped,
          filteredItems: _applySearch(scoped, state.searchQuery),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: userFriendlyErrorMessage(e),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
    state = state.copyWith(
      filteredItems: state.filtersFromDataset
          ? _applyClientDatasetFilters(state.allItems)
          : _applySearch(state.allItems, query),
    );
  }

  void setProjectFilter(String? project) {
    final String value = project ?? '';
    if (state.filtersFromDataset) {
      final List<RfiLogItem> base = value.isEmpty
          ? state.allItems
          : state.allItems
              .where((RfiLogItem item) => item.project == value)
              .toList();
      state = state.copyWith(
        projectFilter: value,
        workFilter: '',
        contractFilter: '',
        currentPage: 1,
        availableWorks: _uniqueSorted(base.map((RfiLogItem e) => e.work)),
        availableContracts:
            _uniqueSorted(base.map((RfiLogItem e) => e.contract)),
        filteredItems: _applyClientDatasetFilters(
          state.allItems,
          projectOverride: value,
          workOverride: '',
          contractOverride: '',
        ),
      );
      return;
    }

    state = state.copyWith(
      projectFilter: value,
      workFilter: '',
      contractFilter: '',
      currentPage: 1,
    );
    fetchRfiLogs();
  }

  void setWorkFilter(String? work) {
    final String value = work ?? '';
    if (state.filtersFromDataset) {
      state = state.copyWith(
        workFilter: value,
        contractFilter: '',
        currentPage: 1,
        filteredItems: _applyClientDatasetFilters(
          state.allItems,
          workOverride: value,
          contractOverride: '',
        ),
      );
      final List<RfiLogItem> forContracts = state.filteredItems;
      state = state.copyWith(
        availableContracts:
            _uniqueSorted(forContracts.map((RfiLogItem e) => e.contract)),
      );
      return;
    }

    state = state.copyWith(
      workFilter: value,
      contractFilter: '',
      currentPage: 1,
    );
    fetchRfiLogs();
  }

  void setContractFilter(String? contract) {
    final String value = contract ?? '';
    if (state.filtersFromDataset) {
      state = state.copyWith(
        contractFilter: value,
        currentPage: 1,
        filteredItems: _applyClientDatasetFilters(
          state.allItems,
          contractOverride: value,
        ),
      );
      return;
    }

    state = state.copyWith(
      contractFilter: value,
      currentPage: 1,
    );
    fetchRfiLogs();
  }

  void clearFilters() {
    if (state.filtersFromDataset) {
      state = state.copyWith(
        projectFilter: '',
        workFilter: '',
        contractFilter: '',
        searchQuery: '',
        currentPage: 1,
        availableProjects: _uniqueSorted(
          state.allItems.map((RfiLogItem e) => e.project),
        ),
        availableWorks:
            _uniqueSorted(state.allItems.map((RfiLogItem e) => e.work)),
        availableContracts:
            _uniqueSorted(state.allItems.map((RfiLogItem e) => e.contract)),
        filteredItems: _applySearch(state.allItems, ''),
      );
      return;
    }

    state = state.copyWith(
      projectFilter: '',
      workFilter: '',
      contractFilter: '',
      searchQuery: '',
      currentPage: 1,
    );
    fetchRfiLogs();
  }

  List<RfiLogItem> _applyDashboardStatusFilter(List<RfiLogItem> items) {
    switch (state.dashboardFilter) {
      case RfiLogDashboardFilter.none:
        return items;
      case RfiLogDashboardFilter.approved:
        return items.where(_isApproved).toList();
      case RfiLogDashboardFilter.rejected:
        return items.where(_isRejected).toList();
      case RfiLogDashboardFilter.closed:
        return items
            .where(
              (RfiLogItem item) =>
                  item.status.toUpperCase() == 'INSPECTION_DONE',
            )
            .toList();
    }
  }

  bool _isApproved(RfiLogItem item) {
    if (item.status.toUpperCase() != 'INSPECTION_DONE') {
      return false;
    }
    final String approval = (item.enggApproval ?? '').trim();
    final String validation =
        (item.validationStatus ?? '').trim().toUpperCase();
    return approval == 'Accepted' &&
        (validation == 'APPROVED' || validation.isEmpty);
  }

  bool _isRejected(RfiLogItem item) {
    if (item.status.toUpperCase() != 'INSPECTION_DONE') {
      return false;
    }
    final String approval = (item.enggApproval ?? '').trim();
    final String validation =
        (item.validationStatus ?? '').trim().toUpperCase();
    if (approval == 'Rejected' && validation.isEmpty) {
      return true;
    }
    if ((approval == 'Accepted' || approval == 'Rejected') &&
        validation == 'REJECTED') {
      return true;
    }
    return false;
  }

  List<RfiLogItem> _applyClientDatasetFilters(
    List<RfiLogItem> items, {
    String? projectOverride,
    String? workOverride,
    String? contractOverride,
    String? searchOverride,
  }) {
    final String project = projectOverride ?? state.projectFilter;
    final String work = workOverride ?? state.workFilter;
    final String contract = contractOverride ?? state.contractFilter;
    Iterable<RfiLogItem> filtered = items;
    if (project.isNotEmpty) {
      filtered = filtered.where((RfiLogItem item) => item.project == project);
    }
    if (work.isNotEmpty) {
      filtered = filtered.where((RfiLogItem item) => item.work == work);
    }
    if (contract.isNotEmpty) {
      filtered = filtered.where((RfiLogItem item) => item.contract == contract);
    }
    return _applySearch(
      filtered.toList(),
      searchOverride ?? state.searchQuery,
    );
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
          (item.txnId?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.enggApproval?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<String> _uniqueSorted(Iterable<String> values) {
    final Set<String> unique = <String>{};
    for (final String value in values) {
      final String trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        unique.add(trimmed);
      }
    }
    final List<String> sorted = unique.toList()..sort();
    return sorted;
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
