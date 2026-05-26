import 'package:dio/dio.dart';

class InspectionReferenceApi {
  final Dio dio;
  InspectionReferenceApi(this.dio);

  Future<List<dynamic>> getEnclosureNames() async {
    final response = await dio.get(
      "api/v1/enclouser/names",
      queryParameters: {"action": "OPEN"},
    );
    return response.data;
  }

  Future<List<dynamic>> getEnclosureList() async {
    final response = await dio.get("api/v1/enclouser/enclosure_list");
    return response.data;
  }

  Future<List<dynamic>> getEnclosuresByAction() async {
    final response = await dio.get("api/v1/enclouser/by-action");
    return response.data;
  }

  Future<List<dynamic>> getChecklistDetails(int id) async {
    final response = await dio.get("api/v1/enclouser/get/$id");
    return response.data;
  }

  Future<List<dynamic>> getReferenceForm() async {
    final response = await dio.get("rfi/Referenece-Form");
    return response.data;
  }

  Future<dynamic> submitEnclosure(String name, String action) async {
    final response = await dio.post(
      "api/v1/enclouser/submit",
      data: {"encloserName": name, "action": action},
    );
    return response.data;
  }

  Future<dynamic> updateEnclosure(int id, String name, String action) async {
    final response = await dio.put(
      "api/v1/enclouser/updateEnclosureName/$id",
      data: {"encloserName": name, "action": action},
    );
    return response.data;
  }

  Future<dynamic> deleteEnclosure(int id) async {
    final response = await dio.delete(
      "api/v1/enclouser/deleteEncloserName/$id",
    );
    return response.data;
  }


  Future<dynamic> submitChecklistDescription(
      int enclosureId, String description) async {
    final response = await dio.post(
      "api/v1/enclouser/addDesctiption/$enclosureId",
      data: {"checkListDescription": description},
    );
    return response.data;
  }

  Future<dynamic> updateChecklistDescription(
      int checklistId, String description) async {
    final response = await dio.put(
      "api/v1/enclouser/update/$checklistId",
      data: {"checkListDescription": description},
    );
    return response.data;
  }

  Future<dynamic> deleteChecklistDescription(int checklistId) async {
    final response = await dio.delete(
      "api/v1/enclouser/delete/$checklistId",
    );
    return response.data;
  }


  Future<dynamic> submitReferenceForm(
      String activity, String rfiDescription, String enclosures) async {
    final response = await dio.post(
      "rfi/send-data",
      data: {
        "activity": activity,
        "rfiDescription": rfiDescription,
        "enclosures": enclosures,
      },
    );
    return response.data;
  }

  Future<dynamic> updateReferenceForm(
      int id, String activity, String rfiDescription, String enclosures) async {
    final response = await dio.put(
      "rfi/Update/$id",
      data: {
        "activity": activity,
        "rfiDescription": rfiDescription,
        "enclosures": enclosures,
      },
    );
    return response.data;
  }
}
