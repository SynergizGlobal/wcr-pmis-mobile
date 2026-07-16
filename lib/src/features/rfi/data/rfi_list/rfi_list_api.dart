import 'package:dio/dio.dart';

class RfiListApi {
  final Dio dio;
  RfiListApi(this.dio);

  Future<List<dynamic>> getRfiDetails({String? requestedFormName}) async {
    final response = await dio.get(
      '/rfi/rfi-details',
      queryParameters: requestedFormName == null || requestedFormName.isEmpty
          ? null
          : <String, dynamic>{'requestedFormName': requestedFormName},
    );
    return response.data;
  }
}
