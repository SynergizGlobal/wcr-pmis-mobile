import 'package:dio/dio.dart';

class RfiListApi {
  final Dio dio;
  RfiListApi(this.dio);

  Future<List<dynamic>> getRfiDetails() async {
    final response = await dio.get("/rfi/rfi-details");
    return response.data;
  }
}
