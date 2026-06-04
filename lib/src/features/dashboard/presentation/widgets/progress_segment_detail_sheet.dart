import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/progress_segment.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/widgets/progress_segment_style.dart';

Future<void> showProgressSegmentDetailSheet({
  required BuildContext context,
  required ProgressSegment segment,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      final ThemeData theme = Theme.of(sheetContext);
      final ColorScheme cs = theme.colorScheme;
      final Color statusColor = ProgressSegmentStyle.colorFor(
        sheetContext,
        segment.status,
        segment.progress,
      );

      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.paddingOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    segment.status,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
                Text(
                  segment.progressLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DetailRow(
              label: 'Contract Short Name',
              value: segment.contractShortName.isEmpty
                  ? segment.contractName
                  : segment.contractShortName,
            ),
            _DetailRow(label: 'Contractor', value: segment.contractor),
            _DetailRow(label: 'Structure Type', value: segment.structureType),
            _DetailRow(label: 'Structure', value: segment.subStructure),
            _DetailRow(label: 'Chainage (KM)', value: segment.chainageLabel),
            if (segment.projectSection != null)
              _DetailRow(label: 'Project Section', value: segment.projectSection!),
            _DetailRow(label: 'Status', value: segment.status),
            _DetailRow(label: 'Progress', value: segment.progressLabel),
          ],
        ),
      );
    },
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
