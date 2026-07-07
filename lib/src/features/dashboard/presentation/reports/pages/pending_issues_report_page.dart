import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/report_generate_error.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/issues_report_option.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/report_file_export.dart';

class PendingIssuesReportScreen extends StatefulWidget {
  const PendingIssuesReportScreen({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  State<PendingIssuesReportScreen> createState() =>
      _PendingIssuesReportScreenState();
}

class _PendingIssuesReportScreenState extends State<PendingIssuesReportScreen> {
  bool _loading = false;
  bool _generating = false;

  List<IssuesReportOption> _hodOptions = <IssuesReportOption>[];
  List<IssuesReportOption> _contractOptions = <IssuesReportOption>[];

  IssuesReportOption? _selectedHod;
  IssuesReportOption? _selectedContract;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reloadFilters());
  }

  @override
  Widget build(BuildContext context) {
    final bool canGenerate = _selectedHod != null &&
        _selectedContract != null &&
        !_loading &&
        !_generating;
    final bool hasFilters =
        _selectedHod != null || _selectedContract != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args.formName.trim().isEmpty
              ? 'Pending Issues Report'
              : widget.args.formName,
        ),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppSelectSheetField<IssuesReportOption>(
                      label: 'HOD',
                      title: 'Select HOD',
                      placeholderText: 'Select HOD',
                      items: _hodOptions,
                      value: _selectedHod,
                      enabled: !_loading && !_generating,
                      itemLabelBuilder: (IssuesReportOption option) =>
                          option.label,
                      onChanged: _onHodChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<IssuesReportOption>(
                      label: 'Contract',
                      title: 'Select Contract',
                      placeholderText: 'Select Contract',
                      items: _contractOptions,
                      value: _selectedContract,
                      enabled:
                          !_loading && !_generating && _selectedHod != null,
                      itemLabelBuilder: (IssuesReportOption option) =>
                          option.label,
                      onChanged: (IssuesReportOption value) {
                        setState(() => _selectedContract = value);
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: hasFilters && !_loading && !_generating
                                ? _clearFilters
                                : null,
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
          if (_loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _reloadFilters() async {
    setState(() => _loading = true);
    try {
      final List<List<Map<String, dynamic>>> responses =
          await Future.wait<List<Map<String, dynamic>>>(
        <Future<List<Map<String, dynamic>>>>[
          widget.dataSource.fetchIssuesReportHodList(),
          widget.dataSource.fetchIssuesReportContractList(
            hodUserIdFk: _selectedHod?.value,
          ),
        ],
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _hodOptions = ensureIssuesReportOptionInList(
          _selectedHod,
          dedupeIssuesReportOptions(
            responses[0].map(hodOptionFromRow),
          ),
        );
        _contractOptions = ensureIssuesReportOptionInList(
          _selectedContract,
          dedupeIssuesReportOptions(
            responses[1].map(contractOptionFromRow),
          ),
        );
        _selectedHod = keepIssuesReportOption(_selectedHod, _hodOptions);
        _selectedContract =
            keepIssuesReportOption(_selectedContract, _contractOptions);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load filters',
        message: userFriendlyErrorMessage(error),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _onHodChanged(IssuesReportOption hod) async {
    setState(() {
      _selectedHod = hod;
      _selectedContract = null;
    });
    await _reloadFilters();
  }

  Future<void> _clearFilters() async {
    setState(() {
      _selectedHod = null;
      _selectedContract = null;
    });
    await _reloadFilters();
  }

  Future<void> _generateReport() async {
    final IssuesReportOption? hod = _selectedHod;
    final IssuesReportOption? contract = _selectedContract;
    if (hod == null || contract == null) {
      return;
    }

    setState(() => _generating = true);
    try {
      final ({List<int> bytes, String? fileName}) result =
          await widget.dataSource.generatePendingIssuesReport(
        hodUserIdFk: hod.value,
        contractIdFk: contract.value,
      );
      ensureReportHasData(result.bytes);
      final String fileName = result.fileName?.trim().isNotEmpty == true
          ? result.fileName!.trim()
          : 'pending_issues_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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
