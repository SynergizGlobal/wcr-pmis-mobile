import 'package:dio/dio.dart';

class CreateRfiApi {
  final Dio dio;
  CreateRfiApi(this.dio);

  Future<List<dynamic>> getProjectNames() async {
    final response = await dio.get("rfi/projectNames");
    return response.data;
  }

  Future<List<dynamic>> getWorkNames(String projectId) async {
    final response = await dio
        .get("rfi/workNames", queryParameters: {"projectId": projectId});
    return response.data;
  }

  Future<List<dynamic>> getContractNamesForProject(String projectId) async {
    final response = await dio.get(
      'rfi/contractNames',
      queryParameters: <String, String>{'projectId': projectId},
    );
    return response.data;
  }

  Future<List<dynamic>> getStructureTypes(String contractId) async {
    final response = await dio
        .get("rfi/structureType", queryParameters: {"contractId": contractId});
    return response.data;
  }

  Future<List<dynamic>> getStructures(
      String structureType, String contractId) async {
    final response = await dio.get("rfi/structure", queryParameters: {
      "structureType": structureType,
      "contractId": contractId,
    });
    return response.data;
  }

  Future<List<dynamic>> getComponents(
      String structureType, String contractId, String structureName) async {
    final response = await dio.get("rfi/component", queryParameters: {
      "structureType": structureType,
      "contractId": contractId,
      "structure": structureName,
    });
    return response.data;
  }

  Future<List<dynamic>> getElements(String contractId, String structureType,
      String structureName, String componentName) async {
    final response = await dio.get("rfi/element", queryParameters: {
      "contractId": contractId,
      "structureType": structureType,
      "structure": structureName,
      "component": componentName,
    });
    return response.data;
  }

  // user typo in prompt: "component_id={id}" - I will assume they meant componentId
  Future<List<dynamic>> getActivities(String structureType,
      String structureName, String componentName, String componentId) async {
    final response = await dio.get("rfi/activityNames", queryParameters: {
      "structureType": structureType,
      "structure": structureName,
      "component": componentName,
      "component_id": componentId,
    });
    return response.data;
  }

  Future<List<dynamic>> getRfiDescriptions(String activityName) async {
    final response = await dio.get("rfi/rfi-descriptions", queryParameters: {
      "activity": activityName,
    });
    return response.data;
  }

  Future<List<dynamic>> getRegularUsers() async {
    final response = await dio.get("rfi/regularUsers");
    return response.data;
  }

  /// Uses [silentError] so the global Dio interceptor does not show a second
  /// dialog — the create-RFI flow handles errors once in the UI.
  Future<dynamic> submitRfi(Map<String, dynamic> data) async {
    final response = await dio.post(
      "rfi/create",
      data: data,
      options: Options(
        extra: const <String, dynamic>{'silentError': true},
      ),
    );
    return response.data;
  }
}
