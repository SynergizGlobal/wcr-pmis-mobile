import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import '../../data/rfi_log/rfi_log_repository.dart';
import '../../domain/common/filter_option.dart';
import '../../domain/rfi_log/rfi_log_dashboard_filter.dart';
import '../../domain/rfi_log/rfi_log_item.dart';
import 'rfi_log_state.dart';

part 'rfi_log_provider.g.dart';

String rfiLogProjectFilterId(RfiLogItem item) {
  final String id = (item.projectId ?? '').trim();
  if (id.isNotEmpty) return id;
  return item.project.trim();
}

String rfiLogContractFilterId(RfiLogItem item) {
  final String id = (item.contractId ?? '').trim();
  if (id.isNotEmpty) return id;
  return item.contract.trim();
}

@riverpod
class RfiLogNotifier extends _$RfiLogNotifier {
  @override
  RfiLogState build() {
    Future.microtask(fetchRfiLogs);
    return const RfiLogState();
  }

  Future<void> applyDashboardFilter(RfiLogDashboardFilter filter) async {
    state = state.copyWith(
      dashboardFilter: filter,
      projectFilter: '',
      contractFilter: '',
      searchQuery: '',
      currentPage: 1,
    );
    await fetchRfiLogs();
  }

  Future<void> fetchFilterLists({
    Set<String>? limitProjectIds,
    Set<String>? limitContractIds,
  }) async {
    state = state.copyWith(isLoadingFilters: true);
    try {
      final logRepo = ref.read(rfiLogRepositoryProvider);
      final List<FilterOption> projects = await logRepo.getFilterProjects(
        project: state.projectFilter,
        contract: state.contractFilter,
      );
      final List<FilterOption> contracts = await logRepo.getFilterContracts(
        project: state.projectFilter,
        contract: state.contractFilter,
      );

      if (limitProjectIds != null || limitContractIds != null) {
        final List<FilterOption> fallbackProjects =
            FilterOption.uniqueFromPairs(
          state.allItems.map((RfiLogItem e) => (e.projectId, e.project)),
        );
        final List<FilterOption> fallbackContracts =
            FilterOption.uniqueFromPairs(
          state.allItems.map((RfiLogItem e) => (e.contractId, e.contract)),
        );
        state = state.copyWith(
          isLoadingFilters: false,
          availableProjects: limitProjectIds == null
              ? projects
              : FilterOption.intersectByIds(
                  apiOptions: projects,
                  allowedIds: limitProjectIds,
                  fallback: fallbackProjects,
                ),
          availableContracts: limitContractIds == null
              ? contracts
              : FilterOption.intersectByIds(
                  apiOptions: contracts,
                  allowedIds: limitContractIds,
                  fallback: fallbackContracts,
                ),
        );
      } else {
        state = state.copyWith(
          isLoadingFilters: false,
          availableProjects: projects,
          availableContracts: contracts,
        );
      }
    } catch (_) {
      // Keep previous filter lists on failure — never show a popup dialog.
      state = state.copyWith(isLoadingFilters: false);
    }
  }

  Future<void> fetchRfiLogs() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingFilters: true,
      errorMessage: null,
    );
    try {
      final repository = ref.read(rfiLogRepositoryProvider);
      // Always load full list; Project/Contract/Search filter on frontend.
      final List<RfiLogItem> rawItems = await repository.getAllRfiLogDetails(
        <String, dynamic>{
          'project': '',
          'contract': '',
        },
      );
      final List<RfiLogItem> scoped = _applyDashboardStatusFilter(rawItems);

      state = state.copyWith(
        allItems: scoped,
        filteredItems: _applyClientFilters(scoped),
      );

      // Resolve dropdown labels before revealing the page (avoids filter blink).
      if (state.filtersFromDataset) {
        await fetchFilterLists(
          limitProjectIds: _idsInItems(scoped, isProject: true),
          limitContractIds: _idsInItems(scoped, isProject: false),
        );
      } else {
        await fetchFilterLists();
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingFilters: false,
        errorMessage: userFriendlyErrorMessage(e),
      );
    }
  }

  Set<String> _idsInItems(List<RfiLogItem> items, {required bool isProject}) {
    final Set<String> ids = <String>{};
    for (final RfiLogItem item in items) {
      final String id =
          isProject ? rfiLogProjectFilterId(item) : rfiLogContractFilterId(item);
      final String trimmed = id.trim();
      if (trimmed.isEmpty) continue;
      final String lower = trimmed.toLowerCase();
      if (lower == 'n/a' || lower == 'na' || lower == '-' || lower == 'null') {
        continue;
      }
      ids.add(trimmed);
    }
    return ids;
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 1,
      filteredItems: _applyClientFilters(state.allItems, searchOverride: query),
    );
  }

  Future<void> setProjectFilter(String? projectId) async {
    final String value = projectId ?? '';
    state = state.copyWith(
      projectFilter: value,
      contractFilter: '',
      currentPage: 1,
    );

    if (state.filtersFromDataset) {
      final List<RfiLogItem> base = value.isEmpty
          ? state.allItems
          : state.allItems
              .where((RfiLogItem item) => rfiLogProjectFilterId(item) == value)
              .toList();
      state = state.copyWith(
        filteredItems: _applyClientFilters(
          state.allItems,
          projectOverride: value,
          contractOverride: '',
        ),
      );
      await fetchFilterLists(
        limitProjectIds: _idsInItems(state.allItems, isProject: true),
        limitContractIds: _idsInItems(base, isProject: false),
      );
      return;
    }

    try {
      final logRepo = ref.read(rfiLogRepositoryProvider);
      final contracts = await logRepo.getFilterContracts(project: value);
      final projects = await logRepo.getFilterProjects(contract: '');
      state = state.copyWith(
        availableProjects: projects,
        availableContracts: contracts,
        filteredItems: _applyClientFilters(state.allItems),
      );
    } catch (_) {
      state = state.copyWith(
        filteredItems: _applyClientFilters(state.allItems),
      );
    }
  }

  Future<void> setContractFilter(String? contractId) async {
    final String value = contractId ?? '';
    state = state.copyWith(
      contractFilter: value,
      currentPage: 1,
    );

    if (state.filtersFromDataset) {
      state = state.copyWith(
        filteredItems: _applyClientFilters(
          state.allItems,
          contractOverride: value,
        ),
      );
      final List<RfiLogItem> forProjects = value.isEmpty
          ? state.allItems
          : state.allItems
              .where(
                (RfiLogItem item) => rfiLogContractFilterId(item) == value,
              )
              .toList();
      final List<RfiLogItem> forContracts = state.projectFilter.isEmpty
          ? state.allItems
          : state.allItems
              .where(
                (RfiLogItem item) =>
                    rfiLogProjectFilterId(item) == state.projectFilter,
              )
              .toList();
      await fetchFilterLists(
        limitProjectIds: _idsInItems(forProjects, isProject: true),
        limitContractIds: _idsInItems(forContracts, isProject: false),
      );
      return;
    }

    try {
      final logRepo = ref.read(rfiLogRepositoryProvider);
      final projects = await logRepo.getFilterProjects(
        project: state.projectFilter,
        contract: value,
      );
      final contracts = await logRepo.getFilterContracts(
        project: state.projectFilter,
        contract: value,
      );
      state = state.copyWith(
        availableProjects: projects,
        availableContracts: contracts,
        filteredItems: _applyClientFilters(state.allItems),
      );
    } catch (_) {
      state = state.copyWith(
        filteredItems: _applyClientFilters(state.allItems),
      );
    }
  }

  Future<void> clearFilters() async {
    state = state.copyWith(
      projectFilter: '',
      contractFilter: '',
      searchQuery: '',
      currentPage: 1,
      filteredItems: _applySearch(state.allItems, ''),
    );

    if (state.filtersFromDataset) {
      await fetchFilterLists(
        limitProjectIds: _idsInItems(state.allItems, isProject: true),
        limitContractIds: _idsInItems(state.allItems, isProject: false),
      );
      return;
    }

    await fetchFilterLists();
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

  List<RfiLogItem> _applyClientFilters(
    List<RfiLogItem> items, {
    String? projectOverride,
    String? contractOverride,
    String? searchOverride,
  }) {
    final String project = projectOverride ?? state.projectFilter;
    final String contract = contractOverride ?? state.contractFilter;
    Iterable<RfiLogItem> filtered = items;
    if (project.isNotEmpty) {
      filtered = filtered.where(
        (RfiLogItem item) => rfiLogProjectFilterId(item) == project,
      );
    }
    if (contract.isNotEmpty) {
      filtered = filtered.where(
        (RfiLogItem item) => rfiLogContractFilterId(item) == contract,
      );
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
          item.contract.toLowerCase().contains(lowerQuery) ||
          (item.projectId?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.contractId?.toLowerCase().contains(lowerQuery) ?? false) ||
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

  void setPage(int page) {
    if (page > 0 && page <= state.totalPages) {
      state = state.copyWith(currentPage: page);
    }
  }

  void setEntriesPerPage(int entries) {
    state = state.copyWith(entriesPerPage: entries, currentPage: 1);
  }
}
