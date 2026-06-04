class SitePhotoRow {
  const SitePhotoRow({
    required this.section,
    required this.structureType,
    required this.structure,
    required this.structureComponent,
    required this.componentId,
    required this.photosCount,
    required this.photos,
  });

  final String section;
  final String structureType;
  final String structure;
  final String structureComponent;
  final String componentId;
  final int photosCount;
  final List<String> photos;

  bool get hasPhotos => photos.isNotEmpty && photosCount > 0;

  factory SitePhotoRow.fromMap(Map<String, dynamic> map) {
    final List<String> photos = _parsePhotos(map['photos']);
    final int photosCount = _parsePhotosCount(map['photos_count'], photos.length);
    return SitePhotoRow(
      section: _display(map['section']),
      structureType: _display(map['structure_type']),
      structure: _display(map['structure']),
      structureComponent: _display(map['strip_chart_component']),
      componentId: _display(map['strip_chart_component_id']),
      photosCount: photosCount,
      photos: photos,
    );
  }

  static List<String> _parsePhotos(dynamic value) {
    if (value is! List<dynamic>) {
      return <String>[];
    }
    return value
        .map((dynamic item) => item?.toString().trim() ?? '')
        .where((String name) => name.isNotEmpty)
        .toList();
  }

  static int _parsePhotosCount(dynamic value, int fallback) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    final String text = value?.toString().trim() ?? '';
    if (text.isEmpty) {
      return fallback;
    }
    return int.tryParse(text) ?? fallback;
  }

  static String _display(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? '—' : text;
  }
}
