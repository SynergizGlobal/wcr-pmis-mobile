import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/report_form_registry.dart';

class ReportFormPage extends StatelessWidget {
  const ReportFormPage({
    super.key,
    required this.args,
    required this.dataSource,
  });

  static const String routeName = 'report-form';
  static const String routePath = '/report-form';

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return buildReportPage(args: args, dataSource: dataSource);
  }
}
