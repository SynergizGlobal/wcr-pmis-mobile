import 'package:dio/dio.dart';

class RfiDetailsApi {
  final Dio dio;
  RfiDetailsApi(this.dio);

  Future<Map<String, dynamic>> getRfiDetails(int id) async {
    final response = await dio.get("/rfi/rfi-details/$id");
    return response.data;
  }

  Future<List<dynamic>> getRfiInspections(int id) async {
    final response = await dio.get("/rfi/inspections/$id");
    return response.data;
  }

  Future<List<dynamic>> getEnclosureChecklistItems(String enclosureName, int rfiId) async {
    final response = await dio.get(
      "/api/v1/enclouser/checklist-items",
      queryParameters: {
        'enclosureName': enclosureName,
        'rfiId': rfiId,
      },
    );
    return response.data;
  }
}

