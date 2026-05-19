import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/dio_provider.dart';
import '../../data/inspection/change_executive_api.dart';
import '../auth/auth_provider.dart';
import '../rfi/rfi_provider.dart';

part 'assign_client_person_provider.g.dart';

@riverpod
Future<List<String>> assignExecutiveNames(
    AssignExecutiveNamesRef ref, String contractId) async {
  final Map<String, dynamic>? user = ref.read(authNotifierProvider).value;
  if (user == null) {
    return <String>[];
  }
  final ChangeExecutiveApi api = ChangeExecutiveApi(ref.read(dioProvider));
  final response = await api.getEngineerNames(
    user['userId']?.toString() ?? '',
    contractId,
  );
  final dynamic data = response.data;
  if (data is List) {
    return data.map((dynamic e) => e.toString()).toList();
  }
  return <String>[];
}

@riverpod
class AssignClientPersonController extends _$AssignClientPersonController {
  @override
  FutureOr<void> build() {}

  Future<void> assign(String rfiId, String assignTo) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(rfiRepositoryProvider);
      await repo.assignClientPerson(rfiId, assignTo);
    });
  }
}
