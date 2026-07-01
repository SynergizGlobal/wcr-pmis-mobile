import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/direct_download_report_screen.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/report_shell_page.dart';

class TpcProgressReportPage extends StatelessWidget {
  const TpcProgressReportPage({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return DirectDownloadReportScreen(
      args: args,
      fallbackTitle: 'TCP',
      defaultFileName: 'tpc_status_report',
      download: dataSource.generateTpcStatusReport,
    );
  }
}

class StationImprovementsReportPage extends StatelessWidget {
  const StationImprovementsReportPage({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return DirectDownloadReportScreen(
      args: args,
      fallbackTitle: 'Station Improvements Report',
      defaultFileName: 'station_improvements_report',
      download: dataSource.generateStationImprovementsReport,
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
