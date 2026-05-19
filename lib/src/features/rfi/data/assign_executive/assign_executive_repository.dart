import '../../domain/assign_executive/assign_executive_log.dart';
import '../../domain/create_rfi/dropdown_item.dart';
import '../../domain/executives/executive.dart';
import 'assign_executive_api.dart';

class AssignExecutiveRepository {
  final AssignExecutiveApi api;
  AssignExecutiveRepository(this.api);

  Future<List<AssignExecutiveLog>> getAssignedExecutiveLogs() async {
    final data = await api.getAssignedExecutiveLogs();
    return data.map((json) => AssignExecutiveLog.fromJson(json)).toList();
  }

  Future<List<Executive>> getExecutivesList(String contractId) async {
    final data = await api.getExecutivesList(contractId);
    return data.map((json) => Executive.fromJson(json)).toList();
  }

  Future<List<DropdownItem>> getStructures(
      String contractId, String structureType) async {
    final data = await api.getStructures(contractId, structureType);
    // API returns list of strings
    return data
        .map((item) => DropdownItem(id: item.toString(), name: item.toString()))
        .toList();
  }

  Future<dynamic> assignExecutive(Map<String, dynamic> payload) async {
    return await api.assignExecutive(payload);
  }

  Future<dynamic> deleteAssignment(int id) async {
    return await api.deleteAssignment(id);
  }
}
