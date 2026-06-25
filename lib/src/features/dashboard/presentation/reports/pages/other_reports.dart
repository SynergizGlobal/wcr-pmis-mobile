import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/contract_wise_activities_report_page.dart'
    show ContractWiseActivitiesReportScreen;
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/land_acquisition_report_page.dart'
    show LandAcquisitionReportScreen;
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/utility_shifting_report_page.dart'
    show UtilityShiftingReportScreen;
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/report_shell_page.dart';

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

class ProgressReportPage extends StatelessWidget {
  const ProgressReportPage({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return ReportShellPage(args: args);
  }
}

class FobProgressReportPage extends StatelessWidget {
  const FobProgressReportPage({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return ReportShellPage(args: args);
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
