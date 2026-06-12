import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/structures/update_structure_work_form_page.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

class StructureFormListPage extends StatefulWidget {
  const StructureFormListPage({super.key, required this.dataSource});

  static const String routeName = 'structure-form';
  static const String routePath = '/structure-form';

  final DashboardRemoteDataSource dataSource;

  @override
  State<StructureFormListPage> createState() => _StructureFormListPageState();
}

class _StructureFormListPageState extends State<StructureFormListPage> {
  static const List<int> _pageSizes = <int>[5, 10, 25, 50];
  static const List<String> _headers = <String>[
    'Project',
    'Structure Type',
    'Structure',
    'Contract',
    'Work Status',
    'Edit',
  ];
  static const Map<String, double> _columnWidths = <String, double>{
    'Project': 108,
    'Structure Type': 132,
    'Structure': 168,
    'Contract': 220,
    'Work Status': 112,
    'Edit': 52,
  };

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _searchDebounce;

  bool _loading = false;
  bool _filtersLoading = false;
  String? _loadError;

  String _search = '';
  int _pageSize = 10;
  int _currentPage = 0;
  int _totalRecords = 0;

  String? _selectedContractId;
  String? _selectedStructureType;
  String? _selectedWorkStatus;

  List<_FilterOption> _contractOptions = <_FilterOption>[];
  List<_FilterOption> _structureTypeOptions = <_FilterOption>[];
  List<_FilterOption> _workStatusOptions = <_FilterOption>[];
  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedContractId != null) count++;
    if (_selectedStructureType != null) count++;
    if (_selectedWorkStatus != null) count++;
    return count;
  }

  int get _pageCount =>
      _totalRecords == 0 ? 1 : (_totalRecords / _pageSize).ceil();

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      await _loadList();
      unawaited(_reloadFilters().catchError((_) {}));
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loadError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _reloadFilters() async {
    setState(() => _filtersLoading = true);
    try {
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        widget.dataSource.fetchStructureFormContractFilter(
          structureTypeFk: _selectedStructureType ?? '',
          workStatusFk: _selectedWorkStatus ?? '',
        ),
        widget.dataSource.fetchStructureFormStructureTypeFilter(
          contractIdFk: _selectedContractId ?? '',
          workStatusFk: _selectedWorkStatus ?? '',
        ),
        widget.dataSource.fetchStructureFormWorkStatusFilter(
          contractIdFk: _selectedContractId ?? '',
          structureTypeFk: _selectedStructureType ?? '',
        ),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _contractOptions = _parseContractOptions(
          results[0] as List<Map<String, dynamic>>,
        );
        _structureTypeOptions = _parseStructureTypeOptions(
          results[1] as List<Map<String, dynamic>>,
        );
        _workStatusOptions = _parseWorkStatusOptions(
          results[2] as List<Map<String, dynamic>>,
        );
        _selectedContractId =
            _retain(_selectedContractId, _contractOptions);
        _selectedStructureType =
            _retain(_selectedStructureType, _structureTypeOptions);
        _selectedWorkStatus =
            _retain(_selectedWorkStatus, _workStatusOptions);
        _filtersLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _filtersLoading = false);
      rethrow;
    }
  }

  Future<void> _loadList() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final int safePage = _currentPage.clamp(0, _pageCount - 1);
      if (safePage != _currentPage) {
        _currentPage = safePage;
      }
      final StructureFormListResponse response =
          await widget.dataSource.fetchStructureFormList(
            start: _currentPage * _pageSize,
            length: _pageSize,
            search: _search,
            contractIdFk: _selectedContractId,
            structureTypeFk: _selectedStructureType,
            workStatusFk: _selectedWorkStatus,
          );
      if (!mounted) {
        return;
      }
      if (response.totalRecords > 0 && response.rows.isEmpty) {
        throw StateError(
          'Structure list returned ${response.totalRecords} records, '
          'but the response could not be parsed.',
        );
      }
      setState(() {
        _rows = response.rows;
        _totalRecords = response.totalRecords;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = error.toString();
        _rows = <Map<String, dynamic>>[];
        _totalRecords = 0;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _refreshAll({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 0;
    }
    setState(() => _loading = true);
    try {
      await _reloadFilters();
      await _loadList();
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to refresh',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () async {
      if (!mounted) {
        return;
      }
      setState(() {
        _search = value.trim();
        _currentPage = 0;
      });
      await _loadList();
    });
  }

  Future<void> _clearFilters() async {
    setState(() {
      _selectedContractId = null;
      _selectedStructureType = null;
      _selectedWorkStatus = null;
      _search = '';
      _searchCtrl.clear();
      _currentPage = 0;
    });
    await _refreshAll();
  }

  Future<void> _openFilterSheet() async {
    String? contractId = _selectedContractId;
    String? structureType = _selectedStructureType;
    String? workStatus = _selectedWorkStatus;
    bool apply = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            Future<void> reloadDependentFilters() async {
              setSheetState(() => _filtersLoading = true);
              try {
                final List<Object> results =
                    await Future.wait<Object>(<Future<Object>>[
                  widget.dataSource.fetchStructureFormContractFilter(
                    structureTypeFk: structureType ?? '',
                    workStatusFk: workStatus ?? '',
                  ),
                  widget.dataSource.fetchStructureFormStructureTypeFilter(
                    contractIdFk: contractId ?? '',
                    workStatusFk: workStatus ?? '',
                  ),
                  widget.dataSource.fetchStructureFormWorkStatusFilter(
                    contractIdFk: contractId ?? '',
                    structureTypeFk: structureType ?? '',
                  ),
                ]);
                if (!context.mounted) {
                  return;
                }
                final List<_FilterOption> contracts = _parseContractOptions(
                  results[0] as List<Map<String, dynamic>>,
                );
                final List<_FilterOption> types = _parseStructureTypeOptions(
                  results[1] as List<Map<String, dynamic>>,
                );
                final List<_FilterOption> statuses = _parseWorkStatusOptions(
                  results[2] as List<Map<String, dynamic>>,
                );
                setSheetState(() {
                  _contractOptions = contracts;
                  _structureTypeOptions = types;
                  _workStatusOptions = statuses;
                  contractId = _retain(contractId, contracts);
                  structureType = _retain(structureType, types);
                  workStatus = _retain(workStatus, statuses);
                  _filtersLoading = false;
                });
              } catch (_) {
                if (context.mounted) {
                  setSheetState(() => _filtersLoading = false);
                }
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Filter Structures',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppSelectSheetField<String?>(
                    label: 'Contract',
                    title: 'Select Contract',
                    compact: true,
                    placeholderText: 'All Contracts',
                    enabled: !_filtersLoading,
                    items: <String?>[null, ..._contractOptions.map(( _FilterOption o) => o.value)],
                    value: contractId,
                    itemLabelBuilder: (String? value) =>
                        _labelForOption(value, _contractOptions, 'All Contracts'),
                    onChanged: (String? value) async {
                      contractId = value;
                      await reloadDependentFilters();
                    },
                  ),
                  const SizedBox(height: 10),
                  AppSelectSheetField<String?>(
                    label: 'Structure Type',
                    title: 'Select Structure Type',
                    compact: true,
                    placeholderText: 'All Types',
                    enabled: !_filtersLoading,
                    items: <String?>[null, ..._structureTypeOptions.map(( _FilterOption o) => o.value)],
                    value: structureType,
                    itemLabelBuilder: (String? value) =>
                        _labelForOption(value, _structureTypeOptions, 'All Types'),
                    onChanged: (String? value) async {
                      structureType = value;
                      await reloadDependentFilters();
                    },
                  ),
                  const SizedBox(height: 10),
                  AppSelectSheetField<String?>(
                    label: 'Work Status',
                    title: 'Select Work Status',
                    compact: true,
                    placeholderText: 'All Statuses',
                    enabled: !_filtersLoading,
                    items: <String?>[null, ..._workStatusOptions.map(( _FilterOption o) => o.value)],
                    value: workStatus,
                    itemLabelBuilder: (String? value) =>
                        _labelForOption(value, _workStatusOptions, 'All Statuses'),
                    onChanged: (String? value) async {
                      workStatus = value;
                      await reloadDependentFilters();
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _filtersLoading
                              ? null
                              : () => Navigator.of(sheetContext).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: _filtersLoading
                              ? null
                              : () {
                                  apply = true;
                                  Navigator.of(sheetContext).pop();
                                },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (!apply || !mounted) {
      return;
    }
    setState(() {
      _selectedContractId = contractId;
      _selectedStructureType = structureType;
      _selectedWorkStatus = workStatus;
      _currentPage = 0;
    });
    await _refreshAll();
  }

  Future<void> _onEditTap(Map<String, dynamic> row) async {
    final String? structureId = _structureIdFromRow(row);
    if (structureId == null || structureId.isEmpty) {
      await AppDialog.show(
        context: context,
        title: 'Unable to Edit',
        message: 'Structure id is missing for this row.',
        type: AppDialogType.error,
      );
      return;
    }
    final bool? saved = await context.pushNamed<bool>(
      UpdateStructureWorkFormPage.routeName,
      queryParameters: <String, String>{'structure_id': structureId},
    );
    if (saved == true && mounted) {
      await _loadList();
    }
  }

  String? _structureIdFromRow(Map<String, dynamic> row) {
    for (final String key in const <String>[
      'structure_id',
      'structure_id_fk',
      'id',
    ]) {
      final String? value = _safe(row[key]);
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final int safePage = _currentPage.clamp(0, _pageCount - 1);
    if (safePage != _currentPage) {
      _currentPage = safePage;
    }
    final int start = _totalRecords == 0 ? 0 : safePage * _pageSize;
    final int end = _totalRecords == 0
        ? 0
        : (start + _rows.length).clamp(0, _totalRecords);
    final bool hasActiveFilters =
        _activeFilterCount > 0 || _search.isNotEmpty;
    final double tableWidth = _headers.fold<double>(
      0,
      (double sum, String header) => sum + (_columnWidths[header] ?? 120),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Structure Form')),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search structures...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 36,
                        ),
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _onSearchChanged('');
                                },
                                icon: const Icon(Icons.close_rounded, size: 20),
                              )
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: _loading ? null : _openFilterSheet,
                            icon: const Icon(Icons.filter_alt_rounded, size: 18),
                            label: Text(
                              _activeFilterCount == 0
                                  ? 'Filter'
                                  : 'Filter ($_activeFilterCount)',
                            ),
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: !hasActiveFilters || _loading
                              ? null
                              : _clearFilters,
                          icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                          label: const Text('Clear'),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_loadError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Material(
                    color: colorScheme.errorContainer.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                    child: ListTile(
                      dense: true,
                      title: Text(
                        'Unable to load structures',
                        style: TextStyle(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        _loadError!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                      trailing: TextButton(
                        onPressed: _loading ? null : () => _refreshAll(),
                        child: const Text('Retry'),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _rows.isEmpty && !_loading
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              hasActiveFilters
                                  ? 'No structures match your filters.'
                                  : 'No structures found.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: tableWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                _buildHeader(context, tableWidth),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: _rows.length,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      return _buildRow(
                                        context,
                                        _rows[index],
                                        index,
                                        tableWidth: tableWidth,
                                        isLast: index == _rows.length - 1,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              AppTablePaginationFooter(
                total: _totalRecords,
                startIndex: start,
                endIndex: end,
                currentPage: safePage,
                pageCount: _pageCount,
                pageSize: _pageSize,
                pageSizeOptions: _pageSizes,
                onPageSizeChanged: (int value) async {
                  setState(() {
                    _pageSize = value;
                    _currentPage = 0;
                  });
                  await _loadList();
                },
                onPrevious: safePage > 0 && !_loading
                    ? () async {
                        setState(() => _currentPage = safePage - 1);
                        await _loadList();
                      }
                    : null,
                onNext: safePage < _pageCount - 1 && !_loading
                    ? () async {
                        setState(() => _currentPage = safePage + 1);
                        await _loadList();
                      }
                    : null,
              ),
            ],
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

  Widget _buildHeader(BuildContext context, double tableWidth) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color dividerColor =
        colorScheme.onPrimary.withValues(alpha: 0.35);
    final TextStyle? headerStyle = Theme.of(context).textTheme.labelLarge
        ?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
        );

    return ColoredBox(
      color: colorScheme.primary,
      child: SizedBox(
        width: tableWidth,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _headers.map((String header) {
              final bool isLast = header == _headers.last;
              return _headerCell(
                width: _columnWidths[header],
                showRightBorder: !isLast,
                dividerColor: dividerColor,
                alignment: header == 'Edit'
                    ? Alignment.center
                    : Alignment.centerLeft,
                child: Text(
                  header,
                  style: headerStyle,
                  textAlign: header == 'Edit' ? TextAlign.center : null,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _headerCell({
    required Widget child,
    required bool showRightBorder,
    required Color dividerColor,
    double? width,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: showRightBorder
          ? BoxDecoration(
              border: Border(right: BorderSide(color: dividerColor)),
            )
          : null,
      alignment: alignment,
      child: child,
    );
  }

  Widget _buildRow(
    BuildContext context,
    Map<String, dynamic> row,
    int index, {
    required double tableWidth,
    required bool isLast,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color rowColor = index.isEven
        ? colorScheme.primary.withValues(alpha: 0.06)
        : colorScheme.surface;
    final BorderRadius? radius = isLast
        ? const BorderRadius.vertical(bottom: Radius.circular(14))
        : null;

    return ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: ColoredBox(
        color: rowColor,
        child: SizedBox(
          width: tableWidth,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _dataCell(
                  _projectLabel(row),
                  width: _columnWidths['Project']!,
                ),
                _dataCell(
                  _cellValue(
                    row,
                    const <String>['structure_type_fk', 'structure_type'],
                  ),
                  width: _columnWidths['Structure Type']!,
                ),
                _dataCell(
                  _cellValue(
                    row,
                    const <String>['structure', 'structure_name'],
                  ),
                  width: _columnWidths['Structure']!,
                ),
                _dataCell(
                  _cellValue(
                    row,
                    const <String>[
                      'contract_short_name',
                      'contract_name',
                    ],
                  ),
                  width: _columnWidths['Contract']!,
                ),
                _dataCell(
                  _cellValue(
                    row,
                    const <String>['work_status_fk', 'work_status'],
                  ),
                  width: _columnWidths['Work Status']!,
                ),
                SizedBox(
                  width: _columnWidths['Edit'],
                  child: Center(
                    child: IconButton(
                      tooltip: 'Edit Structure Work',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      onPressed: _loading ? null : () => _onEditTap(row),
                      icon: Icon(
                        Icons.edit_rounded,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dataCell(String value, {required double width}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  List<_FilterOption> _parseContractOptions(List<Map<String, dynamic>> rows) {
    return _dedupeOptions(
      rows.map((Map<String, dynamic> row) {
        final String id = _safe(
              row['contract_id_fk'] ?? row['contract_id'],
            ) ??
            '';
        final String shortName = _safe(row['contract_short_name']) ??
            _safe(row['contract_name']) ??
            '';
        final String label = id.isNotEmpty && shortName.isNotEmpty
            ? '$id - $shortName'
            : id.isNotEmpty
            ? id
            : shortName;
        return _FilterOption(value: id, label: label);
      }),
    );
  }

  List<_FilterOption> _parseStructureTypeOptions(
    List<Map<String, dynamic>> rows,
  ) {
    return _dedupeOptions(
      rows.map((Map<String, dynamic> row) {
        final String type = _safe(row['structure_type']) ?? '';
        return _FilterOption(value: type, label: type);
      }),
    );
  }

  List<_FilterOption> _parseWorkStatusOptions(
    List<Map<String, dynamic>> rows,
  ) {
    return _dedupeOptions(
      rows.map((Map<String, dynamic> row) {
        final String status = _safe(row['work_status_fk']) ??
            _safe(row['work_status']) ??
            '';
        return _FilterOption(value: status, label: status);
      }),
    );
  }

  String _projectLabel(Map<String, dynamic> row) {
    final String? id = _safe(row['project_id_fk'] ?? row['project_id']);
    final String? name = _safe(row['project_name']);
    if (id != null && name != null) {
      return '$id - $name';
    }
    return id ?? name ?? '-';
  }

  String _cellValue(Map<String, dynamic> row, List<String> keys) {
    for (final String key in keys) {
      final String? value = _safe(row[key]);
      if (value != null) {
        return value;
      }
    }
    return '-';
  }

  String _labelForOption(
    String? value,
    List<_FilterOption> options,
    String allLabel,
  ) {
    if (value == null) {
      return allLabel;
    }
    for (final _FilterOption option in options) {
      if (option.value == value) {
        return option.label;
      }
    }
    return value;
  }

  List<_FilterOption> _dedupeOptions(Iterable<_FilterOption> options) {
    final Map<String, _FilterOption> map = <String, _FilterOption>{};
    for (final _FilterOption item in options) {
      if (item.value.isEmpty) {
        continue;
      }
      map.putIfAbsent(item.value, () => item);
    }
    final List<_FilterOption> values = map.values.toList()
      ..sort(
        ( _FilterOption a, _FilterOption b) => a.label.compareTo(b.label),
      );
    return values;
  }

  String? _retain(String? value, List<_FilterOption> options) {
    if (value == null) {
      return null;
    }
    return options.any((_FilterOption option) => option.value == value)
        ? value
        : null;
  }

  String? _safe(dynamic value) {
    if (value == null) {
      return null;
    }
    final String text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }
}

class _FilterOption {
  const _FilterOption({required this.value, required this.label});

  final String value;
  final String label;
}
