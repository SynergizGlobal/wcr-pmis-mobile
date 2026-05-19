import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/rfi_list/rfi_list_item.dart';

part 'rfi_list_state.freezed.dart';

@freezed
class RfiListState with _$RfiListState {
  const factory RfiListState({
    @Default([]) List<RfiListItem> allItems,
    @Default([]) List<RfiListItem> filteredItems,
    @Default('') String searchQuery,
    @Default(10) int entriesPerPage,
    @Default(1) int currentPage,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _RfiListState;

  const RfiListState._();

  int get totalPages => (filteredItems.length / entriesPerPage).ceil();

  List<RfiListItem> get paginatedItems {
    final startIndex = (currentPage - 1) * entriesPerPage;
    final endIndex = (startIndex + entriesPerPage) < filteredItems.length
        ? (startIndex + entriesPerPage)
        : filteredItems.length;

    if (startIndex >= filteredItems.length) return [];

    return filteredItems.sublist(startIndex, endIndex);
  }
}
