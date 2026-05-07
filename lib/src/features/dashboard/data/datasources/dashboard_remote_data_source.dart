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

  Future<Map<String, dynamic>> fetchIssuesList({
    String? contractId,
    String? department,
    String? category,
    String? status,
    String? hod,
  }) async {
    final response = await _dio.post<dynamic>(
      '/issue/ajax/getIssuesList',
      data: _issueFilterPayload(
        contractId: contractId,
        department: department,
        category: category,
        status: status,
        hod: hod,
      ),
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchIssueContractsFilter({
    String? contractId,
    String? department,
    String? category,
    String? status,
    String? hod,
  }) async {
    final response = await _dio.post<dynamic>(
      '/issue/ajax/getContractsListFilterInIssue',
      data: _issueFilterPayload(
        contractId: contractId,
        department: department,
        category: category,
        status: status,
        hod: hod,
      ),
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchIssueHodFilter({
    String? contractId,
    String? department,
    String? category,
    String? status,
    String? hod,
  }) async {
    final response = await _dio.post<dynamic>(
      '/issue/ajax/getHODListFilterInIssue',
      data: _issueFilterPayload(
        contractId: contractId,
        department: department,
        category: category,
        status: status,
        hod: hod,
      ),
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchIssueDepartmentsFilter({
    String? contractId,
    String? department,
    String? category,
    String? status,
    String? hod,
  }) async {
    final response = await _dio.post<dynamic>(
      '/issue/ajax/getDepartmentsListFilterInIssue',
      data: _issueFilterPayload(
        contractId: contractId,
        department: department,
        category: category,
        status: status,
        hod: hod,
      ),
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchIssueCategoryFilter({
    String? contractId,
    String? department,
    String? category,
    String? status,
    String? hod,
  }) async {
    final response = await _dio.post<dynamic>(
      '/issue/ajax/getCategoryListFilterInIssue',
      data: _issueFilterPayload(
        contractId: contractId,
        department: department,
        category: category,
        status: status,
        hod: hod,
      ),
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchIssueStatusFilter({
    String? contractId,
    String? department,
    String? category,
    String? status,
    String? hod,
  }) async {
    final response = await _dio.post<dynamic>(
      '/issue/ajax/getStatusListFilterInIssue',
      data: _issueFilterPayload(
        contractId: contractId,
        department: department,
        category: category,
        status: status,
        hod: hod,
      ),
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Map<String, String> _issueFilterPayload({
    String? contractId,
    String? department,
    String? category,
    String? status,
    String? hod,
  }) {
    String valueOrEmpty(String? value) => value?.trim().isNotEmpty == true
        ? value!.trim()
        : '';
    return <String, String>{
      'contract_id_fk': valueOrEmpty(contractId),
      'department_fk': valueOrEmpty(department),
      'category_fk': valueOrEmpty(category),
      'status_fk': valueOrEmpty(status),
      'hod': valueOrEmpty(hod),
    };
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
