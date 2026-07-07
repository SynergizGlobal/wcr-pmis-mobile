import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/report_generate_error.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/report_file_export.dart';

class _UtilityReportOption {
  const _UtilityReportOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  bool operator ==(Object other) {
    return other is _UtilityReportOption && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class UtilityShiftingReportScreen extends StatefulWidget {
  const UtilityShiftingReportScreen({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  State<UtilityShiftingReportScreen> createState() =>
      _UtilityShiftingReportScreenState();
}

class _UtilityShiftingReportScreenState
    extends State<UtilityShiftingReportScreen> {
  bool _loading = false;
  bool _generating = false;

  List<_UtilityReportOption> _projectOptions = <_UtilityReportOption>[];
  List<_UtilityReportOption> _agencyOptions = <_UtilityReportOption>[];
  List<_UtilityReportOption> _contractOptions = <_UtilityReportOption>[];
  List<_UtilityReportOption> _hodOptions = <_UtilityReportOption>[];

  _UtilityReportOption? _selectedProject;
  _UtilityReportOption? _selectedAgency;
  _UtilityReportOption? _selectedContract;
  _UtilityReportOption? _selectedHod;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reloadFilters());
  }

  @override
  Widget build(BuildContext context) {
    final bool canGenerate = _selectedProject != null &&
        _selectedAgency != null &&
        _selectedContract != null &&
        _selectedHod != null &&
        !_loading &&
        !_generating;
    final bool hasFilters = _selectedProject != null ||
        _selectedAgency != null ||
        _selectedContract != null ||
        _selectedHod != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args.formName.trim().isEmpty
              ? 'Utility Shifting Report'
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
                    AppSelectSheetField<_UtilityReportOption>(
                      label: 'Project',
                      title: 'Select Project',
                      placeholderText: 'Select Project',
                      items: _projectOptions,
                      value: _selectedProject,
                      enabled: !_loading && !_generating,
                      itemLabelBuilder: (_UtilityReportOption option) =>
                          option.label,
                      onChanged: _onProjectChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<_UtilityReportOption>(
                      label: 'Execution Agency',
                      title: 'Select Execution Agency',
                      placeholderText: 'Select Execution Agency',
                      items: _agencyOptions,
                      value: _selectedAgency,
                      enabled:
                          !_loading && !_generating && _selectedProject != null,
                      itemLabelBuilder: (_UtilityReportOption option) =>
                          option.label,
                      onChanged: _onAgencyChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<_UtilityReportOption>(
                      label: 'Impacted Contract',
                      title: 'Select Impacted Contract',
                      placeholderText: 'Select Impacted Contract',
                      items: _contractOptions,
                      value: _selectedContract,
                      enabled:
                          !_loading && !_generating && _selectedAgency != null,
                      itemLabelBuilder: (_UtilityReportOption option) =>
                          option.label,
                      onChanged: _onContractChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<_UtilityReportOption>(
                      label: 'HOD',
                      title: 'Select HOD',
                      placeholderText: 'Select HOD',
                      items: _hodOptions,
                      value: _selectedHod,
                      enabled: !_loading &&
                          !_generating &&
                          _selectedContract != null,
                      itemLabelBuilder: (_UtilityReportOption option) =>
                          option.label,
                      onChanged: (_UtilityReportOption value) {
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

  Future<void> _reloadFilters() async {
    setState(() => _loading = true);
    try {
      final String? projectId = _selectedProject?.value;
      final String? agencyId = _selectedAgency?.value;
      final String? contractId = _selectedContract?.value;
      final List<Map<String, dynamic>> responses =
          await Future.wait<Map<String, dynamic>>(
        <Future<Map<String, dynamic>>>[
          widget.dataSource.fetchUtilityReportFilters(),
          widget.dataSource.fetchUtilityReportFilters(
            projectIdFk: projectId,
          ),
          widget.dataSource.fetchUtilityReportFilters(
            projectIdFk: projectId,
            executionAgencyFk: agencyId,
          ),
          widget.dataSource.fetchUtilityReportFilters(
            projectIdFk: projectId,
            executionAgencyFk: agencyId,
            contractIdFk: contractId,
          ),
        ],
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _projectOptions = _ensureOptionInList(
          _selectedProject,
          _dedupeOptions(
            _rowsFromResponse(responses[0], 'projectsList').map(_projectOption),
          ),
        );
        _agencyOptions = _ensureOptionInList(
          _selectedAgency,
          _dedupeOptions(
            _rowsFromResponse(responses[1], 'executionAgency').map(_agencyOption),
          ),
        );
        _contractOptions = _ensureOptionInList(
          _selectedContract,
          _dedupeOptions(
            _rowsFromResponse(responses[2], 'impactedContractsList')
                .map(_contractOption),
          ),
        );
        _hodOptions = _ensureOptionInList(
          _selectedHod,
          _dedupeOptions(
            _rowsFromResponse(responses[3], 'utilityHODList').map(_hodOption),
          ),
        );
        _selectedProject = _keepOrClear(
          _selectedProject,
          _projectOptions,
        );
        _selectedAgency = _keepOrClear(_selectedAgency, _agencyOptions);
        _selectedContract = _keepOrClear(_selectedContract, _contractOptions);
        _selectedHod = _keepOrClear(_selectedHod, _hodOptions);
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

  Future<void> _onProjectChanged(_UtilityReportOption project) async {
    setState(() {
      _selectedProject = project;
      _selectedAgency = null;
      _selectedContract = null;
      _selectedHod = null;
    });
    await _reloadFilters();
  }

  Future<void> _onAgencyChanged(_UtilityReportOption agency) async {
    setState(() {
      _selectedAgency = agency;
      _selectedContract = null;
      _selectedHod = null;
    });
    await _reloadFilters();
  }

  Future<void> _onContractChanged(_UtilityReportOption contract) async {
    setState(() {
      _selectedContract = contract;
      _selectedHod = null;
    });
    await _reloadFilters();
  }

  Future<void> _clearFilters() async {
    setState(() {
      _selectedProject = null;
      _selectedAgency = null;
      _selectedContract = null;
      _selectedHod = null;
    });
    await _reloadFilters();
  }

  Future<void> _generateReport() async {
    final _UtilityReportOption? project = _selectedProject;
    final _UtilityReportOption? agency = _selectedAgency;
    final _UtilityReportOption? contract = _selectedContract;
    final _UtilityReportOption? hod = _selectedHod;
    if (project == null ||
        agency == null ||
        contract == null ||
        hod == null) {
      return;
    }

    setState(() => _generating = true);
    try {
      final ({Uint8List bytes, String? fileName}) result =
          await widget.dataSource.generateUtilityShiftingReport(
        projectIdFk: project.value,
        executionAgencyFk: agency.value,
        contractIdFk: contract.value,
        hodUserIdFk: hod.value,
      );
      ensureReportHasData(result.bytes);
      final String fileName = result.fileName?.trim().isNotEmpty == true
          ? result.fileName!.trim()
          : 'utility_shifting_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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

  List<Map<String, dynamic>> _rowsFromResponse(
    Map<String, dynamic> response,
    String key,
  ) {
    final dynamic raw = response[key] ?? response['data']?[key];
    if (raw is! List) {
      return const <Map<String, dynamic>>[];
    }
    return raw
        .whereType<Map>()
        .map(
          (Map<dynamic, dynamic> row) => Map<String, dynamic>.from(
            row.map(
              (dynamic key, dynamic value) => MapEntry(key.toString(), value),
            ),
          ),
        )
        .toList();
  }

  _UtilityReportOption? _keepOrClear(
    _UtilityReportOption? selected,
    List<_UtilityReportOption> options,
  ) {
    if (selected == null) {
      return null;
    }
    for (final _UtilityReportOption option in options) {
      if (option.value == selected.value) {
        return option;
      }
    }
    return null;
  }

  List<_UtilityReportOption> _ensureOptionInList(
    _UtilityReportOption? selected,
    List<_UtilityReportOption> options,
  ) {
    if (selected == null) {
      return options;
    }
    final bool hasSelected = options.any(
      (_UtilityReportOption option) => option.value == selected.value,
    );
    if (hasSelected) {
      return options;
    }
    return <_UtilityReportOption>[selected, ...options];
  }

  List<_UtilityReportOption> _dedupeOptions(
    Iterable<_UtilityReportOption?> options,
  ) {
    final Map<String, _UtilityReportOption> unique =
        <String, _UtilityReportOption>{};
    for (final _UtilityReportOption? option in options) {
      if (option == null || option.value.isEmpty) {
        continue;
      }
      unique.putIfAbsent(option.value, () => option);
    }
    final List<_UtilityReportOption> sorted = unique.values.toList()
      ..sort(
        (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
      );
    return sorted;
  }

  _UtilityReportOption? _projectOption(Map<String, dynamic> row) {
    final String id = _string(row['project_id_fk']).isNotEmpty
        ? _string(row['project_id_fk'])
        : _string(row['project_id']);
    if (id.isEmpty) {
      return null;
    }
    final String name = _string(row['project_name']);
    final String label = name.isEmpty ? id : '$id - $name';
    return _UtilityReportOption(value: id, label: label);
  }

  _UtilityReportOption? _agencyOption(Map<String, dynamic> row) {
    final String value = _string(row['execution_agency_fk']).isNotEmpty
        ? _string(row['execution_agency_fk'])
        : _string(row['executed_by']);
    if (value.isEmpty) {
      return null;
    }
    return _UtilityReportOption(value: value, label: value);
  }

  _UtilityReportOption? _contractOption(Map<String, dynamic> row) {
    final String id = _string(row['contract_id_fk']).isNotEmpty
        ? _string(row['contract_id_fk'])
        : _string(row['impacted_contract_id_fk']);
    if (id.isEmpty) {
      return null;
    }
    final String shortName = _string(row['contract_short_name']);
    final String contractName = _string(row['contract_name']);
    final String name = shortName.isNotEmpty ? shortName : contractName;
    final String label = name.isEmpty ? id : '$id - $name';
    return _UtilityReportOption(value: id, label: label);
  }

  _UtilityReportOption? _hodOption(Map<String, dynamic> row) {
    final String id = _string(row['hod_user_id_fk']);
    if (id.isEmpty) {
      return null;
    }
    final String userName = _string(row['user_name']);
    final String designation = _string(row['designation']);
    final String label = userName.isEmpty
        ? id
        : designation.isEmpty
            ? userName
            : '$userName - $designation';
    return _UtilityReportOption(value: id, label: label);
  }

  String _string(dynamic value) => value?.toString().trim() ?? '';
}
