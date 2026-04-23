import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/result/failure.dart';
import 'package:wcr_pmis_mobile/src/core/result/result.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/home_dashboard_data.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<Result<HomeDashboardData>> getHomeDashboardData() async {
    try {
      final _DashboardFetchResult projectTypesResult = await _safeFetch(
        label: 'projectTypes',
        call: _remoteDataSource.fetchProjectTypes,
      );
      final _DashboardFetchResult overviewResult = await _safeFetch(
        label: 'getProjectList',
        call: _remoteDataSource.fetchProjectOverview,
      );
      final _DashboardFetchResult typeWiseResult = await _safeFetch(
        label: 'getProjectListByType',
        call: _remoteDataSource.fetchProjectTypeWise,
      );

      if (!projectTypesResult.hasData &&
          !overviewResult.hasData &&
          !typeWiseResult.hasData) {
        final String errorMessage =
            projectTypesResult.errorMessage ??
            overviewResult.errorMessage ??
            typeWiseResult.errorMessage ??
            'Unable to load home data.';
        debugPrint(
          '[DashboardRepo] all endpoints empty/failed. '
          'projectTypesError=${projectTypesResult.errorMessage}, '
          'overviewError=${overviewResult.errorMessage}, '
          'typeWiseError=${typeWiseResult.errorMessage}',
        );
        return Left<Failure, HomeDashboardData>(Failure(errorMessage));
      }

      debugPrint(
        '[DashboardRepo] payload stats: '
        'projectTypesHasData=${projectTypesResult.hasData}, '
        'overviewHasData=${overviewResult.hasData}, '
        'typeWiseHasData=${typeWiseResult.hasData}',
      );

      final HomeDashboardData data = HomeDashboardData(
        overview: _safeParseOverview(overviewResult.data),
        projectTypes: _safeParseProjectTypes(
          projectTypesResult.data,
          overviewResult.data,
          typeWiseResult.data,
        ),
      );
      debugPrint(
        '[DashboardRepo] parsed result: projects=${data.overview.projectsCount}, '
        'length=${data.overview.totalLength}, '
        'commissioned=${data.overview.commissionedLength}, '
        'projectTypesCount=${data.projectTypes.length}',
      );
      return Right<Failure, HomeDashboardData>(data);
    } on DioException catch (error) {
      final dynamic responseData = error.response?.data;
      String? message;
      if (responseData is Map<String, dynamic>) {
        message = responseData['message']?.toString();
      }
      return Left<Failure, HomeDashboardData>(
        Failure(message ?? error.message ?? 'Unable to load home data.'),
      );
    } catch (error, stackTrace) {
      debugPrint('[DashboardRepo] unexpected exception: $error');
      debugPrint('$stackTrace');
      // Fallback with empty model to avoid hard-failing Home UI
      return const Right<Failure, HomeDashboardData>(
        HomeDashboardData(
          overview: HomeOverview(
            projectsCount: 0,
            totalLength: 0,
            commissionedLength: 0,
          ),
          projectTypes: <HomeProjectType>[],
        ),
      );
    }
  }

  @override
  Future<Result<ProjectDetailsData>> getProjectDetailsByType(
    String projectTypeName,
  ) async {
    try {
      final _DashboardFetchResult typeWiseResult = await _safeFetch(
        label: 'getProjectListByType',
        call: _remoteDataSource.fetchProjectTypeWise,
      );
      final _DashboardFetchResult overviewResult = await _safeFetch(
        label: 'getProjectList',
        call: _remoteDataSource.fetchProjectOverview,
      );

      if (!typeWiseResult.hasData && !overviewResult.hasData) {
        return Left<Failure, ProjectDetailsData>(
          Failure(
            typeWiseResult.errorMessage ??
                overviewResult.errorMessage ??
                'Unable to load project details.',
          ),
        );
      }

      final List<dynamic> detailRows = _extractFirstList(typeWiseResult.data);
      final List<dynamic> overviewRows = _extractFirstList(overviewResult.data);
      final String target = projectTypeName.trim().toLowerCase();

      bool matchesType(Map<String, dynamic> row) {
        final String rowTypeName =
            row['project_type_name']?.toString() ??
            row['projectTypeName']?.toString() ??
            row['project_type']?.toString() ??
            '';
        if (rowTypeName.trim().toLowerCase() == target) {
          return true;
        }
        // Fallback for payloads that only provide IDs.
        final String rowTypeId =
            row['project_type_id_fk']?.toString() ??
            row['project_type_id']?.toString() ??
            row['projectTypeIdFk']?.toString() ??
            row['projectTypeId']?.toString() ??
            '';
        switch (target) {
          case 'new line':
            return rowTypeId == '1';
          case 'gauge conversion':
            return rowTypeId == '2';
          case 'doubling':
            return rowTypeId == '3';
          case 'special projects':
            return rowTypeId == '4';
          case 'station development':
            return rowTypeId == '5';
          default:
            return false;
        }
      }

      final List<Map<String, dynamic>> filteredDetails = detailRows
          .whereType<Map<String, dynamic>>()
          .where(matchesType)
          .toList();

      final List<Map<String, dynamic>> filteredProjects = overviewRows
          .whereType<Map<String, dynamic>>()
          .where(matchesType)
          .toList();

      final List<String> projectNames = <String>[];
      final Set<String> seenProjectNames = <String>{};
      for (final Map<String, dynamic> row in filteredProjects) {
        final String name =
            row['project_name']?.toString().trim() ??
            row['projectName']?.toString().trim() ??
            '';
        if (name.isNotEmpty && seenProjectNames.add(name)) {
          projectNames.add(name);
        }
      }

      final List<ProjectMajorItem> items = <ProjectMajorItem>[];
      for (final Map<String, dynamic> row in filteredDetails) {
        final String projectName =
            row['project_name']?.toString().trim() ??
            row['projectName']?.toString().trim() ??
            'Unknown Project';

        final double progress = _toDouble(
          row['financial_progress'] ??
              row['physical_progress'] ??
              row['progress'],
        );
        items.add(
          ProjectMajorItem(
            projectName: projectName,
            item: row['structure_type']?.toString() ?? '-',
            unit: row['unit']?.toString() ?? '-',
            scope: row['scope']?.toString() ?? '-',
            completed: row['completed']?.toString() ?? '-',
            progressPercent: '${progress.toStringAsFixed(2)} %',
            tdc: row['revised_target_date']?.toString() ?? '-',
          ),
        );
      }

      // Fallback: if overview endpoint has no names, derive from detail endpoint.
      if (projectNames.isEmpty) {
        for (final ProjectMajorItem item in items) {
          if (item.projectName.isNotEmpty &&
              !projectNames.contains(item.projectName)) {
            projectNames.add(item.projectName);
          }
        }
      }

      return Right<Failure, ProjectDetailsData>(
        ProjectDetailsData(
          projectTypeName: projectTypeName,
          projectNames: projectNames,
          items: items,
        ),
      );
    } on DioException catch (error) {
      return Left<Failure, ProjectDetailsData>(
        Failure(error.message ?? 'Unable to load project details.'),
      );
    } catch (_) {
      return const Left<Failure, ProjectDetailsData>(
        Failure('Something went wrong while loading project details.'),
      );
    }
  }

  Future<_DashboardFetchResult> _safeFetch({
    required String label,
    required Future<Map<String, dynamic>> Function() call,
  }) async {
    try {
      final Map<String, dynamic> data = await call();
      debugPrint(
        '[DashboardRepo] $label success. '
        'topLevelKeys=${data.keys.toList()} '
        'dataType=${data['data']?.runtimeType}',
      );
      return _DashboardFetchResult(data: data);
    } on DioException catch (error) {
      final dynamic responseData = error.response?.data;
      String? message;
      if (responseData is Map<String, dynamic>) {
        message = responseData['message']?.toString();
      }
      debugPrint(
        '[DashboardRepo] $label DioException type=${error.type} '
        'status=${error.response?.statusCode} '
        'message=${message ?? error.message} '
        'innerError=${error.error}',
      );
      return _DashboardFetchResult(
        data: const <String, dynamic>{},
        errorMessage: message ?? error.message,
      );
    } catch (error, stackTrace) {
      debugPrint('[DashboardRepo] $label unexpected exception: $error');
      debugPrint('$stackTrace');
      return const _DashboardFetchResult(data: <String, dynamic>{});
    }
  }

  HomeOverview _parseOverview(Map<String, dynamic> json) {
    final Map<String, dynamic> source = _extractFirstMap(json) ?? json;
    final int explicitProjectsCount = _toInt(
      source['projectsCount'] ??
          source['projectCount'] ??
          source['project_count'] ??
          source['totalProjects'] ??
          source['total_projects'] ??
          source['projects'],
    );
    final int fallbackProjectsCount = _extractFirstList(json).length;
    return HomeOverview(
      projectsCount: explicitProjectsCount > 0
          ? explicitProjectsCount
          : fallbackProjectsCount,
      totalLength: _toDouble(
        source['length'] ?? source['totalLength'] ?? source['projectLength'],
      ),
      commissionedLength: _toDouble(
        source['commissionedLength'] ??
            source['commissioned'] ??
            source['completedLength'],
      ),
    );
  }

  HomeOverview _safeParseOverview(Map<String, dynamic> json) {
    try {
      return _parseOverview(json);
    } catch (error, stackTrace) {
      debugPrint('[DashboardRepo] _parseOverview exception: $error');
      debugPrint('$stackTrace');
      return const HomeOverview(
        projectsCount: 0,
        totalLength: 0,
        commissionedLength: 0,
      );
    }
  }

  List<HomeProjectType> _parseProjectTypes(
    Map<String, dynamic> projectTypesJson,
    Map<String, dynamic> overviewJson,
    Map<String, dynamic> typeWiseJson,
  ) {
    final List<dynamic> typeRows = _extractFirstList(projectTypesJson);
    final Map<String, int> overviewCounts = _extractTypeWiseCounts(
      overviewJson,
    );
    final Map<String, int> counts = _extractTypeWiseCounts(typeWiseJson);

    return typeRows.map<HomeProjectType>((dynamic row) {
      if (row is! Map<String, dynamic>) {
        return const HomeProjectType(name: 'Unknown', cumulativeCount: 0);
      }
      final String rawName =
          row['project_type_name']?.toString() ??
          row['projectTypeName']?.toString() ??
          'Unknown';
      final int inlineCount = _toInt(
        row['count'] ??
            row['projectCount'] ??
            row['total'] ??
            row['projectsCount'] ??
            row['cumulativeCount'] ??
            row['project_count'],
      );
      return HomeProjectType(
        name: rawName,
        cumulativeCount: inlineCount > 0
            ? inlineCount
            : overviewCounts[rawName.trim().toLowerCase()] ??
                  counts[rawName.trim().toLowerCase()] ??
                  0,
      );
    }).toList();
  }

  List<HomeProjectType> _safeParseProjectTypes(
    Map<String, dynamic> projectTypesJson,
    Map<String, dynamic> overviewJson,
    Map<String, dynamic> typeWiseJson,
  ) {
    try {
      return _parseProjectTypes(projectTypesJson, overviewJson, typeWiseJson);
    } catch (error, stackTrace) {
      debugPrint('[DashboardRepo] _parseProjectTypes exception: $error');
      debugPrint('$stackTrace');
      return const <HomeProjectType>[];
    }
  }

  Map<String, int> _extractTypeWiseCounts(Map<String, dynamic> json) {
    final List<dynamic> rows = _extractFirstList(json);
    final Map<String, int> result = <String, int>{};
    for (final dynamic row in rows) {
      if (row is! Map<String, dynamic>) {
        continue;
      }
      final String name =
          row['project_type_name']?.toString() ??
          row['projectTypeName']?.toString() ??
          row['project_type']?.toString() ??
          row['type']?.toString() ??
          '';
      if (name.trim().isEmpty) {
        continue;
      }
      final int count = _toInt(
        row['count'] ??
            row['projectCount'] ??
            row['total'] ??
            row['projectsCount'] ??
            row['cumulativeCount'] ??
            row['project_count'],
      );
      final String key = name.trim().toLowerCase();
      final int previous = result[key] ?? 0;
      if (count > 0) {
        // API often repeats rows per structure_type; keep strongest declared total.
        result[key] = count > previous ? count : previous;
      } else {
        // Fallback: no explicit count, so derive from number of rows.
        result[key] = previous + 1;
      }
    }
    return result;
  }

  List<dynamic> _extractFirstList(Map<String, dynamic> json) {
    final dynamic directData = json['data'];
    if (directData is List<dynamic>) {
      return directData;
    }
    for (final dynamic value in json.values) {
      if (value is List<dynamic>) {
        return value;
      }
      if (value is Map<String, dynamic>) {
        for (final dynamic nested in value.values) {
          if (nested is List<dynamic>) {
            return nested;
          }
        }
      }
    }
    return <dynamic>[];
  }

  Map<String, dynamic>? _extractFirstMap(Map<String, dynamic> json) {
    final dynamic directData = json['data'];
    if (directData is Map<String, dynamic>) {
      return directData;
    }
    for (final dynamic value in json.values) {
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is List<dynamic> &&
          value.isNotEmpty &&
          value.first is Map<String, dynamic>) {
        return value.first as Map<String, dynamic>;
      }
    }
    return null;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});

class _DashboardFetchResult {
  const _DashboardFetchResult({required this.data, this.errorMessage});

  final Map<String, dynamic> data;
  final String? errorMessage;

  bool get hasData => data.isNotEmpty;
}
