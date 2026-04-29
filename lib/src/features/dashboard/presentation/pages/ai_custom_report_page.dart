import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

class AiCustomReportPage extends StatefulWidget {
  const AiCustomReportPage({super.key, required this.dataSource});

  static const String routeName = 'ai-custom-report';
  static const String routePath = '/ai-custom-report';

  final DashboardRemoteDataSource dataSource;

  @override
  State<AiCustomReportPage> createState() => _AiCustomReportPageState();
}

class _AiCustomReportPageState extends State<AiCustomReportPage> {
  static const MethodChannel _fileExportChannel = MethodChannel(
    'wcr_pmis_mobile/file_export',
  );
  static const Map<String, String> _columnTitles = <String, String>{
    'project_name': 'Project Name',
    'activity_name': 'Activity Name',
    'completed': 'Completed',
    'scope': 'Scope',
    'progress': 'Progress',
    'status': 'Status',
  };

  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  String _search = '';
  String? _groupBy;
  String? _orderBy;
  bool _ascending = true;
  int _rowsPerPage = 10;
  int _currentPage = 1;
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50, 100];
  final Set<String> _visibleColumns = Set<String>.from(_columnTitles.keys);

  @override
  void dispose() {
    _queryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = _rows.isNotEmpty;
    final List<Map<String, dynamic>> rows = _pagedRows;
    final int totalRows = _processedRows.length;
    final List<String> columns = _selectedColumns;
    return Scaffold(
      appBar: AppBar(title: const Text('AI Custom Report')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: <Widget>[
            _queryCard(context),
            if (hasData) ...<Widget>[
              const SizedBox(height: 10),
              _controlsCard(context),
              const SizedBox(height: 10),
              _tableCard(context, rows, columns),
              const SizedBox(height: 84),
            ],
          ],
        ),
      ),
      bottomNavigationBar: hasData ? _stickyPaginationBar(totalRows) : null,
    );
  }

  Widget _queryCard(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle generateLabelStyle =
        (textTheme.labelLarge ?? const TextStyle()).copyWith(
      color: colorScheme.onPrimary,
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _queryController,
              readOnly: _loading,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Describe the report in plain language....',
                hintMaxLines: 4,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                const Spacer(),
                FilledButton.icon(
                  onPressed: _loading ? null : _generate,
                  icon: _loading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _loading ? 'Generating...' : 'Generate Report',
                    maxLines: 1,
                    style: generateLabelStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlsCard(BuildContext context) {
    final List<String> activeColumns = _activeColumns;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _searchController,
              onChanged: (String value) => setState(() {
                _search = value.trim();
                _currentPage = 1;
              }),
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _titledControl(
                    title: 'Group By',
                    child: _simpleDropdown(
                      options: activeColumns,
                      value: _groupBy,
                      onChanged: (String? v) => setState(() {
                        _groupBy = v;
                        _currentPage = 1;
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _titledControl(
                    title: 'Order By',
                    child: _simpleDropdown(
                      options: activeColumns,
                      value: _orderBy,
                      onChanged: (String? v) => setState(() {
                        _orderBy = v;
                        _currentPage = 1;
                      }),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _titledControl(
                    title: 'Entries',
                    child: _rowsPerPageDropdown(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _titledControl(
                    title: 'Sort',
                    child: _ascDescToggle(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: _openColumnsSheet,
                icon: const Icon(Icons.view_column_rounded),
                label: Text('Columns (${_selectedColumns.length})'),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _rows.isEmpty ? null : _confirmExportExcel,
                    icon: const Icon(Icons.table_view_rounded, size: 18),
                    label: const Text('Excel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _rows.isEmpty ? null : _confirmExportPdf,
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: const Text('PDF'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _rows.isEmpty
                    ? null
                    : () => setState(() => _resetTableControls(preserveRows: true)),
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset filters and sorting'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableCard(
    BuildContext context,
    List<Map<String, dynamic>> rows,
    List<String> columns,
  ) {
    if (rows.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No report data available.')),
        ),
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _tableWidth(columns),
          child: Column(
            children: <Widget>[
              Container(
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: columns
                      .map(
                        (String col) => _cellWithWidth(
                          col,
                          _columnTitles[col] ?? col,
                          isHeader: true,
                        ),
                      )
                      .toList(),
                ),
              ),
              ..._tableBody(context, rows, columns),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cellWithWidth(String columnKey, String text, {bool isHeader = false}) {
    return SizedBox(
      width: _columnWidth(columnKey),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
            color: isHeader ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  Widget _simpleDropdown({
    required List<String> options,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          isDense: true,
          items: <DropdownMenuItem<String?>>[
            const DropdownMenuItem<String?>(value: null, child: Text('None')),
            ...options.map(
              (String key) => DropdownMenuItem<String?>(
                value: key,
                child: Text(_columnLabel(key)),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _titledControl({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  List<Map<String, dynamic>> get _processedRows {
    final List<Map<String, dynamic>> rows = _rows.where((Map<String, dynamic> row) {
      if (_search.isEmpty) {
        return true;
      }
      final String query = _search.toLowerCase();
      return row.values.any((dynamic value) {
        final String text = _displayValue(value, '').toLowerCase();
        return text.contains(query);
      });
    }).toList();

    if (_groupBy != null) {
      rows.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        // Keep group headers in predictable ascending order.
        final int groupCompare = _compareByKey(a, b, _groupBy!);
        if (groupCompare != 0) {
          return groupCompare;
        }
        final String orderKey = _orderBy ?? _groupBy!;
        final int result = _compareByKey(a, b, orderKey);
        if (_orderBy == null) {
          return result;
        }
        return _ascending ? result : -result;
      });
    } else if (_orderBy != null) {
      rows.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        final int result = _compareByKey(a, b, _orderBy!);
        return _ascending ? result : -result;
      });
    }
    return rows;
  }

  int _compareByKey(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
    String key,
  ) {
    final dynamic av = a[key];
    final dynamic bv = b[key];
    if (av == null && bv == null) {
      return 0;
    }
    if (av == null) {
      return 1;
    }
    if (bv == null) {
      return -1;
    }

    final double? ad = _asDouble(av);
    final double? bd = _asDouble(bv);
    if (ad != null && bd != null) {
      return ad.compareTo(bd);
    }

    final DateTime? at = DateTime.tryParse(av.toString());
    final DateTime? bt = DateTime.tryParse(bv.toString());
    if (at != null && bt != null) {
      return at.compareTo(bt);
    }

    return av.toString().toLowerCase().compareTo(bv.toString().toLowerCase());
  }

  double? _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  List<Map<String, dynamic>> get _pagedRows {
    final List<Map<String, dynamic>> allRows = _processedRows;
    if (allRows.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    final int safePage = _currentPage.clamp(1, _totalPages);
    final int start = (safePage - 1) * _rowsPerPage;
    final int end = (start + _rowsPerPage).clamp(0, allRows.length);
    return allRows.sublist(start, end);
  }

  int get _totalPages {
    final int total = _processedRows.length;
    if (total == 0) {
      return 1;
    }
    return (total / _rowsPerPage).ceil();
  }

  Future<void> _generate() async {
    final String query = _queryController.text.trim();
    if (query.isEmpty) {
      await AppDialog.show(
        context: context,
        title: 'Prompt Required',
        message: 'Enter a short description of the report you want.',
        type: AppDialogType.info,
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final Map<String, dynamic> response = await widget.dataSource.fetchAiReport(query);
      final List<dynamic> data = response['data'] as List<dynamic>? ?? <dynamic>[];
      final List<Map<String, dynamic>> rows = data
          .whereType<Map>()
          .map(
            (Map row) => row.map(
              (dynamic key, dynamic value) => MapEntry(key.toString(), value),
            ),
          )
          .toList();
      if (!mounted) {
        return;
      }
      setState(() {
        _rows = rows;
        _resetTableControls(preserveRows: true, preserveVisibleColumns: false);
        final List<String> active = _resolveActiveColumns(rows);
        _visibleColumns
          ..clear()
          ..addAll(active);
        if (_groupBy != null && !active.contains(_groupBy)) {
          _groupBy = null;
        }
        if (_orderBy != null && !active.contains(_orderBy)) {
          _orderBy = null;
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Generate Failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _ascDescToggle(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ascDescChip(
              context,
              label: 'Asc',
              selected: _ascending,
              alignLeft: true,
              onTap: () => setState(() {
                _ascending = true;
                _currentPage = 1;
              }),
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: cs.outlineVariant.withValues(alpha: 0.7),
          ),
          Expanded(
            child: _ascDescChip(
              context,
              label: 'Desc',
              selected: !_ascending,
              alignLeft: false,
              onTap: () => setState(() {
                _ascending = false;
                _currentPage = 1;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ascDescChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required bool alignLeft,
    required VoidCallback onTap,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final BorderRadius radius = alignLeft
        ? const BorderRadius.horizontal(left: Radius.circular(11))
        : const BorderRadius.horizontal(right: Radius.circular(11));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? cs.primaryContainer : Colors.transparent,
            borderRadius: radius,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: tt.labelLarge?.copyWith(
              color: selected
                  ? cs.onPrimaryContainer
                  : cs.onSurface.withValues(alpha: 0.45),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openColumnsSheet() async {
    final List<String> activeColumns = _activeColumns;
    final Set<String> draft = Set<String>.from(_selectedColumns);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Columns',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: activeColumns.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final String key = activeColumns[index];
                        final bool selected = draft.contains(key);
                        return CheckboxListTile(
                          value: selected,
                          title: Text(_columnLabel(key)),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (bool? value) {
                            setSheetState(() {
                              if (value == true) {
                                draft.add(key);
                              } else if (draft.length > 1) {
                                draft.remove(key);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _visibleColumns
                                ..clear()
                                ..addAll(draft);
                              if (_groupBy != null && !draft.contains(_groupBy)) {
                                _groupBy = null;
                              }
                              if (_orderBy != null && !draft.contains(_orderBy)) {
                                _orderBy = null;
                              }
                              _currentPage = 1;
                            });
                            Navigator.of(context).pop();
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
  }

  Widget _stickyPaginationBar(int total) {
    final int page = _currentPage.clamp(1, _totalPages);
    final int start = total == 0 ? 0 : ((page - 1) * _rowsPerPage) + 1;
    final int end = total == 0 ? 0 : (start + _pagedRows.length - 1);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(
                alpha: 0.55,
              ),
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '$start to $end of $total entries',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: page <= 1
                  ? null
                  : () => setState(() => _currentPage = page - 1),
              child: const Text('Prev'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: page >= _totalPages
                  ? null
                  : () => setState(() => _currentPage = page + 1),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowsPerPageDropdown() {
    return InputDecorator(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _rowsPerPage,
          isDense: true,
          items: _pageSizeOptions
              .map((int size) => DropdownMenuItem<int>(
                    value: size,
                    child: Text(size.toString()),
                  ))
              .toList(),
          onChanged: (int? value) {
            if (value == null) {
              return;
            }
            setState(() {
              _rowsPerPage = value;
              _currentPage = 1;
            });
          },
        ),
      ),
    );
  }

  void _resetTableControls({
    bool preserveRows = false,
    bool preserveVisibleColumns = true,
  }) {
    _search = '';
    _searchController.clear();
    _groupBy = null;
    _orderBy = null;
    _ascending = true;
    _rowsPerPage = 10;
    _currentPage = 1;
    if (!preserveVisibleColumns) {
      _visibleColumns
        ..clear()
        ..addAll(_columnTitles.keys);
    }
    if (!preserveRows) {
      _rows = <Map<String, dynamic>>[];
    }
  }

  String _displayValue(dynamic value, String key) {
    if (value == null) {
      return '-';
    }
    if (value is num) {
      if (key == 'progress') {
        return value.toStringAsFixed(2);
      }
      return value.toString();
    }
    final String text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  List<String> get _activeColumns => _resolveActiveColumns(_rows);

  List<String> get _selectedColumns {
    final List<String> active = _activeColumns;
    final List<String> selected = active.where(_visibleColumns.contains).toList();
    return selected.isEmpty && active.isNotEmpty
        ? <String>[active.first]
        : selected;
  }

  List<String> _resolveActiveColumns(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) {
      return _columnTitles.keys.toList();
    }
    final Set<String> discovered = <String>{};
    for (final Map<String, dynamic> row in rows) {
      discovered.addAll(row.keys);
    }
    final List<String> known = _columnTitles.keys
        .where(discovered.contains)
        .toList();
    final List<String> unknown = discovered
        .where((String key) => !_columnTitles.containsKey(key))
        .toList()
      ..sort();
    return <String>[...known, ...unknown];
  }

  String _columnLabel(String key) => _columnTitles[key] ?? key.replaceAll('_', ' ');

  double _columnWidth(String key) {
    return switch (key) {
      'project_name' => 330,
      'activity_name' => 180,
      _ => 130,
    };
  }

  double _tableWidth(List<String> columns) {
    final double width = columns.fold<double>(
      0,
      (double sum, String key) => sum + _columnWidth(key),
    );
    return width < 680 ? 680 : width;
  }

  List<Widget> _tableBody(
    BuildContext context,
    List<Map<String, dynamic>> rows,
    List<String> columns,
  ) {
    final List<Widget> items = <Widget>[];
    String? lastGroup;
    for (int i = 0; i < rows.length; i++) {
      final Map<String, dynamic> row = rows[i];
      if (_groupBy != null) {
        final String currentGroup = _displayValue(row[_groupBy], _groupBy!);
        if (currentGroup != lastGroup) {
          lastGroup = currentGroup;
          items.add(
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              child: Text(
                '${_columnLabel(_groupBy!)}: $currentGroup',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          );
        }
      }
      items.add(
        Container(
          color: i.isEven
              ? Colors.transparent
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.07),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: columns
                .map(
                  (String col) => _cellWithWidth(
                    col,
                    _displayValue(row[col], col),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }
    return items;
  }

  Future<void> _confirmExportExcel() async {
    if (_rows.isEmpty || !mounted) {
      return;
    }
    await AppDialog.show(
      context: context,
      type: AppDialogType.confirmation,
      leadingIcon: Icons.table_view_rounded,
      title: 'Export to Excel',
      message:
          'Download the report as an Excel file (.xlsx)? Current filters, sorting, grouping, and visible columns will be included.',
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Export',
          isPrimary: true,
          onPressed: () => _exportExcel(),
        ),
      ],
    );
  }

  Future<void> _confirmExportPdf() async {
    if (_rows.isEmpty || !mounted) {
      return;
    }
    await AppDialog.show(
      context: context,
      type: AppDialogType.confirmation,
      leadingIcon: Icons.picture_as_pdf_rounded,
      title: 'Export to PDF',
      message:
          'Download the report as a PDF? Current filters, sorting, grouping, and visible columns will be included.',
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Export',
          isPrimary: true,
          onPressed: () => _exportPdf(),
        ),
      ],
    );
  }

  Future<void> _exportExcel() async {
    final List<Map<String, dynamic>> rows = _processedRows;
    final List<String> columns = _selectedColumns;
    final Excel workbook = Excel.createExcel();
    final Sheet sheet = workbook[workbook.getDefaultSheet() ?? 'Sheet1'];
    sheet.appendRow(
      columns.map((String c) => TextCellValue(_columnTitles[c] ?? c)).toList(),
    );
    for (final Map<String, dynamic> row in rows) {
      sheet.appendRow(
        columns.map((String c) => TextCellValue(_displayValue(row[c], c))).toList(),
      );
    }
    final List<int>? encoded = workbook.encode();
    if (encoded == null || encoded.isEmpty) {
      return;
    }
    final String path = await _saveExportFile(
      fileName: 'ai_custom_report_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      bytes: Uint8List.fromList(encoded),
    );
    if (!mounted) {
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'Excel Saved',
      message: 'File saved to:\n$path',
      type: AppDialogType.success,
    );
  }

  Future<void> _exportPdf() async {
    final List<Map<String, dynamic>> rows = _processedRows;
    final List<String> columns = _selectedColumns;
    final pw.Document doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Text('AI Custom Report', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: columns.map((String c) => _columnTitles[c] ?? c).toList(),
              data: rows
                  .map(
                    (Map<String, dynamic> row) =>
                        columns.map((String c) => _displayValue(row[c], c)).toList(),
                  )
                  .toList(),
            ),
          ];
        },
      ),
    );
    final String path = await _saveExportFile(
      fileName: 'ai_custom_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      mimeType: 'application/pdf',
      bytes: Uint8List.fromList(await doc.save()),
    );
    if (!mounted) {
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'PDF Saved',
      message: 'File saved to:\n$path',
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
        // fallback
      } on PlatformException {
        // fallback
      }
    }
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
