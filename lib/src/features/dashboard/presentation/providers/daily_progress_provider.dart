import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

typedef DailyProgressRequest = ({String projectId, String date});

final dailyProgressProvider =
    FutureProvider.family<List<Map<String, dynamic>>, DailyProgressRequest>((
  ref,
  DailyProgressRequest request,
) async {
  return ref.read(dashboardRemoteDataSourceProvider).fetchDailyProgress(
        projectId: request.projectId,
        date: request.date,
      );
});
