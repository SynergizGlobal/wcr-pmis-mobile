import 'package:dio/dio.dart';

class RfiApi {
  final Dio dio;
  RfiApi(this.dio);

  Future<Map<String, dynamic>> getStatusCounts() async {
    final response = await dio.get("rfi/status-counts");
    return response.data;
  }

  Future<int> getRfiCount() async {
    final response = await dio.get("rfi/rfi-count");
    return response.data as int;
  }

  Future<void> assignClientPerson({
    required String rfiId,
    required String clientUserId,
    required String assignedPersonClient,
    required String clientDepartment,
    required String email,
  }) async {
    await dio.post(
      "rfi/assign-client-person",
      data: {
        "rfi_Id": rfiId,
        "clientUserId": clientUserId,
        "assignedPersonClient": assignedPersonClient,
        "clientDepartment": clientDepartment,
        "email": email,
      },
    );
  }

  Future<void> deleteRfi(int id, String description) async {
    await dio.delete(
      "rfi/delete",
      data: {
        "id": id,
        "description": description,
      },
    );
  }

  Future<void> closeRfi(int id) async {
    await dio.post<dynamic>(
      'rfi/close/rfi/$id',
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );
  }

  Future<List<dynamic>> getProjectNames() async {
    final response = await dio.get("rfi/projectNames");
    return response.data;
  }

  Future<List<dynamic>> getWorkNames(String projectId) async {
    final response = await dio.get("rfi/workNames", queryParameters: {"projectId": projectId});
    return response.data;
  }

  Future<List<dynamic>> getContractNames(String workId) async {
    final response = await dio.get("rfi/contractNames", queryParameters: {"workId": workId});
    return response.data;
  }
}
