import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/issue_details_report_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/issues_summary_report_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/pending_issues_report_page.dart';

class PendingIssuesReportPage extends StatelessWidget {
  const PendingIssuesReportPage({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return PendingIssuesReportScreen(
      args: args,
      dataSource: dataSource,
    );
  }
}

class IssuesSummaryReportPage extends StatelessWidget {
  const IssuesSummaryReportPage({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return IssuesSummaryReportScreen(
      args: args,
      dataSource: dataSource,
    );
  }
}

class IssueDetailsReportPage extends StatelessWidget {
  const IssueDetailsReportPage({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  Widget build(BuildContext context) {
    return IssueDetailsReportScreen(
      args: args,
      dataSource: dataSource,
    );
  }
}
