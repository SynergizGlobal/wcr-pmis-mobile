import 'dart:convert';

/// Extracts file path strings from API values (comma-separated, JSON array, etc.).
List<String> extractFilePaths(dynamic data) {
  if (data == null) return [];

  if (data is List) {
    return data.expand((item) => extractFilePaths(item)).toList();
  }

  if (data is Map) {
    if (data.containsKey('filePath')) {
      return extractFilePaths(data['filePath']);
    }
    if (data.containsKey('file')) {
      return extractFilePaths(data['file']);
    }
    if (data.containsKey('enclosureUploadFile')) {
      return extractFilePaths(data['enclosureUploadFile']);
    }
    if (data['id'] != null) {
      return ['api/rfi/view-enclosure?id=${data['id']}'];
    }
    return [];
  }

  final trimmed = data.toString().trim();
  if (trimmed.isEmpty || trimmed.contains('":')) return [];

  if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
    try {
      final decoded = jsonDecode(trimmed);
      return extractFilePaths(decoded);
    } catch (_) {
      return [];
    }
  }

  return trimmed
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}
