import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/bg_contractual_letters_report_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/bg_insurance_report_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/contract_completion_report_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/contract_detail_report_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/pages/list_of_contracts_report_page.dart';
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
    return ContractDetailReportScreen(
      args: args,
      dataSource: dataSource,
    );
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
    return ListOfContractsReportScreen(
      args: args,
      dataSource: dataSource,
    );
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
    return BgInsuranceReportScreen(
      args: args,
      dataSource: dataSource,
    );
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
    return ContractCompletionReportScreen(
      args: args,
      dataSource: dataSource,
    );
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
    return BgContractualLettersReportScreen(
      args: args,
      dataSource: dataSource,
    );
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
