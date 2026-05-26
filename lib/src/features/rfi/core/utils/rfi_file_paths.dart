import 'dart:convert';

class SupportingDocumentEntry {
  const SupportingDocumentEntry({
    required this.filePath,
    this.documentsDescription = '',
  });

  final String filePath;
  final String documentsDescription;

  String get sectionTitle {
    final desc = documentsDescription.trim();
    if (desc.isEmpty) {
      return 'Supporting document - doc';
    }
    return 'Supporting document - $desc - doc';
  }
}

List<SupportingDocumentEntry> extractSupportingDocuments(dynamic data) {
  if (data == null) return [];

  if (data is List) {
    return data.expand((item) => extractSupportingDocuments(item)).toList();
  }

  if (data is Map) {
    final path = (data['filePath'] ?? data['file'] ?? '').toString().trim();
    if (path.isEmpty) return [];
    return [
      SupportingDocumentEntry(
        filePath: path,
        documentsDescription: (data['documentsDescription'] ?? '').toString(),
      ),
    ];
  }

  final trimmed = data.toString().trim();
  if (trimmed.isEmpty) return [];

  if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
    try {
      return extractSupportingDocuments(jsonDecode(trimmed));
    } catch (_) {
      return [];
    }
  }

  return trimmed
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .map((path) => SupportingDocumentEntry(filePath: path))
      .toList();
}

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
  if (trimmed.isEmpty) return [];

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
