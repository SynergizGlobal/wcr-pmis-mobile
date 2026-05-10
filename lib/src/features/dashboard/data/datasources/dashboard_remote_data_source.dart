import 'dart:typed_data';

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

  Future<Map<String, dynamic>> fetchAddIssueFormData() async {
    final response = await _dio.post<dynamic>(
      '/issue/ajax/form/add-issue-form',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchIssueFormContracts({
    required String projectIdFk,
  }) async {
    final response = await _dio.post<dynamic>(
      '/issue/ajax/getContractsListForIssuesForm',
      data: <String, dynamic>{'project_id_fk': projectIdFk},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchIssueFormCategories({
    required String contractTypeFk,
  }) async {
    final response = await _dio.post<dynamic>(
      '/issue/ajax/getIssueCategoryListForIssuesForm',
      data: <String, dynamic>{'contract_type_fk': contractTypeFk},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchIssueFormTitles({
    required String categoryFk,
  }) async {
    final response = await _dio.post<dynamic>(
      '/issue/ajax/getIssueTitlesListForIssuesForm',
      data: <String, dynamic>{'category_fk': categoryFk},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchIssueFormStructures({
    required String contractIdFk,
  }) async {
    final response = await _dio.post<dynamic>(
      '/issue/ajax/getStructureListForIssue',
      data: <String, dynamic>{'contract_id_fk': contractIdFk},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchIssueFormComponents({
    required String contractIdFk,
    required String structure,
  }) async {
    final response = await _dio.post<dynamic>(
      '/issue/ajax/getComponentListForIssue',
      data: <String, dynamic>{
        'contract_id_fk': contractIdFk,
        'structure': structure,
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  /// Add Issue: `POST /issue/add-issue` (multipart). Text fields + optional binary `issueFiles`.
  Future<Map<String, dynamic>> submitAddIssue({
    required Map<String, String> fields,
    List<({Uint8List bytes, String fileName})> files = const [],
  }) async {
    final FormData formData = FormData();
    fields.forEach((String k, String v) {
      formData.fields.add(MapEntry<String, String>(k, v));
    });
    for (final ({Uint8List bytes, String fileName}) p in files) {
      formData.files.add(
        MapEntry<String, MultipartFile>(
          'issueFiles',
          MultipartFile.fromBytes(
            p.bytes,
            filename: p.fileName,
          ),
        ),
      );
    }
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/issue/add-issue',
      data: formData,
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        contentType: null,
      ),
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchUtilityShiftingList({
    int start = 0,
    int length = 10,
    String search = '',
  }) async {
    final response = await _dio.post<dynamic>(
      '/utility-shifting/ajax/getUtilityShiftingList',
      queryParameters: <String, dynamic>{
        'iDisplayStart': start,
        'iDisplayLength': length,
        'sSearch': search,
      },
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchUtilityShiftingUploadsList() async {
    final response = await _dio.post<dynamic>(
      '/utility-shifting/ajax/getUtilityShiftingUploadsList',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchUtilityLocationFilter() async {
    final response = await _dio.post<dynamic>(
      '/utility-shifting/ajax/getLocationListFilter',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchUtilityCategoryFilter() async {
    final response = await _dio.post<dynamic>(
      '/utility-shifting/ajax/getUtilityCategoryListFilter',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchUtilityTypeFilter() async {
    final response = await _dio.post<dynamic>(
      '/utility-shifting/ajax/getUtilityTypeListFilter',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchUtilityStatusFilter() async {
    final response = await _dio.post<dynamic>(
      '/utility-shifting/ajax/getStatusListFilter',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<({Uint8List bytes, String? fileName})>
      downloadUtilityShiftingTemplate() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/utility-shifting/utility-shifting-template',
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        responseType: ResponseType.bytes,
      ),
    );
    final dynamic data = response.data;
    final List<int> raw = data is List<int> ? data : <int>[];
    final String? contentDisposition = response.headers.value('content-disposition');
    final String? fileName = _fileNameFromContentDisposition(contentDisposition);
    return (bytes: Uint8List.fromList(raw), fileName: fileName);
  }

  Future<Map<String, dynamic>> uploadUtilityShiftingTemplate({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'file': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      ),
    });
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/utility-shifting/upload-utility-shifting',
      data: formData,
      options: _requestOptions.copyWith(
        contentType: 'multipart/form-data',
      ),
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchAddUtilityShiftingFormData() async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/utility-shifting/ajax/form/add-utility-shifting',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> submitAddUtilityShifting({
    required Map<String, dynamic> payload,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/utility-shifting/ajax/form/add-utility-shifting',
      data: payload,
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  String? _fileNameFromContentDisposition(String? header) {
    if (header == null || header.trim().isEmpty) {
      return null;
    }
    final RegExpMatch? match = RegExp(
      "filename\\*?=(?:UTF-8''\\s*)?\"?([^\";]+)\"?",
      caseSensitive: false,
    ).firstMatch(header);
    final String? name = match?.group(1);
    if (name == null || name.trim().isEmpty) {
      return null;
    }
    return Uri.decodeFull(name.trim());
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
    // JSON maps are not always typed as Map<String, dynamic> at runtime; normalize
    // keys so callers can read lists/options reliably.
    if (data is Map) {
      final Map<Object?, Object?> map = data as Map<Object?, Object?>;
      return Map<String, dynamic>.fromEntries(
        map.entries.map(
          (MapEntry<Object?, Object?> e) => MapEntry<String, dynamic>(
            e.key.toString(),
            e.value,
          ),
        ),
      );
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
