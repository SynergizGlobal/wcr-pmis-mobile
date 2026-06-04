import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/progress_segment.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/project_progress_chart_builder.dart';

final projectProgressProvider =
    FutureProvider.family<ProjectProgressChartModel, String>((
  ref,
  String projectId,
) async {
  final List<Map<String, dynamic>> rows = await ref
      .read(dashboardRemoteDataSourceProvider)
      .fetchProjectProgress(projectId: projectId);
  final List<ProgressSegment> segments =
      rows.map(ProgressSegment.fromMap).toList();
  return ProjectProgressChartModel.fromSegments(segments);
});
