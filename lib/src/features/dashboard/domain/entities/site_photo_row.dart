import 'package:intl/intl.dart';

class SitePhotoRow {
  const SitePhotoRow({
    required this.section,
    required this.structureType,
    required this.structure,
    required this.structureComponent,
    required this.componentId,
    required this.photosCount,
    required this.photos,
    required this.createdAt,
  });

  final String section;
  final String structureType;
  final String structure;
  final String structureComponent;
  final String componentId;
  final int photosCount;
  final List<String> photos;
  final DateTime? createdAt;

  bool get hasPhotos => photos.isNotEmpty && photosCount > 0;

  String get displayDate {
    final DateTime? created = createdAt;
    if (created == null) {
      return '—';
    }
    return DateFormat('dd-MM-yyyy').format(created);
  }

  String get sectionFilterValue => _filterValue(section);

  String get structureTypeFilterValue => _filterValue(structureType);

  String get structureFilterValue => _filterValue(structure);

  String get structureComponentFilterValue => _filterValue(structureComponent);

  String get componentIdFilterValue => _filterValue(componentId);

  factory SitePhotoRow.fromMap(Map<String, dynamic> map) {
    final List<String> photos = _parsePhotos(map['photos']);
    final int photosCount = _parsePhotosCount(map['photos_count'], photos.length);
    return SitePhotoRow(
      section: _displaySection(map),
      structureType: _display(map['structure_type']),
      structure: _display(map['structure']),
      structureComponent: _display(map['strip_chart_component']),
      componentId: _display(map['strip_chart_component_id']),
      photosCount: photosCount,
      photos: photos,
      createdAt: _parseCreatedDate(map['created_date']),
    );
  }

  static String _filterValue(String display) {
    final String trimmed = display.trim();
    if (trimmed.isEmpty || trimmed == '—') {
      return '';
    }
    return trimmed;
  }

  static String _displaySection(Map<String, dynamic> map) {
    for (final String key in <String>[
      'section',
      'strip_chart_section_name',
      'section_name',
    ]) {
      final dynamic value = map[key];
      final String text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '—';
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
    if (text.isEmpty) {
      return '—';
    }
    final String lower = text.toLowerCase();
    if (lower == 'undefined' || lower == 'null') {
      return '—';
    }
    return text;
  }

  static DateTime? _parseCreatedDate(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    final DateTime? direct = DateTime.tryParse(text);
    if (direct != null) {
      return direct;
    }
    final String withoutFraction = text.split('.').first;
    final String isoLike = withoutFraction.contains(' ')
        ? withoutFraction.replaceFirst(' ', 'T')
        : withoutFraction;
    return DateTime.tryParse(isoLike);
  }
}
