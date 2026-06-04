import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/progress_segment.dart';

class ProjectProgressSectionBand {
  const ProjectProgressSectionBand({
    required this.name,
    required this.fromKm,
    required this.toKm,
  });

  final String name;
  final double fromKm;
  final double toKm;
}

class ProjectProgressChartRow {
  const ProjectProgressChartRow({
    required this.serialNumber,
    required this.structureType,
    required this.segments,
  });

  final int serialNumber;
  final String structureType;
  final List<ProgressSegment> segments;
}

class ProjectProgressChartModel {
  const ProjectProgressChartModel({
    required this.projectName,
    required this.fromKm,
    required this.toKm,
    required this.sections,
    required this.kmMarkers,
    required this.rows,
    this.pixelsPerKm = 11,
  });

  static const List<String> structureTypeOrder = <String>[
    'Land Acquisition - Core',
    'Land Acquisition - Non Core',
    'Formation',
    'Important Bridge',
    'Major Bridge',
    'Minor Bridge',
    'ROB',
    'RUB',
    'Station Works',
    'Track Work',
  ];

  final String projectName;
  final double fromKm;
  final double toKm;
  final List<ProjectProgressSectionBand> sections;
  final List<double> kmMarkers;
  final List<ProjectProgressChartRow> rows;
  final double pixelsPerKm;

  double get chartWidth => (toKm - fromKm) * pixelsPerKm;

  double kmToX(double km) => (km - fromKm) * pixelsPerKm;

  /// KM labels that are far enough apart on the chart to avoid overlap.
  List<double> displayKmMarkers({double minLabelGapPx = 52}) {
    if (kmMarkers.isEmpty) {
      return kmMarkers;
    }
    if (kmMarkers.length <= 2) {
      return kmMarkers;
    }

    final List<double> visible = <double>[kmMarkers.first];
    for (int index = 1; index < kmMarkers.length; index++) {
      final double km = kmMarkers[index];
      final bool isLast = index == kmMarkers.length - 1;
      final double gapPx = kmToX(km) - kmToX(visible.last);

      if (isLast) {
        if (gapPx < minLabelGapPx && visible.length > 1) {
          visible.removeLast();
        }
        if (visible.last != km) {
          visible.add(km);
        }
        continue;
      }

      if (gapPx >= minLabelGapPx) {
        visible.add(km);
      }
    }
    return visible;
  }

  static ProjectProgressChartModel fromSegments(List<ProgressSegment> segments) {
    if (segments.isEmpty) {
      return const ProjectProgressChartModel(
        projectName: '',
        fromKm: 0,
        toKm: 1,
        sections: <ProjectProgressSectionBand>[],
        kmMarkers: <double>[],
        rows: <ProjectProgressChartRow>[],
      );
    }

    final ProgressSegment first = segments.first;
    final double fromKm = first.projectFromKm;
    final double toKm = first.projectToKm;
    final String projectName = first.project;

    final Map<String, List<ProgressSegment>> segmentsByType =
        <String, List<ProgressSegment>>{};
    for (final ProgressSegment segment in segments) {
      segmentsByType
          .putIfAbsent(segment.structureType, () => <ProgressSegment>[])
          .add(segment);
    }

    final List<String> structureTypes = _orderedStructureTypes(
      segmentsByType.keys.toList(),
    );

    final List<ProjectProgressChartRow> rows = <ProjectProgressChartRow>[];
    for (int index = 0; index < structureTypes.length; index++) {
      final String type = structureTypes[index];
      final List<ProgressSegment> rowSegments =
          List<ProgressSegment>.from(segmentsByType[type] ?? <ProgressSegment>[])
            ..sort(
              (ProgressSegment a, ProgressSegment b) =>
                  a.fromKm.compareTo(b.fromKm),
            );
      rows.add(
        ProjectProgressChartRow(
          serialNumber: index + 1,
          structureType: type,
          segments: rowSegments,
        ),
      );
    }

    final List<ProjectProgressSectionBand> sections = _buildSections(segments);
    final List<double> kmMarkers = _buildKmMarkers(
      fromKm: fromKm,
      toKm: toKm,
      sections: sections,
    );

    return ProjectProgressChartModel(
      projectName: projectName,
      fromKm: fromKm,
      toKm: toKm,
      sections: sections,
      kmMarkers: kmMarkers,
      rows: rows,
    );
  }

  static List<String> _orderedStructureTypes(List<String> discovered) {
    final List<String> ordered = <String>[];
    for (final String type in structureTypeOrder) {
      if (discovered.contains(type)) {
        ordered.add(type);
      }
    }
    final List<String> remaining = discovered
        .where((String type) => !structureTypeOrder.contains(type))
        .toList()
      ..sort();
    ordered.addAll(remaining);
    return ordered;
  }

  static List<ProjectProgressSectionBand> _buildSections(
    List<ProgressSegment> segments,
  ) {
    final Map<String, _SectionAccumulator> grouped =
        <String, _SectionAccumulator>{};
    for (final ProgressSegment segment in segments) {
      final String name = segment.projectSection?.trim().isNotEmpty == true
          ? segment.projectSection!.trim()
          : 'Other';
      grouped.putIfAbsent(name, _SectionAccumulator.new).add(segment);
    }

    final List<ProjectProgressSectionBand> sections = grouped.entries
        .map(
          (MapEntry<String, _SectionAccumulator> entry) =>
              ProjectProgressSectionBand(
            name: entry.key,
            fromKm: entry.value.minKm,
            toKm: entry.value.maxKm,
          ),
        )
        .toList()
      ..sort(
        (ProjectProgressSectionBand a, ProjectProgressSectionBand b) =>
            a.fromKm.compareTo(b.fromKm),
      );
    return sections;
  }

  static List<double> _buildKmMarkers({
    required double fromKm,
    required double toKm,
    required List<ProjectProgressSectionBand> sections,
  }) {
    final Set<double> markers = <double>{fromKm, toKm};
    for (final ProjectProgressSectionBand section in sections) {
      markers.add(section.fromKm);
      markers.add(section.toKm);
    }
    final List<double> sorted = markers.toList()..sort();
    return sorted;
  }
}

class _SectionAccumulator {
  double minKm = double.infinity;
  double maxKm = double.negativeInfinity;

  void add(ProgressSegment segment) {
    if (segment.fromKm < minKm) {
      minKm = segment.fromKm;
    }
    if (segment.toKm > maxKm) {
      maxKm = segment.toKm;
    }
  }
}
