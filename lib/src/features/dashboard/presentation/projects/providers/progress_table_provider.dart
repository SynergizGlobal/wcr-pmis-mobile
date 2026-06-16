import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

final progressTableProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
  ref,
  String projectId,
) async {
  return ref
      .read(dashboardRemoteDataSourceProvider)
      .fetchProgressTableData(projectId: projectId);
});
