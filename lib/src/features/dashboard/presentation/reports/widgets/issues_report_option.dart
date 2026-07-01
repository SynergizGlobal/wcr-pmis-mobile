class IssuesReportOption {
  const IssuesReportOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  bool operator ==(Object other) {
    return other is IssuesReportOption && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

List<IssuesReportOption> dedupeIssuesReportOptions(
  Iterable<IssuesReportOption?> options,
) {
  final Map<String, IssuesReportOption> unique = <String, IssuesReportOption>{};
  for (final IssuesReportOption? option in options) {
    if (option == null || option.value.isEmpty) {
      continue;
    }
    unique.putIfAbsent(option.value, () => option);
  }
  final List<IssuesReportOption> sorted = unique.values.toList()
    ..sort(
      (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
    );
  return sorted;
}

IssuesReportOption? hodOptionFromRow(Map<String, dynamic> row) {
  final String id = _string(row['hod_user_id_fk']);
  if (id.isEmpty) {
    return null;
  }
  final String name = _string(row['hod_name']).isNotEmpty
      ? _string(row['hod_name'])
      : _string(row['user_name']);
  final String designation = _string(row['designation']).isNotEmpty
      ? _string(row['designation'])
      : _string(row['hod_designation']);
  final String label = name.isEmpty
      ? id
      : designation.isEmpty
          ? name
          : '$name - $designation';
  return IssuesReportOption(value: id, label: label);
}

IssuesReportOption? contractOptionFromRow(Map<String, dynamic> row) {
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
  return IssuesReportOption(value: id, label: label);
}

IssuesReportOption? statusOptionFromRow(Map<String, dynamic> row) {
  final String value = _string(row['status_fk']).isNotEmpty
      ? _string(row['status_fk'])
      : _string(row['status']);
  if (value.isEmpty) {
    return null;
  }
  return IssuesReportOption(value: value, label: value);
}

IssuesReportOption? locationOptionFromRow(Map<String, dynamic> row) {
  final String value = _string(row['location']);
  if (value.isEmpty) {
    return null;
  }
  return IssuesReportOption(value: value, label: value);
}

IssuesReportOption? categoryOptionFromRow(Map<String, dynamic> row) {
  final String value = _string(row['category_fk']).isNotEmpty
      ? _string(row['category_fk'])
      : _string(row['category']);
  if (value.isEmpty) {
    return null;
  }
  return IssuesReportOption(value: value, label: value);
}

IssuesReportOption? titleOptionFromRow(Map<String, dynamic> row) {
  final String id = _string(row['issue_id']);
  if (id.isEmpty) {
    return null;
  }
  final String title = _string(row['title']);
  final String label = title.isEmpty ? id : title;
  return IssuesReportOption(value: id, label: label);
}

List<IssuesReportOption> ensureIssuesReportOptionInList(
  IssuesReportOption? selected,
  List<IssuesReportOption> options,
) {
  if (selected == null) {
    return options;
  }
  final bool hasSelected = options.any(
    (IssuesReportOption option) => option.value == selected.value,
  );
  if (hasSelected) {
    return options;
  }
  return <IssuesReportOption>[selected, ...options];
}

IssuesReportOption? keepIssuesReportOption(
  IssuesReportOption? selected,
  List<IssuesReportOption> options,
) {
  if (selected == null) {
    return null;
  }
  for (final IssuesReportOption option in options) {
    if (option.value == selected.value) {
      return option;
    }
  }
  return null;
}

String _string(dynamic value) => value?.toString().trim() ?? '';
