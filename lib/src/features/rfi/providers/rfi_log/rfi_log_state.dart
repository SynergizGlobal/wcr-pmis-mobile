import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/common/filter_option.dart';
import '../../domain/rfi_log/rfi_log_dashboard_filter.dart';
import '../../domain/rfi_log/rfi_log_item.dart';

part 'rfi_log_state.freezed.dart';

@freezed
class RfiLogState with _$RfiLogState {
  const factory RfiLogState({
    @Default([]) List<RfiLogItem> allItems,
    @Default([]) List<RfiLogItem> filteredItems,
    @Default('') String searchQuery,
    @Default('') String projectFilter,
    @Default('') String contractFilter,
    @Default('') String structureTypeFilter,
    @Default('') String structureFilter,
    @Default('') String statusFilter,
    @Default([]) List<FilterOption> availableProjects,
    @Default([]) List<FilterOption> availableContracts,
    @Default([]) List<String> availableStructureTypes,
    @Default([]) List<String> availableStructures,
    @Default([]) List<String> availableStatuses,
    @Default(RfiLogDashboardFilter.none)
    RfiLogDashboardFilter dashboardFilter,
    @Default(10) int entriesPerPage,
    @Default(1) int currentPage,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingFilters,
    String? errorMessage,
  }) = _RfiLogState;

  const RfiLogState._();

  int get totalPages {
    if (filteredItems.isEmpty) return 1;
    return (filteredItems.length / entriesPerPage).ceil();
  }

  List<RfiLogItem> get paginatedItems {
    if (filteredItems.isEmpty) return [];
    final startIndex = (currentPage - 1) * entriesPerPage;
    final endIndex = (startIndex + entriesPerPage) < filteredItems.length
        ? (startIndex + entriesPerPage)
        : filteredItems.length;

    return filteredItems.sublist(startIndex, endIndex);
  }

  bool get filtersFromDataset =>
      dashboardFilter != RfiLogDashboardFilter.none;

  int get activeServerFilterCount {
    var count = 0;
    if (projectFilter.trim().isNotEmpty) count++;
    if (contractFilter.trim().isNotEmpty) count++;
    if (structureTypeFilter.trim().isNotEmpty) count++;
    if (structureFilter.trim().isNotEmpty) count++;
    if (statusFilter.trim().isNotEmpty) count++;
    return count;
  }

  bool get hasActiveServerFilters => activeServerFilterCount > 0;
}
