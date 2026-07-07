import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/report_generate_error.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/report_file_export.dart';

class IssuesSummaryReportScreen extends StatefulWidget {
  const IssuesSummaryReportScreen({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  State<IssuesSummaryReportScreen> createState() =>
      _IssuesSummaryReportScreenState();
}

class _IssuesSummaryReportScreenState extends State<IssuesSummaryReportScreen> {
  bool _generating = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args.formName.trim().isEmpty
              ? 'Issues Summary Report'
              : widget.args.formName,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.summarize_outlined,
                    size: 56,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Issues Summary Report',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generates the full issues summary report (ALL).',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _generating ? null : _generateReport,
                      child: _generating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Generate Report'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateReport() async {
    setState(() => _generating = true);
    try {
      final ({List<int> bytes, String? fileName}) result =
          await widget.dataSource.fetchIssuesSummaryReport();
      ensureReportHasData(result.bytes);
      final String fileName = result.fileName?.trim().isNotEmpty == true
          ? result.fileName!.trim()
          : 'issues_summary_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final String path = await ReportFileExport.save(
        fileName: fileName,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        bytes: result.bytes,
      );
      if (!mounted) {
        return;
      }
      await ReportFileExport.showGeneratedDialog(
        context: context,
        savedPath: path,
        bytes: result.bytes,
        fileName: fileName,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: reportErrorTitle(error),
        message: reportErrorMessage(error),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _generating = false);
      }
    }
  }
}
