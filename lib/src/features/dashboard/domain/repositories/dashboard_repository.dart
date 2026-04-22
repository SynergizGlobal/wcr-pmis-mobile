import 'package:wcr_pmis_mobile/src/core/result/result.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/home_dashboard_data.dart';

abstract class DashboardRepository {
  Future<Result<HomeDashboardData>> getHomeDashboardData();
  Future<Result<ProjectDetailsData>> getProjectDetailsByType(
    String projectTypeName,
  );
}
