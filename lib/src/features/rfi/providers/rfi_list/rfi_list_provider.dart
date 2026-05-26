import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/rfi_list/rfi_list_item.dart';
import '../../data/rfi_list/rfi_list_repository.dart';
import 'rfi_list_state.dart';

part 'rfi_list_provider.g.dart';

@riverpod
class RfiListNotifier extends _$RfiListNotifier {
  @override
  RfiListState build() {
    Future.microtask(() => fetchRfiList());
    return const RfiListState();
  }

  Future<void> fetchRfiList() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(rfiListRepositoryProvider);
      final items = await repo.getRfiDetails();
      state = state.copyWith(
        allItems: items,
        filteredItems: _applySearch(items, state.searchQuery),
        isLoading: false,
        currentPage: 1, // Reset to first page on new data
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    final newFiltered = _applySearch(state.allItems, query);
    state = state.copyWith(
      searchQuery: query,
      filteredItems: newFiltered,
      currentPage: 1, // Reset to first page on search
    );
  }

  void setEntriesPerPage(int count) {
    state = state.copyWith(
      entriesPerPage: count,
      currentPage: 1, // Reset to first page when changing page size
    );
  }

  void nextPage() {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  List<RfiListItem> _applySearch(List<RfiListItem> items, String query) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      return item.rfiNo.toLowerCase().contains(lowerQuery) ||
          item.project.toLowerCase().contains(lowerQuery) ||
          item.structure.toLowerCase().contains(lowerQuery) ||
          item.element.toLowerCase().contains(lowerQuery) ||
          item.activity.toLowerCase().contains(lowerQuery) ||
          item.nameOfRepresentative.toLowerCase().contains(lowerQuery) ||
          item.totalQty.toLowerCase().contains(lowerQuery) ||
          item.createdBy.toLowerCase().contains(lowerQuery) ||
          item.assignedPersonClient.toLowerCase().contains(lowerQuery) ||
          item.status.toLowerCase().contains(lowerQuery) ||
          item.dateOfSubmission.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

@riverpod
class RejectedRfiListNotifier extends _$RejectedRfiListNotifier {
  @override
  RfiListState build() {
    Future.microtask(() => fetchRfiList());
    return const RfiListState();
  }

  Future<void> fetchRfiList() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(rfiListRepositoryProvider);
      final rawItems = await repo.getRfiDetails();

      final rejectedItems = rawItems
          .where((item) =>
              item.status == 'INSPECTION_DONE' &&
              (item.approvalStatus == 'Rejected' ||
                  item.validationStatus == 'REJECTED'))
          .toList();

      state = state.copyWith(
        allItems: rejectedItems,
        filteredItems: _applySearch(rejectedItems, state.searchQuery),
        isLoading: false,
        currentPage: 1, // Reset to first page on new data
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    final newFiltered = _applySearch(state.allItems, query);
    state = state.copyWith(
      searchQuery: query,
      filteredItems: newFiltered,
      currentPage: 1, // Reset to first page on search
    );
  }

  void setEntriesPerPage(int count) {
    state = state.copyWith(
      entriesPerPage: count,
      currentPage: 1, // Reset to first page when changing page size
    );
  }

  void nextPage() {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  List<RfiListItem> _applySearch(List<RfiListItem> items, String query) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      return item.rfiNo.toLowerCase().contains(lowerQuery) ||
          item.project.toLowerCase().contains(lowerQuery) ||
          item.structure.toLowerCase().contains(lowerQuery) ||
          item.element.toLowerCase().contains(lowerQuery) ||
          item.activity.toLowerCase().contains(lowerQuery) ||
          item.nameOfRepresentative.toLowerCase().contains(lowerQuery) ||
          item.totalQty.toLowerCase().contains(lowerQuery) ||
          item.createdBy.toLowerCase().contains(lowerQuery) ||
          item.assignedPersonClient.toLowerCase().contains(lowerQuery) ||
          item.status.toLowerCase().contains(lowerQuery) ||
          item.dateOfSubmission.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

@riverpod
class ScheduledRfiListNotifier extends _$ScheduledRfiListNotifier {
  @override
  RfiListState build() {
    Future.microtask(() => fetchRfiList());
    return const RfiListState();
  }

  Future<void> fetchRfiList() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(rfiListRepositoryProvider);
      final rawItems = await repo.getRfiDetails();

      final scheduledItems = rawItems
          .where((item) =>
              item.status == 'CREATED' ||
              item.status == 'UPDATED' ||
              item.status == 'CON_INSP_ONGOING' ||
              item.status == 'UNDER_CON_RECTIFICATION')
          .toList();

      state = state.copyWith(
        allItems: scheduledItems,
        filteredItems: _applySearch(scheduledItems, state.searchQuery),
        isLoading: false,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    final newFiltered = _applySearch(state.allItems, query);
    state = state.copyWith(
      searchQuery: query,
      filteredItems: newFiltered,
      currentPage: 1,
    );
  }

  void setEntriesPerPage(int count) {
    state = state.copyWith(
      entriesPerPage: count,
      currentPage: 1,
    );
  }

  void nextPage() {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  List<RfiListItem> _applySearch(List<RfiListItem> items, String query) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      return item.rfiNo.toLowerCase().contains(lowerQuery) ||
          item.project.toLowerCase().contains(lowerQuery) ||
          item.structure.toLowerCase().contains(lowerQuery) ||
          item.element.toLowerCase().contains(lowerQuery) ||
          item.activity.toLowerCase().contains(lowerQuery) ||
          item.nameOfRepresentative.toLowerCase().contains(lowerQuery) ||
          item.totalQty.toLowerCase().contains(lowerQuery) ||
          item.createdBy.toLowerCase().contains(lowerQuery) ||
          item.assignedPersonClient.toLowerCase().contains(lowerQuery) ||
          item.status.toLowerCase().contains(lowerQuery) ||
          item.dateOfSubmission.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

@riverpod
class RescheduledRfiListNotifier extends _$RescheduledRfiListNotifier {
  @override
  RfiListState build() {
    Future.microtask(() => fetchRfiList());
    return const RfiListState();
  }

  Future<void> fetchRfiList() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(rfiListRepositoryProvider);
      final rawItems = await repo.getRfiDetails();

      final rescheduledItems =
          rawItems.where((item) => item.status == 'RESCHEDULED').toList();

      state = state.copyWith(
        allItems: rescheduledItems,
        filteredItems: _applySearch(rescheduledItems, state.searchQuery),
        isLoading: false,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    final newFiltered = _applySearch(state.allItems, query);
    state = state.copyWith(
      searchQuery: query,
      filteredItems: newFiltered,
      currentPage: 1,
    );
  }

  void setEntriesPerPage(int count) {
    state = state.copyWith(
      entriesPerPage: count,
      currentPage: 1,
    );
  }

  void nextPage() {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  List<RfiListItem> _applySearch(List<RfiListItem> items, String query) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      return item.rfiNo.toLowerCase().contains(lowerQuery) ||
          item.project.toLowerCase().contains(lowerQuery) ||
          item.structure.toLowerCase().contains(lowerQuery) ||
          item.element.toLowerCase().contains(lowerQuery) ||
          item.activity.toLowerCase().contains(lowerQuery) ||
          item.nameOfRepresentative.toLowerCase().contains(lowerQuery) ||
          item.totalQty.toLowerCase().contains(lowerQuery) ||
          item.createdBy.toLowerCase().contains(lowerQuery) ||
          item.assignedPersonClient.toLowerCase().contains(lowerQuery) ||
          item.status.toLowerCase().contains(lowerQuery) ||
          item.dateOfSubmission.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

@riverpod
class SubmittedRfiListNotifier extends _$SubmittedRfiListNotifier {
  @override
  RfiListState build() {
    Future.microtask(() => fetchRfiList());
    return const RfiListState();
  }

  Future<void> fetchRfiList() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(rfiListRepositoryProvider);
      final rawItems = await repo.getRfiDetails();

      final submittedItems =
          rawItems.where((item) => item.status == 'INSPECTED_BY_CON').toList();

      state = state.copyWith(
        allItems: submittedItems,
        filteredItems: _applySearch(submittedItems, state.searchQuery),
        isLoading: false,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    final newFiltered = _applySearch(state.allItems, query);
    state = state.copyWith(
      searchQuery: query,
      filteredItems: newFiltered,
      currentPage: 1,
    );
  }

  void setEntriesPerPage(int count) {
    state = state.copyWith(
      entriesPerPage: count,
      currentPage: 1,
    );
  }

  void nextPage() {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  List<RfiListItem> _applySearch(List<RfiListItem> items, String query) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      return item.rfiNo.toLowerCase().contains(lowerQuery) ||
          item.project.toLowerCase().contains(lowerQuery) ||
          item.structure.toLowerCase().contains(lowerQuery) ||
          item.element.toLowerCase().contains(lowerQuery) ||
          item.activity.toLowerCase().contains(lowerQuery) ||
          item.nameOfRepresentative.toLowerCase().contains(lowerQuery) ||
          item.totalQty.toLowerCase().contains(lowerQuery) ||
          item.createdBy.toLowerCase().contains(lowerQuery) ||
          item.assignedPersonClient.toLowerCase().contains(lowerQuery) ||
          item.status.toLowerCase().contains(lowerQuery) ||
          item.dateOfSubmission.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

@riverpod
class ApprovedRfiListNotifier extends _$ApprovedRfiListNotifier {
  @override
  RfiListState build() {
    Future.microtask(() => fetchRfiList());
    return const RfiListState();
  }

  Future<void> fetchRfiList() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(rfiListRepositoryProvider);
      final rawItems = await repo.getRfiDetails();

      final approvedItems = rawItems
          .where((item) =>
              item.status == 'INSPECTION_DONE' &&
              item.approvalStatus == 'Accepted' &&
              item.validationStatus != 'REJECTED')
          .toList();

      state = state.copyWith(
        allItems: approvedItems,
        filteredItems: _applySearch(approvedItems, state.searchQuery),
        isLoading: false,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    final newFiltered = _applySearch(state.allItems, query);
    state = state.copyWith(
      searchQuery: query,
      filteredItems: newFiltered,
      currentPage: 1,
    );
  }

  void setEntriesPerPage(int count) {
    state = state.copyWith(
      entriesPerPage: count,
      currentPage: 1,
    );
  }

  void nextPage() {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  List<RfiListItem> _applySearch(List<RfiListItem> items, String query) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      return item.rfiNo.toLowerCase().contains(lowerQuery) ||
          item.project.toLowerCase().contains(lowerQuery) ||
          item.structure.toLowerCase().contains(lowerQuery) ||
          item.element.toLowerCase().contains(lowerQuery) ||
          item.activity.toLowerCase().contains(lowerQuery) ||
          item.nameOfRepresentative.toLowerCase().contains(lowerQuery) ||
          item.totalQty.toLowerCase().contains(lowerQuery) ||
          item.createdBy.toLowerCase().contains(lowerQuery) ||
          item.assignedPersonClient.toLowerCase().contains(lowerQuery) ||
          item.status.toLowerCase().contains(lowerQuery) ||
          item.dateOfSubmission.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

@riverpod
class ClosedRfiListNotifier extends _$ClosedRfiListNotifier {
  @override
  RfiListState build() {
    Future.microtask(() => fetchRfiList());
    return const RfiListState();
  }

  Future<void> fetchRfiList() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(rfiListRepositoryProvider);
      final rawItems = await repo.getRfiDetails();

      final closedItems =
          rawItems.where((item) => item.status == 'INSPECTION_DONE').toList();

      state = state.copyWith(
        allItems: closedItems,
        filteredItems: _applySearch(closedItems, state.searchQuery),
        isLoading: false,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    final newFiltered = _applySearch(state.allItems, query);
    state = state.copyWith(
      searchQuery: query,
      filteredItems: newFiltered,
      currentPage: 1,
    );
  }

  void setEntriesPerPage(int count) {
    state = state.copyWith(
      entriesPerPage: count,
      currentPage: 1,
    );
  }

  void nextPage() {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  List<RfiListItem> _applySearch(List<RfiListItem> items, String query) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      return item.rfiNo.toLowerCase().contains(lowerQuery) ||
          item.project.toLowerCase().contains(lowerQuery) ||
          item.structure.toLowerCase().contains(lowerQuery) ||
          item.element.toLowerCase().contains(lowerQuery) ||
          item.activity.toLowerCase().contains(lowerQuery) ||
          item.nameOfRepresentative.toLowerCase().contains(lowerQuery) ||
          item.totalQty.toLowerCase().contains(lowerQuery) ||
          item.createdBy.toLowerCase().contains(lowerQuery) ||
          item.assignedPersonClient.toLowerCase().contains(lowerQuery) ||
          item.status.toLowerCase().contains(lowerQuery) ||
          item.dateOfSubmission.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
