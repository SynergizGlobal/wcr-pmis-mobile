import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

class NewActivitiesUpdatePage extends StatefulWidget {
  const NewActivitiesUpdatePage({super.key, required this.dataSource});

  static const String routeName = 'new-activities-update';
  static const String routePath = '/new-activities-update';

  final DashboardRemoteDataSource dataSource;

  @override
  State<NewActivitiesUpdatePage> createState() => _NewActivitiesUpdatePageState();
}

class _NewActivitiesUpdatePageState extends State<NewActivitiesUpdatePage> {
  static const MethodChannel _fileExportChannel = MethodChannel(
    'wcr_pmis_mobile/file_export',
  );
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50, 100];
  static const List<String> _headers = <String>[
    'Task Code',
    'Activity',
    'Baseline Start',
    'Baseline Finish',
    'Expected Start',
    'Expected Finish',
    'Scope',
    'Validation Pending',
    'Completed',
    'Actual',
  ];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final DateFormat _displayDateFormat = DateFormat('dd-MMM-yy');
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  String _search = '';
  bool _loading = false;
  DateTime _progressDate = DateTime.now();
  final Map<String, _ActivityRowEdit> _rowEdits = <String, _ActivityRowEdit>{};

  String? _selectedProject;
  String? _selectedContract;
  String? _selectedStructureType;
  String? _selectedStructure;
  String? _selectedComponent;
  String? _selectedElement;

  int _pageSize = 10;
  int _currentPage = 0;

  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _lastUpdateRows = <Map<String, dynamic>>[];
  String? _selectedLastUpdateActivityId;
  List<_FilterOption> _projectOptions = <_FilterOption>[];
  List<_FilterOption> _contractOptions = <_FilterOption>[];
  List<_FilterOption> _structureTypeOptions = <_FilterOption>[];
  List<_FilterOption> _structureOptions = <_FilterOption>[];
  List<_FilterOption> _componentOptions = <_FilterOption>[];
  List<_FilterOption> _elementOptions = <_FilterOption>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _remarksController.dispose();
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
      appBar: AppBar(title: const Text('New Activities Update')),
      bottomNavigationBar: _stickyFooter(total: total, start: start, end: end),
      body: Stack(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _toolbar(context, filteredRows),
                  const SizedBox(height: 10),
                  _lastUpdatesSection(context),
                  const SizedBox(height: 10),
                  _progressUpdateSection(context),
                  const SizedBox(height: 10),
                  _tableCard(context, pageRows),
                  const SizedBox(height: 12),
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
    final bool canExport = _canExportActivities;
    final int activeFilterCount = _activeFilterCount;
    final bool narrow = MediaQuery.sizeOf(context).width < 720;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(
                alpha: 0.6,
              ),
            ),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _openFilterDialog,
                      icon: const Icon(Icons.filter_alt_rounded),
                      label: Text(
                        activeFilterCount == 0
                            ? 'Filter'
                            : 'Filter ($activeFilterCount)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.filter_alt_off_rounded),
                      label: const Text('Clear filter'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: canExport ? _confirmExportExcel : null,
                      icon: const Icon(Icons.table_view_rounded),
                      label: const Text('Export'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _rows.isNotEmpty && _canLoadTableWithCurrentFilters
                          ? _submitBulkUpdate
                          : null,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Update'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _uploadUpdateForm,
                  icon: const Icon(Icons.upload_rounded),
                  label: const Text('Upload'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (narrow)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _searchField(),
              const SizedBox(height: 8),
              _entriesControl(),
            ],
          )
        else
          Row(
            children: <Widget>[
              Expanded(child: _searchField()),
              const SizedBox(width: 12),
              _entriesControl(),
            ],
          ),
      ],
    );
  }

  Widget _lastUpdatesSection(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Latest Updated Structure → Component',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (_lastUpdateRows.isEmpty)
            Text(
              'No recent updates. Select filters and tap Filter to load activities.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _lastUpdateRows.length,
                separatorBuilder: (BuildContext context, int _) =>
                    const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> row = _lastUpdateRows[index];
                  final String? activityId = _safeString(row['activity_id']);
                  final String label = _lastUpdateLabel(row);
                  final bool selected =
                      activityId != null &&
                      activityId == _selectedLastUpdateActivityId;
                  return FilterChip(
                    label: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    selected: selected,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: selected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    selectedColor: colorScheme.primaryContainer,
                    backgroundColor:
                        colorScheme.primary.withValues(alpha: 0.06),
                    side: BorderSide(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant.withValues(alpha: 0.8),
                    ),
                    onSelected: (_) {
                      if (activityId == null || activityId.isEmpty) {
                        return;
                      }
                      _onLastUpdateTap(row);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _lastUpdateLabel(Map<String, dynamic> row) {
    final String structure = _safeString(row['structure']) ??
        _safeString(row['strip_chart_structure_id_fk']) ??
        '-';
    final String component = _safeString(row['strip_chart_component']) ?? '-';
    return '$structure → $component';
  }

  Widget _progressUpdateSection(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool narrow = MediaQuery.sizeOf(context).width < 560;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _progressDateField(context),
                const SizedBox(height: 10),
                TextField(
                  controller: _remarksController,
                  decoration: const InputDecoration(
                    labelText: 'Remarks',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: _progressDateField(context)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _remarksController,
                    decoration: const InputDecoration(
                      labelText: 'Remarks',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _progressDateField(BuildContext context) {
    final String label = _displayDateFormat.format(_progressDate);
    return InkWell(
      onTap: () => _pickDate(
        initial: _progressDate,
        onPicked: (DateTime value) => setState(() => _progressDate = value),
      ),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Progress Date *',
          isDense: true,
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: Text(label),
      ),
    );
  }

  Future<void> _onLastUpdateTap(Map<String, dynamic> summaryRow) async {
    final String? activityId = _safeString(summaryRow['activity_id']);
    if (activityId == null || activityId.isEmpty) {
      return;
    }

    setState(() {
      _loading = true;
      _selectedLastUpdateActivityId = activityId;
    });

    try {
      final Map<String, dynamic> response =
          await widget.dataSource.fetchNewActivitiesBindData(
        activityId: activityId,
      );
      final List<Map<String, dynamic>> bindRows = _rowsFromResponse(response);
      if (bindRows.isEmpty) {
        if (!mounted) {
          return;
        }
        await AppDialog.show(
          context: context,
          title: 'Unable to load',
          message: 'No filter data returned for this update.',
          type: AppDialogType.error,
        );
        return;
      }
      await _applyFiltersFromRow(bindRows.first, _projectOptions);
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load update',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      onChanged: (String value) => setState(() {
        _search = value.trim();
        _currentPage = 0;
      }),
      decoration: InputDecoration(
        hintText: 'Search activities',
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
    );
  }

  Widget _entriesControl() {
    return Row(
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
  }

  Widget _tableCard(BuildContext context, List<Map<String, dynamic>> pageRows) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (_rows.isEmpty && !_loading) {
      return Card(
        margin: EdgeInsets.zero,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _activeFilterCount == 0
                  ? 'No recent update found. Select filters and tap Filter to load activities.'
                  : 'No activities found for the selected filters.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    final double tableWidth = _tableContentWidth;
    const double headerBandHeight = 48;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: headerBandHeight,
                child: _tableHeader(context),
              ),
              if (pageRows.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No activity records found.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                for (int index = 0; index < pageRows.length; index++)
                  _tableRow(
                    context,
                    pageRows[index],
                    index,
                    isLast: index == pageRows.length - 1,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  double get _tableContentWidth => _headers.fold<double>(
        0,
        (double sum, String item) => sum + _columnWidth(item),
      );

  Widget _tableHeader(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color dividerColor =
        colorScheme.onPrimary.withValues(alpha: 0.38);
    return ColoredBox(
      color: colorScheme.primary,
      child: SizedBox(
        width: _tableContentWidth,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int index = 0; index < _headers.length; index++)
              _headerCell(
                _headers[index],
                width: _columnWidth(_headers[index]),
                color: colorScheme.onPrimary,
                showRightBorder: index < _headers.length - 1,
                dividerColor: dividerColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(
    String title, {
    required double width,
    required Color color,
    bool showRightBorder = false,
    Color? dividerColor,
  }) {
    return Container(
      width: width,
      alignment: Alignment.center,
      decoration: showRightBorder && dividerColor != null
          ? BoxDecoration(
              border: Border(
                right: BorderSide(color: dividerColor, width: 1),
              ),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          height: 1.1,
        ),
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
    final String activityId = _activityIdForRow(row);
    final _ActivityRowEdit edit = _editForRow(row);
    final Color bg = index.isEven
        ? colorScheme.primary.withValues(alpha: 0.08)
        : colorScheme.surface;
    final BorderRadius? rowRadius = isLast
        ? const BorderRadius.vertical(bottom: Radius.circular(14))
        : null;
    return ClipRRect(
      borderRadius: rowRadius ?? BorderRadius.zero,
      child: Container(
        width: _tableContentWidth,
        color: bg,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _cell(_taskCode(row), width: _columnWidth('Task Code')),
            _cell(_activityName(row), width: _columnWidth('Activity')),
            _editableDateCell(
              context: context,
              width: _columnWidth('Baseline Start'),
              value: edit.baselineStart,
              onChanged: (String value) => _updateRowEdit(
                activityId,
                row,
                (e) => e.baselineStart = value,
              ),
            ),
            _editableDateCell(
              context: context,
              width: _columnWidth('Baseline Finish'),
              value: edit.baselineFinish,
              onChanged: (String value) => _updateRowEdit(
                activityId,
                row,
                (e) => e.baselineFinish = value,
              ),
            ),
            _editableDateCell(
              context: context,
              width: _columnWidth('Expected Start'),
              value: edit.expectedStart,
              onChanged: (String value) => _updateRowEdit(
                activityId,
                row,
                (e) => e.expectedStart = value,
              ),
            ),
            _editableDateCell(
              context: context,
              width: _columnWidth('Expected Finish'),
              value: edit.expectedFinish,
              onChanged: (String value) => _updateRowEdit(
                activityId,
                row,
                (e) => e.expectedFinish = value,
              ),
            ),
            _editableNumericCell(
              fieldKey: 'scope',
              activityId: activityId,
              width: _columnWidth('Scope'),
              value: edit.scope,
              onChanged: (String value) =>
                  _updateRowEdit(activityId, row, (e) => e.scope = value),
            ),
            _cell(
              edit.validationPending.isEmpty ? '-' : edit.validationPending,
              width: _columnWidth('Validation Pending'),
            ),
            _cell(
              edit.completed.isEmpty ? '-' : edit.completed,
              width: _columnWidth('Completed'),
            ),
            _editableNumericCell(
              fieldKey: 'actual',
              activityId: activityId,
              width: _columnWidth('Actual'),
              value: edit.actual,
              onChanged: (String value) =>
                  _updateRowEdit(activityId, row, (e) => e.actual = value),
            ),
          ],
        ),
      ),
    );
  }

  String _activityIdForRow(Map<String, dynamic> row) {
    return _safeString(row['activity_id']) ??
        _safeString(row['strip_chart_activity_id']) ??
        row.hashCode.toString();
  }

  _ActivityRowEdit _editForRow(Map<String, dynamic> row) {
    final String activityId = _activityIdForRow(row);
    return _rowEdits[activityId] ?? _ActivityRowEdit.fromRow(row);
  }

  void _updateRowEdit(
    String activityId,
    Map<String, dynamic> row,
    void Function(_ActivityRowEdit edit) apply,
  ) {
    final _ActivityRowEdit current =
        _rowEdits[activityId] ?? _ActivityRowEdit.fromRow(row);
    apply(current);
    setState(() => _rowEdits[activityId] = current);
  }

  void _syncRowEditsFromRows({bool clearActuals = false}) {
    _rowEdits.clear();
    for (final Map<String, dynamic> row in _rows) {
      final String activityId = _activityIdForRow(row);
      final _ActivityRowEdit edit = _ActivityRowEdit.fromRow(row);
      if (clearActuals) {
        edit.actual = '';
      }
      _rowEdits[activityId] = edit;
    }
  }

  Widget _editableDateCell({
    required BuildContext context,
    required double width,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String display = value.trim();
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () async {
              final DateTime initial =
                  _parseDisplayDate(display) ?? DateTime.now();
              await _pickDate(
                initial: initial,
                onPicked: (DateTime picked) {
                  onChanged(_displayDateFormat.format(picked));
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                display.isEmpty ? 'Select' : display,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: display.isEmpty
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _editableNumericCell({
    required String fieldKey,
    required String activityId,
    required double width,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final String display = value == '-' ? '' : value;
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextFormField(
          key: ValueKey<String>('$fieldKey-$activityId-$display'),
          initialValue: display,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            border: OutlineInputBorder(),
            filled: true,
          ),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  DateTime? _parseDisplayDate(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '-') {
      return null;
    }
    try {
      return _displayDateFormat.parse(trimmed);
    } catch (_) {
      try {
        return DateFormat('dd-MMM-yyyy').parse(trimmed);
      } catch (_) {
        return DateTime.tryParse(trimmed);
      }
    }
  }

  String _toApiDate(String displayValue) {
    final DateTime? parsed = _parseDisplayDate(displayValue);
    if (parsed == null) {
      return '';
    }
    return _apiDateFormat.format(parsed);
  }

  Future<void> _submitBulkUpdate() async {
    if (!_canLoadTableWithCurrentFilters || _rows.isEmpty) {
      return;
    }

    final List<Map<String, dynamic>> missingDates = <Map<String, dynamic>>[];
    for (final Map<String, dynamic> row in _rows) {
      final _ActivityRowEdit edit = _editForRow(row);
      if (edit.baselineStart.trim().isEmpty ||
          edit.baselineFinish.trim().isEmpty ||
          edit.expectedStart.trim().isEmpty ||
          edit.expectedFinish.trim().isEmpty) {
        missingDates.add(row);
      }
    }
    if (missingDates.isNotEmpty) {
      await AppDialog.show(
        context: context,
        title: 'Missing dates',
        message:
            'Please fill Baseline Start, Baseline Finish, Expected Start, and Expected Finish for all activities.',
        type: AppDialogType.error,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final Map<String, dynamic> payload = _buildBulkUpdatePayload();
      final Map<String, dynamic> response =
          await widget.dataSource.submitNewActivitiesBulkUpdate(
        payload: payload,
      );
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
      await _loadTableRows(clearActuals: true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Update failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Map<String, dynamic> _buildBulkUpdatePayload() {
    final List<String> baselineStarts = <String>[];
    final List<String> baselineFinishes = <String>[];
    final List<String> expectedStarts = <String>[];
    final List<String> expectedFinishes = <String>[];
    final List<String> activityIds = <String>[];
    final List<String> actualScopes = <String>[];
    final List<String> totalScopes = <String>[];
    final List<String> completedScopes = <String>[];
    final List<String> scopeValues = <String>[];

    for (final Map<String, dynamic> row in _rows) {
      final _ActivityRowEdit edit = _editForRow(row);
      baselineStarts.add(_toApiDate(edit.baselineStart));
      baselineFinishes.add(_toApiDate(edit.baselineFinish));
      expectedStarts.add(_toApiDate(edit.expectedStart));
      expectedFinishes.add(_toApiDate(edit.expectedFinish));
      activityIds.add(_activityIdForRow(row));
      actualScopes.add(edit.actual.trim());
      totalScopes.add(edit.originalScope);
      completedScopes.add(edit.completed == '-' ? '' : edit.completed);
      scopeValues.add(edit.scope.trim());
    }

    final String? componentId = _selectedElement?.trim().isNotEmpty == true
        ? _selectedElement
        : _safeString(_rows.first['strip_chart_component_id']) ??
            _safeString(_rows.first['strip_chart_component_id_name']);

    return <String, dynamic>{
      'contract_id_fk': _selectedContract,
      'structure_type_fk': _selectedStructureType,
      'strip_chart_structure_id_fk': _selectedStructure,
      'strip_chart_component': _selectedComponent,
      'strip_chart_component_id': componentId ?? '',
      'progress_date': _apiDateFormat.format(_progressDate),
      'remarks': _remarksController.text.trim(),
      'baseline_start_date': baselineStarts,
      'baseline_finish_date': baselineFinishes,
      'start_date': expectedStarts,
      'finish_date': expectedFinishes,
      'activity_ids': activityIds,
      'actualScopes': actualScopes,
      'totalScopes': totalScopes,
      'completedScopes': completedScopes,
      'scope': scopeValues.join(','),
    };
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

  String _taskCode(Map<String, dynamic> row) =>
      _stringValue(row['p6_task_code']);

  String _activityName(Map<String, dynamic> row) =>
      _stringValue(row['strip_chart_activity_name']);

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

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      final List<Map<String, dynamic>> responses =
          await Future.wait<Map<String, dynamic>>(<Future<Map<String, dynamic>>>[
        widget.dataSource.fetchNewActivitiesUpdateBootstrap(),
        widget.dataSource.fetchNewActivitiesLatestRowData(),
        widget.dataSource.fetchNewActivitiesLastUpdateRows(),
      ]);
      if (!mounted) {
        return;
      }

      final Map<String, dynamic> bootstrap = responses[0];
      final Map<String, dynamic> latest = responses[1];
      final Map<String, dynamic> lastUpdates = responses[2];
      final List<_FilterOption> projects = _dedupeOptions(
        _rowsFromMap(bootstrap, 'projectsList').map(_projectOptionFromRow),
      );
      final List<Map<String, dynamic>> latestRows = _rowsFromResponse(latest);
      final List<Map<String, dynamic>> lastUpdateRows =
          _rowsFromResponse(lastUpdates);

      setState(() {
        _projectOptions = projects;
        _lastUpdateRows = lastUpdateRows;
      });

      if (latestRows.isEmpty) {
        setState(() {
          _contractOptions = <_FilterOption>[];
          _structureTypeOptions = <_FilterOption>[];
          _structureOptions = <_FilterOption>[];
          _componentOptions = <_FilterOption>[];
          _elementOptions = <_FilterOption>[];
          _selectedProject = null;
          _selectedContract = null;
          _selectedStructureType = null;
          _selectedStructure = null;
          _selectedComponent = null;
          _selectedElement = null;
          _selectedLastUpdateActivityId = null;
          _rows = <Map<String, dynamic>>[];
          _currentPage = 0;
        });
        return;
      }

      final String? initialActivityId =
          _safeString(latestRows.first['activity_id']);
      setState(() {
        _selectedLastUpdateActivityId = initialActivityId;
      });
      await _applyFiltersFromRow(latestRows.first, projects);
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _applyFiltersFromRow(
    Map<String, dynamic> row,
    List<_FilterOption> projects,
  ) async {
    final String? project =
        _safeString(row['project_id_fk']) ?? _safeString(row['project_id']);
    final String? contract =
        _safeString(row['contract_id_fk']) ?? _safeString(row['contract_id']);
    final String? structureType = _safeString(row['structure_type_fk']) ??
        _safeString(row['structure_type']);
    final String? structure = _safeString(row['strip_chart_structure_id_fk']) ??
        _safeString(row['structure']);
    final String? component = _safeString(row['strip_chart_component']);
    final String? element = _safeString(row['strip_chart_component_id']);

    List<_FilterOption> contracts = <_FilterOption>[];
    List<_FilterOption> structureTypes = <_FilterOption>[];
    List<_FilterOption> structures = <_FilterOption>[];
    List<_FilterOption> components = <_FilterOption>[];
    List<_FilterOption> elements = <_FilterOption>[];

    if (project != null && project.isNotEmpty) {
      final Map<String, dynamic> response = await widget.dataSource
          .fetchNewActivitiesContractsForProject(projectIdFk: project);
      contracts = _dedupeOptions(
        _rowsFromMap(response, 'contractsList').map(_contractOptionFromRow),
      );
    }

    final String? contractId = contract;
    if (contractId != null && contractId.isNotEmpty) {
      final Map<String, dynamic> response = await widget.dataSource
          .fetchNewActivitiesStructureTypes(contractIdFk: contractId);
      structureTypes = _dedupeOptions(
        _rowsFromResponse(response).map(_structureTypeOptionFromRow),
      );
    }

    if (contractId != null &&
        contractId.isNotEmpty &&
        structureType != null &&
        structureType.isNotEmpty) {
      final Map<String, dynamic> response =
          await widget.dataSource.fetchNewActivitiesStructures(
        contractIdFk: contractId,
        structureTypeFk: structureType,
      );
      structures = _dedupeOptions(
        _rowsFromResponse(response).map(_structureOptionFromRow),
      );
    }

    if (contractId != null &&
        structureType != null &&
        structure != null &&
        contractId.isNotEmpty &&
        structureType.isNotEmpty &&
        structure.isNotEmpty) {
      final Map<String, dynamic> response =
          await widget.dataSource.fetchNewActivitiesComponents(
        contractIdFk: contractId,
        structureTypeFk: structureType,
        stripChartStructureIdFk: structure,
      );
      components = _dedupeOptions(
        _rowsFromResponse(response).map(_componentOptionFromRow),
      );
    }

    if (contractId != null &&
        structureType != null &&
        structure != null &&
        component != null &&
        contractId.isNotEmpty &&
        structureType.isNotEmpty &&
        structure.isNotEmpty &&
        component.isNotEmpty) {
      final Map<String, dynamic> response =
          await widget.dataSource.fetchNewActivitiesElements(
        contractIdFk: contractId,
        structureTypeFk: structureType,
        stripChartStructureIdFk: structure,
        stripChartComponent: component,
      );
      elements = _dedupeOptions(
        _rowsFromResponse(response).map(_elementOptionFromRow),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _projectOptions = projects;
      _contractOptions = contracts;
      _structureTypeOptions = structureTypes;
      _structureOptions = structures;
      _componentOptions = components;
      _elementOptions = elements;
      _selectedProject = _retainValid(project, projects);
      _selectedContract = _retainValid(contract, contracts);
      _selectedStructureType = _retainValid(structureType, structureTypes);
      _selectedStructure = _retainValid(structure, structures);
      _selectedComponent = _retainValid(component, components);
      _selectedElement = _retainValid(element, elements);
    });

    if (_canLoadTableWithCurrentFilters) {
      await _loadTableRows();
    }
  }

  bool get _canLoadTableWithCurrentFilters {
    return _selectedContract != null &&
        _selectedContract!.isNotEmpty &&
        _selectedStructureType != null &&
        _selectedStructureType!.isNotEmpty &&
        _selectedStructure != null &&
        _selectedStructure!.isNotEmpty &&
        _selectedComponent != null &&
        _selectedComponent!.isNotEmpty;
  }

  bool get _canExportActivities {
    return _selectedContract != null &&
        _selectedContract!.isNotEmpty &&
        _selectedStructureType != null &&
        _selectedStructureType!.isNotEmpty &&
        _selectedStructure != null &&
        _selectedStructure!.isNotEmpty;
  }

  Future<void> _loadTableRows({bool clearActuals = false}) async {
    final Map<String, dynamic> response =
        await widget.dataSource.fetchNewActivitiesFilterList(
      projectIdFk: _selectedProject,
      contractIdFk: _selectedContract,
      structureTypeFk: _selectedStructureType,
      stripChartStructureIdFk: _selectedStructure,
      stripChartComponent: _selectedComponent,
      stripChartComponentId: _selectedElement,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _rows = _rowsFromResponse(response);
      _currentPage = 0;
      _syncRowEditsFromRows(clearActuals: clearActuals);
    });
  }

  Future<void> _clearFilters() async {
    setState(() => _loading = true);
    try {
      final Map<String, dynamic> bootstrap =
          await widget.dataSource.fetchNewActivitiesUpdateBootstrap();
      if (!mounted) {
        return;
      }
      final List<_FilterOption> projects = _dedupeOptions(
        _rowsFromMap(bootstrap, 'projectsList').map(_projectOptionFromRow),
      );
      setState(() {
        _selectedProject = null;
        _selectedContract = null;
        _selectedStructureType = null;
        _selectedStructure = null;
        _selectedComponent = null;
        _selectedElement = null;
        _selectedLastUpdateActivityId = null;
        _projectOptions = projects;
        _contractOptions = <_FilterOption>[];
        _structureTypeOptions = <_FilterOption>[];
        _structureOptions = <_FilterOption>[];
        _componentOptions = <_FilterOption>[];
        _elementOptions = <_FilterOption>[];
        _rows = <Map<String, dynamic>>[];
        _rowEdits.clear();
        _currentPage = 0;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to clear filters',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openFilterDialog() async {
    String? dialogProject = _selectedProject;
    String? dialogContract = _selectedContract;
    String? dialogStructureType = _selectedStructureType;
    String? dialogStructure = _selectedStructure;
    String? dialogComponent = _selectedComponent;
    String? dialogElement = _selectedElement;

    List<_FilterOption> dialogContracts = List<_FilterOption>.from(_contractOptions);
    List<_FilterOption> dialogStructureTypes =
        List<_FilterOption>.from(_structureTypeOptions);
    List<_FilterOption> dialogStructures =
        List<_FilterOption>.from(_structureOptions);
    List<_FilterOption> dialogComponents =
        List<_FilterOption>.from(_componentOptions);
    List<_FilterOption> dialogElements =
        List<_FilterOption>.from(_elementOptions);

    bool shouldApply = false;
    bool dialogLoading = false;

    Future<void> reloadContracts(StateSetter setDialogState) async {
      if (dialogProject == null || dialogProject!.isEmpty) {
        setDialogState(() {
          dialogContracts = <_FilterOption>[];
          dialogContract = null;
          dialogStructureType = null;
          dialogStructure = null;
          dialogComponent = null;
          dialogElement = null;
          dialogStructureTypes = <_FilterOption>[];
          dialogStructures = <_FilterOption>[];
          dialogComponents = <_FilterOption>[];
          dialogElements = <_FilterOption>[];
        });
        return;
      }
      setDialogState(() => dialogLoading = true);
      try {
        final Map<String, dynamic> response = await widget.dataSource
            .fetchNewActivitiesContractsForProject(projectIdFk: dialogProject!);
        final List<_FilterOption> contracts = _dedupeOptions(
          _rowsFromMap(response, 'contractsList')
              .map(_contractOptionFromRow),
        );
        setDialogState(() {
          dialogContracts = contracts;
          dialogContract = _retainValid(dialogContract, contracts);
          dialogStructureType = null;
          dialogStructure = null;
          dialogComponent = null;
          dialogElement = null;
          dialogStructureTypes = <_FilterOption>[];
          dialogStructures = <_FilterOption>[];
          dialogComponents = <_FilterOption>[];
          dialogElements = <_FilterOption>[];
        });
      } finally {
        setDialogState(() => dialogLoading = false);
      }
    }

    Future<void> reloadStructureTypes(StateSetter setDialogState) async {
      if (dialogContract == null || dialogContract!.isEmpty) {
        setDialogState(() {
          dialogStructureTypes = <_FilterOption>[];
          dialogStructureType = null;
          dialogStructure = null;
          dialogComponent = null;
          dialogElement = null;
          dialogStructures = <_FilterOption>[];
          dialogComponents = <_FilterOption>[];
          dialogElements = <_FilterOption>[];
        });
        return;
      }
      setDialogState(() => dialogLoading = true);
      try {
        final Map<String, dynamic> response = await widget.dataSource
            .fetchNewActivitiesStructureTypes(contractIdFk: dialogContract!);
        final List<_FilterOption> types = _dedupeOptions(
          _rowsFromResponse(response).map(_structureTypeOptionFromRow),
        );
        setDialogState(() {
          dialogStructureTypes = types;
          dialogStructureType = _retainValid(dialogStructureType, types);
          dialogStructure = null;
          dialogComponent = null;
          dialogElement = null;
          dialogStructures = <_FilterOption>[];
          dialogComponents = <_FilterOption>[];
          dialogElements = <_FilterOption>[];
        });
      } finally {
        setDialogState(() => dialogLoading = false);
      }
    }

    Future<void> reloadStructures(StateSetter setDialogState) async {
      if (dialogContract == null ||
          dialogStructureType == null ||
          dialogContract!.isEmpty ||
          dialogStructureType!.isEmpty) {
        setDialogState(() {
          dialogStructures = <_FilterOption>[];
          dialogStructure = null;
          dialogComponent = null;
          dialogElement = null;
          dialogComponents = <_FilterOption>[];
          dialogElements = <_FilterOption>[];
        });
        return;
      }
      setDialogState(() => dialogLoading = true);
      try {
        final Map<String, dynamic> response =
            await widget.dataSource.fetchNewActivitiesStructures(
          contractIdFk: dialogContract!,
          structureTypeFk: dialogStructureType!,
        );
        final List<_FilterOption> structures = _dedupeOptions(
          _rowsFromResponse(response).map(_structureOptionFromRow),
        );
        setDialogState(() {
          dialogStructures = structures;
          dialogStructure = _retainValid(dialogStructure, structures);
          dialogComponent = null;
          dialogElement = null;
          dialogComponents = <_FilterOption>[];
          dialogElements = <_FilterOption>[];
        });
      } finally {
        setDialogState(() => dialogLoading = false);
      }
    }

    Future<void> reloadComponents(StateSetter setDialogState) async {
      if (dialogContract == null ||
          dialogStructureType == null ||
          dialogStructure == null) {
        setDialogState(() {
          dialogComponents = <_FilterOption>[];
          dialogComponent = null;
          dialogElement = null;
          dialogElements = <_FilterOption>[];
        });
        return;
      }
      setDialogState(() => dialogLoading = true);
      try {
        final Map<String, dynamic> response =
            await widget.dataSource.fetchNewActivitiesComponents(
          contractIdFk: dialogContract!,
          structureTypeFk: dialogStructureType!,
          stripChartStructureIdFk: dialogStructure!,
        );
        final List<_FilterOption> components = _dedupeOptions(
          _rowsFromResponse(response).map(_componentOptionFromRow),
        );
        setDialogState(() {
          dialogComponents = components;
          dialogComponent = _retainValid(dialogComponent, components);
          dialogElement = null;
          dialogElements = <_FilterOption>[];
        });
      } finally {
        setDialogState(() => dialogLoading = false);
      }
    }

    Future<void> reloadElements(StateSetter setDialogState) async {
      if (dialogContract == null ||
          dialogStructureType == null ||
          dialogStructure == null ||
          dialogComponent == null) {
        setDialogState(() {
          dialogElements = <_FilterOption>[];
          dialogElement = null;
        });
        return;
      }
      setDialogState(() => dialogLoading = true);
      try {
        final Map<String, dynamic> response =
            await widget.dataSource.fetchNewActivitiesElements(
          contractIdFk: dialogContract!,
          structureTypeFk: dialogStructureType!,
          stripChartStructureIdFk: dialogStructure!,
          stripChartComponent: dialogComponent!,
        );
        final List<_FilterOption> elements = _dedupeOptions(
          _rowsFromResponse(response).map(_elementOptionFromRow),
        );
        setDialogState(() {
          dialogElements = elements;
          dialogElement = _retainValid(dialogElement, elements);
        });
      } finally {
        setDialogState(() => dialogLoading = false);
      }
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Center(child: Text('Filter Activities')),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (dialogLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: LinearProgressIndicator(),
                        ),
                      _dialogPickField(
                        label: 'Project',
                        options: _projectOptions,
                        value: dialogProject,
                        placeholder: 'Select project',
                        enabled: true,
                        onChanged: (String? value) async {
                          setDialogState(() => dialogProject = value);
                          await reloadContracts(setDialogState);
                        },
                      ),
                      const SizedBox(height: 10),
                      _dialogPickField(
                        label: 'Contract',
                        options: dialogContracts,
                        value: dialogContract,
                        placeholder: dialogProject == null
                            ? 'Select project first'
                            : 'Select contract',
                        enabled: dialogProject != null && !dialogLoading,
                        onChanged: (String? value) async {
                          setDialogState(() => dialogContract = value);
                          await reloadStructureTypes(setDialogState);
                        },
                      ),
                      const SizedBox(height: 10),
                      _dialogPickField(
                        label: 'Structure Type',
                        options: dialogStructureTypes,
                        value: dialogStructureType,
                        placeholder: dialogContract == null
                            ? 'Select contract first'
                            : 'Select structure type',
                        enabled: dialogContract != null && !dialogLoading,
                        onChanged: (String? value) async {
                          setDialogState(() => dialogStructureType = value);
                          await reloadStructures(setDialogState);
                        },
                      ),
                      const SizedBox(height: 10),
                      _dialogPickField(
                        label: 'Structure',
                        options: dialogStructures,
                        value: dialogStructure,
                        placeholder: dialogStructureType == null
                            ? 'Select structure type first'
                            : 'Select structure',
                        enabled: dialogStructureType != null && !dialogLoading,
                        onChanged: (String? value) async {
                          setDialogState(() => dialogStructure = value);
                          await reloadComponents(setDialogState);
                        },
                      ),
                      const SizedBox(height: 10),
                      _dialogPickField(
                        label: 'Component',
                        options: dialogComponents,
                        value: dialogComponent,
                        placeholder: dialogStructure == null
                            ? 'Select structure first'
                            : 'Select component',
                        enabled: dialogStructure != null && !dialogLoading,
                        onChanged: (String? value) async {
                          setDialogState(() => dialogComponent = value);
                          await reloadElements(setDialogState);
                        },
                      ),
                      const SizedBox(height: 10),
                      _dialogPickField(
                        label: 'Element',
                        options: dialogElements,
                        value: dialogElement,
                        placeholder: dialogComponent == null
                            ? 'Select component first'
                            : 'All',
                        enabled: dialogComponent != null && !dialogLoading,
                        allowClear: true,
                        onChanged: (String? value) =>
                            setDialogState(() => dialogElement = value),
                      ),
                    ],
                  ),
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

    setState(() {
      _selectedProject = dialogProject;
      _selectedContract = dialogContract;
      _selectedStructureType = dialogStructureType;
      _selectedStructure = dialogStructure;
      _selectedComponent = dialogComponent;
      _selectedElement = dialogElement;
      _selectedLastUpdateActivityId = null;
      _contractOptions = dialogContracts;
      _structureTypeOptions = dialogStructureTypes;
      _structureOptions = dialogStructures;
      _componentOptions = dialogComponents;
      _elementOptions = dialogElements;
      _loading = true;
    });

    try {
      await _loadTableRows();
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Unable to load activities',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _confirmExportExcel() async {
    if (!_canExportActivities || !mounted) {
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'Export to Excel',
      message:
          'Download activities for the selected contract, structure type, structure, and progress date?',
      type: AppDialogType.confirmation,
      leadingIcon: Icons.table_view_rounded,
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Export',
          isPrimary: true,
          onPressed: _exportExcelFromApi,
        ),
      ],
    );
  }

  Future<void> _exportExcelFromApi() async {
    if (!_canExportActivities) {
      return;
    }

    setState(() => _loading = true);
    try {
      final ({Uint8List bytes, String? fileName}) result =
          await widget.dataSource.exportActivitiesByContract(
        contractIdFk: _selectedContract!,
        structureTypeFk: _selectedStructureType!,
        stripChartStructureIdFk: _selectedStructure!,
        progressDate: _apiDateFormat.format(_progressDate),
      );
      if (result.bytes.isEmpty) {
        throw StateError('Export file is empty.');
      }
      final String fileName = result.fileName ??
          'activities_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final String savedPath = await _saveExportFile(
        fileName: fileName,
        bytes: result.bytes,
      );
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Export Complete',
        message: 'Saved to:\n$savedPath',
        type: AppDialogType.success,
        actions: <AppDialogAction>[
          AppDialogAction(
            label: 'Open',
            isPrimary: true,
            onPressed: () async {
              try {
                await _fileExportChannel.invokeMethod<void>(
                  'openFile',
                  <String, String>{'path': savedPath},
                );
              } catch (_) {}
            },
          ),
          const AppDialogAction(label: 'OK', isPrimary: true),
        ],
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Export failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _uploadUpdateForm() async {
    final FilePickerResult? picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['xls', 'xlsx', 'csv'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) {
      return;
    }
    final PlatformFile file = picked.files.first;
    final Uint8List? bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Upload failed',
        message: 'Could not read the selected file.',
        type: AppDialogType.error,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final Map<String, dynamic> response =
          await widget.dataSource.uploadNewActivitiesUpdateFile(
        fileName: file.name,
        bytes: bytes,
      );
      if (!mounted) {
        return;
      }
      final String message = _safeString(response['message']) ??
          'Upload completed successfully.';
      await AppDialog.show(
        context: context,
        title: 'Upload complete',
        message: message,
        type: AppDialogType.success,
      );
      await _loadTableRows();
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Upload failed',
        message: error.toString(),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<String> _saveExportFile({
    required String fileName,
    required List<int> bytes,
  }) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = '${dir.path}/$fileName';
    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return path;
  }

  List<Map<String, dynamic>> _rowsFromResponse(Map<String, dynamic> json) {
    final List<dynamic>? data = json['data'] as List<dynamic>?;
    if (data != null) {
      return _mapList(data);
    }
    for (final String key in <String>[
      'activitiesList',
      'report1List',
      'dataList',
    ]) {
      final List<dynamic>? list = json[key] as List<dynamic>?;
      if (list != null) {
        return _mapList(list);
      }
    }
    return <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _rowsFromMap(
    Map<String, dynamic> json,
    String key,
  ) {
    final List<dynamic>? list = json[key] as List<dynamic>?;
    if (list == null) {
      return <Map<String, dynamic>>[];
    }
    return _mapList(list);
  }

  List<Map<String, dynamic>> _mapList(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map(
          (Map row) => row.map(
            (dynamic key, dynamic value) => MapEntry(key.toString(), value),
          ),
        )
        .toList();
  }

  List<_FilterOption> _dedupeOptions(Iterable<_FilterOption> options) {
    final Map<String, _FilterOption> byValue = <String, _FilterOption>{};
    for (final _FilterOption option in options) {
      if (option.value.isEmpty || option.label.isEmpty) {
        continue;
      }
      byValue.putIfAbsent(option.value, () => option);
    }
    final List<_FilterOption> values = byValue.values.toList()
      ..sort(
        (_FilterOption a, _FilterOption b) =>
            a.label.toLowerCase().compareTo(b.label.toLowerCase()),
      );
    return values;
  }

  _FilterOption _projectOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['project_id']) ??
        _safeString(row['project_id_fk']) ??
        '';
    final String label = _safeString(row['project_name']) ?? value;
    return _FilterOption(value: value, label: label);
  }

  _FilterOption _contractOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['contract_id']) ??
        _safeString(row['contract_id_fk']) ??
        '';
    final String label = _safeString(row['contract_short_name']) ??
        _safeString(row['contract_name']) ??
        value;
    return _FilterOption(value: value, label: label);
  }

  _FilterOption _structureTypeOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['structure_type_fk']) ??
        _safeString(row['structure_type']) ??
        '';
    final String label = _safeString(row['structure_type']) ?? value;
    return _FilterOption(value: value, label: label);
  }

  _FilterOption _structureOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['strip_chart_structure_id_fk']) ??
        _safeString(row['strip_chart_structure_id']) ??
        '';
    return _FilterOption(value: value, label: value);
  }

  _FilterOption _componentOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['strip_chart_component']) ?? '';
    return _FilterOption(value: value, label: value);
  }

  _FilterOption _elementOptionFromRow(Map<String, dynamic> row) {
    final String value = _safeString(row['strip_chart_component_id']) ?? '';
    final String label = _safeString(row['strip_chart_component_id_name']) ??
        value;
    return _FilterOption(value: value, label: label);
  }

  String? _retainValid(String? selected, List<_FilterOption> options) {
    if (selected == null) {
      return null;
    }
    final bool exists =
        options.any((_FilterOption item) => item.value == selected);
    return exists ? selected : null;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedProject != null) count++;
    if (_selectedContract != null) count++;
    if (_selectedStructureType != null) count++;
    if (_selectedStructure != null) count++;
    if (_selectedComponent != null) count++;
    if (_selectedElement != null) count++;
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

  Widget _dialogPickField({
    required String label,
    required List<_FilterOption> options,
    required String? value,
    required String placeholder,
    required bool enabled,
    required ValueChanged<String?> onChanged,
    bool allowClear = false,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String selectedLabel = value == null
        ? placeholder
        : options
                .firstWhere(
                  (_FilterOption option) => option.value == value,
                  orElse: () => _FilterOption(value: value, label: value),
                )
                .label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: !enabled
              ? null
              : () async {
                  if (options.isEmpty) {
                    await AppDialog.show(
                      context: context,
                      title: label,
                      message: 'No $label options available.',
                      type: AppDialogType.info,
                    );
                    return;
                  }
                  final String? picked = await _pickFilterOption(
                    title: label,
                    options: options,
                    selected: value,
                    allowClear: allowClear,
                    clearLabel: placeholder == 'All' ? 'All' : 'Clear',
                  );
                  if (picked != value) {
                    onChanged(picked);
                  }
                },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: enabled
                  ? colorScheme.surface
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
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
                      color: value == null
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  color: enabled
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<String?> _pickFilterOption({
    required String title,
    required List<_FilterOption> options,
    required String? selected,
    bool allowClear = false,
    String clearLabel = 'All',
  }) async {
    return showModalBottomSheet<String?>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final int extraItems = allowClear ? 1 : 0;
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
                  itemCount: options.length + extraItems,
                  separatorBuilder: (BuildContext context, int index) => Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.6),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    if (allowClear && index == 0) {
                      return ListTile(
                        title: Text(clearLabel, textAlign: TextAlign.center),
                        trailing: selected == null
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(null),
                      );
                    }
                    final int optionIndex = index - extraItems;
                    final _FilterOption option = options[optionIndex];
                    final bool isSelected = option.value == selected;
                    return ListTile(
                      title: Text(option.label, textAlign: TextAlign.center),
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

  double _columnWidth(String header) {
    return switch (header) {
      'Activity' => 160,
      'Task Code' => 140,
      'Baseline Start' ||
      'Baseline Finish' ||
      'Expected Start' ||
      'Expected Finish' => 128,
      'Scope' || 'Actual' => 88,
      'Validation Pending' => 120,
      'Completed' => 88,
      _ => 95,
    };
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
}

class _FilterOption {
  const _FilterOption({required this.value, required this.label});

  final String value;
  final String label;
}

class _ActivityRowEdit {
  _ActivityRowEdit({
    required this.baselineStart,
    required this.baselineFinish,
    required this.expectedStart,
    required this.expectedFinish,
    required this.scope,
    required this.actual,
    required this.validationPending,
    required this.completed,
    required this.originalScope,
  });

  String baselineStart;
  String baselineFinish;
  String expectedStart;
  String expectedFinish;
  String scope;
  String actual;
  final String validationPending;
  final String completed;
  final String originalScope;

  factory _ActivityRowEdit.fromRow(Map<String, dynamic> row) {
    String displayOrEmpty(String? value) {
      if (value == null || value.trim().isEmpty || value.trim() == 'null') {
        return '';
      }
      return value.trim();
    }

    String fieldOrEmpty(List<String> keys) {
      for (final String key in keys) {
        final String value = displayOrEmpty(row[key]?.toString());
        if (value.isNotEmpty) {
          return value;
        }
      }
      return '';
    }

    final String baselineStartRaw = fieldOrEmpty(<String>[
      'baseline_start',
      'planned_start',
    ]);
    final String baselineFinishRaw = fieldOrEmpty(<String>[
      'baseline_finish',
      'planned_finish',
    ]);
    final String expectedStartRaw = fieldOrEmpty(<String>['start']);
    final String expectedFinishRaw = fieldOrEmpty(<String>['finish']);
    final String scopeRaw = fieldOrEmpty(<String>['scope', 'total_scope']);

    return _ActivityRowEdit(
      baselineStart: baselineStartRaw,
      baselineFinish: baselineFinishRaw,
      expectedStart: expectedStartRaw,
      expectedFinish: expectedFinishRaw,
      scope: scopeRaw,
      actual: '',
      validationPending: displayOrEmpty(row['validation_pending']?.toString()),
      completed: displayOrEmpty(row['completed']?.toString()),
      originalScope: scopeRaw,
    );
  }

}
