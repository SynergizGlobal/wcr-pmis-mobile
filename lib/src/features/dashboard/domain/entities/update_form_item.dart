import 'dart:convert';

class UpdateFormSubItem {
  const UpdateFormSubItem({
    required this.formId,
    required this.formName,
    required this.priority,
    this.webFormUrl,
    required this.displayInMobile,
  });

  final String formId;
  final String formName;
  final int priority;
  final String? webFormUrl;
  final bool displayInMobile;

  factory UpdateFormSubItem.fromJson(Map<String, dynamic> json) {
    return UpdateFormSubItem(
      formId: json['formId']?.toString() ?? '',
      formName: json['formName']?.toString() ?? '',
      priority: int.tryParse(json['priority']?.toString() ?? '') ?? 0,
      webFormUrl: json['webFormUrl']?.toString(),
      displayInMobile: _isVisibleInMobile(json['displayInMobile']),
    );
  }
}

class UpdateFormItem {
  const UpdateFormItem({
    required this.formId,
    required this.formName,
    required this.priority,
    this.webFormUrl,
    required this.displayInMobile,
    required this.subMenus,
  });

  final String formId;
  final String formName;
  final int priority;
  final String? webFormUrl;
  final bool displayInMobile;
  final List<UpdateFormSubItem> subMenus;

  List<UpdateFormSubItem> get orderedSubMenus {
    final List<UpdateFormSubItem> ordered = List<UpdateFormSubItem>.from(subMenus)
      ..sort(
        (UpdateFormSubItem a, UpdateFormSubItem b) =>
            a.priority.compareTo(b.priority),
      );
    return ordered;
  }

  bool get hasSubMenus => orderedSubMenus.isNotEmpty;

  factory UpdateFormItem.fromJson(Map<String, dynamic> json) {
    final List<UpdateFormSubItem> parsedSubMenus = _parseSubMenus(
      json['formsSubMenu'],
    );

    return UpdateFormItem(
      formId: json['formId']?.toString() ?? '',
      formName: json['formName']?.toString() ?? '',
      priority: int.tryParse(json['priority']?.toString() ?? '') ?? 0,
      webFormUrl: json['webFormUrl']?.toString(),
      displayInMobile: _isVisibleInMobile(json['displayInMobile']),
      subMenus: parsedSubMenus,
    );
  }
}

bool _isVisibleInMobile(dynamic rawValue) {
  if (rawValue == null) {
    return false;
  }
  return rawValue.toString().trim().toLowerCase() == 'yes';
}

List<UpdateFormSubItem> _parseSubMenus(dynamic raw) {
  if (raw is! List) {
    return const <UpdateFormSubItem>[];
  }
  final List<UpdateFormSubItem> items = <UpdateFormSubItem>[];
  for (final dynamic entry in raw) {
    if (entry is Map) {
      final Map<String, dynamic> map = entry.map(
        (dynamic key, dynamic value) => MapEntry(key.toString(), value),
      );
      items.add(UpdateFormSubItem.fromJson(map));
      continue;
    }
    if (entry is String && entry.trim().isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(entry);
        if (decoded is Map) {
          final Map<String, dynamic> map = decoded.map(
            (dynamic key, dynamic value) => MapEntry(key.toString(), value),
          );
          items.add(UpdateFormSubItem.fromJson(map));
        }
      } catch (_) {
        // Ignore malformed submenu row and continue parsing remaining items.
      }
    }
  }
  return items;
}
