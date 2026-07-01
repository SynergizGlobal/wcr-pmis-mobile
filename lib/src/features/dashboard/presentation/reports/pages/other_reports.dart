import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/contract_wise_activities_report_page.dart'
    show ContractWiseActivitiesReportScreen;
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/land_acquisition_report_page.dart'
    show LandAcquisitionReportScreen;
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/utility_shifting_report_page.dart'
    show UtilityShiftingReportScreen;

class ContractWiseActivitiesReportPage extends StatelessWidget {
  const ContractWiseActivitiesReportPage({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return ContractWiseActivitiesReportScreen(
      args: args,
      dataSource: dataSource,
    );
  }
}

class LandAcquisitionReportPage extends StatelessWidget {
  const LandAcquisitionReportPage({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return LandAcquisitionReportScreen(
      args: args,
      dataSource: dataSource,
    );
  }
}

class UtilityReportPage extends StatelessWidget {
  const UtilityReportPage({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return UtilityShiftingReportScreen(
      args: args,
      dataSource: dataSource,
    );
  }
}
