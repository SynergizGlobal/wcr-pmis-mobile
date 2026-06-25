import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/report_shell_page.dart';

class ContractDetailReportPage extends StatelessWidget {
  const ContractDetailReportPage({
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

class ListOfContractorsReportPage extends StatelessWidget {
  const ListOfContractorsReportPage({
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

class ListOfContractsReportPage extends StatelessWidget {
  const ListOfContractsReportPage({
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

class BgInsuranceReportPage extends StatelessWidget {
  const BgInsuranceReportPage({
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

class DateOfCompletionReportPage extends StatelessWidget {
  const DateOfCompletionReportPage({
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

class BgContractualLettersReportPage extends StatelessWidget {
  const BgContractualLettersReportPage({
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

class InsuranceContractualLettersReportPage extends StatelessWidget {
  const InsuranceContractualLettersReportPage({
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

class DocContractualLettersReportPage extends StatelessWidget {
  const DocContractualLettersReportPage({
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
