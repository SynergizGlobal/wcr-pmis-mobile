import 'package:dio/dio.dart';

class ChangeExecutiveApi {
  final Dio _dio;

  ChangeExecutiveApi(this._dio);

  Future<Response> getEngineerNames(String userId, String contractId) async {
    return await _dio.get(
      '/api/auth/engineer-names',
      queryParameters: {
        'userId': userId,
        'contractId': contractId,
      },
    );
  }

  Future<Response> assignClientPerson(Map<String, dynamic> payload) async {
    return await _dio.post('/rfi/assign-client-person', data: payload);
  }
}
