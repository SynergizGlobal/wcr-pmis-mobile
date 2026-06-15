import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/contracts/contract_form_page.dart';

class ContractsPage extends StatefulWidget {
  const ContractsPage({super.key, required this.dataSource});

  static const String routeName = 'contracts';
  static const String routePath = '/contracts';

  final DashboardRemoteDataSource dataSource;

  @override
  State<ContractsPage> createState() => _ContractsPageState();
}

class _ContractsPageState extends State<ContractsPage> {
  static const MethodChannel _fileExportChannel = MethodChannel(
    'wcr_pmis_mobile/file_export',
  );
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50, 100];
  static const List<String> _headers = <String>[
    'Project',
    'Contract ID',
    'Contract Name',
    'Contractor Name',
    'Department',
    'HOD',
    'Dy HOD',
    'Last Update',
    'Action',
  ];
  static const List<String> _exportHeaders = <String>[
    'Project',
    'Contract ID',
    'Contract Name',
    'Contractor Name',
    'Department',
    'HOD',
    'Dy HOD',
    'Last Update',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  bool _loading = false;

  String? _selectedHod;
  String? _selectedDyHod;
  String? _selectedContractor;
  String? _selectedContractStatus;
  String? _selectedWorkStatus;

  int _pageSize = 10;
  int _currentPage = 0;

  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  List<_ContractFilterOption> _hodOptions = <_ContractFilterOption>[];
  List<_ContractFilterOption> _dyHodOptions = <_ContractFilterOption>[];
  List<_ContractFilterOption> _contractorOptions = <_ContractFilterOption>[];
  List<_ContractFilterOption> _contractStatusOptions =
      <_ContractFilterOption>[];
  List<_ContractFilterOption> _workStatusOptions = <_ContractFilterOption>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reloadAll());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filteredRows = _filteredRows(_rows);
    final int total = filteredRows.length;
    final int pageCount = total == 0 ? 1 : (total / _pageSize).ceil();
    if (_currentPage >= pageCount) {
      _currentPage = pageCount - 1;
    }
    final int start = total == 0 ? 0 : (_currentPage * _pageSize);
    final int end = total == 0 ? 0 : (start + _pageSize).clamp(0, total);
    final List<Map<String, dynamic>> pageRows = total == 0
        ? const <Map<String, dynamic>>[]
        : filteredRows.sublist(start, end);

    return Scaffold(
      appBar: AppBar(title: const Text('Contract')),
      bottomNavigationBar: _stickyFooter(total: total, start: start, end: end),
      body: Stack(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  _toolbar(context, filteredRows),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: _tableCard(context, pageRows),
                    ),
                  ),
                ],
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

  Widget _toolbar(BuildContext context, List<Map<String, dynamic>> rows) {
    final bool canExport = rows.isNotEmpty;
    final int activeFilterCount = _activeFilterCount;
    final bool narrow = MediaQuery.sizeOf(context).width < 720;
    final Widget entriesControl = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text('Show ', style: TextStyle(fontSize: 12)),
        DropdownButton<int>(
          value: _pageSize,
          items: _pageSizeOptions
              .map(
                (int e) => DropdownMenuItem<int>(
                  value: e,
                  child: Text('$e'),
                ),
              )
              .toList(),
          onChanged: (int? value) {
            if (value == null) {
              return;
            }
            setState(() {
              _pageSize = value;
              _currentPage = 0;
            });
          },
        ),
        const Text(' entries', style: TextStyle(fontSize: 12)),
      ],
    );
    final Widget searchField = SizedBox(
      width: narrow ? double.infinity : 240,
      child: TextField(
        controller: _searchController,
        onChanged: (String value) => setState(() {
          _search = value.trim();
          _currentPage = 0;
        }),
        decoration: InputDecoration(
          hintText: 'Search contracts...',
          isDense: true,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear',
                  onPressed: () => setState(() {
                    _searchController.clear();
                    _search = '';
                    _currentPage = 0;
                  }),
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );
    final Widget actionsBox = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(
            alpha: 0.6,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _openFilterDialog,
                  icon: const Icon(Icons.filter_alt_rounded),
                  label: Text('Filter ($activeFilterCount)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: activeFilterCount > 0 ? _clearFilters : null,
                  icon: const Icon(Icons.filter_alt_off_rounded),
                  label: const Text('Clear Filter'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canExport ? () => _confirmExportExcel(rows) : null,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Export Excel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _onAddTap,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 1,
          top: 12,
          right: 12,
          left: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            narrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      searchField,
                      const SizedBox(height: 2),
                      entriesControl,
                    ],
                  )
                : Row(
                    children: <Widget>[
                      searchField,
                      const Spacer(),
                      entriesControl,
                    ],
                  ),
            actionsBox,
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _tableCard(BuildContext context, List<Map<String, dynamic>> rows) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double tableWidth = _headers.fold<double>(
      0,
      (double sum, String item) => sum + _columnWidth(item),
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: constraints.maxHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: <Widget>[
                    _tableHeader(context),
                    Expanded(
                      child: rows.isEmpty
                          ? const Center(
                              child: Text('No contract records found.'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 10),
                              itemCount: rows.length,
                              itemBuilder: (BuildContext context, int index) =>
                                  _tableRow(
                                    context,
                                    rows[index],
                                    index,
                                    isLast: index == rows.length - 1,
                                  ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tableHeader(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: _headers
            .map(
              (String title) => _cell(
                title,
                width: _columnWidth(title),
                color: colorScheme.onPrimary,
                weight: FontWeight.w700,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _tableRow(
    BuildContext context,
    Map<String, dynamic> row,
    int index, {
    bool isLast = false,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color bg = index.isEven
        ? colorScheme.primary.withValues(alpha: 0.08)
        : colorScheme.surface;
    final BorderRadius? rowRadius = isLast
        ? const BorderRadius.vertical(bottom: Radius.circular(14))
        : null;
    return ClipRRect(
      borderRadius: rowRadius ?? BorderRadius.zero,
      child: Container(
        color: bg,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: <Widget>[
            _cell(
              _stringValue(row['project_name']),
              width: _columnWidth('Project'),
            ),
            _cell(
              _stringValue(row['contract_id']),
              width: _columnWidth('Contract ID'),
            ),
            _cell(
              _contractName(row),
              width: _columnWidth('Contract Name'),
            ),
            _cell(
              _stringValue(row['contractor_name']),
              width: _columnWidth('Contractor Name'),
            ),
            _cell(
              _stringValue(row['department_name']),
              width: _columnWidth('Department'),
            ),
            _cell(
              _stringValue(row['designation']),
              width: _columnWidth('HOD'),
            ),
            _cell(
              _stringValue(row['dy_hod_designation']),
              width: _columnWidth('Dy HOD'),
            ),
            _cell(
              _lastUpdate(row),
              width: _columnWidth('Last Update'),
            ),
            SizedBox(
              width: _columnWidth('Action'),
              child: Center(
                child: IconButton(
                  tooltip: 'Edit',
                  onPressed: () => _onEditTap(row),
                  icon: Icon(Icons.edit_note_rounded, color: colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(
    String value, {
    required double width,
    Color? color,
    FontWeight weight = FontWeight.w600,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          value,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontWeight: weight),
        ),
      ),
    );
  }

  Widget _stickyFooter({
    required int total,
    required int start,
    required int end,
  }) {
    final int pageCount = total == 0 ? 1 : (total / _pageSize).ceil();
    return AppTablePaginationFooter(
      total: total,
      startIndex: start,
      endIndex: end,
      currentPage: _currentPage,
      pageCount: pageCount,
      onPrevious: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
      onNext: end < total ? () => setState(() => _currentPage++) : null,
    );
  }

  Future<void> _reloadAll() async {
    setState(() => _loading = true);
    try {
      final String designation = _selectedHod ?? '';
      final String dyHodDesignation = _selectedDyHod ?? '';
      final String contractorIdFk = _selectedContractor ?? '';
      final String contractStatus = _selectedContractStatus ?? '';
      final String contractStatusFk = _selectedWorkStatus ?? '';

      final List<dynamic> responses = await Future.wait<dynamic>(<Future<dynamic>>[
        widget.dataSource.fetchContractsList(
          designation: designation,
          dyHodDesignation: dyHodDesignation,
          contractorIdFk: contractorIdFk,
          contractStatus: contractStatus,
          contractStatusFk: contractStatusFk,
        ),
        widget.dataSource.fetchContractHodFilter(
          designation: designation,
          dyHodDesignation: dyHodDesignation,
          contractorIdFk: contractorIdFk,
          contractStatus: contractStatus,
          contractStatusFk: contractStatusFk,
        ),
        widget.dataSource.fetchContractDyHodFilter(
          designation: designation,
          dyHodDesignation: dyHodDesignation,
          contractorIdFk: contractorIdFk,
          contractStatus: contractStatus,
          contractStatusFk: contractStatusFk,
        ),
        widget.dataSource.fetchContractContractorsFilter(
          designation: designation,
          dyHodDesignation: dyHodDesignation,
          contractorIdFk: contractorIdFk,
          contractStatus: contractStatus,
          contractStatusFk: contractStatusFk,
        ),
        widget.dataSource.fetchContractStatusFilter(
          designation: designation,
          dyHodDesignation: dyHodDesignation,
          contractorIdFk: contractorIdFk,
          contractStatus: contractStatus,
          contractStatusFk: contractStatusFk,
        ),
        widget.dataSource.fetchContractWorkStatusFilter(
          designation: designation,
          dyHodDesignation: dyHodDesignation,
          contractorIdFk: contractorIdFk,
          contractStatus: contractStatus,
          contractStatusFk: contractStatusFk,
        ),
      ]);
      if (!mounted) {
        return;
      }

      final List<Map<String, dynamic>> contracts =
          (responses[0] as List<Map<String, dynamic>>);
      final List<_ContractFilterOption> hods = _dedupeOptions(
        (responses[1] as List<Map<String, dynamic>>).map(_hodOptionFromRow),
      );
      final List<_ContractFilterOption> dyHods = _dedupeOptions(
        (responses[2] as List<Map<String, dynamic>>).map(_dyHodOptionFromRow),
      );
      final List<_ContractFilterOption> contractors = _dedupeOptions(
        (responses[3] as List<Map<String, dynamic>>)
            .map(_contractorOptionFromRow),
      );
      final List<_ContractFilterOption> contractStatuses = _dedupeOptions(
        (responses[4] as List<Map<String, dynamic>>)
            .map(_contractStatusOptionFromRow),
      );
      final List<_ContractFilterOption> workStatuses = _dedupeOptions(
        (responses[5] as List<Map<String, dynamic>>)
            .map(_workStatusOptionFromRow),
      );

      setState(() {
        _rows = contracts;
        _hodOptions = hods;
        _dyHodOptions = dyHods;
        _contractorOptions = contractors;
        _contractStatusOptions = contractStatuses;
        _workStatusOptions = workStatuses;
        _selectedHod = _retainValid(_selectedHod, hods);
        _selectedDyHod = _retainValid(_selectedDyHod, dyHods);
        _selectedContractor = _retainValid(_selectedContractor, contractors);
        _selectedContractStatus =
            _retainValid(_selectedContractStatus, contractStatuses);
        _selectedWorkStatus = _retainValid(_selectedWorkStatus, workStatuses);
        _currentPage = 0;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load contracts',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedHod = null;
      _selectedDyHod = null;
      _selectedContractor = null;
      _selectedContractStatus = null;
      _selectedWorkStatus = null;
      _currentPage = 0;
    });
    _reloadAll();
  }

  Future<void> _openFilterDialog() async {
    String? dialogHod = _selectedHod;
    String? dialogDyHod = _selectedDyHod;
    String? dialogContractor = _selectedContractor;
    String? dialogContractStatus = _selectedContractStatus;
    String? dialogWorkStatus = _selectedWorkStatus;
    bool shouldApply = false;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Center(child: Text('Filter Contracts')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _dialogDropdown(
                      label: 'HOD',
                      options: _hodOptions,
                      value: dialogHod,
                      onChanged: (String? value) =>
                          setDialogState(() => dialogHod = value),
                    ),
                    const SizedBox(height: 10),
                    _dialogDropdown(
                      label: 'Dy HOD',
                      options: _dyHodOptions,
                      value: dialogDyHod,
                      onChanged: (String? value) =>
                          setDialogState(() => dialogDyHod = value),
                    ),
                    const SizedBox(height: 10),
                    _dialogDropdown(
                      label: 'Contractor',
                      options: _contractorOptions,
                      value: dialogContractor,
                      onChanged: (String? value) =>
                          setDialogState(() => dialogContractor = value),
                    ),
                    const SizedBox(height: 10),
                    _dialogDropdown(
                      label: 'Contract Status',
                      options: _contractStatusOptions,
                      value: dialogContractStatus,
                      onChanged: (String? value) =>
                          setDialogState(() => dialogContractStatus = value),
                    ),
                    const SizedBox(height: 10),
                    _dialogDropdown(
                      label: 'Status of Work',
                      options: _workStatusOptions,
                      value: dialogWorkStatus,
                      onChanged: (String? value) =>
                          setDialogState(() => dialogWorkStatus = value),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    shouldApply = true;
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!shouldApply || !mounted) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _selectedHod = dialogHod;
      _selectedDyHod = dialogDyHod;
      _selectedContractor = dialogContractor;
      _selectedContractStatus = dialogContractStatus;
      _selectedWorkStatus = dialogWorkStatus;
      _currentPage = 0;
    });
    await _reloadAll();
    if (mounted) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  Future<void> _onAddTap() async {
    final bool? saved = await context.push<bool>(ContractFormPage.routePath);
    if (saved == true && mounted) {
      await _reloadAll();
    }
  }

  Future<void> _onEditTap(Map<String, dynamic> row) async {
    final String contractId = _stringValue(row['contract_id']);
    if (contractId.isEmpty) {
      return;
    }
    final bool? saved = await context.push<bool>(
      '${ContractFormPage.routePath}?contract_id=${Uri.encodeComponent(contractId)}',
      extra: row,
    );
    if (saved == true && mounted) {
      await _reloadAll();
    }
  }

  Future<void> _confirmExportExcel(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty || !mounted) {
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'Export to Excel',
      message:
          'Download ${rows.length} contract record(s) as an Excel file (.xlsx)? Current filters and search results will be included.',
      type: AppDialogType.confirmation,
      leadingIcon: Icons.table_view_rounded,
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Export',
          isPrimary: true,
          onPressed: () => _exportExcel(rows),
        ),
      ],
    );
  }

  Future<void> _exportExcel(List<Map<String, dynamic>> rows) async {
    final Excel workbook = Excel.createExcel();
    final String sheetName = workbook.getDefaultSheet() ?? 'Sheet1';
    final Sheet sheet = workbook[sheetName];
    sheet.appendRow(_exportHeaders.map(TextCellValue.new).toList());
    for (final Map<String, dynamic> row in rows) {
      sheet.appendRow(<CellValue>[
        TextCellValue(_stringValue(row['project_name'])),
        TextCellValue(_stringValue(row['contract_id'])),
        TextCellValue(_contractName(row)),
        TextCellValue(_stringValue(row['contractor_name'])),
        TextCellValue(_stringValue(row['department_name'])),
        TextCellValue(_stringValue(row['designation'])),
        TextCellValue(_stringValue(row['dy_hod_designation'])),
        TextCellValue(_lastUpdate(row)),
      ]);
    }
    final List<int>? bytes = workbook.encode();
    if (bytes == null || bytes.isEmpty) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Excel Export Failed',
        message: 'Unable to generate xlsx file.',
        type: AppDialogType.error,
      );
      return;
    }
    final String fileName =
        'contracts_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final String savedPath = await _saveExportFile(
      fileName: fileName,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      bytes: Uint8List.fromList(bytes),
    );
    if (!mounted) {
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'Excel Saved',
      message: 'File saved to:\n$savedPath',
      type: AppDialogType.success,
    );
  }

  Future<String> _saveExportFile({
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    if (Platform.isAndroid) {
      try {
        final String? relativePath = await _fileExportChannel.invokeMethod<String>(
          'saveToDownloads',
          <String, dynamic>{
            'fileName': fileName,
            'mimeType': mimeType,
            'bytes': bytes,
            'subdirectory': 'WCR Documents',
          },
        );
        if (relativePath != null && relativePath.isNotEmpty) {
          return relativePath;
        }
      } on MissingPluginException {
      } on PlatformException {
      }
    }
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  List<_ContractFilterOption> _dedupeOptions(
    Iterable<_ContractFilterOption> options,
  ) {
    final Map<String, _ContractFilterOption> byValue =
        <String, _ContractFilterOption>{};
    for (final _ContractFilterOption option in options) {
      if (option.value.isEmpty || option.label.isEmpty) {
        continue;
      }
      byValue.putIfAbsent(option.value, () => option);
    }
    final List<_ContractFilterOption> values = byValue.values.toList()
      ..sort(
        (_ContractFilterOption a, _ContractFilterOption b) =>
            a.label.toLowerCase().compareTo(b.label.toLowerCase()),
      );
    return values;
  }

  _ContractFilterOption _hodOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['hod_user_id']) ??
        _safeString(row['hod_user_id_fk']) ??
        '';
    final String label = _combinedLabel(
      _safeString(row['designation']),
      _safeString(row['hod_name']),
      fallback: value,
    );
    return _ContractFilterOption(value: value, label: label);
  }

  _ContractFilterOption _dyHodOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['dy_hod_user_id']) ??
        _safeString(row['dy_hod_user_id_fk']) ??
        '';
    final String label = _combinedLabel(
      _safeString(row['dy_hod_designation']),
      _safeString(row['dy_hod_name']),
      fallback: value,
    );
    return _ContractFilterOption(value: value, label: label);
  }

  _ContractFilterOption _contractorOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['contractor_id_fk']) ?? '';
    final String label = _combinedLabel(
      value,
      _safeString(row['contractor_name']),
      fallback: value,
    );
    return _ContractFilterOption(value: value, label: label);
  }

  _ContractFilterOption _contractStatusOptionFromRow(
    Map<String, dynamic> row,
  ) {
    final String value = _safeString(row['contract_status']) ?? '';
    return _ContractFilterOption(value: value, label: value);
  }

  _ContractFilterOption _workStatusOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['contract_status_fk']) ?? '';
    return _ContractFilterOption(value: value, label: value);
  }

  String? _retainValid(String? selected, List<_ContractFilterOption> options) {
    if (selected == null) {
      return null;
    }
    final bool exists = options.any(
      (_ContractFilterOption item) => item.value == selected,
    );
    return exists ? selected : null;
  }

  String _contractName(Map<String, dynamic> row) {
    return _safeString(row['contract_name']) ??
        _safeString(row['contract_short_name']) ??
        '-';
  }

  String _lastUpdate(Map<String, dynamic> row) {
    return _safeString(row['modified_date']) ?? '-';
  }

  String _stringValue(dynamic value) => _safeString(value) ?? '-';

  String? _safeString(dynamic value) {
    if (value == null) {
      return null;
    }
    final String text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }

  String _combinedLabel(String? first, String? second, {String fallback = ''}) {
    final String part1 = first?.trim() ?? '';
    final String part2 = second?.trim() ?? '';
    if (part1.isNotEmpty && part2.isNotEmpty) {
      return '$part1 - $part2';
    }
    if (part1.isNotEmpty) {
      return part1;
    }
    if (part2.isNotEmpty) {
      return part2;
    }
    return fallback;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedHod != null) count++;
    if (_selectedDyHod != null) count++;
    if (_selectedContractor != null) count++;
    if (_selectedContractStatus != null) count++;
    if (_selectedWorkStatus != null) count++;
    return count;
  }

  List<Map<String, dynamic>> _filteredRows(List<Map<String, dynamic>> rows) {
    final String query = _search.toLowerCase();
    if (query.isEmpty) {
      return rows;
    }
    return rows.where((Map<String, dynamic> row) {
      return <String>[
        _stringValue(row['project_name']),
        _stringValue(row['contract_id']),
        _contractName(row),
        _stringValue(row['contractor_name']),
        _stringValue(row['department_name']),
        _stringValue(row['designation']),
        _stringValue(row['dy_hod_designation']),
        _lastUpdate(row),
        _stringValue(row['contract_status']),
        _stringValue(row['contract_status_fk']),
      ].any((String value) => value.toLowerCase().contains(query));
    }).toList();
  }

  double _columnWidth(String header) {
    return switch (header) {
      'Project' => 280,
      'Contract ID' => 120,
      'Contract Name' => 260,
      'Contractor Name' => 260,
      'Department' => 130,
      'HOD' => 150,
      'Dy HOD' => 150,
      'Last Update' => 120,
      'Action' => 72,
      _ => 120,
    };
  }

  Widget _dialogDropdown({
    required String label,
    required List<_ContractFilterOption> options,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextStyle? labelStyle = Theme.of(context).textTheme.titleMedium
        ?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500);
    final String selectedLabel = value == null
        ? 'All'
        : options
              .firstWhere(
                (_ContractFilterOption option) => option.value == value,
                orElse: () => _ContractFilterOption(value: value, label: value),
              )
              .label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(label, style: labelStyle),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final String? picked = await _pickFilterOption(
                title: label,
                options: options,
                selected: value,
              );
              if (picked != value) {
                onChanged(picked);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      selectedLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.expand_more_rounded, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<String?> _pickFilterOption({
    required String title,
    required List<_ContractFilterOption> options,
    required String? selected,
  }) async {
    return showModalBottomSheet<String?>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.72,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  'Select $title',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: options.length + 1,
                  separatorBuilder: (BuildContext context, int index) => Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return ListTile(
                        title: const Text('All'),
                        trailing: selected == null
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(null),
                      );
                    }
                    final _ContractFilterOption option = options[index - 1];
                    final bool isSelected = option.value == selected;
                    return ListTile(
                      title: Text(
                        option.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(option.value),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContractFilterOption {
  const _ContractFilterOption({required this.value, required this.label});

  final String value;
  final String label;
}
