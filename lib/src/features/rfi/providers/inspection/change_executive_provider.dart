import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/inspection/change_executive_repository.dart';

class ChangeExecutiveState {
  final bool isLoading;
  final List<String> engineerNames;
  final String? error;
  final String? successMessage;

  ChangeExecutiveState({
    this.isLoading = false,
    this.engineerNames = const [],
    this.error,
    this.successMessage,
  });

  ChangeExecutiveState copyWith({
    bool? isLoading,
    List<String>? engineerNames,
    String? error,
    String? successMessage,
  }) {
    return ChangeExecutiveState(
      isLoading: isLoading ?? this.isLoading,
      engineerNames: engineerNames ?? this.engineerNames,
      error: error, // Allow null to clear error
      successMessage: successMessage, // Allow null to clear success message
    );
  }
}

final changeExecutiveProvider =
    StateNotifierProvider<ChangeExecutiveNotifier, ChangeExecutiveState>((ref) {
  final repository = ref.watch(changeExecutiveRepositoryProvider);
  return ChangeExecutiveNotifier(repository);
});

class ChangeExecutiveNotifier extends StateNotifier<ChangeExecutiveState> {
  final ChangeExecutiveRepository _repository;

  ChangeExecutiveNotifier(this._repository) : super(ChangeExecutiveState());

  Future<void> fetchEngineerNames(String userId, String contractId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final names = await _repository.getEngineerNames(userId, contractId);
      state = state.copyWith(isLoading: false, engineerNames: names);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> assignExecutive({
    required String rfiId,
    required String personName,
    required String department,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final message = await _repository.assignClientPerson({
        'rfi_Id': rfiId,
        'assignedPersonClient': personName,
        'clientDepartment': department,
      });
      state = state.copyWith(isLoading: false, successMessage: message);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearState() {
    state = ChangeExecutiveState();
  }
}
