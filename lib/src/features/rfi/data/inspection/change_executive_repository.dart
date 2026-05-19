import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/dio_provider.dart';
import 'change_executive_api.dart';

final changeExecutiveApiProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return ChangeExecutiveApi(dio);
});

final changeExecutiveRepositoryProvider = Provider((ref) {
  final api = ref.watch(changeExecutiveApiProvider);
  return ChangeExecutiveRepository(api);
});

class ChangeExecutiveRepository {
  final ChangeExecutiveApi _api;

  ChangeExecutiveRepository(this._api);

  Future<List<String>> getEngineerNames(String userId, String contractId) async {
    try {
      final response = await _api.getEngineerNames(userId, contractId);
      if (response.statusCode == 200 && response.data != null) {
        return List<String>.from(response.data);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch engineer names: $e');
    }
  }

  Future<String> assignClientPerson(Map<String, dynamic> payload) async {
    try {
      final response = await _api.assignClientPerson(payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data?.toString() ?? 'Assigned successfully';
      }
      throw Exception('Failed to assign executive');
    } catch (e) {
      throw Exception('Error assigning executive: $e');
    }
  }
}
