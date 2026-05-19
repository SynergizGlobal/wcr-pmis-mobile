import 'package:dio/dio.dart';

class RfiLogApi {
  final Dio dio;
  RfiLogApi(this.dio);

  Future<List<dynamic>> getAllRfiLogDetails(Map<String, dynamic> body) async {
    final response = await dio.post("api/rfiLog/getAllRfiLogDetails", data: body);
    if (response.data == null || response.data is! List) {
      return [];
    }
    return response.data;
  }

  Future<Map<String, dynamic>> getFilterList() async {
    final response = await dio.get("api/rfiLog/filter-list");
    return (response.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getRfiReportDetails(String id) async {
    final response = await dio.get("api/rfiLog/getRfiReportDetails/$id");
    return (response.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> downloadPdf({
    required String rfiId,
    required String txnId,
    required String savePath,
  }) async {
    await dio.download(
      "api/rfiLog/pdf/download/$rfiId/$txnId",
      savePath,
      options: Options(responseType: ResponseType.bytes),
    );
  }
}
