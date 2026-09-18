import 'package:dio/dio.dart';

class ValidationApi {
  final Dio dio;
  ValidationApi(this.dio);

  Future<List<dynamic>> getRfiValidations() async {
    final response = await dio.get("api/validation/getRfiValidations");
    return response.data is List ? response.data as List<dynamic> : <dynamic>[];
  }

  Future<List<dynamic>> filterProjects({
    String project = '',
    String contract = '',
  }) async {
    final response = await dio.post(
      'api/validation/filter-project',
      data: <String, dynamic>{
        'project': project,
        'contract': contract,
      },
      options: Options(extra: const <String, dynamic>{'silentError': true}),
    );
    return response.data is List ? response.data as List<dynamic> : <dynamic>[];
  }

  Future<List<dynamic>> filterContracts({
    String project = '',
    String contract = '',
  }) async {
    final response = await dio.post(
      'api/validation/filter-contract',
      data: <String, dynamic>{
        'project': project,
        'contract': contract,
      },
      options: Options(extra: const <String, dynamic>{'silentError': true}),
    );
    return response.data is List ? response.data as List<dynamic> : <dynamic>[];
  }

  Future<Map<String, dynamic>> getRfiReportDetail(int id) async {
    final response = await dio.get("api/validation/getRfiReportDetail/$id");
    return response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};
  }

  Future<void> validateRfi(Map<String, dynamic> data) async {
    final formData = FormData.fromMap(data);
    await dio.post(
      "api/validation/validate",
      data: formData,
      options: Options(extra: {'silentError': true}),
    );
  }
}
