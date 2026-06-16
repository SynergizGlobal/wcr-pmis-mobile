import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_sticky_leading_column_table.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_toolbar_table_scaffold_body.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

enum _ModifyActualsAction {
  completedScopeZero(
    'Completed Scope / Actual Zero by Task Code',
    1,
  ),
  deleteByTaskCode('Delete activities by task code', 2),
  deleteByContract('Delete activities by contract', 3);

  const _ModifyActualsAction(this.label, this.pending);

  final String label;
  final int pending;

  bool get requiresStructure => this == deleteByContract;
}

class _FilterOption {
  const _FilterOption({required this.value, required this.label});

  final String value;
  final String label;
}

class ModifyActualsPage extends StatefulWidget {
  const ModifyActualsPage({super.key, required this.dataSource});

  static const String routeName = 'modify-actuals';
  static const String routePath = '/modify-actuals';

  final DashboardRemoteDataSource dataSource;

  @override
  State<ModifyActualsPage> createState() => _ModifyActualsPageState();
}

class _ModifyActualsPageState extends State<ModifyActualsPage> {
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50, 100];
  static const List<String> _headers = <String>[
    'Task Code',
    'Activity',
    'Scope',
    'Completed',
  ];
  static const double _selectionColumnWidth = 52;
  static const double _rowExtent = 52;

  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  bool _loading = false;
  bool _filtersApplied = false;

  _ModifyActualsAction? _selectedAction;
  String? _selectedContract;
  String? _selectedStructure;

  int _pageSize = 10;
  int _currentPage = 0;

  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  final Set<String> _selectedActivityIds = <String>{};
  List<_FilterOption> _contractOptions = <_FilterOption>[];
  List<_FilterOption> _structureOptions = <_FilterOption>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadContractOptions());
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

    final List<String> pageActivityIds = pageRows
        .map(_activityIdForRow)
        .where((String id) => id.isNotEmpty)
        .toList();
    final bool allPageSelected = pageActivityIds.isNotEmpty &&
        pageActivityIds.every(_selectedActivityIds.contains);

    return Scaffold(
      appBar: AppBar(title: const Text('Modify Actuals')),
      bottomNavigationBar: _stickyFooter(total: total, start: start, end: end),
      body: Stack(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: AppToolbarTableScaffoldBody(
              toolbar: _toolbar(
                context,
                allPageSelected: allPageSelected,
              ),
              table: _tableCard(
                context,
                pageRows,
                allPageSelected: allPageSelected,
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

  Widget _toolbar(BuildContext context, {required bool allPageSelected}) {
    final int activeFilterCount = _activeFilterCount;
    final bool canUpdate =
        _filtersApplied && _selectedActivityIds.isNotEmpty && !_loading;
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
              onSubmitted: (_) => _reloadTableFromApi(),
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: _loading ? null : _openFilterDialog,
                          icon: const Icon(Icons.filter_alt_rounded),
                          label: Text('Filter ($activeFilterCount)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: activeFilterCount > 0 && !_loading
                              ? _clearFilters
                              : null,
                          icon: const Icon(Icons.filter_alt_off_rounded),
                          label: const Text('Clear Filter'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: canUpdate ? _submitSelected : null,
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: Text(
                        _selectedActivityIds.isEmpty
                            ? 'Update Selected'
                            : 'Update Selected (${_selectedActivityIds.length})',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableCard(
    BuildContext context,
    List<Map<String, dynamic>> rows, {
    required bool allPageSelected,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double scrollableWidth = _headers.fold<double>(
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
            child: !_filtersApplied
                ? const Center(child: Text('Apply filters to load activities.'))
                : AppStickyLeadingColumnTable(
                    leadingWidth: _selectionColumnWidth,
                    scrollableWidth: scrollableWidth,
                    rowExtent: _rowExtent,
                    itemCount: rows.length,
                    emptyPlaceholder: const Center(
                      child: Text('No activities found.'),
                    ),
                    leadingHeader: _selectionHeader(
                      context,
                      allPageSelected: allPageSelected,
                    ),
                    scrollableHeader: _scrollableHeader(context),
                    leadingRowBuilder: (BuildContext context, int index) =>
                        _selectionCell(
                      context,
                      rows[index],
                      index,
                    ),
                    scrollableRowBuilder: (BuildContext context, int index) =>
                        _scrollableRow(
                      context,
                      rows[index],
                      index,
                      isLast: index == rows.length - 1,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _selectionHeader(
    BuildContext context, {
    required bool allPageSelected,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: _rowExtent,
      color: colorScheme.primary,
      alignment: Alignment.center,
      child: Checkbox(
        value: allPageSelected,
        tristate: true,
        onChanged: _filtersApplied && _rows.isNotEmpty
            ? (bool? value) => _toggleSelectAll(value)
            : null,
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => colorScheme.onPrimary,
        ),
        checkColor: colorScheme.primary,
      ),
    );
  }

  Widget _scrollableHeader(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: _rowExtent,
      color: colorScheme.primary,
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

  Widget _selectionCell(
    BuildContext context,
    Map<String, dynamic> row,
    int index,
  ) {
    final String activityId = _activityIdForRow(row);
    final bool selected = _selectedActivityIds.contains(activityId);
    return Material(
      color: _rowBackground(context, index, selected: selected),
      child: InkWell(
        onTap: activityId.isEmpty ? null : () => _toggleRowSelection(activityId),
        child: Center(
          child: Checkbox(
            value: selected,
            onChanged: activityId.isEmpty
                ? null
                : (bool? value) => _setRowSelected(activityId, value == true),
          ),
        ),
      ),
    );
  }

  Widget _scrollableRow(
    BuildContext context,
    Map<String, dynamic> row,
    int index, {
    bool isLast = false,
  }) {
    final String activityId = _activityIdForRow(row);
    final bool selected = _selectedActivityIds.contains(activityId);
    final BorderRadius? rowRadius = isLast
        ? const BorderRadius.vertical(bottom: Radius.circular(14))
        : null;
    return ClipRRect(
      borderRadius: rowRadius ?? BorderRadius.zero,
      child: Material(
        color: _rowBackground(context, index, selected: selected),
        child: InkWell(
          onTap: activityId.isEmpty
              ? null
              : () => _toggleRowSelection(activityId),
          child: SizedBox(
            height: _rowExtent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
              _cell(_taskCode(row), width: _columnWidth('Task Code')),
              _cell(_activityName(row), width: _columnWidth('Activity')),
              _cell(_scope(row), width: _columnWidth('Scope')),
              _cell(_completed(row), width: _columnWidth('Completed')),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Color _rowBackground(
    BuildContext context,
    int index, {
    required bool selected,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (selected) {
      return colorScheme.primaryContainer.withValues(alpha: 0.45);
    }
    return index.isEven
        ? colorScheme.primary.withValues(alpha: 0.08)
        : colorScheme.surface;
  }

  void _toggleRowSelection(String activityId) {
    setState(() {
      if (_selectedActivityIds.contains(activityId)) {
        _selectedActivityIds.remove(activityId);
      } else {
        _selectedActivityIds.add(activityId);
      }
    });
  }

  void _setRowSelected(String activityId, bool selected) {
    setState(() {
      if (selected) {
        _selectedActivityIds.add(activityId);
      } else {
        _selectedActivityIds.remove(activityId);
      }
    });
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
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: color, fontWeight: weight, fontSize: 13),
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

  Future<void> _loadContractOptions() async {
    setState(() => _loading = true);
    try {
      final Map<String, dynamic> bootstrap =
          await widget.dataSource.fetchNewActivitiesUpdateBootstrap();
      if (!mounted) {
        return;
      }
      setState(() {
        _contractOptions = _dedupeOptions(
          _rowsFromMap(bootstrap, 'contractsList').map(_contractOptionFromRow),
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load contracts',
        message: userFriendlyErrorMessage(error),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _reloadTableFromApi() async {
    if (!_canLoadTable) {
      return;
    }
    setState(() => _loading = true);
    try {
      final List<Map<String, dynamic>> rows =
          await widget.dataSource.fetchModifyActualsActivitiesList(
        contractIdFk: _selectedContract!,
        stripChartStructureIdFk: _selectedAction!.requiresStructure
            ? _selectedStructure
            : '',
        searchStr: _search,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _rows = rows;
        _selectedActivityIds.removeWhere(
          (String id) => !rows.any(
            (Map<String, dynamic> row) => _activityIdForRow(row) == id,
          ),
        );
        _currentPage = 0;
        _filtersApplied = true;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load activities',
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
      _selectedAction = null;
      _selectedContract = null;
      _selectedStructure = null;
      _structureOptions = <_FilterOption>[];
      _rows = <Map<String, dynamic>>[];
      _selectedActivityIds.clear();
      _filtersApplied = false;
      _currentPage = 0;
      _searchController.clear();
      _search = '';
    });
  }

  Future<void> _openFilterDialog() async {
    _ModifyActualsAction? dialogAction = _selectedAction;
    String? dialogContract = _selectedContract;
    String? dialogStructure = _selectedStructure;
    List<_FilterOption> dialogStructures = _structureOptions;
    bool dialogLoading = false;
    bool shouldApply = false;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            Future<void> onContractChanged(String? value) async {
              setDialogState(() {
                dialogContract = value;
                dialogStructure = null;
                dialogStructures = <_FilterOption>[];
              });
              if (value == null || value.isEmpty) {
                return;
              }
              setDialogState(() => dialogLoading = true);
              try {
                final List<Map<String, dynamic>> rows =
                    await widget.dataSource.fetchContractStructures(
                  contractIdFk: value,
                );
                if (!dialogContext.mounted) {
                  return;
                }
                setDialogState(() {
                  dialogStructures = _dedupeOptions(
                    rows.map(_structureOptionFromRow),
                  );
                  dialogStructure = _retainValid(dialogStructure, dialogStructures);
                });
              } finally {
                if (dialogContext.mounted) {
                  setDialogState(() => dialogLoading = false);
                }
              }
            }

            return AlertDialog(
              title: const Center(child: Text('Filter Activities')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _dialogDropdown(
                      label: 'Action *',
                      options: _ModifyActualsAction.values
                          .map(
                            (_ModifyActualsAction action) => _FilterOption(
                              value: action.name,
                              label: action.label,
                            ),
                          )
                          .toList(),
                      value: dialogAction?.name,
                      onChanged: (String? value) {
                        _ModifyActualsAction? action;
                        if (value != null) {
                          for (final _ModifyActualsAction item
                              in _ModifyActualsAction.values) {
                            if (item.name == value) {
                              action = item;
                              break;
                            }
                          }
                        }
                        setDialogState(() {
                          dialogAction = action;
                          if (action != null && !action.requiresStructure) {
                            dialogStructure = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _dialogDropdown(
                      label: 'Contract *',
                      options: _contractOptions,
                      value: dialogContract,
                      onChanged: (String? value) => onContractChanged(value),
                    ),
                    if (dialogAction?.requiresStructure == true) ...<Widget>[
                      const SizedBox(height: 10),
                      _dialogDropdown(
                        label: 'Structure *',
                        options: dialogStructures,
                        value: dialogStructure,
                        onChanged: dialogLoading
                            ? null
                            : (String? value) =>
                                  setDialogState(() => dialogStructure = value),
                      ),
                    ],
                    if (dialogLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(),
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
                    if (dialogAction == null) {
                      AppDialog.show(
                        context: context,
                        title: 'Action required',
                        message: 'Please select an action.',
                        type: AppDialogType.info,
                      );
                      return;
                    }
                    if (dialogContract == null || dialogContract!.isEmpty) {
                      AppDialog.show(
                        context: context,
                        title: 'Contract required',
                        message: 'Please select a contract.',
                        type: AppDialogType.info,
                      );
                      return;
                    }
                    if (dialogAction!.requiresStructure &&
                        (dialogStructure == null || dialogStructure!.isEmpty)) {
                      AppDialog.show(
                        context: context,
                        title: 'Structure required',
                        message: 'Please select a structure.',
                        type: AppDialogType.info,
                      );
                      return;
                    }
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
    setState(() {
      _selectedAction = dialogAction;
      _selectedContract = dialogContract;
      _selectedStructure = dialogStructure;
      _structureOptions = dialogStructures;
      _selectedActivityIds.clear();
      _currentPage = 0;
    });
    await _reloadTableFromApi();
  }

  Future<void> _submitSelected() async {
    if (_selectedAction == null ||
        _selectedContract == null ||
        _selectedActivityIds.isEmpty) {
      return;
    }
    final _ModifyActualsAction action = _selectedAction!;
    await AppDialog.show(
      context: context,
      title: 'Confirm update',
      message:
          'Apply "${action.label}" to ${_selectedActivityIds.length} selected row(s)?',
      type: AppDialogType.confirmation,
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Update',
          isPrimary: true,
          onPressed: () => _runBulkUpdate(action),
        ),
      ],
    );
  }

  Future<void> _runBulkUpdate(_ModifyActualsAction action) async {
    if (_selectedContract == null || _selectedActivityIds.isEmpty || !mounted) {
      return;
    }

    final List<Map<String, dynamic>> selectedRows = _rows
        .where(
          (Map<String, dynamic> row) =>
              _selectedActivityIds.contains(_activityIdForRow(row)),
        )
        .toList();
    final Map<String, dynamic> payload = <String, dynamic>{
      'pending': action.pending,
      'contract_id_fk': _selectedContract,
      'strip_chart_structure_id_fk': action.requiresStructure
          ? (_selectedStructure ?? '')
          : '',
      'p6_task_codes': selectedRows.map(_taskCode).toList(),
      'activity_ids': selectedRows.map(_activityIdForRow).toList(),
      'totalScopes': selectedRows.map(_scope).toList(),
      'completedScopes': selectedRows.map(_completed).toList(),
      'ids': List<int>.filled(selectedRows.length, 1),
    };

    setState(() => _loading = true);
    try {
      final Map<String, dynamic> response =
          await widget.dataSource.submitModifyActualsBulk(payload: payload);
      if (!mounted) {
        return;
      }
      final String message = _safeString(response['success']) ??
          _safeString(response['message']) ??
          'Activities updated successfully.';
      await AppDialog.show(
        context: context,
        title: 'Update complete',
        message: message,
        type: AppDialogType.success,
      );
      setState(() => _selectedActivityIds.clear());
      await _reloadTableFromApi();
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Update failed',
        message: userFriendlyErrorMessage(error),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _toggleSelectAll(bool? value) {
    final List<Map<String, dynamic>> filteredRows = _filteredRows(_rows);
    final int start = _currentPage * _pageSize;
    final int end = (start + _pageSize).clamp(0, filteredRows.length);
    final List<Map<String, dynamic>> pageRows = filteredRows.sublist(
      start.clamp(0, filteredRows.length),
      end,
    );
    setState(() {
      if (value == true) {
        for (final Map<String, dynamic> row in pageRows) {
          final String id = _activityIdForRow(row);
          if (id.isNotEmpty) {
            _selectedActivityIds.add(id);
          }
        }
      } else {
        for (final Map<String, dynamic> row in pageRows) {
          _selectedActivityIds.remove(_activityIdForRow(row));
        }
      }
    });
  }

  bool get _canLoadTable {
    if (_selectedAction == null ||
        _selectedContract == null ||
        _selectedContract!.isEmpty) {
      return false;
    }
    if (_selectedAction!.requiresStructure) {
      return _selectedStructure != null && _selectedStructure!.isNotEmpty;
    }
    return true;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedAction != null) {
      count++;
    }
    if (_selectedContract != null) {
      count++;
    }
    if (_selectedStructure != null) {
      count++;
    }
    return count;
  }

  List<Map<String, dynamic>> _filteredRows(List<Map<String, dynamic>> rows) {
    if (_search.isEmpty) {
      return rows;
    }
    final String query = _search.toLowerCase();
    return rows
        .where(
          (Map<String, dynamic> row) {
            final String haystack =
                '${_taskCode(row)} ${_activityName(row)} ${_scope(row)} ${_completed(row)}'
                    .toLowerCase();
            return haystack.contains(query);
          },
        )
        .toList();
  }

  double _columnWidth(String header) {
    switch (header) {
      case 'Task Code':
        return 150;
      case 'Activity':
        return 180;
      case 'Scope':
      case 'Completed':
        return 100;
      default:
        return 120;
    }
  }

  Widget _dialogDropdown({
    required String label,
    required List<_FilterOption> options,
    required String? value,
    required ValueChanged<String?>? onChanged,
  }) {
    final String selectedLabel = value == null
        ? 'Select'
        : options
                  .where((_FilterOption item) => item.value == value)
                  .map((_FilterOption item) => item.label)
                  .firstOrNull ??
              value;
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
          hint: Text(selectedLabel),
          items: options
              .map(
                (_FilterOption option) => DropdownMenuItem<String>(
                  value: option.value,
                  child: Text(
                    option.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
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

  String? _retainValid(String? selected, List<_FilterOption> options) {
    if (selected == null) {
      return null;
    }
    final bool exists =
        options.any((_FilterOption item) => item.value == selected);
    return exists ? selected : null;
  }

  List<Map<String, dynamic>> _rowsFromMap(
    Map<String, dynamic> json,
    String key,
  ) {
    final List<dynamic>? list = json[key] as List<dynamic>?;
    if (list == null) {
      return <Map<String, dynamic>>[];
    }
    return list
        .whereType<Map>()
        .map(
          (Map row) => row.map(
            (dynamic key, dynamic value) => MapEntry(key.toString(), value),
          ),
        )
        .toList();
  }

  _FilterOption _contractOptionFromRow(Map<String, dynamic> row) {
    final String value = _stringValue(
      row['contract_id_fk'] ?? row['contract_id'],
    );
    final String label = _stringValue(
      row['contract_short_name'] ?? row['contract_name'] ?? value,
    );
    return _FilterOption(value: value, label: label);
  }

  _FilterOption _structureOptionFromRow(Map<String, dynamic> row) {
    final String value = _stringValue(
      row['strip_chart_structure_id_fk'] ??
          row['strip_chart_structure_id'] ??
          row['structure_id_fk'] ??
          row['structure'],
    );
    final String label = _stringValue(
      row['strip_chart_structure'] ??
          row['structure_name'] ??
          row['structure'] ??
          value,
    );
    return _FilterOption(value: value, label: label);
  }

  String _taskCode(Map<String, dynamic> row) => _stringValue(row['p6_task_code']);

  String _activityName(Map<String, dynamic> row) =>
      _stringValue(row['strip_chart_activity_name']);

  String _scope(Map<String, dynamic> row) => _stringValue(row['scope']);

  String _completed(Map<String, dynamic> row) => _stringValue(row['completed']);

  String _activityIdForRow(Map<String, dynamic> row) =>
      _stringValue(row['activity_id'] ?? row['strip_chart_activity_id']);

  String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }

  String? _safeString(dynamic value) {
    if (value == null) {
      return null;
    }
    final String text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
