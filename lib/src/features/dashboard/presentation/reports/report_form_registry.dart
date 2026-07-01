import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/report_kind.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/contract_reports.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/issues_reports.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/other_reports.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/progress_reports.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/report_shell_page.dart';

Widget buildReportPage({
  required ReportFormArgs args,
  required DashboardRemoteDataSource dataSource,
}) {
  return switch (resolveReportKind(args)) {
    ReportKind.contractDetail => ContractDetailReportPage(
      args: args,
      dataSource: dataSource,
    ),
    ReportKind.listOfContractors => ReportShellPage(args: args),
    ReportKind.listOfContracts => ListOfContractsReportPage(
      args: args,
      dataSource: dataSource,
    ),
    ReportKind.bgInsuranceReport => BgInsuranceReportPage(
      args: args,
      dataSource: dataSource,
    ),
    ReportKind.dateOfCompletionReport => DateOfCompletionReportPage(
      args: args,
      dataSource: dataSource,
    ),
    ReportKind.bgContractualLetters => BgContractualLettersReportPage(
      args: args,
      dataSource: dataSource,
    ),
    ReportKind.insuranceContractualLetters =>
      InsuranceContractualLettersReportPage(
        args: args,
        dataSource: dataSource,
      ),
    ReportKind.docContractualLetters => DocContractualLettersReportPage(
      args: args,
      dataSource: dataSource,
    ),
    ReportKind.contractWiseActivities => ContractWiseActivitiesReportPage(
      args: args,
      dataSource: dataSource,
    ),
    ReportKind.progressReport => ProgressReportPage(
      args: args,
      dataSource: dataSource,
    ),
    ReportKind.fobProgressReport => FobProgressReportPage(
      args: args,
      dataSource: dataSource,
    ),
    ReportKind.tpcProgressReport => ReportShellPage(args: args),
    ReportKind.stationImprovementsReport => ReportShellPage(args: args),
    ReportKind.pendingIssuesReport => PendingIssuesReportPage(
      args: args,
      dataSource: dataSource,
    ),
    ReportKind.issuesSummaryReport => IssuesSummaryReportPage(
      args: args,
      dataSource: dataSource,
    ),
    ReportKind.issueDetailsReport => IssueDetailsReportPage(
      args: args,
      dataSource: dataSource,
    ),
    ReportKind.landAcquisitionReport => LandAcquisitionReportPage(
      args: args,
      dataSource: dataSource,
    ),
    ReportKind.utilityReport => UtilityReportPage(
      args: args,
      dataSource: dataSource,
    ),
    ReportKind.unknown => ReportShellPage(args: args),
  };
}
