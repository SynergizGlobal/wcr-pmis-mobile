import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/validation/validation_item.dart';

part 'validation_state.freezed.dart';

@freezed
class ValidationState with _$ValidationState {
  const factory ValidationState({
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default([]) List<ValidationItem> allItems,
    @Default([]) List<ValidationItem> filteredItems,
    @Default("") String searchQuery,
    @Default(1) int currentPage,
    @Default(5) int entriesPerPage,
    @Default({}) Map<int, String> pendingRemarks,
    @Default({}) Map<int, String> pendingComments,
    @Default(false) bool isValidating,
    String? actionErrorMessage,
  }) = _ValidationState;

  const ValidationState._();

  int get totalPages => (filteredItems.length / entriesPerPage).ceil();

  List<ValidationItem> get paginatedItems {
    final start = (currentPage - 1) * entriesPerPage;
    final end = start + entriesPerPage;
    if (start >= filteredItems.length) return [];
    return filteredItems.sublist(
      start,
      end > filteredItems.length ? filteredItems.length : end,
    );
  }
}
