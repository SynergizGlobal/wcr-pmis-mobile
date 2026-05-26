import 'package:dio/dio.dart';

class ValidationApi {
  final Dio dio;
  ValidationApi(this.dio);

  Future<List<dynamic>> getRfiValidations() async {
    final response = await dio.get("api/validation/getRfiValidations");
    return response.data;
  }

  Future<Map<String, dynamic>> getRfiReportDetail(int id) async {
    final response = await dio.get("api/validation/getRfiReportDetail/$id");
    return response.data;
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
