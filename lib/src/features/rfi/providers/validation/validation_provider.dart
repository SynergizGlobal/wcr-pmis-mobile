import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../data/validation/validation_repository.dart';
import '../../domain/validation/validation_item.dart';
import 'validation_state.dart';

part 'validation_provider.g.dart';

@riverpod
class ValidationNotifier extends _$ValidationNotifier {
  @override
  ValidationState build() {
    Future.microtask(() {
      fetchValidations();
    });
    return const ValidationState();
  }

  Future<void> fetchValidations() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(validationRepositoryProvider);
      final items = await repository.getRfiValidations();

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

  List<ValidationItem> _applySearch(List<ValidationItem> items, String query) {
    if (query.isEmpty) return items;
    final lowerQuery = query.toLowerCase();

    return items.where((item) {
      return item.stringRfiId.toLowerCase().contains(lowerQuery) ||
          (item.status?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.remarks?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.comment?.toLowerCase().contains(lowerQuery) ?? false) ||
          (item.valdationAuth?.toLowerCase().contains(lowerQuery) ?? false);
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
      state = state.copyWith(actionErrorMessage: 'Remarks and Comments are mandatory');
      return false;
    }

    state = state.copyWith(isValidating: true, actionErrorMessage: null);
    try {
      final repository = ref.read(validationRepositoryProvider);
      await repository.validateRfi({
        "long_rfi_id": longRfiId,
        "long_rfi_validate_id": longRfiValidateId,
        "remarks": remarks,
        "action": action,
        "comment": comment,
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
        msg = e.toString();
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
