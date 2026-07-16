import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/inspection/inspection_item.dart';

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
    @Default([]) List<String> availableProjects,
    @Default([]) List<String> availableContracts,
    @Default(false) bool rescheduledOnly,
    @Default(1) int currentPage,
    @Default(5) int rowsPerPage, // Matching references which use 5 or 10
  }) = _InspectionState;
}
