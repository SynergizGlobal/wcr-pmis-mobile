import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/common/filter_option.dart';
import '../../domain/inspection/inspection_item.dart';
import '../../domain/inspection/inspection_list_mode.dart';

part 'inspection_state.freezed.dart';

@freezed
class InspectionState with _$InspectionState {
  const factory InspectionState({
    @Default([]) List<InspectionItem> allItems,
    @Default([]) List<InspectionItem> filteredItems,
    @Default(true) bool isLoading,
    String? error,
    @Default('') String searchQuery,
    @Default('') String projectFilter,
    @Default('') String contractFilter,
    @Default([]) List<FilterOption> availableProjects,
    @Default([]) List<FilterOption> availableContracts,
    @Default(InspectionListMode.all) InspectionListMode listMode,
    @Default(1) int currentPage,
    @Default(5) int rowsPerPage,
    @Default(false) bool isLoadingFilters,
  }) = _InspectionState;
}
