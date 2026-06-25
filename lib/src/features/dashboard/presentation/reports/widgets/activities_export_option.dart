class ActivitiesExportOption {
  const ActivitiesExportOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  bool operator ==(Object other) {
    return other is ActivitiesExportOption && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

List<ActivitiesExportOption> dedupeActivitiesExportOptions(
  Iterable<ActivitiesExportOption?> options,
) {
  final Map<String, ActivitiesExportOption> unique =
      <String, ActivitiesExportOption>{};
  for (final ActivitiesExportOption? option in options) {
    if (option == null || option.value.isEmpty) {
      continue;
    }
    unique.putIfAbsent(option.value, () => option);
  }
  final List<ActivitiesExportOption> sorted = unique.values.toList()
    ..sort(
      (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
    );
  return sorted;
}

ActivitiesExportOption? projectOptionFromRow(Map<String, dynamic> row) {
  final String id = _string(row['project_id_fk']).isNotEmpty
      ? _string(row['project_id_fk'])
      : _string(row['project_id']);
  if (id.isEmpty) {
    return null;
  }
  final String name = _string(row['project_name']);
  final String label = name.isEmpty ? id : '$id - $name';
  return ActivitiesExportOption(value: id, label: label);
}

ActivitiesExportOption? contractOptionFromRow(Map<String, dynamic> row) {
  final String id = _string(row['contract_id_fk']).isNotEmpty
      ? _string(row['contract_id_fk'])
      : _string(row['contract_id']);
  if (id.isEmpty) {
    return null;
  }
  final String shortName = _string(row['contract_short_name']);
  final String contractName = _string(row['contract_name']);
  final String name = shortName.isNotEmpty ? shortName : contractName;
  final String label = name.isEmpty ? id : '$id - $name';
  return ActivitiesExportOption(value: id, label: label);
}

ActivitiesExportOption? keepActivitiesExportOption(
  ActivitiesExportOption? selected,
  List<ActivitiesExportOption> options,
) {
  if (selected == null) {
    return null;
  }
  for (final ActivitiesExportOption option in options) {
    if (option.value == selected.value) {
      return option;
    }
  }
  return null;
}

String _string(dynamic value) => value?.toString().trim() ?? '';

bool contractBelongsToProject(Map<String, dynamic> row, String projectId) {
  final String rowProjectId = _string(row['project_id']).isNotEmpty
      ? _string(row['project_id'])
      : _string(row['project_id_fk']);
  return rowProjectId.isEmpty || rowProjectId == projectId;
}
