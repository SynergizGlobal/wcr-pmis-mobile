/// Builds RFI Log PDF download paths for [Dio] (relative to RFI base URL).
abstract final class RfiLogPdfPaths {
  /// Picks the best human-readable RFI id from a log list row (display as API returns).
  static String readRfiIdFromJson(Map<dynamic, dynamic> json) {
    final List<dynamic> candidates = <dynamic>[
      json['stringRfiId'],
      json['rfi_Id'],
      json['rfiId'],
    ];
    for (final dynamic candidate in candidates) {
      final String? value = candidate?.toString().trim();
      if (value != null && value.isNotEmpty && value != 'N/A') {
        return value;
      }
    }
    return 'N/A';
  }

  /// Server PDF endpoint expects underscores (web: `MJB_105_1_A1_...`).
  /// API often returns slashes from structure ids (`MJB_105/1_A1_...`).
  static String downloadRfiId(String rfiId) => normalizeRfiId(rfiId);

  /// Web uses underscore-separated ids; API rows may include `/` from structure.
  static String normalizeRfiId(String rfiId) {
    return rfiId.trim().replaceAll('\\', '/').replaceAll('/', '_');
  }

  static String _sanitizeRawRfiId(String rfiId) {
    return rfiId.trim().replaceAll('\\', '/');
  }

  /// Ordered paths to try: web-style underscores first, then raw API id encoded.
  static List<String> downloadPathCandidates({
    required String rfiId,
    required String txnId,
  }) {
    final String raw = _sanitizeRawRfiId(rfiId);
    final String normalized = normalizeRfiId(raw);
    final String txn = txnId.trim();

    final List<String> paths = <String>[
      _downloadPathForIds(normalized, txn),
    ];
    if (normalized != raw) {
      paths.add(_downloadPathForIds(raw, txn));
    }
    return paths;
  }

  /// Primary download path (web-style, underscore id).
  static String downloadPath({
    required String rfiId,
    required String txnId,
  }) {
    return downloadPathCandidates(rfiId: rfiId, txnId: txnId).first;
  }

  static String _downloadPathForIds(String rfiId, String txnId) {
    return <String>[
      'api',
      'rfiLog',
      'pdf',
      'download',
      Uri.encodeComponent(rfiId),
      Uri.encodeComponent(txnId),
    ].join('/');
  }
}
