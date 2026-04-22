import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/dio_client.dart';

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource(this._dio);

  final Dio _dio;
  static const Duration _dashboardReceiveTimeout = Duration(seconds: 90);
  static const Duration _dashboardConnectTimeout = Duration(seconds: 30);

  Options get _requestOptions => Options(
    receiveTimeout: _dashboardReceiveTimeout,
    connectTimeout: _dashboardConnectTimeout,
  );

  Future<Map<String, dynamic>> fetchProjectTypes() async {
    final response = await _dio.get<dynamic>(
      '/projects/api/projectTypes',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchProjectOverview() async {
    final response = await _dio.get<dynamic>(
      '/projects/api/getProjectList',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchProjectTypeWise() async {
    final response = await _dio.get<dynamic>(
      '/projects/api/getProjectListByType',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchUpdateForms() async {
    final response = await _dio.get<dynamic>(
      '/forms/api/getUpdateForms',
      queryParameters: <String, String>{
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Map<String, dynamic> _normalizeResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is List<dynamic>) {
      return <String, dynamic>{'data': data};
    }
    return <String, dynamic>{};
  }
}

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  return DashboardRemoteDataSource(ref.watch(dioProvider));
});
