import 'package:dio/dio.dart';

class InspectionApi {
  final Dio _dio;

  InspectionApi(this._dio);

  Future<Response> getInspectionDetails() async {
    try {
      final response = await _dio.get('/rfi/rfi-details');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getRfiDetails(int id) async {
    return await _dio.get('/rfi/rfi-details/$id');
  }

  Future<Response> getChecklistItems(String enclosureName, int rfiId) async {
    return await _dio.get(
      '/api/v1/enclouser/checklist-items',
      queryParameters: {
        'enclosureName': enclosureName,
        'rfiId': rfiId,
      },
    );
  }

  Future<Response> getEnclosureDescription(String enclosureName) async {
    return await _dio.get(
      '/api/v1/enclouser/description',
      queryParameters: {'enclosername': enclosureName},
    );
  }

  Future<Response> uploadPdfContractor(FormData data) async {
    return await _dio.post(
      '/rfi/uploadPdfContractor',
      data: data,
      options: Options(extra: {'silentError': true}),
    );
  }

  Future<Response> uploadPdfEngg(FormData data) async {
    return await _dio.post(
      '/rfi/rfi/uploadPdf/Engg',
      data: data,
      options: Options(extra: {'silentError': true}),
    );
  }

  Future<Response> stampPdf(FormData data) async {
    return await _dio.post(
      '/rfi/stampPdfFromXml',
      data: data,
      options: Options(extra: {'silentError': true}),
    );
  }

  Future<Response> stampEnggPdf(FormData data) async {
    return await _dio.post(
      '/rfi/stampEnggPdfFromXml',
      data: data,
      options: Options(extra: {'silentError': true}),
    );
  }

  Future<Response> uploadEnclosure(FormData data) async {
    return await _dio.post('/rfi/upload', data: data);
  }

  Future<Response> uploadSiteImage(FormData data) async {
    return await _dio.post('/rfi/inspection/uploadSiteImage', data: data);
  }

  Future<Response> finalSubmit(FormData data) async {
    return await _dio.post(
      '/rfi/finalSubmit',
      data: data,
      options: Options(extra: {'silentError': true}),
    );
  }

  Future<Response> saveAsDraft(Map<String, dynamic> data) async {
    return await _dio.post('/rfi/inspections/draft', data: data);
  }

  Future<Response> deleteEnclosure(int id) async {
    return await _dio.delete('/rfi/enclosure/files', queryParameters: {'id': id});
  }

  Future<Response> deleteSiteImage({
    required int rfiId,
    required String img,
    required String uploadedBy,
  }) async {
    return await _dio.post(
      '/rfi/delete-site-img',
      queryParameters: {
        'rfiId': rfiId,
        'img': img,
        'uploadedBy': uploadedBy,
      },
    );
  }

  Future<Response> sendForValidation(int rfiId) async {
    return await _dio.post(
      '/api/validation/send-for-validation/$rfiId',
      options: Options(extra: {'silentError': true}),
    );
  }

  Future<Response> saveEnclosureChecklist(FormData data) async {
    return await _dio.post('/rfi/saveChecklist', data: data);
  }

  Future<Response> uploadAttachment(FormData data) async {
    return await _dio.post('/rfi/upload-attachment', data: data);
  }

  Future<Response> uploadTestReport(FormData data) async {
    return await _dio.post('/rfi/uploadPostTestReport', data: data);
  }
}
