import 'package:intl/intl.dart';

class ProgressTableContractOption {
  const ProgressTableContractOption({
    required this.contractId,
    required this.label,
  });

  final String contractId;
  final String label;
}

class ProgressTableStructureRow {
  const ProgressTableStructureRow({
    required this.structureType,
    required this.unit,
    required this.scope,
    required this.progress,
    required this.tdc,
  });

  final String structureType;
  final String unit;
  final String scope;
  final String progress;
  final String tdc;

  factory ProgressTableStructureRow.fromMap(Map<String, dynamic> row) {
    return ProgressTableStructureRow(
      structureType: ProgressTableMapper.stringValue(
        row['structure_type_new'] ?? row['structure_type'],
      ),
      unit: ProgressTableMapper.stringValue(
        row['str_type_unit'] ?? row['unit'],
      ),
      scope: ProgressTableMapper.formatNumber(
        row['str_type_scope'] ?? row['scope'],
      ),
      progress: ProgressTableMapper.formatNumber(
        row['str_type_progress'] ?? row['completed'],
        emptyAsZero: true,
      ),
      tdc: ProgressTableMapper.formatTdc(
        row['baseline_finish'] ?? row['expected_finish'],
      ),
    );
  }
}

class ProgressTableSection {
  const ProgressTableSection({
    required this.section,
    required this.rows,
  });

  final String section;
  final List<ProgressTableStructureRow> rows;
}

class ProgressTableMapper {
  const ProgressTableMapper._();

  static final NumberFormat _numberFormat = NumberFormat('#,##0.##');
  static final DateFormat _tdcFormat = DateFormat('dd-MM-yyyy');

  static List<ProgressTableContractOption> contractsFromRows(
    List<Map<String, dynamic>> rows,
  ) {
    final Map<String, String> unique = <String, String>{};
    for (final Map<String, dynamic> row in rows) {
      final String contractId = stringValue(row['contract_id']);
      if (contractId.isEmpty) {
        continue;
      }
      unique[contractId] = stringValue(
        row['contract_short_name'] ?? row['contract_name'] ?? contractId,
      );
    }
    return unique.entries
        .map(
          (MapEntry<String, String> entry) => ProgressTableContractOption(
            contractId: entry.key,
            label: entry.value,
          ),
        )
        .toList()
      ..sort(
        (ProgressTableContractOption a, ProgressTableContractOption b) =>
            a.label.toLowerCase().compareTo(b.label.toLowerCase()),
      );
  }

  static List<ProgressTableSection> sectionsFromRows({
    required List<Map<String, dynamic>> rows,
    String? contractId,
  }) {
    final Iterable<Map<String, dynamic>> filtered = contractId == null
        ? rows
        : rows.where(
            (Map<String, dynamic> row) =>
                stringValue(row['contract_id']) == contractId,
          );

    final Map<String, Map<String, Map<String, dynamic>>> grouped =
        <String, Map<String, Map<String, dynamic>>>{};
    for (final Map<String, dynamic> row in filtered) {
      final String section = stringValue(row['section']).isEmpty
          ? '—'
          : stringValue(row['section']);
      final String structureType = stringValue(
        row['structure_type_new'] ?? row['structure_type'],
      ).isEmpty
          ? '—'
          : stringValue(row['structure_type_new'] ?? row['structure_type']);
      grouped.putIfAbsent(section, () => <String, Map<String, dynamic>>{});
      grouped[section]!.putIfAbsent(structureType, () => row);
    }

    final List<String> sectionKeys = grouped.keys.toList()..sort();
    return sectionKeys
        .map((String sectionKey) {
          final Map<String, Map<String, dynamic>> types = grouped[sectionKey]!;
          final List<String> typeKeys = types.keys.toList()..sort();
          return ProgressTableSection(
            section: sectionKey,
            rows: typeKeys
                .map(
                  (String typeKey) =>
                      ProgressTableStructureRow.fromMap(types[typeKey]!),
                )
                .toList(),
          );
        })
        .toList();
  }

  static String stringValue(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }

  static String formatNumber(
    dynamic value, {
    bool emptyAsZero = false,
  }) {
    if (value == null || value.toString().trim().isEmpty) {
      return emptyAsZero ? '0' : '—';
    }
    final double? parsed = double.tryParse(value.toString());
    if (parsed == null) {
      return value.toString();
    }
    return _numberFormat.format(parsed);
  }

  static String formatTdc(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return '—';
    }
    final int? millis = int.tryParse(value.toString());
    if (millis == null) {
      return value.toString();
    }
    return _tdcFormat.format(DateTime.fromMillisecondsSinceEpoch(millis));
  }
}
