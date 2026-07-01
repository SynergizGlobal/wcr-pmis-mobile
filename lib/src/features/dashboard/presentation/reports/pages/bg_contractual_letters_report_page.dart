import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_date_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/report_file_export.dart';

class BgContractualLettersReportScreen extends StatefulWidget {
  const BgContractualLettersReportScreen({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  State<BgContractualLettersReportScreen> createState() =>
      _BgContractualLettersReportScreenState();
}

class _BgContractualLettersReportScreenState
    extends State<BgContractualLettersReportScreen> {
  bool _generating = false;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final bool canGenerate =
        _startDate != null && _endDate != null && !_generating;
    final bool hasFilters = _startDate != null || _endDate != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args.formName.trim().isEmpty
              ? 'BG Contractual Letters'
              : widget.args.formName,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDateField(
                  label: 'Start Date',
                  value: _startDate,
                  enabled: !_generating,
                  onChanged: (DateTime date) {
                    setState(() => _startDate = date);
                  },
                ),
                const SizedBox(height: 14),
                AppDateField(
                  label: 'End Date',
                  value: _endDate,
                  enabled: !_generating,
                  onChanged: (DateTime date) {
                    setState(() => _endDate = date);
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            hasFilters && !_generating ? _clearFilters : null,
                        child: const Text('Clear Filter'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: canGenerate ? _generateReport : null,
                        child: _generating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Generate Report'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _generateReport() async {
    final DateTime? startDate = _startDate;
    final DateTime? endDate = _endDate;
    if (startDate == null || endDate == null) {
      return;
    }

    setState(() => _generating = true);
    try {
      final ({List<int> bytes, String? fileName}) result =
          await widget.dataSource.generateBgContractualLettersReport(
        dateOfStart: AppDateField.apiFormat.format(startDate),
        bgDate: AppDateField.apiFormat.format(endDate),
      );
      if (result.bytes.isEmpty) {
        throw Exception('Empty report received from server.');
      }
      final String fileName = result.fileName?.trim().isNotEmpty == true
          ? result.fileName!.trim()
          : 'bg_contractual_letters_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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
        title: 'Generate Failed',
        message: userFriendlyErrorMessage(error),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _generating = false);
      }
    }
  }
}
