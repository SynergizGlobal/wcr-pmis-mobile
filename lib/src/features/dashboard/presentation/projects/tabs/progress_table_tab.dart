import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/progress_table_mapper.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/providers/progress_table_provider.dart';

class ProgressTableTab extends ConsumerStatefulWidget {
  const ProgressTableTab({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  ConsumerState<ProgressTableTab> createState() => _ProgressTableTabState();
}

class _ProgressTableTabState extends ConsumerState<ProgressTableTab> {
  static const List<String> _headers = <String>[
    'Section',
    'Structure Type',
    'Unit',
    'Scope',
    'Structure type Progress',
    'TDC',
  ];

  String? _selectedContractId;

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

    final AsyncValue<List<Map<String, dynamic>>> tableAsync = ref.watch(
      progressTableProvider(widget.projectId),
    );

    return tableAsync.when(
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
                    ref.invalidate(progressTableProvider(widget.projectId)),
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
    final List<ProgressTableContractOption> contracts =
        ProgressTableMapper.contractsFromRows(rows);
    final String? contractId = _resolvedContractId(contracts);

    final List<ProgressTableSection> sections =
        ProgressTableMapper.sectionsFromRows(
      rows: rows,
      contractId: contractId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (contracts.isNotEmpty)
          AppSelectSheetField<String>(
            key: ValueKey<String?>(contractId),
            label: 'Contract',
            title: 'Select Contract',
            leadingIcon: Icons.assignment_outlined,
            items: contracts
                .map((ProgressTableContractOption c) => c.contractId)
                .toList(),
            value: contractId,
            itemLabelBuilder: (String id) {
              return contracts
                      .where(
                        (ProgressTableContractOption c) => c.contractId == id,
                      )
                      .map((ProgressTableContractOption c) => c.label)
                      .firstOrNull ??
                  id;
            },
            onChanged: (String value) =>
                setState(() => _selectedContractId = value),
          ),
        if (contracts.isNotEmpty) const SizedBox(height: 10),
        Expanded(
          child: sections.isEmpty
              ? Center(
                  child: Text(
                    contracts.isEmpty
                        ? 'No progress table data available for this project.'
                        : 'No progress data for the selected contract.',
                    textAlign: TextAlign.center,
                  ),
                )
              : _table(context, sections),
        ),
      ],
    );
  }

  String? _resolvedContractId(List<ProgressTableContractOption> contracts) {
    if (contracts.isEmpty) {
      return null;
    }
    if (_selectedContractId != null &&
        contracts.any(
          (ProgressTableContractOption item) =>
              item.contractId == _selectedContractId,
        )) {
      return _selectedContractId;
    }
    return contracts.first.contractId;
  }

  Widget _table(BuildContext context, List<ProgressTableSection> sections) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double tableWidth = _headers.fold<double>(
      0,
      (double sum, String header) => sum + _columnWidth(header),
    );

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth < constraints.maxWidth
                  ? constraints.maxWidth
                  : tableWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _headerRow(context),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sections.length,
                      itemBuilder: (BuildContext context, int index) =>
                          _sectionBlock(
                        context,
                        sections[index],
                        sectionIndex: index,
                        isLast: index == sections.length - 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _headerRow(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: _headers
            .map(
              (String title) => _headerCell(
                title,
                width: _columnWidth(title),
                color: colorScheme.onPrimary,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _sectionBlock(
    BuildContext context,
    ProgressTableSection section, {
    required int sectionIndex,
    bool isLast = false,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final BorderSide divider = BorderSide(
      color: colorScheme.outlineVariant.withValues(alpha: 0.65),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            width: _columnWidth('Section'),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: sectionIndex.isEven
                  ? colorScheme.primary.withValues(alpha: 0.06)
                  : colorScheme.surface,
              border: Border(
                right: divider,
                bottom: isLast ? BorderSide.none : divider,
              ),
            ),
            child: Text(
              section.section,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          SizedBox(
            width: _columnWidth('Structure Type') +
                _columnWidth('Unit') +
                _columnWidth('Scope') +
                _columnWidth('Structure type Progress') +
                _columnWidth('TDC'),
            child: Column(
              children: section.rows.asMap().entries.map((
                MapEntry<int, ProgressTableStructureRow> entry,
              ) {
                final int rowIndex = entry.key;
                final ProgressTableStructureRow row = entry.value;
                final bool isLastRowInSection =
                    rowIndex == section.rows.length - 1;
                return _structureRow(
                  context,
                  row,
                  rowIndex: sectionIndex * 100 + rowIndex,
                  showBottomBorder: !isLast || !isLastRowInSection,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _structureRow(
    BuildContext context,
    ProgressTableStructureRow row, {
    required int rowIndex,
    required bool showBottomBorder,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color bg = rowIndex.isEven
        ? colorScheme.primary.withValues(alpha: 0.06)
        : colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: showBottomBorder
            ? Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.65),
                ),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          _bodyCell(row.structureType, width: _columnWidth('Structure Type')),
          _bodyCell(row.unit, width: _columnWidth('Unit')),
          _bodyCell(row.scope, width: _columnWidth('Scope')),
          _bodyCell(
            row.progress,
            width: _columnWidth('Structure type Progress'),
          ),
          _bodyCell(row.tdc, width: _columnWidth('TDC')),
        ],
      ),
    );
  }

  Widget _headerCell(
    String value, {
    required double width,
    required Color color,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _bodyCell(String value, {required double width}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }

  double _columnWidth(String header) {
    switch (header) {
      case 'Section':
        return 130;
      case 'Structure Type':
        return 150;
      case 'Unit':
        return 70;
      case 'Scope':
        return 110;
      case 'Structure type Progress':
        return 140;
      case 'TDC':
        return 110;
      default:
        return 100;
    }
  }
}
