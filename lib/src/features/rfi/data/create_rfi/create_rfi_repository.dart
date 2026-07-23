import 'create_rfi_api.dart';
import '../../domain/create_rfi/dropdown_item.dart';

class CreateRfiRepository {
  final CreateRfiApi api;
  CreateRfiRepository(this.api);

  List<DropdownItem> _dedupeDropdownItems(List<DropdownItem> items) {
    final seen = <String>{};
    final result = <DropdownItem>[];
    for (final item in items) {
      final key = item.id.trim().isNotEmpty ? item.id.trim() : item.name.trim();
      if (seen.add(key)) {
        result.add(item);
      }
    }
    return result;
  }

  List<DropdownItem> _mapToDropdownItems(List<dynamic> data) {
    if (data.isEmpty) return [];

    if (data.first is String) {
      return _dedupeDropdownItems(
        data.map((str) => DropdownItem(id: str, name: str)).toList(),
      );
    }

    return _dedupeDropdownItems(data.map((dynamic item) {
      final json = item as Map<String, dynamic>;

      final idValue = json['id'] ??
          json['userId'] ??
          json['user_id'] ??
          json['projectId'] ??
          json['workId'] ??
          json['contractIdFk'] ?? // Corrected user key
          json['structureTypeId'] ??
          json['structureId'] ??
          json['componentId'] ??
          json['elementId'] ??
          json['activityId'] ??
          json['rfiDescription'] ??
          json['username'] ??
          json['login'] ??
          json['emailId'] ??
          json['email'] ??
          '';

      final nameValue = json['name'] ??
          json['userName'] ??
          json['user_name'] ??
          json['fullName'] ??
          json['fullname'] ??
          json['displayName'] ??
          json['projectName'] ??
          json['workName'] ??
          json['contractShortName'] ?? // Corrected user key
          json['structureType'] ??
          json['structure'] ??
          json['component'] ??
          json['element'] ??
          json['activity'] ??
          json['rfiDescription'] ??
          json['username'] ??
          json['login'] ??
          json['emailId'] ??
          json['email'] ??
          '';

      List<String>? enclosures;
      if (json['enclosures'] != null && json['enclosures'] is List) {
        enclosures =
            (json['enclosures'] as List).map((e) => e.toString()).toList();
      }

      int? p6ActivityIdFk;
      final rawP6 = json['p6ActivityIdFk'] ??
          json['p6ActivityId'] ??
          json['p6_activity_id_fk'];
      if (rawP6 != null) {
        if (rawP6 is int) {
          p6ActivityIdFk = rawP6;
        } else if (rawP6 is num) {
          p6ActivityIdFk = rawP6.toInt();
        } else {
          p6ActivityIdFk = int.tryParse(rawP6.toString());
        }
      }

      final String? pmisCalcFk =
          json['pmisCalcFk']?.toString() ?? json['pmis_calc_fk']?.toString();

      final String id = idValue.toString().trim();
      String name = nameValue.toString().trim();
      if (name.isEmpty && id.isNotEmpty) {
        name = id;
      }

      return DropdownItem(
        id: id,
        name: name,
        enclosures: enclosures,
        p6ActivityIdFk: p6ActivityIdFk,
        pmisCalcFk: pmisCalcFk,
      );
    }).toList());
  }

  Future<List<DropdownItem>> getProjectNames() async {
    final response = await api.getProjectNames();
    return _mapToDropdownItems(response);
  }

  Future<List<DropdownItem>> getWorkNames(String projectId) async {
    final response = await api.getWorkNames(projectId);
    return _mapToDropdownItems(response);
  }

  Future<List<DropdownItem>> getContractNamesForProject(String projectId) async {
    final response = await api.getContractNamesForProject(projectId);
    return _mapToDropdownItems(response);
  }

  Future<List<DropdownItem>> getStructureTypes(String contractId) async {
    final response = await api.getStructureTypes(contractId);
    return _mapToDropdownItems(response);
  }

  Future<List<DropdownItem>> getStructures(
      String structureType, String contractId) async {
    final response = await api.getStructures(structureType, contractId);
    return _mapToDropdownItems(response);
  }

  Future<List<DropdownItem>> getComponents(
      String structureType, String contractId, String structureName) async {
    final response =
        await api.getComponents(structureType, contractId, structureName);
    return _mapToDropdownItems(response);
  }

  Future<List<DropdownItem>> getElements(String contractId,
      String structureType, String structureName, String componentName) async {
    final response = await api.getElements(
        contractId, structureType, structureName, componentName);
    return _mapToDropdownItems(response);
  }

  Future<List<DropdownItem>> getActivities(String structureType,
      String structureName, String componentName, String componentId) async {
    final response = await api.getActivities(
        structureType, structureName, componentName, componentId);
    return _mapToDropdownItems(response);
  }

  Future<List<DropdownItem>> getRfiDescriptions(String activityName) async {
    final response = await api.getRfiDescriptions(activityName);
    return _mapToDropdownItems(response);
  }

  Future<List<DropdownItem>> getRegularUsers() async {
    final response = await api.getRegularUsers();
    return _mapToDropdownItems(response);
  }

  Future<dynamic> submitRfi(Map<String, dynamic> data) async {
    return await api.submitRfi(data);
  }
}
