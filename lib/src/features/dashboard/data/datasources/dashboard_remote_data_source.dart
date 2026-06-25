import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/dio_client.dart';

class StructureFormListResponse {
  const StructureFormListResponse({
    required this.rows,
    required this.totalRecords,
  });

  final List<Map<String, dynamic>> rows;
  final int totalRecords;
}

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

  Future<List<Map<String, dynamic>>> fetchReportForms() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/forms/api/getReportForms',
      queryParameters: <String, String>{
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchLandReportProjectList({
    String? categoryFk,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/land-report/project-list',
      queryParameters: <String, dynamic>{
        if (categoryFk != null && categoryFk.trim().isNotEmpty)
          'category_fk': categoryFk.trim(),
      },
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchLandReportTypeList({
    String? projectIdFk,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/land-report/type-list',
      queryParameters: <String, dynamic>{
        if (projectIdFk != null && projectIdFk.trim().isNotEmpty)
          'project_id_fk': projectIdFk.trim(),
      },
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchLandReportSubCategoryList({
    String? projectIdFk,
    String? categoryFk,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/land-report/sub-category-list',
      queryParameters: <String, dynamic>{
        if (projectIdFk != null && projectIdFk.trim().isNotEmpty)
          'project_id_fk': projectIdFk.trim(),
        if (categoryFk != null && categoryFk.trim().isNotEmpty)
          'category_fk': categoryFk.trim(),
      },
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<({Uint8List bytes, String? fileName})> generateLandAcquisitionReport({
    required String projectIdFk,
    required String categoryFk,
    required String laSubCategoryFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/land-report/generate',
      data: <String, dynamic>{
        'project_id_fk': projectIdFk,
        'category_fk': categoryFk,
        'la_sub_category_fk': laSubCategoryFk,
      },
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        responseType: ResponseType.bytes,
      ),
    );
    final dynamic data = response.data;
    final List<int> raw = data is List<int> ? data : <int>[];
    final String? contentDisposition =
        response.headers.value('content-disposition');
    final String? fileName = _fileNameFromContentDisposition(contentDisposition);
    return (bytes: Uint8List.fromList(raw), fileName: fileName);
  }

  Future<Map<String, dynamic>> fetchUtilityReportFilters({
    String? projectIdFk,
    String? executionAgencyFk,
    String? contractIdFk,
    String? hodUserIdFk,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/utility-report',
      queryParameters: <String, dynamic>{
        if (projectIdFk != null && projectIdFk.trim().isNotEmpty)
          'project_id_fk': projectIdFk.trim(),
        if (executionAgencyFk != null && executionAgencyFk.trim().isNotEmpty)
          'execution_agency_fk': executionAgencyFk.trim(),
        if (contractIdFk != null && contractIdFk.trim().isNotEmpty)
          'contract_id_fk': contractIdFk.trim(),
        if (hodUserIdFk != null && hodUserIdFk.trim().isNotEmpty)
          'hod_user_id_fk': hodUserIdFk.trim(),
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchActivitiesExportProjectList() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/activities-export/projects',
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchActivitiesExportContractList({
    String? projectId,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/activities-export/contracts',
      queryParameters: <String, dynamic>{
        if (projectId != null && projectId.trim().isNotEmpty)
          'project_id': projectId.trim(),
      },
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<({Uint8List bytes, String? fileName})> generateContractWiseActivitiesReport({
    required String projectId,
    required String contractIdFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/activities-export/generate',
      data: <String, dynamic>{
        'project_id': projectId,
        'contract_id_fk': contractIdFk,
      },
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        responseType: ResponseType.bytes,
      ),
    );
    return _bytesResponse(response);
  }

  Future<({Uint8List bytes, String? fileName})> generateUtilityShiftingReport({
    required String projectIdFk,
    required String executionAgencyFk,
    required String contractIdFk,
    required String hodUserIdFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/utility-report/generate',
      data: <String, dynamic>{
        'project_id_fk': projectIdFk,
        'execution_agency_fk': executionAgencyFk,
        'contract_id_fk': contractIdFk,
        'hod_user_id_fk': hodUserIdFk,
      },
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        responseType: ResponseType.bytes,
      ),
    );
    final dynamic data = response.data;
    final List<int> raw = data is List<int> ? data : <int>[];
    final String? contentDisposition =
        response.headers.value('content-disposition');
    final String? fileName = _fileNameFromContentDisposition(contentDisposition);
    return (bytes: Uint8List.fromList(raw), fileName: fileName);
  }

  Map<String, dynamic> _issuesReportFilterPayload({
    String? hodUserIdFk,
    String? contractIdFk,
    String? statusFk,
    String? location,
    String? categoryFk,
    String? issueId,
  }) {
    String valueOrEmpty(String? value) =>
        value != null && value.trim().isNotEmpty ? value.trim() : '';
    return <String, dynamic>{
      'hod_user_id_fk': valueOrEmpty(hodUserIdFk),
      'contract_id_fk': valueOrEmpty(contractIdFk),
      'status_fk': valueOrEmpty(statusFk),
      'location': valueOrEmpty(location),
      'category_fk': valueOrEmpty(categoryFk),
      'issue_id': valueOrEmpty(issueId),
    };
  }

  Future<List<Map<String, dynamic>>> _postIssuesReportList(
    String path, {
    String? hodUserIdFk,
    String? contractIdFk,
    String? statusFk,
    String? location,
    String? categoryFk,
    String? issueId,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      path,
      data: _issuesReportFilterPayload(
        hodUserIdFk: hodUserIdFk,
        contractIdFk: contractIdFk,
        statusFk: statusFk,
        location: location,
        categoryFk: categoryFk,
        issueId: issueId,
      ),
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchIssuesReportHodList({
    String? hodUserIdFk,
    String? contractIdFk,
    String? statusFk,
    String? location,
    String? categoryFk,
    String? issueId,
  }) {
    return _postIssuesReportList(
      '/api/issues-report/getHodList',
      hodUserIdFk: hodUserIdFk,
      contractIdFk: contractIdFk,
      statusFk: statusFk,
      location: location,
      categoryFk: categoryFk,
      issueId: issueId,
    );
  }

  Future<List<Map<String, dynamic>>> fetchIssuesReportContractList({
    String? hodUserIdFk,
    String? contractIdFk,
    String? statusFk,
    String? location,
    String? categoryFk,
    String? issueId,
  }) {
    return _postIssuesReportList(
      '/api/issues-report/getContractList',
      hodUserIdFk: hodUserIdFk,
      contractIdFk: contractIdFk,
      statusFk: statusFk,
      location: location,
      categoryFk: categoryFk,
      issueId: issueId,
    );
  }

  Future<List<Map<String, dynamic>>> fetchIssuesReportStatusList({
    String? hodUserIdFk,
    String? contractIdFk,
    String? statusFk,
    String? location,
    String? categoryFk,
    String? issueId,
  }) {
    return _postIssuesReportList(
      '/api/issues-report/status-list',
      hodUserIdFk: hodUserIdFk,
      contractIdFk: contractIdFk,
      statusFk: statusFk,
      location: location,
      categoryFk: categoryFk,
      issueId: issueId,
    );
  }

  Future<List<Map<String, dynamic>>> fetchIssuesReportLocationList({
    String? hodUserIdFk,
    String? contractIdFk,
    String? statusFk,
    String? location,
    String? categoryFk,
    String? issueId,
  }) {
    return _postIssuesReportList(
      '/api/issues-report/location-list',
      hodUserIdFk: hodUserIdFk,
      contractIdFk: contractIdFk,
      statusFk: statusFk,
      location: location,
      categoryFk: categoryFk,
      issueId: issueId,
    );
  }

  Future<List<Map<String, dynamic>>> fetchIssuesReportCategoryList({
    String? hodUserIdFk,
    String? contractIdFk,
    String? statusFk,
    String? location,
    String? categoryFk,
    String? issueId,
  }) {
    return _postIssuesReportList(
      '/api/issues-report/category-list',
      hodUserIdFk: hodUserIdFk,
      contractIdFk: contractIdFk,
      statusFk: statusFk,
      location: location,
      categoryFk: categoryFk,
      issueId: issueId,
    );
  }

  Future<List<Map<String, dynamic>>> fetchIssuesReportTitleList({
    String? hodUserIdFk,
    String? contractIdFk,
    String? statusFk,
    String? location,
    String? categoryFk,
    String? issueId,
  }) {
    return _postIssuesReportList(
      '/api/issues-report/title-list',
      hodUserIdFk: hodUserIdFk,
      contractIdFk: contractIdFk,
      statusFk: statusFk,
      location: location,
      categoryFk: categoryFk,
      issueId: issueId,
    );
  }

  Future<({Uint8List bytes, String? fileName})> generatePendingIssuesReport({
    required String hodUserIdFk,
    required String contractIdFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/issues-report/generate',
      data: <String, dynamic>{
        'hod_user_id_fk': hodUserIdFk,
        'contract_id_fk': contractIdFk,
      },
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        responseType: ResponseType.bytes,
      ),
    );
    return _bytesResponse(response);
  }

  Future<({Uint8List bytes, String? fileName})> fetchIssuesSummaryReport({
    String scope = 'ALL',
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/issues-report/issues-summary-report/$scope',
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        responseType: ResponseType.bytes,
      ),
    );
    return _bytesResponse(response);
  }

  Future<({Uint8List bytes, String? fileName})> generateIssueDetailsReport({
    required String hodUserIdFk,
    required String contractIdFk,
    required String statusFk,
    required String location,
    required String categoryFk,
    required String issueId,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/issues-details-report/generate',
      data: <String, dynamic>{
        'hod_user_id_fk': hodUserIdFk,
        'contract_id_fk': contractIdFk,
        'status_fk': statusFk,
        'location': location,
        'category_fk': categoryFk,
        'issue_id': issueId,
      },
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        responseType: ResponseType.bytes,
      ),
    );
    return _bytesResponse(response);
  }

  ({Uint8List bytes, String? fileName}) _bytesResponse(Response<dynamic> response) {
    final dynamic data = response.data;
    final List<int> raw = data is List<int> ? data : <int>[];
    final String? contentDisposition =
        response.headers.value('content-disposition');
    final String? fileName = _fileNameFromContentDisposition(contentDisposition);
    return (bytes: Uint8List.fromList(raw), fileName: fileName);
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

  Future<List<Map<String, dynamic>>> fetchProjectsDropdown() async {
    final response = await _dio.get<dynamic>(
      '/projects/api/getProjects',
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchAllProjectStructureSummaries() async {
    final response = await _dio.get<dynamic>(
      '/structures/allProjectSummaries',
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<String>> fetchStructureTypes() async {
    final response = await _dio.get<dynamic>(
      '/structures/types',
      options: _requestOptions,
    );
    final dynamic raw = response.data;
    if (raw is List) {
      return raw.map((dynamic item) => item.toString()).toList();
    }
    return _normalizeListResponse(raw).map((Map<String, dynamic> row) {
      return row.values.first?.toString() ?? '';
    }).where((String value) => value.isNotEmpty).toList();
  }

  Future<Map<String, dynamic>> fetchProjectStructureChainage(
    String projectId,
  ) async {
    final response = await _dio.get<dynamic>(
      '/structures/project-chainage/${Uri.encodeComponent(projectId)}',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchStructuresForProject(String projectId) async {
    final response = await _dio.get<dynamic>(
      '/structures/full/${Uri.encodeComponent(projectId)}',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> saveOrUpdateStructures(
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.post<dynamic>(
      '/structures/saveOrUpdate',
      data: payload,
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> deleteStructureRow(String structureId) async {
    final response = await _dio.delete<dynamic>(
      '/structures/${Uri.encodeComponent(structureId)}',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> deleteStructureType({
    required String projectId,
    required String type,
  }) async {
    final response = await _dio.delete<dynamic>(
      '/structures/type',
      queryParameters: <String, String>{
        'projectId': projectId,
        'type': type,
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchStructureFormContractFilter({
    String structureTypeFk = '',
    String workStatusFk = '',
  }) async {
    final response = await _dio.get<dynamic>(
      '/ajax/getContractsFilterListInStructure',
      queryParameters: <String, String>{
        'structure_type_fk': structureTypeFk,
        'work_status_fk': workStatusFk,
      },
      options: _requestOptions,
    );
    return _parseListOfMaps(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchStructureFormStructureTypeFilter({
    String contractIdFk = '',
    String workStatusFk = '',
  }) async {
    final response = await _dio.get<dynamic>(
      '/ajax/getStructureTypeListForFilter',
      queryParameters: <String, String>{
        'contract_id_fk': contractIdFk,
        'work_status_fk': workStatusFk,
      },
      options: _requestOptions,
    );
    return _parseListOfMaps(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchStructureFormWorkStatusFilter({
    String contractIdFk = '',
    String structureTypeFk = '',
  }) async {
    final response = await _dio.get<dynamic>(
      '/ajax/getWorkStatusListInStructure',
      queryParameters: <String, String>{
        'contract_id_fk': contractIdFk,
        'structure_type_fk': structureTypeFk,
      },
      options: _requestOptions,
    );
    return _parseListOfMaps(response.data);
  }

  Future<StructureFormListResponse> fetchStructureFormList({
    int start = 0,
    int length = 10,
    String search = '',
    String? contractIdFk,
    String? structureTypeFk,
    String? workStatusFk,
  }) async {
    final Map<String, dynamic> queryParameters = <String, dynamic>{
      'iDisplayStart': start,
      'iDisplayLength': length,
      'sSearch': search,
    };
    if (contractIdFk != null && contractIdFk.isNotEmpty) {
      queryParameters['contract_id_fk'] = contractIdFk;
    }
    if (structureTypeFk != null && structureTypeFk.isNotEmpty) {
      queryParameters['structure_type_fk'] = structureTypeFk;
    }
    if (workStatusFk != null && workStatusFk.isNotEmpty) {
      queryParameters['work_status_fk'] = workStatusFk;
    }
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/ajax/getStructuresList',
      queryParameters: queryParameters,
      options: _requestOptions,
    );
    final Map<String, dynamic> payload = _unwrapDataTablesMap(response.data);
    final List<Map<String, dynamic>> rows = _extractAaDataRows(payload);
    final int totalRecords = _extractDataTablesTotal(payload, rows.length);
    return StructureFormListResponse(
      rows: rows,
      totalRecords: totalRecords,
    );
  }

  Future<Map<String, dynamic>> fetchStructureWorkForm({
    required String structureId,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/get-structure-form',
      queryParameters: <String, String>{
        'structure_id': structureId,
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchContractsListForStructureFormProject({
    required String projectIdFk,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/ajax/getContractsListForStructureFrom',
      queryParameters: <String, String>{
        'project_id_fk': projectIdFk,
      },
      options: _requestOptions,
    );
    return _parseListOfMaps(response.data);
  }

  Future<Map<String, dynamic>> submitUpdateStructureWorkForm({
    required List<MapEntry<String, String>> fields,
    List<({Uint8List bytes, String fileName})> structureFiles =
        const <({Uint8List bytes, String fileName})>[],
  }) async {
    final FormData formData = FormData();
    formData.fields.addAll(fields);
    for (final ({Uint8List bytes, String fileName}) file in structureFiles) {
      formData.files.add(
        MapEntry<String, MultipartFile>(
          'structureFiles',
          MultipartFile.fromBytes(
            file.bytes,
            filename: file.fileName,
          ),
        ),
      );
    }
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/update-structure-form',
      data: formData,
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        contentType: null,
      ),
    );
    return _normalizeResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchContractorsList() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/contractors',
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<Map<String, dynamic>> addContractor(
    Map<String, dynamic> payload,
  ) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/contractors',
      data: payload,
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> updateContractor({
    required String contractorId,
    required Map<String, dynamic> payload,
  }) async {
    final Response<dynamic> response = await _dio.put<dynamic>(
      '/contractors/${Uri.encodeComponent(contractorId)}',
      data: payload,
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchContractsList({
    String? designation,
    String? dyHodDesignation,
    String? contractorIdFk,
    String? contractStatus,
    String? contractStatusFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/contract/ajax/getContracts',
      data: _contractFilterPayload(
        designation: designation,
        dyHodDesignation: dyHodDesignation,
        contractorIdFk: contractorIdFk,
        contractStatus: contractStatus,
        contractStatusFk: contractStatusFk,
      ),
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchContractHodFilter({
    String? designation,
    String? dyHodDesignation,
    String? contractorIdFk,
    String? contractStatus,
    String? contractStatusFk,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/contract/ajax/getDesignationsFilterListInContract',
      queryParameters: _contractFilterQueryParams(
        designation: designation,
        dyHodDesignation: dyHodDesignation,
        contractorIdFk: contractorIdFk,
        contractStatus: contractStatus,
        contractStatusFk: contractStatusFk,
        includeDesignation: false,
      ),
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchContractDyHodFilter({
    String? designation,
    String? dyHodDesignation,
    String? contractorIdFk,
    String? contractStatus,
    String? contractStatusFk,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/contract/ajax/getDyHODDesignationsFilterListInContract',
      queryParameters: _contractFilterQueryParams(
        designation: designation,
        dyHodDesignation: dyHodDesignation,
        contractorIdFk: contractorIdFk,
        contractStatus: contractStatus,
        contractStatusFk: contractStatusFk,
        includeDyHodDesignation: false,
      ),
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchContractContractorsFilter({
    String? designation,
    String? dyHodDesignation,
    String? contractorIdFk,
    String? contractStatus,
    String? contractStatusFk,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/contract/ajax/getContractorsFilterListInContract',
      queryParameters: _contractFilterQueryParams(
        designation: designation,
        dyHodDesignation: dyHodDesignation,
        contractorIdFk: contractorIdFk,
        contractStatus: contractStatus,
        contractStatusFk: contractStatusFk,
        includeContractorIdFk: false,
      ),
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchContractStatusFilter({
    String? designation,
    String? dyHodDesignation,
    String? contractorIdFk,
    String? contractStatus,
    String? contractStatusFk,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/contract/ajax/getContractStatusFilterListInContract',
      queryParameters: _contractFilterQueryParams(
        designation: designation,
        dyHodDesignation: dyHodDesignation,
        contractorIdFk: contractorIdFk,
        contractStatus: contractStatus,
        contractStatusFk: contractStatusFk,
        includeContractStatus: false,
      ),
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchContractWorkStatusFilter({
    String? designation,
    String? dyHodDesignation,
    String? contractorIdFk,
    String? contractStatus,
    String? contractStatusFk,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/contract/ajax/getStatusFilterListInContract',
      queryParameters: _contractFilterQueryParams(
        designation: designation,
        dyHodDesignation: dyHodDesignation,
        contractorIdFk: contractorIdFk,
        contractStatus: contractStatus,
        contractStatusFk: contractStatusFk,
        includeContractStatusFk: false,
      ),
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchAddContractFormData() async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/contract/add-contract-form',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchEditContractFormData({
    required String contractId,
  }) async {
    final String trimmedId = contractId.trim();
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/contract/add-contract-form',
      data: <String, dynamic>{'contract_id': trimmedId},
      options: _requestOptions,
    );
    final Map<String, dynamic> data = _normalizeResponse(response.data);
    if (_contractFormHasRecord(data, trimmedId)) {
      return data;
    }

    final Response<dynamic> getResponse = await _dio.get<dynamic>(
      '/contract/add-contract-form',
      queryParameters: <String, String>{'contract_id': trimmedId},
      options: _requestOptions,
    );
    return _normalizeResponse(getResponse.data);
  }

  bool _contractFormHasRecord(Map<String, dynamic> data, String contractId) {
    final dynamic statusRaw = data['contract_Status'] ?? data['contractStatus'];
    if (statusRaw is! List) {
      return false;
    }
    for (final dynamic item in statusRaw) {
      if (item is! Map) {
        continue;
      }
      final Map<Object?, Object?> map = item as Map<Object?, Object?>;
      final String id = _stringValue(map['contract_id'] ?? map['contract_id_fk']);
      if (id == contractId) {
        return true;
      }
      final String name = _stringValue(map['contract_name']);
      if (name.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  String _stringValue(dynamic raw) {
    if (raw == null) {
      return '';
    }
    final String value = raw.toString().trim();
    if (value.isEmpty || value.toLowerCase() == 'null') {
      return '';
    }
    return value;
  }

  Future<List<Map<String, dynamic>>> fetchContractWorkStatusForForm({
    required String contractAwarded,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/contract/ajax/getContractStatusLIstFormContractFom',
      queryParameters: <String, String>{
        'contract_status': contractAwarded,
      },
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchContractExecutivesForDepartment({
    required String departmentFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/contract/ajax/getExecutivesListForContractForm',
      data: <String, dynamic>{'department_fk': departmentFk},
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<Map<String, dynamic>> submitAddContract(
    Map<String, dynamic> payload,
  ) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/contract/add-contract',
      data: _contractPayloadFormData(payload),
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        contentType: null,
      ),
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> submitUpdateContract(
    Map<String, dynamic> payload,
  ) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/contract/update-contract',
      data: _contractPayloadFormData(payload),
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        contentType: null,
      ),
    );
    return _normalizeResponse(response.data);
  }

  FormData _contractPayloadFormData(Map<String, dynamic> payload) {
    final FormData formData = FormData();
    formData.files.add(
      MapEntry<String, MultipartFile>(
        'payload',
        MultipartFile.fromString(
          jsonEncode(payload),
          filename: 'blob',
          contentType: DioMediaType.parse('application/json'),
        ),
      ),
    );
    return formData;
  }

  Future<Map<String, dynamic>> fetchAiReport(String query) async {
    final response = await _dio.post<dynamic>(
      '/api/ai/report',
      data: <String, dynamic>{'query': query},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchDailyProgress({
    required String projectId,
    required String date,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/execution/daily-progress',
      queryParameters: <String, String>{
        'projectId': projectId,
        'date': date,
      },
      options: _requestOptions,
    );
    return _extractRowList(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchSitePhotos({
    required String projectId,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/execution/site-photos-display',
      queryParameters: <String, String>{'projectId': projectId},
      options: _requestOptions,
    );
    return _extractRowList(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchProjectProgress({
    required String projectId,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/execution/progress',
      queryParameters: <String, String>{'project_id': projectId},
      options: _requestOptions,
    );
    return _extractRowList(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchProgressTableData({
    required String projectId,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/progresstable/data/${Uri.encodeComponent(projectId.trim())}',
      options: _requestOptions,
    );
    if (response.data is List<dynamic>) {
      return _extractRowList(response.data);
    }
    return _normalizeListResponse(response.data);
  }

  Future<Uint8List> fetchStructurePhotoBytes(String fileName) async {
    final String trimmed = fileName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Photo file name is required.');
    }
    final Response<List<int>> response = await _dio.get<List<int>>(
      '/STRUCTURE_FILES/${Uri.encodeComponent(trimmed)}',
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
      ),
    );
    final List<int>? bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Empty photo response for $trimmed');
    }
    return Uint8List.fromList(bytes);
  }

  List<Map<String, dynamic>> _extractRowList(dynamic data) {
    if (data is List<dynamic>) {
      return data.whereType<Map>().map(_mapRow).toList();
    }
    final Map<String, dynamic> normalized = _normalizeResponse(data);
    final dynamic payload = normalized['data'] ?? normalized['result'];
    if (payload is List<dynamic>) {
      return payload.whereType<Map>().map(_mapRow).toList();
    }
    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _mapRow(Map row) {
    return row.map(
      (dynamic key, dynamic value) => MapEntry(key.toString(), value),
    );
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

  Future<Map<String, dynamic>> fetchIssueForEdit({
    required String issueId,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/issue/ajax/form/get-issue/get-issue',
      data: <String, dynamic>{'issue_id': issueId},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> submitUpdateIssue({
    required Map<String, String> fields,
  }) async {
    final FormData formData = FormData();
    fields.forEach((String k, String v) {
      formData.fields.add(MapEntry<String, String>(k, v));
    });
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/issue/update-issue',
      data: formData,
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        contentType: null,
      ),
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionList({
    Map<String, dynamic> filters = const <String, dynamic>{},
  }) async {
    final response = await _dio.post<dynamic>(
      '/quality-inspection/get-inspection-list',
      data: filters,
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionProjectFilter() async {
    final response = await _dio.post<dynamic>(
      '/quality-inspection/get-project-filter',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionSectionFilter() async {
    final response = await _dio.post<dynamic>(
      '/quality-inspection/get-section-filter',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionContractFilter() async {
    final response = await _dio.post<dynamic>(
      '/quality-inspection/get-contract-filter',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionStructureTypeFilter() async {
    final response = await _dio.post<dynamic>(
      '/quality-inspection/get-structure-type-filter',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionStructureFilter() async {
    final response = await _dio.post<dynamic>(
      '/quality-inspection/get-structure-filter',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionDropdownProjects() async {
    final response = await _dio.get<dynamic>(
      '/quality-inspection/dropdown-projects',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionDropdownSections() async {
    final response = await _dio.get<dynamic>(
      '/quality-inspection/dropdown-sections',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionDropdownContracts({
    required String projectIdFk,
  }) async {
    final response = await _dio.get<dynamic>(
      '/quality-inspection/dropdown-contracts',
      queryParameters: <String, String>{'projectIdFk': projectIdFk},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionDropdownStructureTypes({
    required String projectIdFk,
  }) async {
    final response = await _dio.get<dynamic>(
      '/quality-inspection/dropdown-structure-types',
      queryParameters: <String, String>{'projectIdFk': projectIdFk},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionDropdownStructures({
    required String projectIdFk,
    required String structureTypeFk,
  }) async {
    final response = await _dio.get<dynamic>(
      '/quality-inspection/dropdown-structures',
      queryParameters: <String, String>{
        'projectIdFk': projectIdFk,
        'structureTypeFk': structureTypeFk,
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionDropdownItems({
    required String structureTypeFk,
  }) async {
    final response = await _dio.get<dynamic>(
      '/quality-inspection/dropdown-items',
      queryParameters: <String, String>{'structureTypeFk': structureTypeFk},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionDropdownInspectionTypes() async {
    final response = await _dio.get<dynamic>(
      '/quality-inspection/dropdown-inspection-types',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionDropdownCategories() async {
    final response = await _dio.get<dynamic>(
      '/quality-inspection/dropdown-categories',
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionDropdownSubCategories({
    required String categoryIdFk,
  }) async {
    final response = await _dio.get<dynamic>(
      '/quality-inspection/dropdown-sub-categories',
      queryParameters: <String, String>{'categoryIdFk': categoryIdFk},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionTestParameters({
    required String itemIdFk,
    required String categoryIdFk,
    required String subCategoryIdFk,
  }) async {
    final response = await _dio.get<dynamic>(
      '/quality-inspection/test-parameters',
      queryParameters: <String, String>{
        'itemIdFk': itemIdFk,
        'categoryIdFk': categoryIdFk,
        'subCategoryIdFk': subCategoryIdFk,
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchQualityInspectionView({
    required String inspectionId,
  }) async {
    final response = await _dio.get<dynamic>(
      '/quality-inspection/inspection-view/$inspectionId',
      queryParameters: <String, String>{
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> submitQualityInspectionSaveSubmit({
    required FormData formData,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/quality-inspection/save-submit',
      data: formData,
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        contentType: null,
      ),
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchCorrespondenceFilterData({
    int draw = 1,
    int start = 0,
    int length = 10,
    Map<String, dynamic> columnFilters = const <String, dynamic>{
      '-1': <String>['send', 'Send'],
    },
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/correspondence/filter-data',
      data: <String, dynamic>{
        'draw': draw,
        'start': start,
        'length': length,
        'columnFilters': columnFilters,
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchDmsProjectNames() async {
    final response = await _dio.get<dynamic>(
      '/projects/get-project-name',
      queryParameters: <String, String>{
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      options: _requestOptions,
    );
    return _parseListOfMaps(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchDmsContractNames() async {
    final response = await _dio.get<dynamic>(
      '/contract/get-contract-name',
      queryParameters: <String, String>{
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      options: _requestOptions,
    );
    return _parseListOfMaps(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchDmsDepartments() async {
    final response = await _dio.get<dynamic>(
      '/api/departments/get',
      queryParameters: <String, String>{
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      options: _requestOptions,
    );
    return _parseListOfMaps(response.data);
  }

  Future<Map<String, dynamic>> createDmsDepartment({required String name}) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/departments',
      data: <String, dynamic>{'name': name},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<void> deleteDmsDepartment(int id) async {
    await _dio.delete<dynamic>(
      '/api/departments/$id',
      options: _requestOptions,
    );
  }

  Future<List<Map<String, dynamic>>> fetchDmsStatuses() async {
    final response = await _dio.get<dynamic>(
      '/api/statuses/get',
      queryParameters: <String, String>{
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      options: _requestOptions,
    );
    return _parseListOfMaps(response.data);
  }

  Future<Map<String, dynamic>> createDmsStatus({required String name}) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/statuses/create',
      data: <String, dynamic>{'name': name},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<void> deleteDmsStatus(int id) async {
    await _dio.delete<dynamic>(
      '/api/statuses/$id',
      options: _requestOptions,
    );
  }

  Future<List<Map<String, dynamic>>> searchDmsUsers({String query = ''}) async {
    final response = await _dio.get<dynamic>(
      '/users/search',
      queryParameters: <String, String>{
        'query': query,
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      options: _requestOptions,
    );
    return _parseListOfMaps(response.data);
  }

  Future<Map<String, dynamic>> uploadCorrespondenceLetter({
    required Map<String, dynamic> dto,
    Uint8List? documentBytes,
    String? documentFileName,
  }) async {
    final FormData formData = FormData();
    formData.files.add(
      MapEntry<String, MultipartFile>(
        'dto',
        MultipartFile.fromString(
          jsonEncode(dto),
          filename: 'blob',
          contentType: DioMediaType.parse('application/json'),
        ),
      ),
    );
    if (documentBytes != null &&
        documentFileName != null &&
        documentFileName.isNotEmpty) {
      formData.files.add(
        MapEntry<String, MultipartFile>(
          'document',
          MultipartFile.fromBytes(
            documentBytes,
            filename: documentFileName,
          ),
        ),
      );
    }
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/correspondence/uploadLetter',
      data: formData,
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        contentType: null,
      ),
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchDocumentsFilterData({
    int draw = 1,
    int start = 0,
    int length = 10,
    Map<String, dynamic> columnFilters = const <String, dynamic>{},
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/documents/filter-data',
      data: <String, dynamic>{
        'draw': draw,
        'start': start,
        'length': length,
        'columnFilters': columnFilters,
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchDmsFolders() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/folders/get',
      queryParameters: <String, String>{
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      options: _requestOptions,
    );
    return _parseListOfMaps(response.data);
  }

  Future<List<String>> fetchDmsContractsByProject(String projectName) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/api/documents/contracts-by-project',
      queryParameters: <String, String>{
        'projectName': projectName,
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      options: _requestOptions,
    );
    final dynamic data = response.data;
    if (data is! List) {
      return const <String>[];
    }
    return data
        .map((dynamic item) => item?.toString().trim() ?? '')
        .where((String name) => name.isNotEmpty)
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchDmsRootFiles({
    List<String> projects = const <String>[],
    List<String> contracts = const <String>[],
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/documents/root-files',
      data: <String, dynamic>{
        'projects': projects,
        'contracts': contracts,
      },
      options: _requestOptions,
    );
    return _parseListOfMaps(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchDmsSubfolderFiles(
    int folderId, {
    List<String> projects = const <String>[],
    List<String> contracts = const <String>[],
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/subfolders/files/$folderId',
      data: <String, dynamic>{
        'projects': projects,
        'contracts': contracts,
      },
      options: _requestOptions,
    );
    return _parseListOfMaps(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchCorrespondenceFolderFiles({
    required String type,
    List<String> projects = const <String>[],
    List<String> contracts = const <String>[],
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/correspondence/getFolderFiles',
      queryParameters: <String, String>{'type': type},
      data: <String, dynamic>{
        'projects': projects,
        'contracts': contracts,
      },
      options: _requestOptions,
    );
    return _parseListOfMaps(response.data);
  }

  Future<Map<String, dynamic>> createDmsFolder({
    required String name,
    int? parentId,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/folders/create',
      data: <String, dynamic>{
        'name': name,
        'parentId': parentId,
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<void> deleteDmsFolder(int id) async {
    await _dio.delete<dynamic>(
      '/api/folders/delete-folder/$id',
      options: _requestOptions,
    );
  }

  Future<Map<String, dynamic>> uploadDmsDocument({
    required Map<String, dynamic> dto,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final FormData formData = FormData();
    formData.files.add(
      MapEntry<String, MultipartFile>(
        'dto',
        MultipartFile.fromString(
          jsonEncode(dto),
          filename: 'blob',
          contentType: DioMediaType.parse('application/json'),
        ),
      ),
    );
    formData.files.add(
      MapEntry<String, MultipartFile>(
        'file',
        MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        ),
      ),
    );
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/api/documents/upload',
      data: formData,
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        contentType: null,
      ),
    );
    return _normalizeResponse(response.data);
  }

  List<Map<String, dynamic>> _parseListOfMaps(dynamic data) {
    if (data is! List) {
      return const <Map<String, dynamic>>[];
    }
    return data
        .whereType<Map>()
        .map(
          (Map<dynamic, dynamic> item) => Map<String, dynamic>.from(
            item.map(
              (dynamic key, dynamic value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .toList();
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

  Future<List<Map<String, dynamic>>> fetchDesignContractFilter({
    String? contractIdFk,
    String? structureTypeFk,
    String? drawingTypeFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/design/ajax/getContractListFilterInDesign',
      data: _designFilterPayload(
        contractIdFk: contractIdFk,
        structureTypeFk: structureTypeFk,
        drawingTypeFk: drawingTypeFk,
      ),
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchDesignStructureTypeFilter({
    String? contractIdFk,
    String? structureTypeFk,
    String? drawingTypeFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/design/ajax/getStructureListFilterInDesign',
      data: _designFilterPayload(
        contractIdFk: contractIdFk,
        structureTypeFk: structureTypeFk,
        drawingTypeFk: drawingTypeFk,
      ),
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchDesignDrawingTypeFilter({
    String? contractIdFk,
    String? structureTypeFk,
    String? drawingTypeFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/design/ajax/getDrawingTypeListFilterInDesign',
      data: _designFilterPayload(
        contractIdFk: contractIdFk,
        structureTypeFk: structureTypeFk,
        drawingTypeFk: drawingTypeFk,
      ),
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<({List<Map<String, dynamic>> rows, int total})> fetchDesignsList({
    int start = 0,
    int length = 10,
    String search = '',
    String? contractIdFk,
    String? structureTypeFk,
    String? drawingTypeFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/design/ajax/getDesignsList',
      queryParameters: <String, dynamic>{
        'iDisplayStart': start,
        'iDisplayLength': length,
        'sSearch': search,
        'contract_id_fk': contractIdFk?.trim() ?? '',
        'structure_type_fk': structureTypeFk?.trim() ?? '',
        'drawing_type_fk': drawingTypeFk?.trim() ?? '',
      },
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    final Map<String, dynamic> payload = _unwrapDataTablesMap(response.data);
    final List<Map<String, dynamic>> rows = _extractAaDataRows(payload);
    return (
      rows: rows,
      total: _extractDataTablesTotal(payload, rows.length),
    );
  }

  Future<List<Map<String, dynamic>>> fetchDesignUploadsList() async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/design/ajax/getDesignUploadsList',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<Uint8List> fetchDesignUploadFileBytes({
    required String fileName,
    String? designDataId,
  }) async {
    final String trimmedName = fileName.trim();
    final String trimmedId = designDataId?.trim() ?? '';
    final List<String> paths = <String>[
      if (trimmedId.isNotEmpty)
        '/design/ajax/downloadUploadedDesignData?design_data_id=${Uri.encodeComponent(trimmedId)}',
      if (trimmedName.isNotEmpty)
        '/DESIGN_DATA_FILES/${Uri.encodeComponent(trimmedName)}',
      if (trimmedName.isNotEmpty)
        '/DESIGN_UPLOAD_FILES/${Uri.encodeComponent(trimmedName)}',
    ];
    Object? lastError;
    for (final String path in paths) {
      try {
        final Response<List<int>> response = await _dio.get<List<int>>(
          path,
          options: Options(
            responseType: ResponseType.bytes,
            receiveTimeout: _dashboardReceiveTimeout,
            connectTimeout: _dashboardConnectTimeout,
          ),
        );
        final List<int>? bytes = response.data;
        if (bytes != null && bytes.isNotEmpty) {
          return Uint8List.fromList(bytes);
        }
      } catch (error) {
        lastError = error;
      }
    }
    if (trimmedId.isNotEmpty) {
      try {
        final Response<List<int>> response = await _dio.post<List<int>>(
          '/design/ajax/downloadUploadedDesignData',
          data: <String, dynamic>{'design_data_id': trimmedId},
          options: Options(
            responseType: ResponseType.bytes,
            receiveTimeout: _dashboardReceiveTimeout,
            connectTimeout: _dashboardConnectTimeout,
          ),
        );
        final List<int>? bytes = response.data;
        if (bytes != null && bytes.isNotEmpty) {
          return Uint8List.fromList(bytes);
        }
      } catch (error) {
        lastError = error;
      }
    }
    throw lastError ?? StateError('Unable to download design upload file.');
  }

  Map<String, dynamic> _designFilterPayload({
    String? contractIdFk,
    String? structureTypeFk,
    String? drawingTypeFk,
  }) {
    return <String, dynamic>{
      'contract_id_fk': contractIdFk?.trim() ?? '',
      'structure_type_fk': structureTypeFk?.trim() ?? '',
      'drawing_type_fk': drawingTypeFk?.trim() ?? '',
    };
  }

  Future<Map<String, dynamic>> fetchAddUtilityShiftingFormData() async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/utility-shifting/ajax/form/add-utility-shifting',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchUtilityShiftingForEdit({
    required String utilityShiftingId,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/utility-shifting/ajax/form/get-utility-shifting/get-utility-shifting',
      data: <String, dynamic>{
        'utility_shifting_id': utilityShiftingId,
      },
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

  Future<Map<String, dynamic>> submitUpdateUtilityShifting({
    required Map<String, String> fields,
  }) async {
    final FormData formData = FormData.fromMap(fields);
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/utility-shifting/updateUtilityShifting',
      data: formData,
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchNewActivitiesUpdateBootstrap() async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/newActivitiesUpdate',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchNewActivitiesContractsForProject({
    required String projectIdFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/getContractListForProject',
      data: <String, dynamic>{'project_id_fk': projectIdFk},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchNewActivitiesStructureTypes({
    required String contractIdFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/ajax/getStructureTypesInActivitiesUpdate',
      data: <String, dynamic>{'contract_id_fk': contractIdFk},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchNewActivitiesStructures({
    required String contractIdFk,
    required String structureTypeFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/ajax/getNewActivitiesUpdateStructures',
      data: <String, dynamic>{
        'contract_id_fk': contractIdFk,
        'structure_type_fk': structureTypeFk,
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchNewActivitiesComponents({
    required String contractIdFk,
    required String structureTypeFk,
    required String stripChartStructureIdFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/ajax/getNewActivitiesUpdateComponentsList',
      data: <String, dynamic>{
        'contract_id_fk': contractIdFk,
        'structure_type_fk': structureTypeFk,
        'strip_chart_structure_id_fk': stripChartStructureIdFk,
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchNewActivitiesElements({
    required String contractIdFk,
    required String structureTypeFk,
    required String stripChartStructureIdFk,
    required String stripChartComponent,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/ajax/getNewActivitiesUpdateComponentIdsList',
      data: <String, dynamic>{
        'contract_id_fk': contractIdFk,
        'structure_type_fk': structureTypeFk,
        'strip_chart_structure_id_fk': stripChartStructureIdFk,
        'strip_chart_component': stripChartComponent,
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchNewActivitiesLatestRowData() async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/ajax/getLatestRowData',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchNewActivitiesLastUpdateRows() async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/ajax/getLastUpdateRows',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchNewActivitiesBindData({
    required String activityId,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/ajax/bindData',
      queryParameters: <String, dynamic>{
        'activity_id': activityId,
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchNewActivitiesFilterList({
    String? projectIdFk,
    String? contractIdFk,
    String? structureTypeFk,
    String? stripChartStructureIdFk,
    String? stripChartComponent,
    String? stripChartComponentId,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/ajax/getNewActivitiesfiltersList',
      data: <String, dynamic>{
        'project_id_fk': projectIdFk ?? '',
        'contract_id_fk': contractIdFk ?? '',
        'structure_type_fk': structureTypeFk ?? '',
        'strip_chart_structure_id_fk': stripChartStructureIdFk ?? '',
        'strip_chart_component': stripChartComponent ?? '',
        'strip_chart_component_id': stripChartComponentId ?? '',
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<({Uint8List bytes, String? fileName})> exportActivitiesByContract({
    required String contractIdFk,
    required String structureTypeFk,
    required String stripChartStructureIdFk,
    required String progressDate,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/exportActivitiesbyContract',
      data: <String, dynamic>{
        'contract_id_fk': contractIdFk,
        'structure_type_fk': structureTypeFk,
        'strip_chart_structure_id_fk': stripChartStructureIdFk,
        'progress_date': progressDate,
      },
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        responseType: ResponseType.bytes,
      ),
    );
    final dynamic data = response.data;
    final List<int> raw = data is List<int> ? data : <int>[];
    final String? contentDisposition =
        response.headers.value('content-disposition');
    final String? fileName =
        _fileNameFromContentDisposition(contentDisposition);
    return (bytes: Uint8List.fromList(raw), fileName: fileName);
  }

  Future<Map<String, dynamic>> submitNewActivitiesBulkUpdate({
    required Map<String, dynamic> payload,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/update-new-activities-bulk',
      data: payload,
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchModifyActualsActivitiesList({
    required String contractIdFk,
    String? stripChartStructureIdFk,
    String? searchStr,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/ajax/getNewActivitiesfiltersList',
      data: <String, dynamic>{
        'contract_id_fk': contractIdFk,
        'strip_chart_structure_id_fk': stripChartStructureIdFk ?? '',
        'searchStr': searchStr ?? '',
      },
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchContractStructures({
    required String contractIdFk,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/ajax/getContractStructures',
      queryParameters: <String, dynamic>{
        'contract_id_fk': contractIdFk,
      },
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<Map<String, dynamic>> submitModifyActualsBulk({
    required Map<String, dynamic> payload,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/update-modify-actuals-bulk',
      data: payload,
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchValidationContracts({
    required String approvalStatusFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/validation/ajax/getContractsInApprovableActivities',
      data: <String, dynamic>{'approval_status_fk': approvalStatusFk},
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchValidationStructures({
    required String approvalStatusFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/validation/ajax/getStructuresInApprovableActivities',
      data: <String, dynamic>{'approval_status_fk': approvalStatusFk},
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchValidationUpdatedByList({
    required String approvalStatusFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/validation/ajax/getUpdatedByListInApprovableActivities',
      data: <String, dynamic>{'approval_status_fk': approvalStatusFk},
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchApprovableActivities({
    required String approvalStatusFk,
    String? contractIdFk,
    String? structure,
    String? updatedByUserIdFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/validation/ajax/getApprovableActivities',
      data: <String, dynamic>{
        'updated_by_user_id_fk': updatedByUserIdFk ?? '',
        'contract_id_fk': contractIdFk ?? '',
        'structure': structure ?? '',
        'approval_status_fk': approvalStatusFk.toLowerCase(),
      },
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<Map<String, dynamic>> approveActivityProgress({
    required String structure,
    required String progressId,
    String? workIdFk,
    required String contractIdFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/validation/ajax/approveActivityProgress',
      queryParameters: <String, dynamic>{
        'structure': structure,
        'progress_id': progressId,
        'work_id_fk': workIdFk ?? 'null',
        'contract_id_fk': contractIdFk,
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> rejectActivityProgress({
    required String structure,
    required String progressId,
    String? workIdFk,
    required String contractIdFk,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/validation/ajax/rejectActivityProgress',
      queryParameters: <String, dynamic>{
        'structure': structure,
        'progress_id': progressId,
        'work_id_fk': workIdFk ?? 'null',
        'contract_id_fk': contractIdFk,
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> approveMultipleActivityProgress({
    required String progressIds,
    String? workIdFk,
    required String contractIdFk,
    required String structure,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/validation/ajax/approveMultipleActivityProgress',
      queryParameters: <String, dynamic>{
        'progress_id': progressIds,
        'work_id_fk': workIdFk ?? '',
        'contract_id_fk': contractIdFk,
        'structure': structure,
      },
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> rejectMultipleActivityProgress({
    required String progressIds,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/validation/ajax/rejectMultipleActivityProgress',
      queryParameters: <String, dynamic>{'progress_id': progressIds},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> uploadNewActivitiesUpdateFile({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'stripChartFile': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      ),
    });
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/upload-new-activities',
      data: formData,
      options: _requestOptions.copyWith(
        contentType: 'multipart/form-data',
      ),
    );
    return _normalizeResponse(response.data);
  }

  Map<String, String> _p6NewDataFilterPayload({
    String? contractIdFk,
    String? statusFk,
    String? uploadType,
  }) {
    String valueOrEmpty(String? value) => value?.trim().isNotEmpty == true
        ? value!.trim()
        : '';
    return <String, String>{
      'contract_id_fk': valueOrEmpty(contractIdFk),
      'status_fk': valueOrEmpty(statusFk),
      'upload_type': valueOrEmpty(uploadType),
    };
  }

  Future<List<Map<String, dynamic>>> fetchP6NewActivityData({
    String? contractIdFk,
    String? statusFk,
    String? uploadType,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/ajax/getP6NewActivityData',
      data: _p6NewDataFilterPayload(
        contractIdFk: contractIdFk,
        statusFk: statusFk,
        uploadType: uploadType,
      ),
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchP6NewDataContractsFilter() async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/ajax/getContractsListFilterInP6New',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchP6NewDataUploadTypesFilter() async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/ajax/getUploadTypesFilterInP6New',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchP6NewDataStatusFilter() async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/ajax/getStatusListFilterInP6New',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeListResponse(response.data);
  }

  Future<Map<String, dynamic>> fetchP6NewDataFormBootstrap() async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '/p6-new-data-new',
      data: const <String, dynamic>{},
      options: _requestOptions,
    );
    return _normalizeResponse(response.data);
  }

  Future<({Uint8List bytes, String? fileName})> downloadP6NewDataFileFormat() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/p6-new-data-template',
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        responseType: ResponseType.bytes,
      ),
    );
    final dynamic data = response.data;
    final List<int> raw = data is List<int> ? data : <int>[];
    final String? contentDisposition =
        response.headers.value('content-disposition');
    final String? fileName = _fileNameFromContentDisposition(contentDisposition);
    return (bytes: Uint8List.fromList(raw), fileName: fileName);
  }

  Future<Map<String, dynamic>> submitP6NewDataUpload({
    required String endpoint,
    required String projectIdFk,
    required String contractIdFk,
    required String dataDate,
    required String fileName,
    required Uint8List bytes,
    bool includeFobId = false,
  }) async {
    final Map<String, dynamic> fields = <String, dynamic>{
      'project_id_fk': projectIdFk,
      'contract_id_fk': contractIdFk,
      'data_date': dataDate,
      if (includeFobId) 'fob_id_fk': '',
    };
    final FormData formData = FormData.fromMap(<String, dynamic>{
      ...fields,
      'p6dataFile': MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      ),
    });
    final Response<dynamic> response = await _dio.post<dynamic>(
      endpoint,
      data: formData,
      options: Options(
        receiveTimeout: _dashboardReceiveTimeout,
        connectTimeout: _dashboardConnectTimeout,
        contentType: null,
      ),
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

  Map<String, String> _contractFilterPayload({
    String? designation,
    String? dyHodDesignation,
    String? contractorIdFk,
    String? contractStatus,
    String? contractStatusFk,
  }) {
    String valueOrEmpty(String? value) => value?.trim().isNotEmpty == true
        ? value!.trim()
        : '';
    return <String, String>{
      'designation': valueOrEmpty(designation),
      'dy_hod_designation': valueOrEmpty(dyHodDesignation),
      'contractor_id_fk': valueOrEmpty(contractorIdFk),
      'contract_status': valueOrEmpty(contractStatus),
      'contract_status_fk': valueOrEmpty(contractStatusFk),
    };
  }

  Map<String, String> _contractFilterQueryParams({
    String? designation,
    String? dyHodDesignation,
    String? contractorIdFk,
    String? contractStatus,
    String? contractStatusFk,
    bool includeDesignation = true,
    bool includeDyHodDesignation = true,
    bool includeContractorIdFk = true,
    bool includeContractStatus = true,
    bool includeContractStatusFk = true,
  }) {
    String valueOrEmpty(String? value) => value?.trim().isNotEmpty == true
        ? value!.trim()
        : '';
    return <String, String>{
      if (includeDesignation)
        'designation': valueOrEmpty(designation),
      if (includeDyHodDesignation)
        'dy_hod_designation': valueOrEmpty(dyHodDesignation),
      if (includeContractorIdFk)
        'contractor_id_fk': valueOrEmpty(contractorIdFk),
      if (includeContractStatus)
        'contract_status': valueOrEmpty(contractStatus),
      if (includeContractStatusFk)
        'contract_status_fk': valueOrEmpty(contractStatusFk),
    };
  }

  dynamic _coerceJsonValue(dynamic data) {
    if (data is String) {
      final String trimmed = data.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          return jsonDecode(trimmed);
        } catch (_) {
          return data;
        }
      }
    }
    return data;
  }

  bool _hasDataTablesFields(Map<String, dynamic> map) {
    return map.containsKey('aaData') ||
        map.containsKey('iTotalDisplayRecords') ||
        map.containsKey('iTotalRecords');
  }

  Map<String, dynamic> _unwrapDataTablesMap(dynamic data) {
    final dynamic decoded = _coerceJsonValue(data);
    if (decoded is! Map) {
      return <String, dynamic>{};
    }
    final Map<String, dynamic> map = _normalizeResponse(decoded);
    if (_hasDataTablesFields(map)) {
      return map;
    }
    for (final String key in <String>['data', 'result', 'payload']) {
      final dynamic nested = map[key];
      if (nested is Map) {
        final Map<String, dynamic> nestedMap = _normalizeResponse(nested);
        if (_hasDataTablesFields(nestedMap)) {
          return nestedMap;
        }
      }
    }
    return map;
  }

  List<Map<String, dynamic>> _extractAaDataRows(Map<String, dynamic> map) {
    dynamic raw = map['aaData'] ?? map['rows'];
    if (raw is! List) {
      final dynamic nested = map['data'];
      if (nested is List) {
        raw = nested;
      } else if (nested is Map) {
        raw = nested['aaData'] ?? nested['rows'];
      }
    }
    if (raw is! List) {
      return const <Map<String, dynamic>>[];
    }
    final List<Map<String, dynamic>> rows = <Map<String, dynamic>>[];
    for (final dynamic item in raw) {
      if (item is Map) {
        rows.add(_mapRow(item));
        continue;
      }
      if (item is List) {
        rows.add(_mapDataTablesArrayRow(item));
      }
    }
    return rows;
  }

  Map<String, dynamic> _mapDataTablesArrayRow(List<dynamic> columns) {
    const List<String> keys = <String>[
      'project_id_fk',
      'structure_type_fk',
      'structure',
      'contract_short_name',
      'work_status_fk',
      'structure_id',
    ];
    final Map<String, dynamic> row = <String, dynamic>{};
    for (int index = 0; index < columns.length && index < keys.length; index++) {
      row[keys[index]] = columns[index];
    }
    return row;
  }

  int _extractDataTablesTotal(Map<String, dynamic> map, int fallback) {
    final dynamic value = map['iTotalDisplayRecords'] ??
        map['iTotalRecords'] ??
        map['recordsFiltered'] ??
        map['recordsTotal'];
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  List<Map<String, dynamic>> _normalizeListResponse(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (Map<dynamic, dynamic> row) => Map<String, dynamic>.from(
              row.map(
                (dynamic key, dynamic value) => MapEntry(key.toString(), value),
              ),
            ),
          )
          .toList();
    }
    if (data is Map) {
      final Map<String, dynamic> map = _normalizeResponse(data);
      final dynamic nested = map['data'] ?? map['result'] ?? map['rows'];
      if (nested is List) {
        return _normalizeListResponse(nested);
      }
    }
    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _normalizeResponse(dynamic data) {
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
    if (data is bool) {
      return <String, dynamic>{'success': data, 'result': data};
    }
    return <String, dynamic>{};
  }
}

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  return DashboardRemoteDataSource(ref.watch(dioProvider));
});
