import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_filter_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/site_photo_row.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/site_photos_filters.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/providers/site_photos_provider.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/widgets/site_photos_preview_dialog.dart';

class SitePhotosTab extends ConsumerStatefulWidget {
  const SitePhotosTab({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  ConsumerState<SitePhotosTab> createState() => _SitePhotosTabState();
}

class _SitePhotosTabState extends ConsumerState<SitePhotosTab> {
  static const List<int> _pageSizeOptions = <int>[5, 10, 25, 50];

  int _pageSize = 10;
  int _currentPage = 0;
  SitePhotosFilterState _filters = SitePhotosFilterState.cleared;

  void _clearFilters() {
    setState(() {
      _filters = SitePhotosFilterState.cleared;
      _currentPage = 0;
    });
  }

  void _applyFilters(SitePhotosFilterState next) {
    setState(() {
      _filters = next;
      _currentPage = 0;
    });
  }

  int _activeFilterCount(SitePhotosFilterState filters) {
    var count = 0;
    if (filters.section != SitePhotosFilters.all) {
      count++;
    }
    if (filters.structureType != SitePhotosFilters.all) {
      count++;
    }
    if (filters.structure != SitePhotosFilters.all) {
      count++;
    }
    if (filters.structureComponent != SitePhotosFilters.all) {
      count++;
    }
    if (filters.componentId != SitePhotosFilters.all) {
      count++;
    }
    if (filters.fromDate != null) {
      count++;
    }
    if (filters.toDate != null) {
      count++;
    }
    return count;
  }

  SitePhotosFilterState _normalizeFilters(
    List<SitePhotoRow> allRows,
    SitePhotosFilterState state,
  ) {
    final List<String> sections =
        SitePhotosFilters.sectionOptions(allRows, state);
    final List<String> structureTypes =
        SitePhotosFilters.structureTypeOptions(allRows, state);
    final List<String> structures =
        SitePhotosFilters.structureOptions(allRows, state);
    final List<String> components =
        SitePhotosFilters.structureComponentOptions(allRows, state);
    final List<String> componentIds =
        SitePhotosFilters.componentIdOptions(allRows, state);

    String section =
        SitePhotosFilters.sheetValue(sections, state.section);
    String structureType = SitePhotosFilters.sheetValue(
      structureTypes,
      state.structureType,
    );
    String structure = SitePhotosFilters.sheetValue(structures, state.structure);
    String structureComponent = SitePhotosFilters.sheetValue(
      components,
      state.structureComponent,
    );
    String componentId = SitePhotosFilters.sheetValue(
      componentIds,
      state.componentId,
    );

    if (structureType == SitePhotosFilters.all) {
      structure = SitePhotosFilters.all;
      structureComponent = SitePhotosFilters.all;
      componentId = SitePhotosFilters.all;
    } else if (structure == SitePhotosFilters.all) {
      structureComponent = SitePhotosFilters.all;
      componentId = SitePhotosFilters.all;
    } else if (structureComponent == SitePhotosFilters.all) {
      componentId = SitePhotosFilters.all;
    }

    return state.copyWith(
      section: section,
      structureType: structureType,
      structure: structure,
      structureComponent: structureComponent,
      componentId: componentId,
    );
  }

  Future<void> _openFilterDialog(List<SitePhotoRow> allRows) async {
    SitePhotosFilterState dialogFilters = _normalizeFilters(allRows, _filters);
    bool shouldApply = false;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            SitePhotosFilterState working = _normalizeFilters(
              allRows,
              dialogFilters,
            );

            void updateDialog(SitePhotosFilterState next) {
              setDialogState(() {
                dialogFilters = _normalizeFilters(allRows, next);
              });
            }

            final List<String> sections =
                SitePhotosFilters.sectionOptions(allRows, working);
            final List<String> structureTypes =
                SitePhotosFilters.structureTypeOptions(allRows, working);
            final List<String> structures =
                SitePhotosFilters.structureOptions(allRows, working);
            final List<String> components =
                SitePhotosFilters.structureComponentOptions(allRows, working);
            final List<String> componentIds =
                SitePhotosFilters.componentIdOptions(allRows, working);

            final bool structureEnabled =
                working.structureType != SitePhotosFilters.all;
            final bool componentEnabled =
                structureEnabled && working.structure != SitePhotosFilters.all;
            final bool componentIdEnabled = componentEnabled &&
                working.structureComponent != SitePhotosFilters.all;

            Future<void> pickFromDate() async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: working.fromDate ?? DateTime.now(),
                firstDate: DateTime(2015),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                updateDialog(
                  working.copyWith(fromDate: DateUtils.dateOnly(picked)),
                );
              }
            }

            Future<void> pickToDate() async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: working.toDate ?? working.fromDate ?? DateTime.now(),
                firstDate: DateTime(2015),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                updateDialog(
                  working.copyWith(toDate: DateUtils.dateOnly(picked)),
                );
              }
            }

            final String fromLabel = working.fromDate == null
                ? 'dd/mm/yyyy'
                : DateFormat('dd/MM/yyyy').format(working.fromDate!);
            final String toLabel = working.toDate == null
                ? 'dd/mm/yyyy'
                : DateFormat('dd/MM/yyyy').format(working.toDate!);
            final bool invalidRange = working.fromDate != null &&
                working.toDate != null &&
                working.fromDate!.isAfter(working.toDate!);

            return AppFilterDialog(
              title: 'Filter Site Photos',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    AppSelectSheetField<String>(
                      label: 'Section',
                      title: 'Select Section',
                      compact: true,
                      placeholderText: SitePhotosFilters.all,
                      items: sections,
                      value: SitePhotosFilters.sheetValue(
                        sections,
                        working.section,
                      ),
                      itemLabelBuilder: (String value) => value,
                      onChanged: (String value) => updateDialog(
                        working.copyWith(section: value),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Date range',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: pickFromDate,
                        icon: const Icon(Icons.calendar_today_rounded, size: 16),
                        label: Text('From: $fromLabel'),
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
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: pickToDate,
                        icon: const Icon(Icons.calendar_today_rounded, size: 16),
                        label: Text('To: $toLabel'),
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
                    if (invalidRange) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        'From date must be on or before To date.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    AppSelectSheetField<String>(
                      label: 'Structure Type',
                      title: 'Select Structure Type',
                      compact: true,
                      placeholderText: SitePhotosFilters.all,
                      items: structureTypes,
                      value: SitePhotosFilters.sheetValue(
                        structureTypes,
                        working.structureType,
                      ),
                      itemLabelBuilder: (String value) => value,
                      onChanged: (String value) => updateDialog(
                        working.copyWith(
                          structureType: value,
                          structure: SitePhotosFilters.all,
                          structureComponent: SitePhotosFilters.all,
                          componentId: SitePhotosFilters.all,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppSelectSheetField<String>(
                      label: 'Structure',
                      title: 'Select Structure',
                      compact: true,
                      enabled: structureEnabled,
                      placeholderText: SitePhotosFilters.all,
                      items: structures,
                      value: SitePhotosFilters.sheetValue(
                        structures,
                        working.structure,
                      ),
                      itemLabelBuilder: (String value) => value,
                      onChanged: (String value) => updateDialog(
                        working.copyWith(
                          structure: value,
                          structureComponent: SitePhotosFilters.all,
                          componentId: SitePhotosFilters.all,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppSelectSheetField<String>(
                      label: 'Structure Component',
                      title: 'Select Structure Component',
                      compact: true,
                      enabled: componentEnabled,
                      placeholderText: SitePhotosFilters.all,
                      items: components,
                      value: SitePhotosFilters.sheetValue(
                        components,
                        working.structureComponent,
                      ),
                      itemLabelBuilder: (String value) => value,
                      onChanged: (String value) => updateDialog(
                        working.copyWith(
                          structureComponent: value,
                          componentId: SitePhotosFilters.all,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppSelectSheetField<String>(
                      label: 'Component ID',
                      title: 'Select Component ID',
                      compact: true,
                      enabled: componentIdEnabled,
                      placeholderText: SitePhotosFilters.all,
                      items: componentIds,
                      value: SitePhotosFilters.sheetValue(
                        componentIds,
                        working.componentId,
                      ),
                      itemLabelBuilder: (String value) => value,
                      onChanged: (String value) => updateDialog(
                        working.copyWith(componentId: value),
                      ),
                    ),
                  ],
                ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => updateDialog(SitePhotosFilterState.cleared),
                  child: const Text('Clear'),
                ),
                FilledButton(
                  onPressed: invalidRange
                      ? null
                      : () {
                          shouldApply = true;
                          Navigator.of(context).pop();
                        },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldApply) {
      _applyFilters(_normalizeFilters(allRows, dialogFilters));
    }
  }

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

    final AsyncValue<List<SitePhotoRow>> photosAsync = ref.watch(
      sitePhotosProvider(widget.projectId),
    );

    return photosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                userFriendlyErrorMessage(error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () =>
                    ref.invalidate(sitePhotosProvider(widget.projectId)),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (List<SitePhotoRow> rows) => _content(context, rows),
    );
  }

  Widget _content(BuildContext context, List<SitePhotoRow> allRows) {
    final SitePhotosFilterState activeFilters =
        _normalizeFilters(allRows, _filters);
    if (activeFilters.section != _filters.section ||
        activeFilters.structureType != _filters.structureType ||
        activeFilters.structure != _filters.structure ||
        activeFilters.structureComponent != _filters.structureComponent ||
        activeFilters.componentId != _filters.componentId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() => _filters = activeFilters);
      });
    }

    final List<SitePhotoRow> rows =
        SitePhotosFilters.apply(allRows, activeFilters);
    final int total = rows.length;
    final int pageCount = total == 0 ? 1 : (total / _pageSize).ceil();
    if (_currentPage >= pageCount) {
      _currentPage = pageCount - 1;
    }
    if (_currentPage < 0) {
      _currentPage = 0;
    }
    final int start = total == 0 ? 0 : _currentPage * _pageSize;
    final int end = total == 0 ? 0 : (start + _pageSize).clamp(0, total);
    final List<SitePhotoRow> pageRows =
        total == 0 ? rows : rows.sublist(start, end);

    final String emptyMessage = allRows.isEmpty
        ? 'No site photos available for this project.'
        : 'No site photos match the selected filters.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _headerCard(context, allRows: allRows),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              if (rows.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      emptyMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(child: _tableArea(context, pageRows)),
            ],
          ),
        ),
        AppTablePaginationFooter(
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
          onPrevious: _currentPage > 0
              ? () => setState(() => _currentPage -= 1)
              : null,
          onNext: _currentPage < pageCount - 1
              ? () => setState(() => _currentPage += 1)
              : null,
        ),
      ],
    );
  }

  Widget _headerCard(
    BuildContext context, {
    required List<SitePhotoRow> allRows,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    final bool canFilter = allRows.isNotEmpty;
    final bool hasActiveFilters = _filters.hasActiveFilters;
    final int activeCount = _activeFilterCount(_filters);
    final String filterLabel =
        activeCount > 0 ? 'Filter ($activeCount)' : 'Filter';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Site Photos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                children: <TextSpan>[
                  const TextSpan(text: 'Project ID: '),
                  TextSpan(
                    text: widget.projectId,
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
                    onPressed:
                        canFilter ? () => _openFilterDialog(allRows) : null,
                    icon: const Icon(Icons.filter_alt_rounded, size: 18),
                    label: Text(filterLabel),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasActiveFilters ? _clearFilters : null,
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      minimumSize: const Size(0, 40),
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

  Widget _tableArea(BuildContext context, List<SitePhotoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .shadow
                .withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _SitePhotosColumnLayout.totalWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _tableHeader(context),
              for (int index = 0; index < rows.length; index++) ...<Widget>[
                if (index > 0)
                  Divider(
                    height: 1,
                    thickness: 0.6,
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.45),
                  ),
                _tableRow(context, rows[index]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(BuildContext context) {
    final Color headerColor = Theme.of(context).colorScheme.primary;
    return Container(
      color: headerColor,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: _SitePhotosColumnLayout.horizontalPadding / 2,
      ),
      child: Row(
        children: <Widget>[
          _headerCell('SECTION', _SitePhotosColumnLayout.section),
          _headerCell('DATE', _SitePhotosColumnLayout.date),
          _headerCell('STRUCTURE TYPE', _SitePhotosColumnLayout.structureType),
          _headerCell('STRUCTURE', _SitePhotosColumnLayout.structure),
          _headerCell(
            'STRUCTURE COMPONENT',
            _SitePhotosColumnLayout.structureComponent,
          ),
          _headerCell('COMPONENT ID', _SitePhotosColumnLayout.componentId),
          _headerCell(
            'PHOTOS COUNT',
            _SitePhotosColumnLayout.photosCount,
            centered: true,
          ),
          _headerCell('VIEW', _SitePhotosColumnLayout.view, centered: true),
        ],
      ),
    );
  }

  Widget _headerCell(
    String label,
    double width, {
    bool centered = false,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: centered ? TextAlign.center : TextAlign.left,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _tableRow(BuildContext context, SitePhotoRow row) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool canView = row.hasPhotos;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.22),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: _SitePhotosColumnLayout.horizontalPadding / 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _textCell(row.section, width: _SitePhotosColumnLayout.section),
            _textCell(row.displayDate, width: _SitePhotosColumnLayout.date),
            _textCell(
              row.structureType,
              width: _SitePhotosColumnLayout.structureType,
            ),
            _textCell(
              row.structure,
              width: _SitePhotosColumnLayout.structure,
              weight: FontWeight.w600,
            ),
            _textCell(
              row.structureComponent,
              width: _SitePhotosColumnLayout.structureComponent,
            ),
            _textCell(
              row.componentId,
              width: _SitePhotosColumnLayout.componentId,
            ),
            SizedBox(
              width: _SitePhotosColumnLayout.photosCount,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.75),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${row.photosCount}',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: _SitePhotosColumnLayout.view,
              child: Center(
                child: FilledButton(
                  onPressed: canView
                      ? () => showSitePhotosPreviewDialog(
                            context: context,
                            row: row,
                          )
                      : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(92, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    'View Photos',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textCell(
    String value, {
    required double width,
    FontWeight weight = FontWeight.w500,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        value,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: weight,
          height: 1.25,
        ),
      ),
    );
  }
}

class _SitePhotosColumnLayout {
  static const double section = 128;
  static const double date = 92;
  static const double structureType = 108;
  static const double structure = 196;
  static const double structureComponent = 132;
  static const double componentId = 120;
  static const double photosCount = 88;
  static const double view = 108;
  static const double horizontalPadding = 20;

  static double get totalWidth =>
      section +
      date +
      structureType +
      structure +
      structureComponent +
      componentId +
      photosCount +
      view +
      horizontalPadding;
}
