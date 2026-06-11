import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/progress_segment.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/project_progress_chart_builder.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/widgets/progress_segment_detail_sheet.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/widgets/progress_segment_style.dart';

class ProgressStripChart extends StatelessWidget {
  const ProgressStripChart({
    super.key,
    required this.model,
  });

  final ProjectProgressChartModel model;

  static const double leftPanelWidth = 188;
  static const double serialColumnWidth = 34;
  static const double structureColumnWidth = 154;
  static const double sectionHeaderHeight = 50;
  static const double kmHeaderHeight = 32;
  static const double rowHeight = 44;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double totalWidth = leftPanelWidth + math.max(model.chartWidth, 320);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: cs.shadow.withValues(alpha: isDark ? 0.12 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _LeftHeaderCell(
                        height: sectionHeaderHeight + kmHeaderHeight,
                      ),
                      SizedBox(
                        width: math.max(model.chartWidth, 320),
                        child: Column(
                          children: <Widget>[
                            _SectionHeaderRow(model: model),
                            _KmHeaderRow(model: model),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ...model.rows.map(
                    (ProjectProgressChartRow row) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _LeftRowLabel(
                          serialNumber: row.serialNumber,
                          structureType: row.structureType,
                          height: rowHeight,
                        ),
                        SizedBox(
                          width: math.max(model.chartWidth, 320),
                          child: _ChartDataRow(
                            model: model,
                            row: row,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

class _LeftHeaderCell extends StatelessWidget {
  const _LeftHeaderCell({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      width: ProgressStripChart.leftPanelWidth,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: cs.primary,
        border: Border(
          bottom: BorderSide(color: cs.primary.withValues(alpha: 0.4)),
          right: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'SN',
            style: TextStyle(
              color: cs.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'STRUCTURE TYPE',
            style: TextStyle(
              color: cs.onPrimary.withValues(alpha: 0.92),
              fontWeight: FontWeight.w700,
              fontSize: 9,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftRowLabel extends StatelessWidget {
  const _LeftRowLabel({
    required this.serialNumber,
    required this.structureType,
    required this.height,
  });

  final int serialNumber;
  final String structureType;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool even = serialNumber.isEven;
    return Container(
      width: ProgressStripChart.leftPanelWidth,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: even
            ? cs.surfaceContainerHighest.withValues(alpha: 0.35)
            : cs.surface,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.45)),
          right: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: ProgressStripChart.serialColumnWidth,
            child: Text(
              '$serialNumber',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: cs.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              structureType,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                height: 1.2,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeaderRow extends StatelessWidget {
  const _SectionHeaderRow({required this.model});

  final ProjectProgressChartModel model;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: ProgressStripChart.sectionHeaderHeight,
      width: model.chartWidth,
      child: Stack(
        children: List<Widget>.generate(model.sections.length, (int index) {
          final ProjectProgressSectionBand section = model.sections[index];
          final double left = model.kmToX(section.fromKm);
          final double width = math.max(
            model.kmToX(section.toKm) - left,
            40,
          );
          final bool even = index.isEven;
          return Positioned(
            left: left,
            width: width,
            top: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: even
                    ? cs.primary.withValues(alpha: 0.92)
                    : cs.primary.withValues(alpha: 0.78),
                border: Border(
                  right: BorderSide(
                    color: cs.onPrimary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              child: Text(
                section.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  height: 1.15,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _KmHeaderRow extends StatelessWidget {
  const _KmHeaderRow({required this.model});

  final ProjectProgressChartModel model;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: ProgressStripChart.kmHeaderHeight,
      width: model.chartWidth,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.88),
                border: Border(
                  bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
          ...model.displayKmMarkers().map((double km) {
            final String label = _formatMarker(km);
            final double labelWidth = math.max(28, label.length * 5.5);
            final double left = (model.kmToX(km) - labelWidth / 2)
                .clamp(0, model.chartWidth - labelWidth);
            return Positioned(
              left: left,
              top: 0,
              bottom: 0,
              width: labelWidth,
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  static String _formatMarker(double km) {
    if (km == km.roundToDouble()) {
      return km.toStringAsFixed(0);
    }
    final String compact = km.toStringAsFixed(2);
    if (compact.endsWith('0')) {
      return km.toStringAsFixed(1);
    }
    return compact;
  }
}

class _ChartDataRow extends StatelessWidget {
  const _ChartDataRow({
    required this.model,
    required this.row,
  });

  final ProjectProgressChartModel model;
  final ProjectProgressChartRow row;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool even = row.serialNumber.isEven;

    return SizedBox(
      height: ProgressStripChart.rowHeight,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(
              painter: _SectionBandPainter(
                sections: model.sections,
                kmToX: model.kmToX,
                evenRow: even,
                surface: cs.surface,
                band: cs.surfaceContainerHighest.withValues(alpha: 0.28),
                divider: cs.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
          ),
          ...row.segments.map(
            (ProgressSegment segment) => _SegmentWidget(
              model: model,
              segment: segment,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBandPainter extends CustomPainter {
  _SectionBandPainter({
    required this.sections,
    required this.kmToX,
    required this.evenRow,
    required this.surface,
    required this.band,
    required this.divider,
  });

  final List<ProjectProgressSectionBand> sections;
  final double Function(double km) kmToX;
  final bool evenRow;
  final Color surface;
  final Color band;
  final Color divider;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint basePaint = Paint()..color = evenRow ? surface : band;
    canvas.drawRect(Offset.zero & size, basePaint);

    final Paint linePaint = Paint()
      ..color = divider
      ..strokeWidth = 1;

    for (final ProjectProgressSectionBand section in sections) {
      final double x = kmToX(section.fromKm);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, size.height),
      linePaint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SectionBandPainter oldDelegate) => false;
}

class _SegmentWidget extends StatelessWidget {
  const _SegmentWidget({
    required this.model,
    required this.segment,
  });

  final ProjectProgressChartModel model;
  final ProgressSegment segment;

  @override
  Widget build(BuildContext context) {
    final Color color = ProgressSegmentStyle.colorFor(
      context,
      segment.status,
      segment.progress,
    );
    final double left = model.kmToX(segment.fromKm);
    final double rawWidth = model.kmToX(segment.toKm) - left;
    final bool isPoint = segment.isPointSegment;
    final double width = isPoint
        ? 5
        : math.max(rawWidth, 10);
    final double top = isPoint ? 6 : 14;
    final double height = isPoint ? 32 : 16;

    return Positioned(
      left: isPoint ? left - 2 : left,
      top: top,
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showProgressSegmentDetailSheet(
            context: context,
            segment: segment,
          ),
          borderRadius: BorderRadius.circular(isPoint ? 2 : 4),
          child: Ink(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(isPoint ? 2 : 4),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.12),
                width: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
