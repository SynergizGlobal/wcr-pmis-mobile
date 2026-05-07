import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

class IssuesPage extends StatefulWidget {
  const IssuesPage({super.key, required this.dataSource});

  static const String routeName = 'issues';
  static const String routePath = '/issues';

  final DashboardRemoteDataSource dataSource;

  @override
  State<IssuesPage> createState() => _IssuesPageState();
}

class _IssuesPageState extends State<IssuesPage> {
  static const MethodChannel _fileExportChannel = MethodChannel(
    'wcr_pmis_mobile/file_export',
  );
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50, 100];
  static const List<String> _headers = <String>[
    'Contract',
    'Short Description',
    'Location',
    'Responsible Person',
    'Department',
    'Issue Status',
    'Last Update',
    'Action',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  bool _loading = false;

  String? _selectedContract;
  String? _selectedHod;
  String? _selectedDepartment;
  String? _selectedCategory;
  String? _selectedStatus;

  int _pageSize = 10;
  int _currentPage = 0;

  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  List<_IssueFilterOption> _contractOptions = <_IssueFilterOption>[];
  List<_IssueFilterOption> _hodOptions = <_IssueFilterOption>[];
  List<_IssueFilterOption> _departmentOptions = <_IssueFilterOption>[];
  List<_IssueFilterOption> _categoryOptions = <_IssueFilterOption>[];
  List<_IssueFilterOption> _statusOptions = <_IssueFilterOption>[];

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
      appBar: AppBar(title: const Text('Issues')),
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
        const Text('Show ',style: TextStyle(fontSize: 12)),
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
        const Text(' entries',style: TextStyle(fontSize: 12)),
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
          hintText: 'Search',
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
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: FilledButton.tonalIcon(
                  onPressed: _openFilterDialog,
                  icon: const Icon(Icons.filter_alt_rounded),
                  label: Text('Filter ($activeFilterCount)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
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
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: canExport ? () => _confirmExportExcel(rows) : null,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Export Excel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: FilledButton.icon(
                  onPressed: _onAddIssueTap,
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
        padding: const EdgeInsets.only(bottom: 1,top: 12,right: 12,left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            actionsBox,
            const SizedBox(height: 8),
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
                          ? const Center(child: Text('No issue records found.'))
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 10),
                              itemCount: rows.length,
                              itemBuilder: (BuildContext context, int index) => _tableRow(
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
            _cell(_issueContract(row), width: _columnWidth('Contract')),
            _cell(_stringValue(row['title']), width: _columnWidth('Short Description')),
            _cell(_stringValue(row['location']), width: _columnWidth('Location')),
            _cell(
              _stringValue(row['responsible_person']),
              width: _columnWidth('Responsible Person'),
            ),
            _cell(_issueDepartment(row), width: _columnWidth('Department')),
            _cell(_stringValue(row['status_fk']), width: _columnWidth('Issue Status')),
            _cell(_issueLastUpdate(row), width: _columnWidth('Last Update')),
            SizedBox(
              width: _columnWidth('Action'),
              child: Center(
                child: IconButton(
                  tooltip: 'View',
                  onPressed: () => _onIssueViewTap(row),
                  icon: Icon(Icons.list_alt_rounded, color: colorScheme.primary),
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

  Widget _paginationBar({
    required int total,
    required int start,
    required int end,
    required int pageCount,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final String summary = total == 0
        ? 'Showing 0 to 0 of 0 entries'
        : 'Showing ${start + 1} to $end of $total entries';
    final int currentPage = total == 0 ? 0 : (_currentPage + 1);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          summary,
          style: tt.titleMedium?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
            fontSize: 12
          ),
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxWidth < 430;
            final double buttonWidth = compact ? 92 : 100;
            final double gap = compact ? 8 : 10;
            final double pillHorizontalPadding = compact ? 12 : 18;
            final TextStyle? pageStyle = (compact ? tt.titleSmall : tt.bodySmall)
                ?.copyWith(color: cs.primary, fontWeight: FontWeight.w700);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: buttonWidth, maxWidth: buttonWidth + 14),
                  child: OutlinedButton.icon(
                    onPressed:
                        _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: const Text('Prev'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(buttonWidth, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                SizedBox(width: gap),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: pillHorizontalPadding, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text('Page $currentPage of $pageCount', style: pageStyle),
                ),
                SizedBox(width: gap),
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: buttonWidth, maxWidth: buttonWidth + 14),
                  child: OutlinedButton.icon(
                    onPressed: end < total ? () => setState(() => _currentPage++) : null,
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.chevron_right_rounded),
                    label: const Text('Next'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(buttonWidth,42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _stickyFooter({
    required int total,
    required int start,
    required int end,
  }) {
    final int pageCount = total == 0 ? 1 : (total / _pageSize).ceil();
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
        child: _paginationBar(
          total: total,
          start: start,
          end: end,
          pageCount: pageCount,
        ),
      ),
    );
  }

  Future<void> _reloadAll() async {
    setState(() => _loading = true);
    try {
      final Map<String, String> payload = _filterPayload;
      final List<Map<String, dynamic>> responses = await Future.wait<
          Map<String, dynamic>>(<Future<Map<String, dynamic>>>[
        widget.dataSource.fetchIssuesList(
          contractId: payload['contract_id_fk'],
          department: payload['department_fk'],
          category: payload['category_fk'],
          status: payload['status_fk'],
          hod: payload['hod'],
        ),
        widget.dataSource.fetchIssueContractsFilter(
          contractId: payload['contract_id_fk'],
          department: payload['department_fk'],
          category: payload['category_fk'],
          status: payload['status_fk'],
          hod: payload['hod'],
        ),
        widget.dataSource.fetchIssueHodFilter(
          contractId: payload['contract_id_fk'],
          department: payload['department_fk'],
          category: payload['category_fk'],
          status: payload['status_fk'],
          hod: payload['hod'],
        ),
        widget.dataSource.fetchIssueDepartmentsFilter(
          contractId: payload['contract_id_fk'],
          department: payload['department_fk'],
          category: payload['category_fk'],
          status: payload['status_fk'],
          hod: payload['hod'],
        ),
        widget.dataSource.fetchIssueCategoryFilter(
          contractId: payload['contract_id_fk'],
          department: payload['department_fk'],
          category: payload['category_fk'],
          status: payload['status_fk'],
          hod: payload['hod'],
        ),
        widget.dataSource.fetchIssueStatusFilter(
          contractId: payload['contract_id_fk'],
          department: payload['department_fk'],
          category: payload['category_fk'],
          status: payload['status_fk'],
          hod: payload['hod'],
        ),
      ]);
      if (!mounted) {
        return;
      }

      final List<Map<String, dynamic>> issues = _rowsFromResponse(responses[0]);
      final List<_IssueFilterOption> contracts = _dedupeOptions(
        _rowsFromResponse(responses[1]).map(_contractOptionFromRow),
      );
      final List<_IssueFilterOption> hods = _dedupeOptions(
        _rowsFromResponse(responses[2]).map(_hodOptionFromRow),
      );
      final List<_IssueFilterOption> departments = _dedupeOptions(
        _rowsFromResponse(responses[3]).map(_departmentOptionFromRow),
      );
      final List<_IssueFilterOption> categories = _dedupeOptions(
        _rowsFromResponse(responses[4]).map(_categoryOptionFromRow),
      );
      final List<_IssueFilterOption> statuses = _dedupeOptions(
        _rowsFromResponse(responses[5]).map(_statusOptionFromRow),
      );

      setState(() {
        _rows = issues;
        _contractOptions = contracts;
        _hodOptions = hods;
        _departmentOptions = departments;
        _categoryOptions = categories;
        _statusOptions = statuses;
        _selectedContract = _retainValid(_selectedContract, contracts);
        _selectedHod = _retainValid(_selectedHod, hods);
        _selectedDepartment = _retainValid(_selectedDepartment, departments);
        _selectedCategory = _retainValid(_selectedCategory, categories);
        _selectedStatus = _retainValid(_selectedStatus, statuses);
        _currentPage = 0;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load issues',
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
      _selectedContract = null;
      _selectedHod = null;
      _selectedDepartment = null;
      _selectedCategory = null;
      _selectedStatus = null;
      _currentPage = 0;
    });
    _reloadAll();
  }

  Future<void> _openFilterDialog() async {
    String? dialogContract = _selectedContract;
    String? dialogHod = _selectedHod;
    String? dialogDepartment = _selectedDepartment;
    String? dialogCategory = _selectedCategory;
    String? dialogStatus = _selectedStatus;
    bool shouldApply = false;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Center(child: Text('Filter Issues')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _dialogDropdown(
                      label: 'Contract',
                      options: _contractOptions,
                      value: dialogContract,
                      onChanged: (String? value) =>
                          setDialogState(() => dialogContract = value),
                    ),
                    const SizedBox(height: 10),
                    _dialogDropdown(
                      label: 'HOD',
                      options: _hodOptions,
                      value: dialogHod,
                      onChanged: (String? value) =>
                          setDialogState(() => dialogHod = value),
                    ),
                    const SizedBox(height: 10),
                    _dialogDropdown(
                      label: 'Department',
                      options: _departmentOptions,
                      value: dialogDepartment,
                      onChanged: (String? value) =>
                          setDialogState(() => dialogDepartment = value),
                    ),
                    const SizedBox(height: 10),
                    _dialogDropdown(
                      label: 'Category',
                      options: _categoryOptions,
                      value: dialogCategory,
                      onChanged: (String? value) =>
                          setDialogState(() => dialogCategory = value),
                    ),
                    const SizedBox(height: 10),
                    _dialogDropdown(
                      label: 'Status',
                      options: _statusOptions,
                      value: dialogStatus,
                      onChanged: (String? value) =>
                          setDialogState(() => dialogStatus = value),
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

    if (!shouldApply) {
      return;
    }
    if (!mounted) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _selectedContract = dialogContract;
      _selectedHod = dialogHod;
      _selectedDepartment = dialogDepartment;
      _selectedCategory = dialogCategory;
      _selectedStatus = dialogStatus;
      _currentPage = 0;
    });
    await _reloadAll();
    if (mounted) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  Future<void> _onAddIssueTap() async {
    await AppDialog.show(
      context: context,
      title: 'Add Issue',
      message: 'Issue add form will be connected next.',
      type: AppDialogType.info,
    );
  }

  Future<void> _onIssueViewTap(Map<String, dynamic> row) async {
    await AppDialog.show(
      context: context,
      title: 'Issue Details',
      message:
          'Issue ID: ${_stringValue(row['issue_id'])}\nDescription: ${_stringValue(row['description'])}',
      type: AppDialogType.info,
    );
  }

  Future<void> _confirmExportExcel(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty || !mounted) {
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'Export to Excel',
      message:
          'Download the issues list as an Excel file (.xlsx)? Current filters and search results will be included.',
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
    sheet.appendRow(_headers.map(TextCellValue.new).toList());
    for (final Map<String, dynamic> row in rows) {
      sheet.appendRow(<CellValue>[
        TextCellValue(_issueContract(row)),
        TextCellValue(_stringValue(row['title'])),
        TextCellValue(_stringValue(row['location'])),
        TextCellValue(_stringValue(row['responsible_person'])),
        TextCellValue(_issueDepartment(row)),
        TextCellValue(_stringValue(row['status_fk'])),
        TextCellValue(_issueLastUpdate(row)),
        TextCellValue(''),
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
    final String fileName = 'issues_${DateTime.now().millisecondsSinceEpoch}.xlsx';
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
        // fallback below
      } on PlatformException {
        // fallback below
      }
    }
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Map<String, String> get _filterPayload => <String, String>{
    'contract_id_fk': _selectedContract ?? '',
    'department_fk': _selectedDepartment ?? '',
    'category_fk': _selectedCategory ?? '',
    'status_fk': _selectedStatus ?? '',
    'hod': _selectedHod ?? '',
  };

  List<Map<String, dynamic>> _rowsFromResponse(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] as List<dynamic>? ?? <dynamic>[];
    return data
        .whereType<Map>()
        .map(
          (Map row) => row.map(
            (dynamic key, dynamic value) => MapEntry(key.toString(), value),
          ),
        )
        .toList();
  }

  List<_IssueFilterOption> _dedupeOptions(Iterable<_IssueFilterOption> options) {
    final Map<String, _IssueFilterOption> byValue = <String, _IssueFilterOption>{};
    for (final _IssueFilterOption option in options) {
      if (option.value.isEmpty || option.label.isEmpty) {
        continue;
      }
      byValue.putIfAbsent(option.value, () => option);
    }
    final List<_IssueFilterOption> values = byValue.values.toList()
      ..sort((_IssueFilterOption a, _IssueFilterOption b) {
        return a.label.toLowerCase().compareTo(b.label.toLowerCase());
      });
    return values;
  }

  _IssueFilterOption _contractOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['contract_id']) ??
        _safeString(row['contract_id_fk']) ??
        '';
    final String label = _safeString(row['contract_short_name']) ??
        _safeString(row['contract_name']) ??
        value;
    return _IssueFilterOption(value: value, label: label);
  }

  _IssueFilterOption _hodOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['hod_user_id_fk']) ??
        _safeString(row['hod']) ??
        _safeString(row['user_name']) ??
        '';
    final String userName = _safeString(row['user_name']) ?? value;
    final String designation = _safeString(row['designation']) ?? '';
    final String label = designation.isEmpty ? userName : '$userName-$designation';
    return _IssueFilterOption(value: value, label: label);
  }

  _IssueFilterOption _departmentOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['department_fk']) ?? '';
    final String label = _safeString(row['department_name']) ??
        _safeString(row['department']) ??
        value;
    return _IssueFilterOption(value: value, label: label);
  }

  _IssueFilterOption _categoryOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['category_fk']) ?? '';
    return _IssueFilterOption(value: value, label: value);
  }

  _IssueFilterOption _statusOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['status_fk']) ?? '';
    return _IssueFilterOption(value: value, label: value);
  }

  String? _retainValid(String? selected, List<_IssueFilterOption> options) {
    if (selected == null) {
      return null;
    }
    final bool exists = options.any((_IssueFilterOption item) => item.value == selected);
    return exists ? selected : null;
  }

  double _columnWidth(String header) {
    return switch (header) {
      'Contract' => 280,
      'Short Description' => 180,
      'Location' => 160,
      'Responsible Person' => 160,
      'Department' => 150,
      'Issue Status' => 120,
      'Last Update' => 120,
      'Action' => 84,
      _ => 100,
    };
  }

  String _issueContract(Map<String, dynamic> row) {
    return _safeString(row['contract_short_name']) ??
        _safeString(row['contract_name']) ??
        _safeString(row['contract_id_fk']) ??
        '-';
  }

  String _issueDepartment(Map<String, dynamic> row) {
    return _safeString(row['department_name']) ??
        _safeString(row['department']) ??
        _safeString(row['department_fk']) ??
        '-';
  }

  String _issueLastUpdate(Map<String, dynamic> row) {
    return _safeString(row['modified_date']) ??
        _safeString(row['created_date']) ??
        _safeString(row['date']) ??
        '-';
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

  int get _activeFilterCount {
    int count = 0;
    if (_selectedContract != null) count++;
    if (_selectedHod != null) count++;
    if (_selectedDepartment != null) count++;
    if (_selectedCategory != null) count++;
    if (_selectedStatus != null) count++;
    return count;
  }

  List<Map<String, dynamic>> _filteredRows(List<Map<String, dynamic>> rows) {
    final String query = _search.toLowerCase();
    if (query.isEmpty) {
      return rows;
    }
    return rows.where((Map<String, dynamic> row) {
      return row.values.any(
        (dynamic value) => _stringValue(value).toLowerCase().contains(query),
      );
    }).toList();
  }

  Widget _dialogDropdown({
    required String label,
    required List<_IssueFilterOption> options,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextStyle? labelStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: cs.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    final String selectedLabel = value == null
        ? 'All'
        : options
                .firstWhere(
                  (_IssueFilterOption option) => option.value == value,
                  orElse: () => _IssueFilterOption(value: value, label: value),
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
    required List<_IssueFilterOption> options,
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
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
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
                    final _IssueFilterOption option = options[index - 1];
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

class _IssueFilterOption {
  const _IssueFilterOption({required this.value, required this.label});

  final String value;
  final String label;
}
