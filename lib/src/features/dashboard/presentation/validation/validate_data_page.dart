import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_sticky_leading_column_table.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_toolbar_table_scaffold_body.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

enum ValidateDataTab {
  pending('Pending', 'pending'),
  approved('Approved', 'approved'),
  rejected('Rejected', 'rejected');

  const ValidateDataTab(this.filterStatus, this.listStatus);

  final String filterStatus;
  final String listStatus;

  bool get isPending => this == ValidateDataTab.pending;
}

class _FilterOption {
  const _FilterOption({required this.value, required this.label});

  final String value;
  final String label;
}

class ValidateDataPage extends StatefulWidget {
  const ValidateDataPage({
    super.key,
    required this.dataSource,
    this.initialTab = ValidateDataTab.pending,
  });

  static const String routeName = 'validate-data';
  static const String routePath = '/validate-data';

  final DashboardRemoteDataSource dataSource;
  final ValidateDataTab initialTab;

  @override
  State<ValidateDataPage> createState() => _ValidateDataPageState();
}

class _ValidateDataPageState extends State<ValidateDataPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ValidateDataTab.values.length,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color appBarForeground =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validate Data'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: appBarForeground,
          unselectedLabelColor: appBarForeground.withValues(alpha: 0.72),
          indicatorColor: appBarForeground,
          dividerColor: appBarForeground.withValues(alpha: 0.22),
          tabs: const <Tab>[
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: ValidateDataTab.values
            .map(
              (ValidateDataTab tab) => _ValidateDataTabPanel(
                key: ValueKey<String>(tab.name),
                tab: tab,
                dataSource: widget.dataSource,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ValidateDataTabPanel extends StatefulWidget {
  const _ValidateDataTabPanel({
    super.key,
    required this.tab,
    required this.dataSource,
  });

  final ValidateDataTab tab;
  final DashboardRemoteDataSource dataSource;

  @override
  State<_ValidateDataTabPanel> createState() => _ValidateDataTabPanelState();
}

class _ValidateDataTabPanelState extends State<_ValidateDataTabPanel> {
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50, 100];
  static const double _selectionColumnWidth = 52;
  static const double _rowExtent = 56;

  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  bool _loading = false;

  String? _selectedContract;
  String? _selectedStructure;
  String? _selectedUpdatedBy;

  int _pageSize = 10;
  int _currentPage = 0;

  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  final Set<String> _selectedProgressIds = <String>{};
  List<_FilterOption> _contractOptions = <_FilterOption>[];
  List<_FilterOption> _structureOptions = <_FilterOption>[];
  List<_FilterOption> _updatedByOptions = <_FilterOption>[];

  List<String> get _dataHeaders {
    final List<String> headers = <String>[
      'Task Code',
      'Contract',
      'Structure',
      'Component',
      'Element',
      'Activity',
      'Unit',
      'Scope',
      'Reporting',
      'Actual Updated',
    ];
    if (widget.tab.isPending) {
      headers.add('Updated On');
      headers.add('Action');
    } else if (widget.tab == ValidateDataTab.approved) {
      headers.add('Approved On');
    } else {
      headers.add('Rejected On');
    }
    return headers;
  }

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

    final bool allPageSelected = widget.tab.isPending &&
        pageRows.isNotEmpty &&
        pageRows.every(
          (Map<String, dynamic> row) =>
              _selectedProgressIds.contains(_progressId(row)),
        );

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: _stickyFooter(total: total, start: start, end: end),
      body: Stack(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: AppToolbarTableScaffoldBody(
              toolbar: _toolbar(allPageSelected: allPageSelected),
              table: _tableCard(pageRows, allPageSelected: allPageSelected),
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

  Widget _toolbar({required bool allPageSelected}) {
    final int activeFilterCount = _activeFilterCount;
    final bool canBulkAct =
        widget.tab.isPending && _selectedProgressIds.isNotEmpty && !_loading;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
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
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: _loading ? null : _openFilterDialog,
              icon: const Icon(Icons.filter_alt_rounded),
              label: Text('Filter ($activeFilterCount)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: activeFilterCount > 0 && !_loading
                  ? _clearFilters
                  : null,
              icon: const Icon(Icons.filter_alt_off_rounded),
              label: const Text('Clear Filter'),
            ),
            if (widget.tab.isPending) ...<Widget>[
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton(
                      onPressed: canBulkAct ? _bulkApprove : null,
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: canBulkAct ? _bulkReject : null,
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: _loading ? null : _showEnableCompletedInfo,
                  child: const Text('Enable Completed Activities'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tableCard(
    List<Map<String, dynamic>> rows, {
    required bool allPageSelected,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double scrollableWidth = _dataHeaders.fold<double>(
      0,
      (double sum, String header) => sum + _columnWidth(header),
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
            child: widget.tab.isPending
                ? AppStickyLeadingColumnTable(
                    leadingWidth: _selectionColumnWidth,
                    scrollableWidth: scrollableWidth,
                    rowExtent: _rowExtent,
                    itemCount: rows.length,
                    emptyPlaceholder: const Center(
                      child: Text('No records found.'),
                    ),
                    leadingHeader: _selectionHeader(allPageSelected),
                    scrollableHeader: _scrollableHeader(),
                    leadingRowBuilder: (BuildContext context, int index) =>
                        _selectionCell(rows[index], index),
                    scrollableRowBuilder: (BuildContext context, int index) =>
                        _scrollableRow(rows[index], index),
                  )
                : _readOnlyTable(rows),
          ),
        );
      },
    );
  }

  Widget _readOnlyTable(List<Map<String, dynamic>> rows) {
    final double tableWidth = _dataHeaders.fold<double>(
      0,
      (double sum, String header) => sum + _columnWidth(header),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: tableWidth,
        child: Column(
          children: <Widget>[
            _scrollableHeader(),
            Expanded(
              child: rows.isEmpty
                  ? const Center(child: Text('No records found.'))
                  : ListView.builder(
                      itemExtent: _rowExtent,
                      itemCount: rows.length,
                      itemBuilder: (BuildContext context, int index) =>
                          _scrollableRow(rows[index], index),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectionHeader(bool allPageSelected) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: _rowExtent,
      color: colorScheme.primary,
      alignment: Alignment.center,
      child: Checkbox(
        value: allPageSelected,
        tristate: true,
        onChanged: _rows.isNotEmpty
            ? (bool? value) => _toggleSelectAll(value)
            : null,
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => colorScheme.onPrimary,
        ),
        checkColor: colorScheme.primary,
      ),
    );
  }

  Widget _scrollableHeader() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: _rowExtent,
      color: colorScheme.primary,
      child: Row(
        children: _dataHeaders
            .map(
              (String title) => _cell(
                title,
                width: _columnWidth(title),
                color: colorScheme.onPrimary,
                weight: FontWeight.w700,
                fontSize: 11,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _selectionCell(Map<String, dynamic> row, int index) {
    final String progressId = _progressId(row);
    final bool selected = _selectedProgressIds.contains(progressId);
    return Material(
      color: _rowBackground(index, selected: selected),
      child: InkWell(
        onTap: progressId.isEmpty
            ? null
            : () => _toggleSelection(progressId),
        child: Center(
          child: Checkbox(
            value: selected,
            onChanged: progressId.isEmpty
                ? null
                : (bool? value) =>
                      _setSelection(progressId, value == true),
          ),
        ),
      ),
    );
  }

  Widget _scrollableRow(Map<String, dynamic> row, int index) {
    final bool selected = _selectedProgressIds.contains(_progressId(row));
    return Material(
      color: _rowBackground(index, selected: selected),
      child: SizedBox(
        height: _rowExtent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _cell(_taskCode(row), width: _columnWidth('Task Code')),
            _cell(_contract(row), width: _columnWidth('Contract')),
            _cell(_string(row['structure']), width: _columnWidth('Structure')),
            _cell(_string(row['component']), width: _columnWidth('Component')),
            _cell(_string(row['component_id']), width: _columnWidth('Element')),
            _cell(
              _string(row['activity_name']),
              width: _columnWidth('Activity'),
            ),
            _cell(_string(row['unit']), width: _columnWidth('Unit')),
            _cell(_scope(row), width: _columnWidth('Scope')),
            _cell(_reporting(row), width: _columnWidth('Reporting')),
            _cell(
              _string(row['actual_for_the_day']),
              width: _columnWidth('Actual Updated'),
            ),
            _cell(_dateColumn(row), width: _columnWidth(_dateHeader)),
            if (widget.tab.isPending)
              SizedBox(
                width: _columnWidth('Action'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Approve',
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.check_circle_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      onPressed: () => _approveRow(row),
                    ),
                    IconButton(
                      tooltip: 'Reject',
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.cancel_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => _rejectRow(row),
                    ),
                    IconButton(
                      tooltip: 'Info',
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.info_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => _showInfo(row),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String get _dateHeader {
    if (widget.tab.isPending) {
      return 'Updated On';
    }
    if (widget.tab == ValidateDataTab.approved) {
      return 'Approved On';
    }
    return 'Rejected On';
  }

  String _dateColumn(Map<String, dynamic> row) {
    if (widget.tab.isPending) {
      return _string(row['updated_on']);
    }
    if (widget.tab == ValidateDataTab.approved) {
      return _string(row['approved_on']);
    }
    return _string(row['rejected_on']);
  }

  Widget _cell(
    String value, {
    required double width,
    Color? color,
    FontWeight weight = FontWeight.w600,
    double fontSize = 12,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontWeight: weight,
            fontSize: fontSize,
          ),
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
      pageSize: _pageSize,
      pageSizeOptions: _pageSizeOptions,
      onPageSizeChanged: (int value) => setState(() {
        _pageSize = value;
        _currentPage = 0;
      }),
      onPrevious: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
      onNext: end < total ? () => setState(() => _currentPage++) : null,
    );
  }

  Future<void> _reloadAll() async {
    setState(() => _loading = true);
    try {
      final List<List<Map<String, dynamic>>> responses =
          await Future.wait<List<Map<String, dynamic>>>(
        <Future<List<Map<String, dynamic>>>>[
          widget.dataSource.fetchValidationContracts(
            approvalStatusFk: widget.tab.filterStatus,
          ),
          widget.dataSource.fetchValidationStructures(
            approvalStatusFk: widget.tab.filterStatus,
          ),
          widget.dataSource.fetchValidationUpdatedByList(
            approvalStatusFk: widget.tab.filterStatus,
          ),
          widget.dataSource.fetchApprovableActivities(
            approvalStatusFk: widget.tab.listStatus,
            contractIdFk: _selectedContract,
            structure: _selectedStructure,
            updatedByUserIdFk: _selectedUpdatedBy,
          ),
        ],
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _contractOptions = _dedupeOptions(
          responses[0].map(_contractOptionFromRow),
        );
        _structureOptions = _dedupeOptions(
          responses[1].map(_structureOptionFromRow),
        );
        _updatedByOptions = _dedupeOptions(
          responses[2].map(_updatedByOptionFromRow),
        );
        _rows = responses[3];
        _selectedProgressIds.removeWhere(
          (String id) => !_rows.any(
            (Map<String, dynamic> row) => _progressId(row) == id,
          ),
        );
        _currentPage = 0;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load data',
        message: userFriendlyErrorMessage(error),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _reloadTable() async {
    setState(() => _loading = true);
    try {
      final List<Map<String, dynamic>> rows =
          await widget.dataSource.fetchApprovableActivities(
        approvalStatusFk: widget.tab.listStatus,
        contractIdFk: _selectedContract,
        structure: _selectedStructure,
        updatedByUserIdFk: _selectedUpdatedBy,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _rows = rows;
        _selectedProgressIds.clear();
        _currentPage = 0;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load records',
        message: userFriendlyErrorMessage(error),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _clearFilters() async {
    setState(() {
      _selectedContract = null;
      _selectedStructure = null;
      _selectedUpdatedBy = null;
      _searchController.clear();
      _search = '';
      _selectedProgressIds.clear();
    });
    await _reloadTable();
  }

  Future<void> _openFilterDialog() async {
    String? dialogContract = _selectedContract;
    String? dialogStructure = _selectedStructure;
    String? dialogUpdatedBy = _selectedUpdatedBy;
    bool shouldApply = false;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Center(child: Text('Filter Records')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _dialogDropdown(
                  label: 'Contract',
                  options: _contractOptions,
                  value: dialogContract,
                  onChanged: (String? value) =>
                      dialogContract = value,
                ),
                const SizedBox(height: 10),
                _dialogDropdown(
                  label: 'Structure',
                  options: _structureOptions,
                  value: dialogStructure,
                  onChanged: (String? value) =>
                      dialogStructure = value,
                ),
                const SizedBox(height: 10),
                _dialogDropdown(
                  label: 'Modified By',
                  options: _updatedByOptions,
                  value: dialogUpdatedBy,
                  onChanged: (String? value) =>
                      dialogUpdatedBy = value,
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

    if (!shouldApply || !mounted) {
      return;
    }
    setState(() {
      _selectedContract = dialogContract;
      _selectedStructure = dialogStructure;
      _selectedUpdatedBy = dialogUpdatedBy;
      _selectedProgressIds.clear();
    });
    await _reloadTable();
  }

  Future<void> _approveRow(Map<String, dynamic> row) async {
    await _runAction(
      title: 'Approve activity',
      message: 'Approve progress update for ${_taskCode(row)}?',
      action: () => widget.dataSource.approveActivityProgress(
        structure: _string(row['structure']),
        progressId: _progressId(row),
        workIdFk: _nullableString(row['work_id_fk']),
        contractIdFk: _string(row['contract_id_fk']),
      ),
    );
  }

  Future<void> _rejectRow(Map<String, dynamic> row) async {
    await _runAction(
      title: 'Reject activity',
      message: 'Reject progress update for ${_taskCode(row)}?',
      action: () => widget.dataSource.rejectActivityProgress(
        structure: _string(row['structure']),
        progressId: _progressId(row),
        workIdFk: _nullableString(row['work_id_fk']),
        contractIdFk: _string(row['contract_id_fk']),
      ),
    );
  }

  Future<void> _bulkApprove() async {
    final List<Map<String, dynamic>> selectedRows = _selectedRows();
    if (selectedRows.isEmpty) {
      return;
    }
    await _runAction(
      title: 'Approve selected',
      message: 'Approve ${selectedRows.length} selected record(s)?',
      action: () => _approveRows(selectedRows),
    );
  }

  Future<Map<String, dynamic>> _approveRows(
    List<Map<String, dynamic>> rows,
  ) async {
    final Map<String, List<Map<String, dynamic>>> groups =
        <String, List<Map<String, dynamic>>>{};

    for (final Map<String, dynamic> row in rows) {
      final String progressId = _progressId(row);
      if (progressId.isEmpty) {
        continue;
      }
      final String groupKey =
          '${_string(row['contract_id_fk'])}|'
          '${_string(row['structure'])}|'
          '${_nullableString(row['work_id_fk']) ?? ''}';
      groups.putIfAbsent(groupKey, () => <Map<String, dynamic>>[]).add(row);
    }

    if (groups.isEmpty) {
      throw StateError('No valid records selected for approval.');
    }

    Map<String, dynamic> lastResult = <String, dynamic>{};
    for (final List<Map<String, dynamic>> group in groups.values) {
      if (group.length == 1) {
        final Map<String, dynamic> row = group.first;
        lastResult = await widget.dataSource.approveActivityProgress(
          structure: _string(row['structure']),
          progressId: _progressId(row),
          workIdFk: _nullableString(row['work_id_fk']),
          contractIdFk: _string(row['contract_id_fk']),
        );
        continue;
      }

      final Map<String, dynamic> anchor = group.first;
      lastResult = await widget.dataSource.approveMultipleActivityProgress(
        progressIds: group.map(_progressId).join(','),
        workIdFk: _nullableString(anchor['work_id_fk']),
        contractIdFk: _string(anchor['contract_id_fk']),
        structure: _string(anchor['structure']),
      );
    }
    return lastResult;
  }

  Future<void> _bulkReject() async {
    final List<Map<String, dynamic>> selectedRows = _selectedRows();
    if (selectedRows.isEmpty) {
      return;
    }
    await _runAction(
      title: 'Reject selected',
      message: 'Reject ${selectedRows.length} selected record(s)?',
      action: () => widget.dataSource.rejectMultipleActivityProgress(
        progressIds: selectedRows.map(_progressId).join(','),
      ),
    );
  }

  Future<void> _runAction({
    required String title,
    required String message,
    required Future<Map<String, dynamic>> Function() action,
  }) async {
    await AppDialog.show(
      context: context,
      title: title,
      message: message,
      type: AppDialogType.confirmation,
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Confirm',
          isPrimary: true,
          onPressed: () async {
            setState(() => _loading = true);
            try {
              await action();
              if (!mounted) {
                return;
              }
              await AppDialog.show(
                context: context,
                title: 'Success',
                message: 'Action completed successfully.',
                type: AppDialogType.success,
              );
              if (widget.tab.isPending) {
                await _reloadAll();
              } else {
                await _reloadTable();
              }
            } catch (error) {
              if (!mounted) {
                return;
              }
              await AppDialog.show(
                context: context,
                title: 'Action failed',
                message: userFriendlyErrorMessage(error),
                type: AppDialogType.error,
              );
            } finally {
              if (mounted) {
                setState(() => _loading = false);
              }
            }
          },
        ),
      ],
    );
  }

  Future<void> _showInfo(Map<String, dynamic> row) async {
    final String taskCode = _taskCode(row);
    final String reporter = _string(row['updated_by']);
    final String reportDate =
        _string(row['progress_date']).isNotEmpty
            ? _string(row['progress_date'])
            : _string(row['updated_on']);
    await AppDialog.show(
      context: context,
      title: 'Info for $taskCode',
      message: 'Reporting: $reporter $reportDate'.trim(),
      type: AppDialogType.info,
    );
  }

  Future<void> _showEnableCompletedInfo() async {
    await AppDialog.show(
      context: context,
      title: 'Enable Completed Activities',
      message:
          'This action is available on the web dashboard. Mobile support will be added in a future update.',
      type: AppDialogType.info,
    );
  }

  void _toggleSelectAll(bool? value) {
    final List<Map<String, dynamic>> pageRows = _currentPageRows();
    setState(() {
      if (value == true) {
        for (final Map<String, dynamic> row in pageRows) {
          final String id = _progressId(row);
          if (id.isNotEmpty) {
            _selectedProgressIds.add(id);
          }
        }
      } else {
        for (final Map<String, dynamic> row in pageRows) {
          _selectedProgressIds.remove(_progressId(row));
        }
      }
    });
  }

  void _toggleSelection(String progressId) {
    setState(() {
      if (_selectedProgressIds.contains(progressId)) {
        _selectedProgressIds.remove(progressId);
      } else {
        _selectedProgressIds.add(progressId);
      }
    });
  }

  void _setSelection(String progressId, bool selected) {
    setState(() {
      if (selected) {
        _selectedProgressIds.add(progressId);
      } else {
        _selectedProgressIds.remove(progressId);
      }
    });
  }

  List<Map<String, dynamic>> _selectedRows() {
    return _rows
        .where(
          (Map<String, dynamic> row) =>
              _selectedProgressIds.contains(_progressId(row)),
        )
        .toList();
  }

  List<Map<String, dynamic>> _currentPageRows() {
    final List<Map<String, dynamic>> filteredRows = _filteredRows(_rows);
    final int start = _currentPage * _pageSize;
    final int end = (start + _pageSize).clamp(0, filteredRows.length);
    if (start >= filteredRows.length) {
      return const <Map<String, dynamic>>[];
    }
    return filteredRows.sublist(start, end);
  }

  List<Map<String, dynamic>> _filteredRows(List<Map<String, dynamic>> rows) {
    if (_search.isEmpty) {
      return rows;
    }
    final String query = _search.toLowerCase();
    return rows.where((Map<String, dynamic> row) {
      final String haystack =
          '${_taskCode(row)} ${_contract(row)} ${_string(row['structure'])} '
          '${_string(row['component'])} ${_string(row['component_id'])} '
          '${_string(row['activity_name'])} ${_reporting(row)}'
              .toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Color _rowBackground(int index, {required bool selected}) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (selected) {
      return colorScheme.primaryContainer.withValues(alpha: 0.45);
    }
    return index.isEven
        ? colorScheme.primary.withValues(alpha: 0.06)
        : colorScheme.surface;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedContract != null) count++;
    if (_selectedStructure != null) count++;
    if (_selectedUpdatedBy != null) count++;
    return count;
  }

  Widget _dialogDropdown({
    required String label,
    required List<_FilterOption> options,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: const Text('Select'),
          items: <DropdownMenuItem<String>>[
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All'),
            ),
            ...options.map(
              (_FilterOption option) => DropdownMenuItem<String>(
                value: option.value,
                child: Text(
                  option.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  List<_FilterOption> _dedupeOptions(Iterable<_FilterOption> options) {
    final Map<String, _FilterOption> unique = <String, _FilterOption>{};
    for (final _FilterOption option in options) {
      if (option.value.isEmpty) {
        continue;
      }
      unique.putIfAbsent(option.value, () => option);
    }
    return unique.values.toList()
      ..sort(
        (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
      );
  }

  _FilterOption _contractOptionFromRow(Map<String, dynamic> row) {
    final String value = _string(row['contract_id_fk']);
    final String label = _string(
      row['contract_short_name'] ?? row['contract_name'] ?? value,
    );
    return _FilterOption(value: value, label: label);
  }

  _FilterOption _structureOptionFromRow(Map<String, dynamic> row) {
    final String value = _string(row['structure']);
    return _FilterOption(value: value, label: value);
  }

  _FilterOption _updatedByOptionFromRow(Map<String, dynamic> row) {
    final String value = _string(row['user_id']);
    final String label = _string(row['user_name']).isEmpty
        ? value
        : _string(row['user_name']);
    return _FilterOption(value: value, label: label);
  }

  String _progressId(Map<String, dynamic> row) => _string(row['progress_id']);

  String _taskCode(Map<String, dynamic> row) => _string(row['p6_task_code']);

  String _contract(Map<String, dynamic> row) =>
      _string(row['contract_short_name']);

  String _scope(Map<String, dynamic> row) =>
      _string(row['total_scope']).isEmpty
          ? _string(row['scope'])
          : _string(row['total_scope']);

  String _reporting(Map<String, dynamic> row) {
    final String name = _string(row['updated_by']);
    final String date = _string(row['progress_date']).isNotEmpty
        ? _string(row['progress_date'])
        : _string(row['updated_on']);
    if (name.isEmpty) {
      return date;
    }
    if (date.isEmpty) {
      return name;
    }
    return '$name $date';
  }

  String _string(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }

  String? _nullableString(dynamic value) {
    final String text = _string(value);
    return text.isEmpty ? null : text;
  }

  double _columnWidth(String header) {
    switch (header) {
      case 'Task Code':
        return 120;
      case 'Contract':
        return 180;
      case 'Structure':
      case 'Component':
      case 'Element':
        return 140;
      case 'Activity':
        return 110;
      case 'Unit':
        return 60;
      case 'Scope':
      case 'Actual Updated':
        return 100;
      case 'Reporting':
        return 130;
      case 'Updated On':
      case 'Approved On':
      case 'Rejected On':
        return 110;
      case 'Action':
        return 120;
      default:
        return 100;
    }
  }
}
