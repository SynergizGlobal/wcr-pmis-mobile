import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_engineer_option.dart';

import '../../core/providers/dio_provider.dart';
import '../../data/inspection/change_executive_api.dart';
import '../auth/auth_provider.dart';
import '../rfi/rfi_provider.dart';

part 'assign_client_person_provider.g.dart';

@riverpod
Future<List<RfiEngineerOption>> assignExecutiveNames(
    AssignExecutiveNamesRef ref, String contractId) async {
  final Map<String, dynamic>? user = ref.read(authNotifierProvider).value;
  if (user == null) {
    return const <RfiEngineerOption>[];
  }
  final ChangeExecutiveApi api = ChangeExecutiveApi(ref.read(dioProvider));
  final response = await api.getEngineerNames(
    user['userId']?.toString() ?? '',
    contractId,
  );
  return RfiEngineerOption.parseList(response.data);
}

@riverpod
class AssignClientPersonController extends _$AssignClientPersonController {
  @override
  FutureOr<void> build() {}

  Future<void> assign(String rfiId, RfiEngineerOption engineer) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(rfiRepositoryProvider);
      await repo.assignClientPerson(
        rfiId: rfiId,
        clientUserId: engineer.userId,
        assignedPersonClient: engineer.name,
        clientDepartment: engineer.department,
        email: engineer.email,
      );
    });
  }
}
