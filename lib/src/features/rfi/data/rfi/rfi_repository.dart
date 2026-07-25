import 'rfi_api.dart';
import '../../domain/rfi/status_counts.dart';

class RfiRepository {
  final RfiApi api;
  RfiRepository(this.api);

  Future<StatusCounts> getStatusCounts() async {
    final response = await api.getStatusCounts();
    return StatusCounts.fromJson(response);
  }

  Future<int> getRfiCount() async {
    return api.getRfiCount();
  }

  Future<void> assignClientPerson({
    required String rfiId,
    required String clientUserId,
    required String assignedPersonClient,
    required String clientDepartment,
    required String email,
  }) {
    return api.assignClientPerson(
      rfiId: rfiId,
      clientUserId: clientUserId,
      assignedPersonClient: assignedPersonClient,
      clientDepartment: clientDepartment,
      email: email,
    );
  }

  Future<void> deleteRfi(int id, String description) {
    return api.deleteRfi(id, description);
  }

  Future<void> closeRfi(int id) {
    return api.closeRfi(id);
  }

  Future<List<dynamic>> getProjectNames() {
    return api.getProjectNames();
  }

  Future<List<dynamic>> getWorkNames(String projectId) {
    return api.getWorkNames(projectId);
  }

  Future<List<dynamic>> getContractNames(String workId) {
    return api.getContractNames(workId);
  }
}
