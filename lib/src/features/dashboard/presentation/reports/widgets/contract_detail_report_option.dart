class ContractDetailReportOption {
  const ContractDetailReportOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  bool operator ==(Object other) {
    return other is ContractDetailReportOption && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

List<ContractDetailReportOption> dedupeContractDetailReportOptions(
  Iterable<ContractDetailReportOption?> options,
) {
  final Map<String, ContractDetailReportOption> unique =
      <String, ContractDetailReportOption>{};
  for (final ContractDetailReportOption? option in options) {
    if (option == null || option.value.isEmpty) {
      continue;
    }
    unique.putIfAbsent(option.value, () => option);
  }
  final List<ContractDetailReportOption> sorted = unique.values.toList()
    ..sort(
      (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
    );
  return sorted;
}

ContractDetailReportOption? projectOptionFromRow(Map<String, dynamic> row) {
  final String id = _string(row['project_id']).isNotEmpty
      ? _string(row['project_id'])
      : _string(row['project_id_fk']);
  if (id.isEmpty) {
    return null;
  }
  final String name = _string(row['project_name']);
  final String label = name.isEmpty ? id : '$id - $name';
  return ContractDetailReportOption(value: id, label: label);
}

ContractDetailReportOption? contractOptionFromRow(Map<String, dynamic> row) {
  final String id = _string(row['contract_id']).isNotEmpty
      ? _string(row['contract_id'])
      : _string(row['contract_id_fk']);
  if (id.isEmpty) {
    return null;
  }
  final String shortName = _string(row['contract_short_name']);
  final String contractName = _string(row['contract_name']);
  final String name = shortName.isNotEmpty ? shortName : contractName;
  final String label = name.isEmpty ? id : '$id - $name';
  return ContractDetailReportOption(value: id, label: label);
}

ContractDetailReportOption? contractorOptionFromRow(Map<String, dynamic> row) {
  final String id = _string(row['contractor_id_fk']).isNotEmpty
      ? _string(row['contractor_id_fk'])
      : _string(row['contractor_id']);
  if (id.isEmpty) {
    return null;
  }
  final String name = _string(row['contractor_name']);
  final String label = name.isEmpty ? id : '$id - $name';
  return ContractDetailReportOption(value: id, label: label);
}

ContractDetailReportOption? contractStatusOptionFromRow(
  Map<String, dynamic> row,
) {
  final String value = _string(row['contract_status_fk']);
  if (value.isEmpty) {
    return null;
  }
  return ContractDetailReportOption(value: value, label: value);
}

ContractDetailReportOption? contractOpenStatusOptionFromRow(
  Map<String, dynamic> row,
) {
  final String value = _string(row['status']);
  if (value.isEmpty) {
    return null;
  }
  return ContractDetailReportOption(value: value, label: value);
}

ContractDetailReportOption? hodOptionFromRow(Map<String, dynamic> row) {
  final String designation = _string(row['designation']).isNotEmpty
      ? _string(row['designation'])
      : _string(row['hod_designation']);
  if (designation.isEmpty) {
    return null;
  }
  final String name = _string(row['user_name']).isNotEmpty
      ? _string(row['user_name'])
      : _string(row['hod_name']);
  final String label = name.isEmpty ? designation : '$designation - $name';
  return ContractDetailReportOption(value: designation, label: label);
}

List<ContractDetailReportOption> ensureContractDetailReportOptionInList(
  ContractDetailReportOption? selected,
  List<ContractDetailReportOption> options,
) {
  if (selected == null) {
    return options;
  }
  final bool hasSelected = options.any(
    (ContractDetailReportOption option) => option.value == selected.value,
  );
  if (hasSelected) {
    return options;
  }
  return <ContractDetailReportOption>[selected, ...options];
}

ContractDetailReportOption? keepContractDetailReportOption(
  ContractDetailReportOption? selected,
  List<ContractDetailReportOption> options,
) {
  if (selected == null) {
    return null;
  }
  for (final ContractDetailReportOption option in options) {
    if (option.value == selected.value) {
      return option;
    }
  }
  return null;
}

String _string(dynamic value) => value?.toString().trim() ?? '';
