/// Project / contract dropdown option from WCR filter APIs.
class FilterOption {
  const FilterOption({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  bool get isEmpty => id.trim().isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterOption && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'FilterOption(id: $id, name: $name)';

  /// Parses `{projectId, projectName}` / `{contractId, contractName}` lists
  /// (also accepts plain strings and legacy `id`/`name` maps).
  static List<FilterOption> parseList(
    dynamic data, {
    required bool isProject,
  }) {
    if (data is! List) {
      return const <FilterOption>[];
    }

    final List<FilterOption> options = <FilterOption>[];
    final Set<String> seenIds = <String>{};

    for (final dynamic entry in data) {
      if (entry is String) {
        final String name = entry.trim();
        if (name.isEmpty || !seenIds.add(name)) continue;
        options.add(FilterOption(id: name, name: name));
        continue;
      }
      if (entry is! Map) continue;

      final Map map = entry;
      final String id = (isProject
                  ? (map['projectId'] ?? map['id'] ?? map['value'])
                  : (map['contractId'] ?? map['id'] ?? map['value']))
              ?.toString()
              .trim() ??
          '';
      final String name = (isProject
                  ? (map['projectName'] ??
                      map['project'] ??
                      map['name'] ??
                      map['label'])
                  : (map['contractName'] ??
                      map['contract'] ??
                      map['name'] ??
                      map['label']))
              ?.toString()
              .trim() ??
          '';

      if (id.isEmpty && name.isEmpty) continue;
      final String resolvedId = id.isNotEmpty ? id : name;
      final String resolvedName = name.isNotEmpty ? name : id;
      if (!seenIds.add(resolvedId)) continue;
      options.add(FilterOption(id: resolvedId, name: resolvedName));
    }

    options.sort(
      (FilterOption a, FilterOption b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return options;
  }

  static List<FilterOption> uniqueFromPairs(
    Iterable<(String? id, String? name)> pairs,
  ) {
    final Map<String, FilterOption> byId = <String, FilterOption>{};
    for (final (String? id, String? name) in pairs) {
      final String rawId = (id ?? '').trim();
      final String rawName = (name ?? '').trim();
      final String resolvedId = rawId.isNotEmpty
          ? rawId
          : (_isPlaceholder(rawName) ? '' : rawName);
      if (resolvedId.isEmpty || _isPlaceholder(resolvedId)) continue;

      final String resolvedName =
          (!_isPlaceholder(rawName) && rawName.isNotEmpty)
              ? rawName
              : resolvedId;

      final FilterOption? existing = byId[resolvedId];
      if (existing == null ||
          _isPlaceholder(existing.name) ||
          (existing.name == existing.id &&
              resolvedName != resolvedId &&
              !_isPlaceholder(resolvedName))) {
        byId[resolvedId] = FilterOption(id: resolvedId, name: resolvedName);
      }
    }
    final List<FilterOption> list = byId.values.toList()
      ..sort(
        (FilterOption a, FilterOption b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    return list;
  }

  static bool _isPlaceholder(String value) {
    final String lower = value.trim().toLowerCase();
    return lower.isEmpty ||
        lower == 'n/a' ||
        lower == 'na' ||
        lower == 'null' ||
        lower == 'undefined' ||
        lower == '-';
  }

  /// Keeps options whose ids appear in [allowedIds], filling gaps from [fallback].
  static List<FilterOption> intersectByIds({
    required List<FilterOption> apiOptions,
    required Set<String> allowedIds,
    List<FilterOption> fallback = const <FilterOption>[],
  }) {
    if (allowedIds.isEmpty) return const <FilterOption>[];

    final Map<String, FilterOption> byId = <String, FilterOption>{};
    for (final FilterOption option in apiOptions) {
      if (!allowedIds.contains(option.id)) continue;
      if (_isPlaceholder(option.name) && option.name == option.id) continue;
      byId[option.id] = option;
    }
    for (final FilterOption option in fallback) {
      if (!allowedIds.contains(option.id)) continue;
      final FilterOption? existing = byId[option.id];
      if (existing == null ||
          _isPlaceholder(existing.name) ||
          existing.name == existing.id) {
        byId[option.id] = option;
      }
    }
    for (final String id in allowedIds) {
      byId.putIfAbsent(id, () => FilterOption(id: id, name: id));
    }

    final List<FilterOption> list = byId.values.toList()
      ..sort(
        (FilterOption a, FilterOption b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    return list;
  }
}
