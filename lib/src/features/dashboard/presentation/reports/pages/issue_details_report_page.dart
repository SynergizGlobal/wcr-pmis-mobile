import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/report_form_args.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/issues_report_option.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/widgets/report_file_export.dart';

class IssueDetailsReportScreen extends StatefulWidget {
  const IssueDetailsReportScreen({
    super.key,
    required this.args,
    required this.dataSource,
  });

  final ReportFormArgs args;
  final DashboardRemoteDataSource dataSource;

  @override
  State<IssueDetailsReportScreen> createState() =>
      _IssueDetailsReportScreenState();
}

class _IssueDetailsReportScreenState extends State<IssueDetailsReportScreen> {
  bool _loading = false;
  bool _generating = false;

  List<IssuesReportOption> _hodOptions = <IssuesReportOption>[];
  List<IssuesReportOption> _contractOptions = <IssuesReportOption>[];
  List<IssuesReportOption> _statusOptions = <IssuesReportOption>[];
  List<IssuesReportOption> _locationOptions = <IssuesReportOption>[];
  List<IssuesReportOption> _categoryOptions = <IssuesReportOption>[];
  List<IssuesReportOption> _titleOptions = <IssuesReportOption>[];

  IssuesReportOption? _selectedHod;
  IssuesReportOption? _selectedContract;
  IssuesReportOption? _selectedStatus;
  IssuesReportOption? _selectedLocation;
  IssuesReportOption? _selectedCategory;
  IssuesReportOption? _selectedTitle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reloadFilters());
  }

  @override
  Widget build(BuildContext context) {
    final bool canGenerate = _selectedHod != null &&
        _selectedContract != null &&
        _selectedStatus != null &&
        _selectedLocation != null &&
        _selectedCategory != null &&
        _selectedTitle != null &&
        !_loading &&
        !_generating;
    final bool hasFilters = _selectedHod != null ||
        _selectedContract != null ||
        _selectedStatus != null ||
        _selectedLocation != null ||
        _selectedCategory != null ||
        _selectedTitle != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args.formName.trim().isEmpty
              ? 'Issue Details Report'
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
                      onChanged: _onContractChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<IssuesReportOption>(
                      label: 'Status',
                      title: 'Select Status',
                      placeholderText: 'Select Status',
                      items: _statusOptions,
                      value: _selectedStatus,
                      enabled: !_loading &&
                          !_generating &&
                          _selectedContract != null,
                      itemLabelBuilder: (IssuesReportOption option) =>
                          option.label,
                      onChanged: _onStatusChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<IssuesReportOption>(
                      label: 'Location',
                      title: 'Select Location',
                      placeholderText: 'Select Location',
                      items: _locationOptions,
                      value: _selectedLocation,
                      enabled: !_loading &&
                          !_generating &&
                          _selectedStatus != null,
                      itemLabelBuilder: (IssuesReportOption option) =>
                          option.label,
                      onChanged: _onLocationChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<IssuesReportOption>(
                      label: 'Category',
                      title: 'Select Category',
                      placeholderText: 'Select Category',
                      items: _categoryOptions,
                      value: _selectedCategory,
                      enabled: !_loading &&
                          !_generating &&
                          _selectedLocation != null,
                      itemLabelBuilder: (IssuesReportOption option) =>
                          option.label,
                      onChanged: _onCategoryChanged,
                    ),
                    const SizedBox(height: 14),
                    AppSelectSheetField<IssuesReportOption>(
                      label: 'Title',
                      title: 'Select Title',
                      placeholderText: 'Select Title',
                      items: _titleOptions,
                      value: _selectedTitle,
                      enabled: !_loading &&
                          !_generating &&
                          _selectedCategory != null,
                      itemLabelBuilder: (IssuesReportOption option) =>
                          option.label,
                      onChanged: (IssuesReportOption value) {
                        setState(() => _selectedTitle = value);
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
          widget.dataSource.fetchIssuesReportStatusList(
            hodUserIdFk: _selectedHod?.value,
            contractIdFk: _selectedContract?.value,
          ),
          widget.dataSource.fetchIssuesReportLocationList(
            hodUserIdFk: _selectedHod?.value,
            contractIdFk: _selectedContract?.value,
            statusFk: _selectedStatus?.value,
          ),
          widget.dataSource.fetchIssuesReportCategoryList(
            hodUserIdFk: _selectedHod?.value,
            contractIdFk: _selectedContract?.value,
            statusFk: _selectedStatus?.value,
            location: _selectedLocation?.value,
          ),
          widget.dataSource.fetchIssuesReportTitleList(
            hodUserIdFk: _selectedHod?.value,
            contractIdFk: _selectedContract?.value,
            statusFk: _selectedStatus?.value,
            location: _selectedLocation?.value,
            categoryFk: _selectedCategory?.value,
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
        _statusOptions = ensureIssuesReportOptionInList(
          _selectedStatus,
          dedupeIssuesReportOptions(
            responses[2].map(statusOptionFromRow),
          ),
        );
        _locationOptions = ensureIssuesReportOptionInList(
          _selectedLocation,
          dedupeIssuesReportOptions(
            responses[3].map(locationOptionFromRow),
          ),
        );
        _categoryOptions = ensureIssuesReportOptionInList(
          _selectedCategory,
          dedupeIssuesReportOptions(
            responses[4].map(categoryOptionFromRow),
          ),
        );
        _titleOptions = ensureIssuesReportOptionInList(
          _selectedTitle,
          dedupeIssuesReportOptions(
            responses[5].map(titleOptionFromRow),
          ),
        );
        _selectedHod = keepIssuesReportOption(_selectedHod, _hodOptions);
        _selectedContract =
            keepIssuesReportOption(_selectedContract, _contractOptions);
        _selectedStatus =
            keepIssuesReportOption(_selectedStatus, _statusOptions);
        _selectedLocation =
            keepIssuesReportOption(_selectedLocation, _locationOptions);
        _selectedCategory =
            keepIssuesReportOption(_selectedCategory, _categoryOptions);
        _selectedTitle =
            keepIssuesReportOption(_selectedTitle, _titleOptions);
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
      _selectedStatus = null;
      _selectedLocation = null;
      _selectedCategory = null;
      _selectedTitle = null;
    });
    await _reloadFilters();
  }

  Future<void> _onContractChanged(IssuesReportOption contract) async {
    setState(() {
      _selectedContract = contract;
      _selectedStatus = null;
      _selectedLocation = null;
      _selectedCategory = null;
      _selectedTitle = null;
    });
    await _reloadFilters();
  }

  Future<void> _onStatusChanged(IssuesReportOption status) async {
    setState(() {
      _selectedStatus = status;
      _selectedLocation = null;
      _selectedCategory = null;
      _selectedTitle = null;
    });
    await _reloadFilters();
  }

  Future<void> _onLocationChanged(IssuesReportOption location) async {
    setState(() {
      _selectedLocation = location;
      _selectedCategory = null;
      _selectedTitle = null;
    });
    await _reloadFilters();
  }

  Future<void> _onCategoryChanged(IssuesReportOption category) async {
    setState(() {
      _selectedCategory = category;
      _selectedTitle = null;
    });
    await _reloadFilters();
  }

  Future<void> _clearFilters() async {
    setState(() {
      _selectedHod = null;
      _selectedContract = null;
      _selectedStatus = null;
      _selectedLocation = null;
      _selectedCategory = null;
      _selectedTitle = null;
    });
    await _reloadFilters();
  }

  Future<void> _generateReport() async {
    final IssuesReportOption? hod = _selectedHod;
    final IssuesReportOption? contract = _selectedContract;
    final IssuesReportOption? status = _selectedStatus;
    final IssuesReportOption? location = _selectedLocation;
    final IssuesReportOption? category = _selectedCategory;
    final IssuesReportOption? title = _selectedTitle;
    if (hod == null ||
        contract == null ||
        status == null ||
        location == null ||
        category == null ||
        title == null) {
      return;
    }

    setState(() => _generating = true);
    try {
      final ({List<int> bytes, String? fileName}) result =
          await widget.dataSource.generateIssueDetailsReport(
        hodUserIdFk: hod.value,
        contractIdFk: contract.value,
        statusFk: status.value,
        location: location.value,
        categoryFk: category.value,
        issueId: title.value,
      );
      if (result.bytes.isEmpty) {
        throw Exception('Empty report received from server.');
      }
      final String fileName = result.fileName?.trim().isNotEmpty == true
          ? result.fileName!.trim()
          : 'issue_details_report_${DateTime.now().millisecondsSinceEpoch}.docx';
      final String path = await ReportFileExport.save(
        fileName: fileName,
        mimeType:
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
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
