import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/report_generate_error.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/activities_export_option.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/report_file_export.dart';

class ContractWiseActivitiesReportScreen extends StatefulWidget {
  const ContractWiseActivitiesReportScreen({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  State<ContractWiseActivitiesReportScreen> createState() =>
      _ContractWiseActivitiesReportScreenState();
}

class _ContractWiseActivitiesReportScreenState
    extends State<ContractWiseActivitiesReportScreen> {
  bool _loading = false;
  bool _generating = false;

  List<ActivitiesExportOption> _projectOptions = <ActivitiesExportOption>[];
  List<ActivitiesExportOption> _contractOptions = <ActivitiesExportOption>[];

  ActivitiesExportOption? _selectedProject;
  ActivitiesExportOption? _selectedContract;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reloadFilters());
  }

  @override
  Widget build(BuildContext context) {
    final bool canGenerate = _selectedProject != null &&
        _selectedContract != null &&
        !_loading &&
        !_generating;
    final bool hasFilters =
        _selectedProject != null || _selectedContract != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args.formName.trim().isEmpty
              ? 'Contract Wise Activities Report'
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
                    AppSelectSheetField<ActivitiesExportOption>(
                      label: 'Project',
                      title: 'Select Project',
                      placeholderText: 'Select Project',
                      items: _projectOptions,
                      value: _selectedProject,
                      enabled: !_loading && !_generating,
                      itemLabelBuilder: (ActivitiesExportOption option) =>
                          option.label,
                      onChanged: _onProjectChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<ActivitiesExportOption>(
                      label: 'Contract',
                      title: 'Select Contract',
                      placeholderText: 'Select Contract',
                      items: _contractOptions,
                      value: _selectedContract,
                      enabled:
                          !_loading && !_generating && _selectedProject != null,
                      itemLabelBuilder: (ActivitiesExportOption option) =>
                          option.label,
                      onChanged: (ActivitiesExportOption value) {
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
          widget.dataSource.fetchActivitiesExportProjectList(),
          widget.dataSource.fetchActivitiesExportContractList(
            projectId: _selectedProject?.value,
          ),
        ],
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _projectOptions = dedupeActivitiesExportOptions(
          responses[0].map(projectOptionFromRow),
        );
        _contractOptions = dedupeActivitiesExportOptions(
          responses[1]
              .where(
                (Map<String, dynamic> row) =>
                    _selectedProject == null ||
                    contractBelongsToProject(row, _selectedProject!.value),
              )
              .map(contractOptionFromRow),
        );
        _selectedProject =
            keepActivitiesExportOption(_selectedProject, _projectOptions);
        _selectedContract =
            keepActivitiesExportOption(_selectedContract, _contractOptions);
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

  Future<void> _onProjectChanged(ActivitiesExportOption project) async {
    setState(() {
      _selectedProject = project;
      _selectedContract = null;
    });
    await _reloadFilters();
  }

  Future<void> _clearFilters() async {
    setState(() {
      _selectedProject = null;
      _selectedContract = null;
    });
    await _reloadFilters();
  }

  Future<void> _generateReport() async {
    final ActivitiesExportOption? project = _selectedProject;
    final ActivitiesExportOption? contract = _selectedContract;
    if (project == null || contract == null) {
      return;
    }

    setState(() => _generating = true);
    try {
      final ({List<int> bytes, String? fileName}) result =
          await widget.dataSource.generateContractWiseActivitiesReport(
        projectId: project.value,
        contractIdFk: contract.value,
      );
      ensureReportHasData(result.bytes);
      final String fileName = result.fileName?.trim().isNotEmpty == true
          ? result.fileName!.trim()
          : 'contract_wise_activities_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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
