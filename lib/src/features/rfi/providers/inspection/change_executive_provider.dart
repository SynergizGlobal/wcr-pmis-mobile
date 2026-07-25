import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_engineer_option.dart';
import '../../data/inspection/change_executive_repository.dart';

class ChangeExecutiveState {
  final bool isLoading;
  final List<RfiEngineerOption> engineers;
  final String? error;
  final String? successMessage;

  ChangeExecutiveState({
    this.isLoading = false,
    this.engineers = const <RfiEngineerOption>[],
    this.error,
    this.successMessage,
  });

  ChangeExecutiveState copyWith({
    bool? isLoading,
    List<RfiEngineerOption>? engineers,
    String? error,
    String? successMessage,
  }) {
    return ChangeExecutiveState(
      isLoading: isLoading ?? this.isLoading,
      engineers: engineers ?? this.engineers,
      error: error,
      successMessage: successMessage,
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
      final engineers = await _repository.getEngineerNames(userId, contractId);
      state = state.copyWith(isLoading: false, engineers: engineers);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFriendlyErrorMessage(e));
    }
  }

  Future<bool> assignExecutive({
    required String rfiId,
    required RfiEngineerOption engineer,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final message = await _repository.assignClientPerson({
        'rfi_Id': rfiId,
        'clientUserId': engineer.userId,
        'assignedPersonClient': engineer.name,
        'clientDepartment': engineer.department,
        'email': engineer.email,
      });
      state = state.copyWith(isLoading: false, successMessage: message);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: userFriendlyErrorMessage(e));
      return false;
    }
  }

  void clearState() {
    state = ChangeExecutiveState();
  }
}
