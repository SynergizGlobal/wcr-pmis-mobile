import 'dart:convert';

import '../../domain/inspection/inspection_item.dart';

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

/// Supporting files uploaded by contractor on a prior inspection (CON detail).
List<SupportingDocumentEntry> extractContractorSupportingFromInspectionDetails(
  List<InspectionDetail>? details,
) {
  if (details == null || details.isEmpty) return [];

  final merged = <SupportingDocumentEntry>[];
  final seenPaths = <String>{};

  for (final detail in details) {
    if (detail.uploadedBy?.trim().toUpperCase() != 'CON') continue;

    final paths = extractSupportingDocuments(detail.supportingDocuments);
    if (paths.isEmpty) continue;

    final descriptions =
        parseSupportingDescriptionList(detail.documentsDescription);

    for (var i = 0; i < paths.length; i++) {
      final path = paths[i].filePath.trim();
      if (path.isEmpty || !seenPaths.add(path)) continue;
      merged.add(
        SupportingDocumentEntry(
          filePath: path,
          documentsDescription: i < descriptions.length
              ? descriptions[i]
              : paths[i].documentsDescription,
        ),
      );
    }
  }
  return merged;
}

List<String> parseSupportingDescriptionList(dynamic data) {
  if (data == null) return [];

  if (data is List) {
    return data
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  final trimmed = data.toString().trim();
  if (trimmed.isEmpty) return [];

  if (trimmed.startsWith('[')) {
    try {
      return parseSupportingDescriptionList(jsonDecode(trimmed));
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
