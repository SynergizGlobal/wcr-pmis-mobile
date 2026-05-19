import 'package:dio/dio.dart';

class AssignExecutiveApi {
  final Dio dio;
  AssignExecutiveApi(this.dio);

  Future<List<dynamic>> getAssignedExecutiveLogs() async {
    final response = await dio.get("/rfi/getAssinedExecutiveLogs");
    return response.data;
  }

  Future<List<dynamic>> getExecutivesList(String contractId) async {
    final response = await dio.get(
      "/rfi/getExecutivesList",
      queryParameters: {"contractId": contractId},
    );
    return response.data;
  }

  Future<List<dynamic>> getStructures(
      String contractId, String structureType) async {
    final response = await dio.get(
      "/rfi/structure",
      queryParameters: {
        "contractId": contractId,
        "structureType": structureType,
      },
    );
    return response.data;
  }

  Future<dynamic> assignExecutive(Map<String, dynamic> payload) async {
    final response = await dio.post("/rfi/assign-executive", data: payload);
    return response.data;
  }

  Future<dynamic> deleteAssignment(int id) async {
    final response = await dio.post("/rfi/assignExecutive/delete/$id");
    return response.data;
  }
}
