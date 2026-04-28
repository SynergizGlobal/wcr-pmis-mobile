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

  Future<Map<String, dynamic>> fetchRailwayZones() async {
    final response = await _dio.get<dynamic>(
      '/projects/api/railwayZones',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchYearList() async {
    final response = await _dio.get<dynamic>(
      '/projects/api/yearList',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchDivisions() async {
    final response = await _dio.get<dynamic>(
      '/projects/api/divisions',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchSections() async {
    final response = await _dio.get<dynamic>(
      '/projects/api/sections',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> addProject(Map<String, dynamic> payload) async {
    final response = await _dio.post<dynamic>(
      '/projects/api/addProject',
      data: payload,
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> updateProject({
    required String projectId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _dio.put<dynamic>(
      '/projects/api/updateProject/$projectId',
      data: payload,
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> deleteProject(String projectId) async {
    final response = await _dio.delete<dynamic>(
      '/projects/api/deleteProject/$projectId',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchAiReport(String query) async {
    final response = await _dio.post<dynamic>(
      '/api/ai/report',
      data: <String, dynamic>{'query': query},
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
    if (data is String) {
      final String message = data.trim();
      final String normalized = message.toLowerCase();
      final bool success =
          normalized.contains('success') ||
          normalized.contains('updated') ||
          normalized.contains('added') ||
          normalized.contains('deleted');
      return <String, dynamic>{
        'message': message,
        'success': success,
      };
    }
    return <String, dynamic>{};
  }
}

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  return DashboardRemoteDataSource(ref.watch(dioProvider));
});
