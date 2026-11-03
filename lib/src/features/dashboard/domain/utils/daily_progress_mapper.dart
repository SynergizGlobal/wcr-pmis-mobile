import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/daily_progress.dart';

class DailyProgressMapper {
  const DailyProgressMapper._();

  static List<DailyProgressGroup> groupRows(List<Map<String, dynamic>> rows) {
    final Map<String, List<Map<String, dynamic>>> grouped =
        <String, List<Map<String, dynamic>>>{};

    for (final Map<String, dynamic> row in rows) {
      final String section = sectionFromRow(row, fallback: '—');
      final String activity = structureTypeFromRow(row, fallback: '—');
      final String key = '$section|$activity';
      grouped.putIfAbsent(key, () => <Map<String, dynamic>>[]).add(row);
    }

    final List<DailyProgressGroup> groups = grouped.entries.map((
      MapEntry<String, List<Map<String, dynamic>>> entry,
    ) {
      final List<Map<String, dynamic>> groupRows = entry.value;
      final Map<String, dynamic> first = groupRows.first;
      final String section = sectionFromRow(first, fallback: '—');
      final String activity = structureTypeFromRow(first, fallback: '—');

      double scopeSum = 0;
      double completedSum = 0;
      double progressSum = 0;
      double askingRateSum = 0;
      bool hasAskingRate = false;
      final Set<String> units = <String>{};

      final List<DailyProgressStructureRow> structures =
          groupRows.map((Map<String, dynamic> row) {
            final double scope = _toDouble(row['scope']);
            final double actualTill = _toDouble(row['actual_till_date']);
            final double actualForDay = _toDouble(
              row['actual_for_day'] ?? row['actual_for_the_day'],
            );
            final String unit = _string(row['unit'], fallback: '—');
            units.add(unit);
            scopeSum += scope;
            completedSum += actualTill;
            progressSum += actualForDay;
            final double? askingRate = _toNullableDouble(
              row['asking_rate_per_day'] ?? row['asking_rate'],
            );
            if (askingRate != null) {
              askingRateSum += askingRate;
              hasAskingRate = true;
            }
            return DailyProgressStructureRow(
              structure: _string(row['structure'], fallback: '—'),
              unit: unit,
              scope: scope,
              plannedTillDate: _toDouble(row['planned_till_date']),
              actualTillDate: actualTill,
              askingRatePerDay: askingRate,
              actualForDay: actualForDay,
              cumulativeActual: _toDouble(row['cumulative_actual']),
              mpDeployment: _displayValue(row['mp_deployment']),
              manpowerDeployment: _displayValue(row['manpower_deployment']),
              tdc: _formatTdc(row['tdc']),
            );
          }).toList()
            ..sort(
              (DailyProgressStructureRow a, DailyProgressStructureRow b) =>
                  a.structure.compareTo(b.structure),
            );

      final String groupUnit = units.length == 1
          ? units.first
          : _string(first['unit'], fallback: '—');

      return DailyProgressGroup(
        section: section,
        activity: activity,
        unit: groupUnit,
        structureCount: structures.length,
        scope: scopeSum,
        completedQty: completedSum,
        balance: scopeSum - completedSum,
        askingRatePerDay: hasAskingRate ? askingRateSum : null,
        progressOnDate: progressSum,
        tdc: _latestTdc(groupRows),
        structures: structures,
      );
    }).toList();

    groups.sort((DailyProgressGroup a, DailyProgressGroup b) {
      final int activityCompare = a.activity.compareTo(b.activity);
      if (activityCompare != 0) {
        return activityCompare;
      }
      return a.section.compareTo(b.section);
    });
    return groups;
  }

  static List<DailyProgressActivityGroup> groupByActivity(
    List<Map<String, dynamic>> rows,
  ) {
    final List<DailyProgressGroup> sectionGroups = groupRows(rows);
    final Map<String, List<DailyProgressGroup>> byActivity =
        <String, List<DailyProgressGroup>>{};

    for (final DailyProgressGroup group in sectionGroups) {
      byActivity
          .putIfAbsent(group.activity, () => <DailyProgressGroup>[])
          .add(group);
    }

    final List<DailyProgressActivityGroup> activities =
        byActivity.entries.map((
      MapEntry<String, List<DailyProgressGroup>> entry,
    ) {
      final List<DailyProgressGroup> sections = entry.value
        ..sort(
          (DailyProgressGroup a, DailyProgressGroup b) =>
              a.section.compareTo(b.section),
        );

      double scopeSum = 0;
      double completedSum = 0;
      double balanceSum = 0;
      double progressSum = 0;
      double askingRateSum = 0;
      bool hasAskingRate = false;
      int structureCount = 0;
      final Set<String> units = <String>{};
      String tdc = '—';
      DateTime? latestTdc;

      for (final DailyProgressGroup section in sections) {
        scopeSum += section.scope;
        completedSum += section.completedQty;
        balanceSum += section.balance;
        progressSum += section.progressOnDate;
        structureCount += section.structureCount;
        units.add(section.unit);
        if (section.askingRatePerDay != null) {
          askingRateSum += section.askingRatePerDay!;
          hasAskingRate = true;
        }
        final DateTime? parsed = _parseTdcDateFromDisplay(section.tdc);
        if (parsed != null &&
            (latestTdc == null || parsed.isAfter(latestTdc))) {
          latestTdc = parsed;
          tdc = section.tdc;
        }
      }

      final String unit = units.length == 1 ? units.first : '—';

      return DailyProgressActivityGroup(
        activity: entry.key,
        unit: unit,
        structureCount: structureCount,
        scope: scopeSum,
        completedQty: completedSum,
        balance: balanceSum,
        askingRatePerDay: hasAskingRate ? askingRateSum : null,
        progressOnDate: progressSum,
        tdc: tdc,
        sections: sections,
      );
    }).toList()
          ..sort(
            (DailyProgressActivityGroup a, DailyProgressActivityGroup b) =>
                a.activity.compareTo(b.activity),
          );

    return activities;
  }

  static DateTime? _parseTdcDateFromDisplay(String value) {
    if (value == '—') {
      return null;
    }
    return _parseTdcDate(value);
  }

  static String sectionFromRow(
    Map<String, dynamic> row, {
    String fallback = '',
  }) {
    return _string(
      row['section'] ?? row['section_name'] ?? row['sections'],
      fallback: fallback,
    );
  }

  static String structureTypeFromRow(
    Map<String, dynamic> row, {
    String fallback = '',
  }) {
    return _string(
      row['structure_type_new'] ??
          row['structure_type'] ??
          row['activity'],
      fallback: fallback,
    );
  }

  static List<String> uniqueSections(List<Map<String, dynamic>> rows) {
    final Set<String> values = <String>{};
    for (final Map<String, dynamic> row in rows) {
      final String section = sectionFromRow(row);
      if (section.isNotEmpty && section != '—') {
        values.add(section);
      }
    }
    final List<String> sorted = values.toList()..sort();
    return sorted;
  }

  static List<String> uniqueActivities(List<Map<String, dynamic>> rows) {
    final Set<String> values = <String>{};
    for (final Map<String, dynamic> row in rows) {
      final String activity = structureTypeFromRow(row);
      if (activity.isNotEmpty && activity != '—') {
        values.add(activity);
      }
    }
    final List<String> sorted = values.toList()..sort();
    return sorted;
  }

  static String _string(dynamic value, {String fallback = ''}) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString().replaceAll(',', '')) ?? 0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    final String text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }
    return double.tryParse(text.replaceAll(',', ''));
  }

  static String _displayValue(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? '—' : text;
  }

  static String _formatTdc(dynamic value) {
    if (value is List && value.length >= 3) {
      final int year = _toInt(value[0]);
      final int month = _toInt(value[1]);
      final int day = _toInt(value[2]);
      if (year > 0 && month > 0 && day > 0) {
        return '${day.toString().padLeft(2, '0')}-'
            '${month.toString().padLeft(2, '0')}-'
            '$year';
      }
    }
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? '—' : text;
  }

  static String _latestTdc(List<Map<String, dynamic>> rows) {
    DateTime? latest;
    for (final Map<String, dynamic> row in rows) {
      final DateTime? parsed = _parseTdcDate(row['tdc']);
      if (parsed == null) {
        continue;
      }
      if (latest == null || parsed.isAfter(latest)) {
        latest = parsed;
      }
    }
    if (latest == null) {
      return '—';
    }
    return '${latest.day.toString().padLeft(2, '0')}-'
        '${latest.month.toString().padLeft(2, '0')}-'
        '${latest.year}';
  }

  static DateTime? _parseTdcDate(dynamic value) {
    if (value is List && value.length >= 3) {
      final int year = _toInt(value[0]);
      final int month = _toInt(value[1]);
      final int day = _toInt(value[2]);
      if (year > 0 && month > 0 && day > 0) {
        return DateTime(year, month, day);
      }
    }
    final String text = value?.toString().trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    final RegExpMatch? match = RegExp(
      r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})$',
    ).firstMatch(text);
    if (match != null) {
      return DateTime(
        int.parse(match.group(3)!),
        int.parse(match.group(2)!),
        int.parse(match.group(1)!),
      );
    }
    return null;
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
