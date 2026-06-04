import 'dart:io';
import 'dart:math' as math;

import 'package:excel/excel.dart' hide Border, TextSpan;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/daily_progress.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/daily_progress_mapper.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/providers/daily_progress_provider.dart';

class DailyProgressTab extends ConsumerStatefulWidget {
  const DailyProgressTab({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  final String projectId;
  final String projectName;

  @override
  ConsumerState<DailyProgressTab> createState() => _DailyProgressTabState();
}

class _DailyProgressTabState extends ConsumerState<DailyProgressTab> {
  static const MethodChannel _fileExportChannel = MethodChannel(
    'wcr_pmis_mobile/file_export',
  );
  static const String _allSections = 'All Sections';
  static const String _allActivities = 'All Activities';
  static const String _exportDash = '-';
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50];

  late DateTime _selectedDate;
  String _sectionFilter = _allSections;
  String _activityFilter = _allActivities;
  int _pageSize = 10;
  int _currentPage = 0;
  final Set<String> _expandedGroups = <String>{};

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String get _apiDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  String get _displayDate => DateFormat('dd/MM/yyyy').format(_selectedDate);

  @override
  Widget build(BuildContext context) {
    if (widget.projectId.trim().isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Project ID is unavailable for this project.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final AsyncValue<List<Map<String, dynamic>>> progressAsync = ref.watch(
      dailyProgressProvider((
        projectId: widget.projectId,
        date: _apiDate,
      )),
    );

    return progressAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Unable to load daily progress.\n$error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => ref.invalidate(
                  dailyProgressProvider((
                    projectId: widget.projectId,
                    date: _apiDate,
                  )),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (List<Map<String, dynamic>> rows) => _content(context, rows),
    );
  }

  Widget _content(BuildContext context, List<Map<String, dynamic>> rows) {
    final List<String> sections = <String>[
      _allSections,
      ...DailyProgressMapper.uniqueSections(rows),
    ];
    final List<String> activities = <String>[
      _allActivities,
      ...DailyProgressMapper.uniqueActivities(rows),
    ];

    if (!sections.contains(_sectionFilter)) {
      _sectionFilter = _allSections;
    }
    if (!activities.contains(_activityFilter)) {
      _activityFilter = _allActivities;
    }

    final List<Map<String, dynamic>> filteredRows = rows.where((
      Map<String, dynamic> row,
    ) {
      final String section = row['section']?.toString() ?? '';
      final String activity = row['structure_type']?.toString() ?? '';
      final bool sectionMatch =
          _sectionFilter == _allSections || section == _sectionFilter;
      final bool activityMatch =
          _activityFilter == _allActivities || activity == _activityFilter;
      return sectionMatch && activityMatch;
    }).toList();

    final List<DailyProgressGroup> groups =
        DailyProgressMapper.groupRows(filteredRows);
    final int total = groups.length;
    final int pageCount = total == 0 ? 1 : (total / _pageSize).ceil();
    if (_currentPage >= pageCount) {
      _currentPage = pageCount - 1;
    }
    if (_currentPage < 0) {
      _currentPage = 0;
    }
    final int start = total == 0 ? 0 : _currentPage * _pageSize;
    final int end = total == 0 ? 0 : (start + _pageSize).clamp(0, total);
    final List<DailyProgressGroup> pageGroups =
        total == 0 ? groups : groups.sublist(start, end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _headerCard(
                  context,
                  sections,
                  activities,
                  allRows: rows,
                  groups: groups,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              if (groups.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No daily progress data for selected filters.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: _tableArea(context, pageGroups),
                ),
            ],
          ),
        ),
        _paginationFooter(total: total, start: start, end: end, pageCount: pageCount),
      ],
    );
  }

  int get _activeFilterCount {
    int count = 0;
    if (_sectionFilter != _allSections) {
      count++;
    }
    if (_activityFilter != _allActivities) {
      count++;
    }
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    if (!DateUtils.isSameDay(_selectedDate, today)) {
      count++;
    }
    return count;
  }

  bool get _hasSectionOrActivityFilter =>
      _sectionFilter != _allSections || _activityFilter != _allActivities;

  List<DailyProgressGroup> _exportGroups(
    List<Map<String, dynamic>> allRows,
    List<DailyProgressGroup> filteredGroups,
  ) {
    if (_hasSectionOrActivityFilter) {
      return filteredGroups;
    }
    return DailyProgressMapper.groupRows(allRows);
  }

  String _exportScopeMessage(List<DailyProgressGroup> exportGroups) {
    if (_hasSectionOrActivityFilter) {
      return 'Download filtered results (${exportGroups.length} groups) with '
          'structure details for each group?';
    }
    return 'Download the full daily progress report (${exportGroups.length} groups) '
        'with all structure details for each group?';
  }

  Widget _headerCard(
    BuildContext context,
    List<String> sections,
    List<String> activities, {
    required List<Map<String, dynamic>> allRows,
    required List<DailyProgressGroup> groups,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final String filterLabel = _activeFilterCount > 0
        ? 'Filter ($_activeFilterCount)'
        : 'Filter';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Daily Progress Report',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                children: <TextSpan>[
                  const TextSpan(text: 'Report date: '),
                  TextSpan(
                    text: _displayDate,
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openFilterDialog(
                      sections: sections,
                      activities: activities,
                    ),
                    icon: const Icon(Icons.filter_alt_rounded, size: 18),
                    label: Text(filterLabel),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: groups.isEmpty
                        ? null
                        : () => _openDownloadSheet(
                              allRows: allRows,
                              groups: groups,
                            ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Download'),
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFilterDialog({
    required List<String> sections,
    required List<String> activities,
  }) async {
    String dialogSection = _sectionFilter;
    String dialogActivity = _activityFilter;
    DateTime dialogDate = _selectedDate;
    bool shouldApply = false;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            Future<void> pickDialogDate() async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: dialogDate,
                firstDate: DateTime(2015),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setDialogState(() => dialogDate = picked);
              }
            }

            void clearDialogFilters() {
              setDialogState(() {
                dialogSection = _allSections;
                dialogActivity = _allActivities;
                dialogDate = DateTime.now();
              });
            }

            final String dialogDateLabel =
                DateFormat('dd/MM/yyyy').format(dialogDate);

            return AlertDialog(
              title: const Text('Filter Daily Progress'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppSelectSheetField<String>(
                      label: 'Section',
                      title: 'Select Section',
                      compact: true,
                      items: sections,
                      value: sections.contains(dialogSection)
                          ? dialogSection
                          : _allSections,
                      itemLabelBuilder: (String value) => value,
                      onChanged: (String value) =>
                          setDialogState(() => dialogSection = value),
                    ),
                    const SizedBox(height: 10),
                    AppSelectSheetField<String>(
                      label: 'Activity',
                      title: 'Select Activity',
                      compact: true,
                      items: activities,
                      value: activities.contains(dialogActivity)
                          ? dialogActivity
                          : _allActivities,
                      itemLabelBuilder: (String value) => value,
                      onChanged: (String value) =>
                          setDialogState(() => dialogActivity = value),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Report date',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: pickDialogDate,
                        icon: const Icon(Icons.calendar_today_rounded, size: 16),
                        label: Text(dialogDateLabel),
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: clearDialogFilters,
                  child: const Text('Clear'),
                ),
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
      _sectionFilter = dialogSection;
      _activityFilter = dialogActivity;
      _selectedDate = dialogDate;
      _currentPage = 0;
      _expandedGroups.clear();
    });
  }

  Future<void> _openDownloadSheet({
    required List<Map<String, dynamic>> allRows,
    required List<DailyProgressGroup> groups,
  }) async {
    final List<DailyProgressGroup> exportGroups = _exportGroups(allRows, groups);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Download report',
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.table_view_rounded, color: Colors.green.shade700),
                title: const Text('Export Excel'),
                subtitle: const Text('Download as .xlsx file'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _confirmExportExcel(exportGroups);
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf_rounded, color: Colors.red.shade700),
                title: const Text('Export PDF'),
                subtitle: const Text('Download as .pdf file'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _confirmExportPdf(exportGroups);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tableArea(BuildContext context, List<DailyProgressGroup> groups) {
    final double tableWidth = math.max(
      _SummaryColumnLayout.totalWidth,
      _DetailColumnLayout.totalWidth + 38,
    );
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _summaryHeader(context),
                for (int index = 0; index < groups.length; index++) ...<Widget>[
                  if (index > 0)
                    Divider(
                      height: 1,
                      thickness: 0.6,
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.45),
                    ),
                  Builder(
                    builder: (BuildContext context) {
                      final DailyProgressGroup group = groups[index];
                      final bool expanded =
                          _expandedGroups.contains(group.groupKey);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _summaryRow(context, group, expanded: expanded),
                          if (expanded) _detailBlock(context, group),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryHeader(BuildContext context) {
    final Color headerColor = Theme.of(context).colorScheme.primary;
    return Container(
      color: headerColor,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: _SummaryColumnLayout.horizontalPadding / 2,
      ),
      child: Row(
        children: <Widget>[
          _headerCell('', _SummaryColumnLayout.expand),
          _headerCell('SECTION', _SummaryColumnLayout.section),
          _headerCell('ACTIVITY', _SummaryColumnLayout.activity),
          _headerCell('UNIT', _SummaryColumnLayout.unit),
          _headerCell('STRUCTURES', _SummaryColumnLayout.structures),
          _headerCell('SCOPE (CUM)', _SummaryColumnLayout.scope, alignRight: true),
          _headerCell(
            'COMPLETED QTY (CUM)',
            _SummaryColumnLayout.completed,
            alignRight: true,
          ),
          _headerCell('BALANCE (CUM)', _SummaryColumnLayout.balance, alignRight: true),
          _headerCell('ASKING RATE', _SummaryColumnLayout.askingRate, alignRight: true),
          _headerCell(
            'PROGRESS ON DATE (CUM)',
            _SummaryColumnLayout.progressOnDate,
            alignRight: true,
          ),
          _headerCell('TDC', _SummaryColumnLayout.tdc),
          _headerCell('ACTION', _SummaryColumnLayout.action, centered: true),
        ],
      ),
    );
  }

  Widget _headerCell(
    String label,
    double width, {
    bool alignRight = false,
    bool centered = false,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: centered
            ? TextAlign.center
            : alignRight
            ? TextAlign.right
            : TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context,
    DailyProgressGroup group, {
    required bool expanded,
  }) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Material(
      color: expanded
          ? cs.primaryContainer.withValues(alpha: 0.18)
          : cs.surfaceContainerHighest.withValues(alpha: 0.28),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: _SummaryColumnLayout.horizontalPadding / 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: _SummaryColumnLayout.expand,
              child: IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: Icon(
                  expanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  color: cs.primary,
                ),
                onPressed: () => setState(() {
                  if (expanded) {
                    _expandedGroups.remove(group.groupKey);
                  } else {
                    _expandedGroups.add(group.groupKey);
                  }
                }),
              ),
            ),
            _textCell(group.section, width: _SummaryColumnLayout.section, weight: FontWeight.w700),
            _textCell(group.activity, width: _SummaryColumnLayout.activity, weight: FontWeight.w700),
            _textCell(group.unit, width: _SummaryColumnLayout.unit),
            SizedBox(
              width: _SummaryColumnLayout.structures,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    '${group.structureCount} Structures',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
            _textCell(
              _formatQty(group.scope),
              width: _SummaryColumnLayout.scope,
              align: TextAlign.right,
            ),
            _metricCell(
              _formatQty(group.completedQty),
              width: _SummaryColumnLayout.completed,
              background: _metricBackground(context, Colors.green),
              foreground: _metricForeground(context, Colors.green.shade800),
            ),
            _metricCell(
              _formatQty(group.balance),
              width: _SummaryColumnLayout.balance,
              background: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.55),
              foreground: Theme.of(context).colorScheme.primary,
            ),
            _textCell(
              '—',
              width: _SummaryColumnLayout.askingRate,
              align: TextAlign.right,
            ),
            _metricCell(
              _formatQty(group.progressOnDate),
              width: _SummaryColumnLayout.progressOnDate,
              background: _metricBackground(context, Colors.deepPurple),
              foreground: _metricForeground(context, Colors.deepPurple.shade700),
            ),
            _textCell(group.tdc, width: _SummaryColumnLayout.tdc),
            SizedBox(
              width: _SummaryColumnLayout.action,
              child: Center(
                child: FilledButton(
                  onPressed: () => setState(() {
                    if (expanded) {
                      _expandedGroups.remove(group.groupKey);
                    } else {
                      _expandedGroups.add(group.groupKey);
                    }
                  }),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(58, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    expanded ? 'Hide' : 'View',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailBlock(BuildContext context, DailyProgressGroup group) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final double detailWidth = _DetailColumnLayout.totalWidth;
    return Container(
      width: math.max(
        _SummaryColumnLayout.totalWidth,
        _DetailColumnLayout.totalWidth + 38,
      ),
      color: cs.primaryContainer.withValues(alpha: 0.10),
      padding: const EdgeInsets.fromLTRB(28, 8, 10, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: cs.primary.withValues(alpha: 0.45), width: 3),
          ),
        ),
        child: SizedBox(
          width: detailWidth,
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.88),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: <Widget>[
                    _headerCell('STRUCTURE', _DetailColumnLayout.structure),
                    _headerCell('UNIT', _DetailColumnLayout.unit, centered: true),
                    _headerCell('SCOPE', _DetailColumnLayout.scope, alignRight: true),
                    _headerCell(
                      'PLANNED TILL DATE',
                      _DetailColumnLayout.plannedTillDate,
                      alignRight: true,
                    ),
                    _headerCell(
                      'ACTUAL TILL DATE',
                      _DetailColumnLayout.actualTillDate,
                      alignRight: true,
                    ),
                    _headerCell(
                      'ASKING RATE / DAY',
                      _DetailColumnLayout.askingRatePerDay,
                      alignRight: true,
                    ),
                    _headerCell(
                      'ACTUAL FOR DAY',
                      _DetailColumnLayout.actualForDay,
                      alignRight: true,
                    ),
                    _headerCell(
                      'CUM. ACTUAL',
                      _DetailColumnLayout.cumulativeActual,
                      alignRight: true,
                    ),
                    _headerCell('M&P', _DetailColumnLayout.mp, centered: true),
                    _headerCell('MANPOWER', _DetailColumnLayout.manpower, centered: true),
                    _headerCell('TDC', _DetailColumnLayout.tdc),
                  ],
                ),
              ),
              ...group.structures.asMap().entries.map((
                MapEntry<int, DailyProgressStructureRow> entry,
              ) {
                final DailyProgressStructureRow row = entry.value;
                final bool even = entry.key.isEven;
                return Container(
                  color: even
                      ? cs.surface.withValues(alpha: 0.72)
                      : cs.surfaceContainerHighest.withValues(alpha: 0.35),
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _textCell(
                        row.structure,
                        width: _DetailColumnLayout.structure,
                        weight: FontWeight.w600,
                      ),
                      SizedBox(
                        width: _DetailColumnLayout.unit,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              row.unit,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _textCell(
                        _formatQty(row.scope),
                        width: _DetailColumnLayout.scope,
                        align: TextAlign.right,
                      ),
                      _textCell(
                        _formatQty(row.plannedTillDate),
                        width: _DetailColumnLayout.plannedTillDate,
                        align: TextAlign.right,
                      ),
                      _metricCell(
                        _formatQty(row.actualTillDate),
                        width: _DetailColumnLayout.actualTillDate,
                        background: _metricBackground(context, Colors.green),
                        foreground: _metricForeground(context, Colors.green.shade800),
                      ),
                      _textCell(
                        row.askingRatePerDay == null
                            ? '—'
                            : _formatQty(row.askingRatePerDay!),
                        width: _DetailColumnLayout.askingRatePerDay,
                        align: TextAlign.right,
                      ),
                      _metricCell(
                        _formatQty(row.actualForDay),
                        width: _DetailColumnLayout.actualForDay,
                        background: _metricBackground(context, Colors.deepPurple),
                        foreground: _metricForeground(
                          context,
                          Colors.deepPurple.shade700,
                        ),
                      ),
                      _textCell(
                        _formatQty(row.cumulativeActual),
                        width: _DetailColumnLayout.cumulativeActual,
                        align: TextAlign.right,
                      ),
                      _textCell(
                        row.mpDeployment,
                        width: _DetailColumnLayout.mp,
                        align: TextAlign.center,
                      ),
                      _textCell(
                        row.manpowerDeployment,
                        width: _DetailColumnLayout.manpower,
                        align: TextAlign.center,
                      ),
                      _textCell(row.tdc, width: _DetailColumnLayout.tdc),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textCell(
    String value, {
    required double width,
    Color? color,
    FontWeight weight = FontWeight.w500,
    TextAlign align = TextAlign.left,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        value,
        textAlign: align,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: weight,
          height: 1.25,
        ),
      ),
    );
  }

  Widget _metricCell(
    String value, {
    required double width,
    required Color background,
    required Color foreground,
  }) {
    return SizedBox(
      width: width,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _paginationFooter({
    required int total,
    required int start,
    required int end,
    required int pageCount,
  }) {
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

  String _formatQty(double value) {
    return NumberFormat('#,##0.00', 'en_IN').format(value);
  }

  Color _metricBackground(BuildContext context, MaterialColor color) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? color.withValues(alpha: 0.22)
        : color.shade50;
  }

  Color _metricForeground(BuildContext context, Color lightColor) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white.withValues(alpha: 0.92) : lightColor;
  }

  String _exportFileStem() {
    final String projectPart = widget.projectId.trim().isEmpty
        ? 'project'
        : widget.projectId.trim();
    return 'daily_progress_${projectPart}_$_apiDate';
  }

  Future<void> _confirmExportExcel(List<DailyProgressGroup> groups) async {
    if (!mounted || groups.isEmpty) {
      return;
    }
    await AppDialog.show(
      context: context,
      type: AppDialogType.confirmation,
      leadingIcon: Icons.table_view_rounded,
      title: 'Export to Excel',
      message: _exportScopeMessage(groups),
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Export',
          isPrimary: true,
          onPressed: () => _exportExcel(groups),
        ),
      ],
    );
  }

  Future<void> _confirmExportPdf(List<DailyProgressGroup> groups) async {
    if (!mounted || groups.isEmpty) {
      return;
    }
    await AppDialog.show(
      context: context,
      type: AppDialogType.confirmation,
      leadingIcon: Icons.picture_as_pdf_rounded,
      title: 'Export to PDF',
      message: _exportScopeMessage(groups),
      actions: <AppDialogAction>[
        const AppDialogAction(label: 'Cancel'),
        AppDialogAction(
          label: 'Export',
          isPrimary: true,
          onPressed: () => _exportPdf(groups),
        ),
      ],
    );
  }

  Future<void> _exportExcel(List<DailyProgressGroup> groups) async {
    try {
      final Excel workbook = Excel.createExcel();
      final String defaultSheet = workbook.getDefaultSheet() ?? 'Sheet1';
      workbook.rename(defaultSheet, 'Summary');
      workbook.copy('Summary', 'Details');

      final Sheet summarySheet = workbook['Summary'];
      summarySheet.appendRow(<CellValue>[
        TextCellValue('Project'),
        TextCellValue('Report Date'),
        TextCellValue('Section'),
        TextCellValue('Activity'),
        TextCellValue('Unit'),
        TextCellValue('Structures'),
        TextCellValue('Scope (CUM)'),
        TextCellValue('Completed Qty (CUM)'),
        TextCellValue('Balance (CUM)'),
        TextCellValue('Asking Rate'),
        TextCellValue('Progress On Date (CUM)'),
        TextCellValue('TDC'),
      ]);
      for (final DailyProgressGroup group in groups) {
        summarySheet.appendRow(<CellValue>[
          TextCellValue(widget.projectName),
          TextCellValue(_displayDate),
          TextCellValue(group.section),
          TextCellValue(group.activity),
          TextCellValue(group.unit),
          TextCellValue('${group.structureCount}'),
          TextCellValue(_formatQty(group.scope)),
          TextCellValue(_formatQty(group.completedQty)),
          TextCellValue(_formatQty(group.balance)),
          TextCellValue(_exportDash),
          TextCellValue(_formatQty(group.progressOnDate)),
          TextCellValue(group.tdc),
        ]);
      }

      final Sheet detailsSheet = workbook['Details'];
      while (detailsSheet.maxRows > 0) {
        detailsSheet.removeRow(0);
      }
      for (final DailyProgressGroup group in groups) {
        detailsSheet.appendRow(<CellValue>[
          TextCellValue('GROUP'),
          TextCellValue(widget.projectName),
          TextCellValue(_displayDate),
          TextCellValue(group.section),
          TextCellValue(group.activity),
          TextCellValue('${group.structureCount} structures'),
        ]);
        detailsSheet.appendRow(<CellValue>[
          TextCellValue('Structure'),
          TextCellValue('Unit'),
          TextCellValue('Scope'),
          TextCellValue('Planned Till Date'),
          TextCellValue('Actual Till Date'),
          TextCellValue('Asking Rate / Day'),
          TextCellValue('Actual For Day'),
          TextCellValue('Cum. Actual'),
          TextCellValue('M&P'),
          TextCellValue('Manpower'),
          TextCellValue('TDC'),
        ]);
        for (final DailyProgressStructureRow row in group.structures) {
          detailsSheet.appendRow(<CellValue>[
            TextCellValue(row.structure),
            TextCellValue(row.unit),
            TextCellValue(_formatQty(row.scope)),
            TextCellValue(_formatQty(row.plannedTillDate)),
            TextCellValue(_formatQty(row.actualTillDate)),
            TextCellValue(
              row.askingRatePerDay == null
                  ? _exportDash
                  : _formatQty(row.askingRatePerDay!),
            ),
            TextCellValue(_formatQty(row.actualForDay)),
            TextCellValue(_formatQty(row.cumulativeActual)),
            TextCellValue(row.mpDeployment),
            TextCellValue(row.manpowerDeployment),
            TextCellValue(row.tdc),
          ]);
        }
        detailsSheet.appendRow(<CellValue>[TextCellValue('')]);
      }

      final List<int>? encoded = workbook.encode();
      if (encoded == null || encoded.isEmpty) {
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

      final String savedPath = await _saveExportFile(
        fileName: '${_exportFileStem()}.xlsx',
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        bytes: Uint8List.fromList(encoded),
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
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Excel Export Failed',
        message: 'Unable to generate xlsx file.\n$error',
        type: AppDialogType.error,
      );
    }
  }

  List<String> _structureDetailPdfHeaders() {
    return <String>[
      'Structure',
      'Unit',
      'Scope',
      'Planned Till Date',
      'Actual Till Date',
      'Asking Rate / Day',
      'Actual For Day',
      'Cum. Actual',
      'M&P',
      'Manpower',
      'TDC',
    ];
  }

  List<List<String>> _structureDetailPdfRows(DailyProgressGroup group) {
    return group.structures
        .map(
          (DailyProgressStructureRow row) => <String>[
            _pdfSafe(row.structure),
            _pdfSafe(row.unit),
            _pdfSafe(_formatQty(row.scope)),
            _pdfSafe(_formatQty(row.plannedTillDate)),
            _pdfSafe(_formatQty(row.actualTillDate)),
            row.askingRatePerDay == null
                ? _exportDash
                : _pdfSafe(_formatQty(row.askingRatePerDay!)),
            _pdfSafe(_formatQty(row.actualForDay)),
            _pdfSafe(_formatQty(row.cumulativeActual)),
            _pdfSafe(row.mpDeployment),
            _pdfSafe(row.manpowerDeployment),
            _pdfSafe(row.tdc),
          ],
        )
        .toList();
  }

  Future<void> _exportPdf(List<DailyProgressGroup> groups) async {
    try {
      final pw.Font baseFont = await PdfGoogleFonts.notoSansRegular();
      final pw.Font boldFont = await PdfGoogleFonts.notoSansBold();
      final pw.Document doc = pw.Document(
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
      );

      final List<List<String>> summaryData = groups
          .map(
            (DailyProgressGroup group) => <String>[
              _pdfSafe(group.section),
              _pdfSafe(group.activity),
              _pdfSafe(group.unit),
              '${group.structureCount}',
              _pdfSafe(_formatQty(group.scope)),
              _pdfSafe(_formatQty(group.completedQty)),
              _pdfSafe(_formatQty(group.balance)),
              _exportDash,
              _pdfSafe(_formatQty(group.progressOnDate)),
              _pdfSafe(group.tdc),
            ],
          )
          .toList();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            final List<pw.Widget> content = <pw.Widget>[
              pw.Text(
                'Daily Progress Report',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Project: ${_pdfSafe(widget.projectName)} | '
                'Project ID: ${_pdfSafe(widget.projectId)} | '
                'Report date: ${_pdfSafe(_displayDate)}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Summary',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: <String>[
                  'Section',
                  'Activity',
                  'Unit',
                  'Structures',
                  'Scope (CUM)',
                  'Completed Qty (CUM)',
                  'Balance (CUM)',
                  'Asking Rate',
                  'Progress On Date (CUM)',
                  'TDC',
                ],
                data: summaryData,
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8,
                ),
                cellStyle: const pw.TextStyle(fontSize: 7),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Structure Details',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ];

            for (final DailyProgressGroup group in groups) {
              content
                ..add(pw.SizedBox(height: 10))
                ..add(
                  pw.Text(
                    _pdfSafe(
                      '${group.section} · ${group.activity} '
                      '(${group.structureCount} structures)',
                    ),
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                )
                ..add(pw.SizedBox(height: 4))
                ..add(
                  pw.TableHelper.fromTextArray(
                    headers: _structureDetailPdfHeaders(),
                    data: _structureDetailPdfRows(group),
                    headerStyle: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 7,
                    ),
                    cellStyle: const pw.TextStyle(fontSize: 6),
                    headerDecoration:
                        const pw.BoxDecoration(color: PdfColors.indigo),
                    cellAlignment: pw.Alignment.centerLeft,
                  ),
                );
            }

            return content;
          },
        ),
      );

      final Uint8List bytes = Uint8List.fromList(await doc.save());
      final String savedPath = await _saveExportFile(
        fileName: '${_exportFileStem()}.pdf',
        mimeType: 'application/pdf',
        bytes: bytes,
      );
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'PDF Saved',
        message: 'File saved to:\n$savedPath',
        type: AppDialogType.success,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'PDF Export Failed',
        message: 'Unable to generate PDF.\n$error',
        type: AppDialogType.error,
      );
    }
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
    final String filePath = '${dir.path}/$fileName';
    final File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  String _pdfSafe(String value) {
    const Map<String, String> replacements = <String, String>{
      '–': '-',
      '—': '-',
      '−': '-',
      '“': '"',
      '”': '"',
      '‘': "'",
      '’': "'",
    };
    String normalized = value;
    replacements.forEach((String from, String to) {
      normalized = normalized.replaceAll(from, to);
    });
    return normalized.replaceAll(RegExp(r'[^\x20-\x7E]'), ' ');
  }
}

class _SummaryColumnLayout {
  static const double expand = 32;
  static const double section = 118;
  static const double activity = 128;
  static const double unit = 56;
  static const double structures = 92;
  static const double scope = 104;
  static const double completed = 122;
  static const double balance = 104;
  static const double askingRate = 88;
  static const double progressOnDate = 132;
  static const double tdc = 92;
  static const double action = 72;
  static const double horizontalPadding = 20;

  static double get totalWidth =>
      expand +
      section +
      activity +
      unit +
      structures +
      scope +
      completed +
      balance +
      askingRate +
      progressOnDate +
      tdc +
      action +
      horizontalPadding;
}

class _DetailColumnLayout {
  static const double structure = 196;
  static const double unit = 56;
  static const double scope = 92;
  static const double plannedTillDate = 112;
  static const double actualTillDate = 112;
  static const double askingRatePerDay = 112;
  static const double actualForDay = 102;
  static const double cumulativeActual = 102;
  static const double mp = 72;
  static const double manpower = 92;
  static const double tdc = 92;

  static double get totalWidth =>
      structure +
      unit +
      scope +
      plannedTillDate +
      actualTillDate +
      askingRatePerDay +
      actualForDay +
      cumulativeActual +
      mp +
      manpower +
      tdc +
      16;
}
