import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/inspection/inspection_repository.dart';
import 'inspection_state.dart';

final inspectionProvider =
    StateNotifierProvider<InspectionNotifier, InspectionState>((ref) {
  final repository = ref.watch(inspectionRepositoryProvider);
  return InspectionNotifier(repository);
});

class InspectionNotifier extends StateNotifier<InspectionState> {
  final InspectionRepository _repository;

  InspectionNotifier(this._repository) : super(const InspectionState()) {
    fetchInspections();
  }

  Future<void> fetchInspections() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final items = await _repository.getInspectionList();
      state = state.copyWith(
        allItems: items,
        filteredItems: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      state = state.copyWith(
        searchQuery: query,
        filteredItems: state.allItems,
        currentPage: 1,
      );
    } else {
      final lowerQuery = query.toLowerCase();
      final filtered = state.allItems.where((item) {
        return (item.rfiId?.toLowerCase().contains(lowerQuery) ?? false) ||
            (item.structure?.toLowerCase().contains(lowerQuery) ?? false) ||
            (item.element?.toLowerCase().contains(lowerQuery) ?? false) ||
            (item.activity?.toLowerCase().contains(lowerQuery) ?? false) ||
            (item.rfiDescription?.toLowerCase().contains(lowerQuery) ??
                false) ||
            (item.assignedPersonClient?.toLowerCase().contains(lowerQuery) ??
                false) ||
            (item.createdBy?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();

      state = state.copyWith(
        searchQuery: query,
        filteredItems: filtered,
        currentPage: 1, // Reset to first page on search
      );
    }
  }

  void updateRowsPerPage(int rows) {
    state = state.copyWith(
      rowsPerPage: rows,
      currentPage: 1, // Reset to first page
    );
  }

  void updatePage(int page) {
    state = state.copyWith(currentPage: page);
  }

  Future<void> sendForValidation(int rfiId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.sendForValidation(rfiId);
      // Refresh the list after successful send
      await fetchInspections();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<String> uploadAttachment({
    required int rfiId,
    required String description,
    required PlatformFile file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'rfiId': rfiId,
        'description': description,
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      final message = await _repository.uploadAttachment(formData);
      return message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadTestReport({
    required int rfiId,
    required String testType,
    required PlatformFile file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'rfiId': rfiId,
        'testType': testType,
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      final message = await _repository.uploadTestReport(formData);
      return message;
    } catch (e) {
      rethrow;
    }
  }
}
