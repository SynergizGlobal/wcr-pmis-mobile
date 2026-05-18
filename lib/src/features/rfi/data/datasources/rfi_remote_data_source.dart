import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/rfi_dio_client.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/data/mappers/rfi_dropdown_mapper.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_dropdown_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_list_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_status_counts.dart';

final rfiRemoteDataSourceProvider = Provider<RfiRemoteDataSource>((ref) {
  return RfiRemoteDataSource(ref.watch(rfiDioProvider));
});

class RfiRemoteDataSource {
  const RfiRemoteDataSource(this._dio);

  final Dio _dio;

  Future<RfiStatusCounts> fetchStatusCounts() async {
    final Response<dynamic> response = await _dio.get<dynamic>('rfi/status-counts');
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return RfiStatusCounts.fromJson(data);
    }
    if (data is Map) {
      return RfiStatusCounts.fromJson(Map<String, dynamic>.from(data));
    }
    return const RfiStatusCounts();
  }

  Future<int> fetchRfiCount() async {
    final Response<dynamic> response = await _dio.get<dynamic>('rfi/rfi-count');
    return _parseCount(response.data);
  }

  Future<List<RfiListItem>> fetchRfiList() async {
    final Response<dynamic> response = await _dio.get<dynamic>('/rfi/rfi-details');
    final dynamic data = response.data;
    if (data is! List) {
      return const <RfiListItem>[];
    }
    return data
        .whereType<Map>()
        .map(
          (Map<dynamic, dynamic> row) =>
              RfiListItem.fromJson(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  Future<void> deleteRfi(int id, String description) async {
    await _dio.delete<dynamic>(
      'rfi/delete',
      data: <String, dynamic>{'id': id, 'description': description},
    );
  }

  Future<void> closeRfi(int id) async {
    await _dio.post<dynamic>(
      'rfi/close/rfi/$id',
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<List<RfiDropdownItem>> fetchProjectNames() async {
    return _fetchDropdownList('rfi/projectNames');
  }

  Future<List<RfiDropdownItem>> fetchContractNamesForProject(
    String projectId,
  ) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      'rfi/contractNames',
      queryParameters: <String, String>{'projectId': projectId},
    );
    return RfiDropdownMapper.fromList(response.data);
  }

  Future<List<RfiDropdownItem>> fetchStructureTypes(String contractId) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      'rfi/structureType',
      queryParameters: <String, String>{'contractId': contractId},
    );
    return RfiDropdownMapper.fromList(response.data);
  }

  Future<List<RfiDropdownItem>> fetchStructures({
    required String structureType,
    required String contractId,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      'rfi/structure',
      queryParameters: <String, String>{
        'structureType': structureType,
        'contractId': contractId,
      },
    );
    return RfiDropdownMapper.fromList(response.data);
  }

  Future<List<RfiDropdownItem>> fetchComponents({
    required String structureType,
    required String contractId,
    required String structureName,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      'rfi/component',
      queryParameters: <String, String>{
        'structureType': structureType,
        'contractId': contractId,
        'structure': structureName,
      },
    );
    return RfiDropdownMapper.fromList(response.data);
  }

  Future<List<RfiDropdownItem>> fetchElements({
    required String contractId,
    required String structureType,
    required String structureName,
    required String componentName,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      'rfi/element',
      queryParameters: <String, String>{
        'contractId': contractId,
        'structureType': structureType,
        'structure': structureName,
        'component': componentName,
      },
    );
    return RfiDropdownMapper.fromList(response.data);
  }

  Future<List<RfiDropdownItem>> fetchActivities({
    required String structureType,
    required String structureName,
    required String componentName,
    required String componentId,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      'rfi/activityNames',
      queryParameters: <String, String>{
        'structureType': structureType,
        'structure': structureName,
        'component': componentName,
        'component_id': componentId,
      },
    );
    return RfiDropdownMapper.fromList(response.data);
  }

  Future<List<RfiDropdownItem>> fetchRfiDescriptions(String activityName) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      'rfi/rfi-descriptions',
      queryParameters: <String, String>{'activity': activityName},
    );
    return RfiDropdownMapper.fromList(response.data);
  }

  Future<List<RfiDropdownItem>> fetchRegularUsers() async {
    return _fetchDropdownList('rfi/regularUsers');
  }

  Future<dynamic> createRfi(Map<String, dynamic> body) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      'rfi/create',
      data: body,
    );
    return response.data;
  }

  Future<List<RfiDropdownItem>> _fetchDropdownList(String path) async {
    final Response<dynamic> response = await _dio.get<dynamic>(path);
    return RfiDropdownMapper.fromList(response.data);
  }

  Future<Map<String, dynamic>> fetchRfiDetail(int id) async {
    final Response<dynamic> response =
        await _dio.get<dynamic>('/rfi/rfi-details/$id');
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  int _parseCount(dynamic data) {
    if (data is int) {
      return data;
    }
    if (data is num) {
      return data.toInt();
    }
    if (data is Map) {
      final dynamic value =
          data['count'] ?? data['rfiCount'] ?? data['total'] ?? data['data'];
      if (value is num) {
        return value.toInt();
      }
    }
    return 0;
  }
}
