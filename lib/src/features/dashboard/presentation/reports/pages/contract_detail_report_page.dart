import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/contract_detail_report_option.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/report_file_export.dart';

class ContractDetailReportScreen extends StatefulWidget {
  const ContractDetailReportScreen({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  State<ContractDetailReportScreen> createState() =>
      _ContractDetailReportScreenState();
}

class _ContractDetailReportScreenState extends State<ContractDetailReportScreen> {
  bool _loading = false;
  bool _generating = false;

  List<ContractDetailReportOption> _projectOptions =
      <ContractDetailReportOption>[];
  List<ContractDetailReportOption> _contractOptions =
      <ContractDetailReportOption>[];
  List<ContractDetailReportOption> _contractorOptions =
      <ContractDetailReportOption>[];
  List<ContractDetailReportOption> _statusOptions =
      <ContractDetailReportOption>[];
  List<ContractDetailReportOption> _hodOptions = <ContractDetailReportOption>[];

  ContractDetailReportOption? _selectedProject;
  ContractDetailReportOption? _selectedContract;
  ContractDetailReportOption? _selectedContractor;
  ContractDetailReportOption? _selectedStatus;
  ContractDetailReportOption? _selectedHod;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  @override
  Widget build(BuildContext context) {
    final bool canGenerate =
        _selectedContract != null && !_loading && !_generating;
    final bool hasFilters = _selectedProject != null ||
        _selectedContract != null ||
        _selectedContractor != null ||
        _selectedStatus != null ||
        _selectedHod != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args.formName.trim().isEmpty
              ? 'Contract Detail Report'
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
                    AppSelectSheetField<ContractDetailReportOption>(
                      label: 'Project',
                      title: 'Select Project',
                      placeholderText: 'Select Project',
                      items: _projectOptions,
                      value: _selectedProject,
                      enabled: !_loading && !_generating,
                      itemLabelBuilder: (ContractDetailReportOption option) =>
                          option.label,
                      onChanged: _onProjectChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<ContractDetailReportOption>(
                      label: 'Contract',
                      title: 'Select Contract',
                      placeholderText: 'Select Contract',
                      items: _contractOptions,
                      value: _selectedContract,
                      enabled: !_loading && !_generating,
                      itemLabelBuilder: (ContractDetailReportOption option) =>
                          option.label,
                      onChanged: _onContractChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<ContractDetailReportOption>(
                      label: 'Contractor',
                      title: 'Select Contractor',
                      placeholderText: 'Select Contractor',
                      items: _contractorOptions,
                      value: _selectedContractor,
                      enabled:
                          !_loading && !_generating && _selectedContract != null,
                      itemLabelBuilder: (ContractDetailReportOption option) =>
                          option.label,
                      onChanged: _onContractorChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<ContractDetailReportOption>(
                      label: 'Status of Work',
                      title: 'Select Status of Work',
                      placeholderText: 'Select Status of Work',
                      items: _statusOptions,
                      value: _selectedStatus,
                      enabled: !_loading &&
                          !_generating &&
                          _selectedContractor != null,
                      itemLabelBuilder: (ContractDetailReportOption option) =>
                          option.label,
                      onChanged: _onStatusChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<ContractDetailReportOption>(
                      label: 'HOD',
                      title: 'Select HOD',
                      placeholderText: 'Select HOD',
                      items: _hodOptions,
                      value: _selectedHod,
                      enabled: !_loading &&
                          !_generating &&
                          _selectedStatus != null,
                      itemLabelBuilder: (ContractDetailReportOption option) =>
                          option.label,
                      onChanged: (ContractDetailReportOption value) {
                        setState(() => _selectedHod = value);
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

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    try {
      final List<Map<String, dynamic>> projects =
          await widget.dataSource.fetchContractDetailReportProjectList();
      if (!mounted) {
        return;
      }
      setState(() {
        _projectOptions = dedupeContractDetailReportOptions(
          projects.map(projectOptionFromRow),
        );
      });
      await _reloadFilters();
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

  Future<void> _reloadFilters() async {
    setState(() => _loading = true);
    try {
      final List<List<Map<String, dynamic>>> responses =
          await Future.wait<List<Map<String, dynamic>>>(
        <Future<List<Map<String, dynamic>>>>[
          widget.dataSource.fetchContractDetailReportContractList(
            projectIdFk: _selectedProject?.value,
          ),
          widget.dataSource.fetchContractDetailReportContractorList(
            projectIdFk: _selectedProject?.value,
            contractId: _selectedContract?.value,
          ),
          widget.dataSource.fetchContractDetailReportStatusList(
            projectIdFk: _selectedProject?.value,
            contractId: _selectedContract?.value,
            contractorIdFk: _selectedContractor?.value,
          ),
          widget.dataSource.fetchContractDetailReportHodList(
            projectIdFk: _selectedProject?.value,
            contractId: _selectedContract?.value,
            contractorIdFk: _selectedContractor?.value,
            contractStatusFk: _selectedStatus?.value,
          ),
        ],
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _contractOptions = ensureContractDetailReportOptionInList(
          _selectedContract,
          dedupeContractDetailReportOptions(
            responses[0].map(contractOptionFromRow),
          ),
        );
        _contractorOptions = ensureContractDetailReportOptionInList(
          _selectedContractor,
          dedupeContractDetailReportOptions(
            responses[1].map(contractorOptionFromRow),
          ),
        );
        _statusOptions = ensureContractDetailReportOptionInList(
          _selectedStatus,
          dedupeContractDetailReportOptions(
            responses[2].map(contractStatusOptionFromRow),
          ),
        );
        _hodOptions = ensureContractDetailReportOptionInList(
          _selectedHod,
          dedupeContractDetailReportOptions(
            responses[3].map(hodOptionFromRow),
          ),
        );
        _selectedProject =
            keepContractDetailReportOption(_selectedProject, _projectOptions);
        _selectedContract =
            keepContractDetailReportOption(_selectedContract, _contractOptions);
        _selectedContractor = keepContractDetailReportOption(
          _selectedContractor,
          _contractorOptions,
        );
        _selectedStatus =
            keepContractDetailReportOption(_selectedStatus, _statusOptions);
        _selectedHod =
            keepContractDetailReportOption(_selectedHod, _hodOptions);
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

  Future<void> _onProjectChanged(ContractDetailReportOption project) async {
    setState(() {
      _selectedProject = project;
      _selectedContract = null;
      _selectedContractor = null;
      _selectedStatus = null;
      _selectedHod = null;
    });
    await _reloadFilters();
  }

  Future<void> _onContractChanged(ContractDetailReportOption contract) async {
    setState(() {
      _selectedContract = contract;
      _selectedContractor = null;
      _selectedStatus = null;
      _selectedHod = null;
    });
    await _reloadFilters();
  }

  Future<void> _onContractorChanged(
    ContractDetailReportOption contractor,
  ) async {
    setState(() {
      _selectedContractor = contractor;
      _selectedStatus = null;
      _selectedHod = null;
    });
    await _reloadFilters();
  }

  Future<void> _onStatusChanged(ContractDetailReportOption status) async {
    setState(() {
      _selectedStatus = status;
      _selectedHod = null;
    });
    await _reloadFilters();
  }

  Future<void> _clearFilters() async {
    setState(() {
      _selectedProject = null;
      _selectedContract = null;
      _selectedContractor = null;
      _selectedStatus = null;
      _selectedHod = null;
    });
    await _reloadFilters();
  }

  Future<void> _generateReport() async {
    final ContractDetailReportOption? contract = _selectedContract;
    if (contract == null) {
      return;
    }

    setState(() => _generating = true);
    try {
      final ({List<int> bytes, String? fileName}) result =
          await widget.dataSource.generateContractDetailReport(
        contractId: contract.value,
        projectIdFk: _selectedProject?.value,
        hodDesignations: _selectedHod?.value,
        contractorIdFk: _selectedContractor?.value,
        contractStatusFk: _selectedStatus?.value,
      );
      if (result.bytes.isEmpty) {
        throw Exception('Empty report received from server.');
      }
      final String fileName = result.fileName?.trim().isNotEmpty == true
          ? result.fileName!.trim()
          : 'contract_detail_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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
