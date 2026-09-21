import 'package:dio/dio.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/core/utils/rfi_log_pdf_paths.dart';

class RfiLogApi {
  final Dio dio;
  RfiLogApi(this.dio);

  Future<List<dynamic>> getAllRfiLogDetails(Map<String, dynamic> body) async {
    final response = await dio.post('api/rfiLog/getAllRfiLogDetails', data: body);
    if (response.data == null || response.data is! List) {
      return [];
    }
    return response.data;
  }

  Future<List<dynamic>> filterListProjects({
    String project = '',
    String contract = '',
  }) async {
    final response = await dio.post(
      'api/rfiLog/filter-list-project',
      data: <String, dynamic>{
        'project': project,
        'contract': contract,
      },
      options: Options(extra: const <String, dynamic>{'silentError': true}),
    );
    return response.data is List ? response.data as List<dynamic> : <dynamic>[];
  }

  Future<List<dynamic>> filterListContracts({
    String project = '',
    String contract = '',
  }) async {
    final response = await dio.post(
      'api/rfiLog/filter-list-contract',
      data: <String, dynamic>{
        'project': project,
        'contract': contract,
      },
      options: Options(extra: const <String, dynamic>{'silentError': true}),
    );
    return response.data is List ? response.data as List<dynamic> : <dynamic>[];
  }

  @Deprecated('Use filterListProjects / filterListContracts')
  Future<Map<String, dynamic>> getFilterList() async {
    final response = await dio.get('api/rfiLog/filter-list');
    return (response.data as Map<String, dynamic>?) ?? {};
  }

  Future<Map<String, dynamic>> getRfiReportDetails(String id) async {
    final response = await dio.get('api/rfiLog/getRfiReportDetails/$id');
    return (response.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> downloadPdf({
    required String rfiId,
    required String txnId,
    required String savePath,
  }) async {
    final paths = RfiLogPdfPaths.downloadPathCandidates(
      rfiId: rfiId,
      txnId: txnId,
    );
    DioException? lastError;
    for (var i = 0; i < paths.length; i++) {
      try {
        await dio.download(
          paths[i],
          savePath,
          options: Options(responseType: ResponseType.bytes),
        );
        return;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404 && i < paths.length - 1) {
          lastError = e;
          continue;
        }
        rethrow;
      }
    }
    if (lastError != null) {
      throw lastError;
    }
  }
}
