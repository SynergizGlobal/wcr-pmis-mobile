import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/data/datasources/rfi_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_dropdown_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_list_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_status_counts.dart';

final rfiRepositoryProvider = Provider<RfiRepository>((ref) {
  return RfiRepository(ref.watch(rfiRemoteDataSourceProvider));
});

class RfiDashboardSnapshot {
  const RfiDashboardSnapshot({
    required this.statusCounts,
    required this.createdCount,
  });

  final RfiStatusCounts statusCounts;
  final int createdCount;
}

class RfiRepository {
  const RfiRepository(this._remote);

  final RfiRemoteDataSource _remote;

  Future<RfiDashboardSnapshot> fetchDashboard() async {
    final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
      _remote.fetchStatusCounts(),
      _remote.fetchRfiCount(),
    ]);
    return RfiDashboardSnapshot(
      statusCounts: results[0]! as RfiStatusCounts,
      createdCount: results[1]! as int,
    );
  }

  Future<List<RfiListItem>> fetchRfiList({String? requestedFormName}) =>
      _remote.fetchRfiList(requestedFormName: requestedFormName);

  Future<Map<String, dynamic>> fetchRfiDetail(int id) =>
      _remote.fetchRfiDetail(id);

  Future<void> deleteRfi(int id, String description) =>
      _remote.deleteRfi(id, description);

  Future<void> closeRfi(int id) => _remote.closeRfi(id);

  Future<List<RfiDropdownItem>> fetchCreateProjects() =>
      _remote.fetchProjectNames();

  Future<List<RfiDropdownItem>> fetchCreateContracts(String projectId) =>
      _remote.fetchContractNamesForProject(projectId);

  Future<List<RfiDropdownItem>> fetchCreateStructureTypes(String contractId) =>
      _remote.fetchStructureTypes(contractId);

  Future<List<RfiDropdownItem>> fetchCreateStructures({
    required String structureType,
    required String contractId,
  }) =>
      _remote.fetchStructures(
        structureType: structureType,
        contractId: contractId,
      );

  Future<List<RfiDropdownItem>> fetchCreateComponents({
    required String structureType,
    required String contractId,
    required String structureName,
  }) =>
      _remote.fetchComponents(
        structureType: structureType,
        contractId: contractId,
        structureName: structureName,
      );

  Future<List<RfiDropdownItem>> fetchCreateElements({
    required String contractId,
    required String structureType,
    required String structureName,
    required String componentName,
  }) =>
      _remote.fetchElements(
        contractId: contractId,
        structureType: structureType,
        structureName: structureName,
        componentName: componentName,
      );

  Future<List<RfiDropdownItem>> fetchCreateActivities({
    required String structureType,
    required String structureName,
    required String componentName,
    required String componentId,
  }) =>
      _remote.fetchActivities(
        structureType: structureType,
        structureName: structureName,
        componentName: componentName,
        componentId: componentId,
      );

  Future<List<RfiDropdownItem>> fetchCreateRfiDescriptions(String activity) =>
      _remote.fetchRfiDescriptions(activity);

  Future<List<RfiDropdownItem>> fetchCreateRepresentatives() =>
      _remote.fetchRegularUsers();

  Future<void> submitCreateRfi(Map<String, dynamic> body) async {
    await _remote.createRfi(body);
  }
}
