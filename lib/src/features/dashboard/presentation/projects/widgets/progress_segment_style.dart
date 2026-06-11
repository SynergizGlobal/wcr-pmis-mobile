import 'package:flutter/material.dart';

class ProgressSegmentStyle {
  const ProgressSegmentStyle._();

  static const Color completed = Color(0xFF2E7D32);
  static const Color almostCompleted = Color(0xFF66BB6A);
  static const Color inProgress = Color(0xFFFB8C00);
  static const Color notStarted = Color(0xFF9E9E9E);
  static const Color notAwarded = Color(0xFFE53935);

  static Color colorFor(
    BuildContext context,
    String status,
    double progress,
  ) {
    final String normalized = status.trim().toUpperCase();
    if (normalized == 'NOT AWARDED') {
      return notAwarded;
    }
    if (normalized == 'NOT STARTED') {
      return notStarted;
    }
    if (progress >= 100 || normalized == 'COMPLETED') {
      return completed;
    }
    if (progress >= 90) {
      return almostCompleted;
    }
    if (normalized.contains('PROGRESS')) {
      return inProgress;
    }
    return Theme.of(context).colorScheme.outline;
  }

  static String legendLabel(
    BuildContext context,
    String status,
    double progress,
  ) {
    final String normalized = status.trim().toUpperCase();
    if (normalized == 'NOT AWARDED') {
      return 'Not Awarded';
    }
    if (normalized == 'NOT STARTED') {
      return 'Not Started';
    }
    if (progress >= 100 || normalized == 'COMPLETED') {
      return 'Completed (100%)';
    }
    if (progress >= 90) {
      return 'Almost Completed (90–99%)';
    }
    if (normalized.contains('PROGRESS')) {
      return 'In Progress';
    }
    return status;
  }
}

class ProgressLegendItem {
  const ProgressLegendItem({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;
}

List<ProgressLegendItem> progressLegendItems() {
  return const <ProgressLegendItem>[
    ProgressLegendItem(label: '100%', color: ProgressSegmentStyle.completed),
    ProgressLegendItem(
      label: '90–99%',
      color: ProgressSegmentStyle.almostCompleted,
    ),
    ProgressLegendItem(label: 'In progress', color: ProgressSegmentStyle.inProgress),
    ProgressLegendItem(label: 'Not started', color: ProgressSegmentStyle.notStarted),
    ProgressLegendItem(label: 'Not awarded', color: ProgressSegmentStyle.notAwarded),
  ];
}
