import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_dropdown_item.dart';

abstract final class RfiDropdownMapper {
  static List<RfiDropdownItem> fromList(dynamic data) {
    if (data == null) {
      return const <RfiDropdownItem>[];
    }

    // Plain map of id -> name (no nested list).
    if (data is Map && !_looksLikeWrappedList(data)) {
      final List<RfiDropdownItem> fromEntries = <RfiDropdownItem>[];
      data.forEach((dynamic key, dynamic value) {
        if (value is Map) {
          fromEntries.add(fromJson(Map<String, dynamic>.from(value)));
          return;
        }
        final String id = key.toString().trim();
        final String name = value?.toString().trim() ?? '';
        if (id.isEmpty && name.isEmpty) {
          return;
        }
        fromEntries.add(
          RfiDropdownItem(
            id: id.isNotEmpty ? id : name,
            name: name.isNotEmpty ? name : id,
          ),
        );
      });
      return dedupeById(
        fromEntries
            .where((RfiDropdownItem item) => item.name.isNotEmpty)
            .toList(),
      );
    }

    final List<dynamic>? list = _asList(data);
    if (list == null || list.isEmpty) {
      return const <RfiDropdownItem>[];
    }

    final List<RfiDropdownItem> mapped;
    if (list.first is String || list.first is num) {
      mapped = list
          .map(
            (dynamic value) => RfiDropdownItem(
              id: value.toString(),
              name: value.toString(),
            ),
          )
          .toList();
    } else {
      mapped = list
          .whereType<Map>()
          .map(
            (Map<dynamic, dynamic> row) =>
                fromJson(Map<String, dynamic>.from(row)),
          )
          .where((RfiDropdownItem item) => item.name.isNotEmpty)
          .toList();
    }
    return dedupeById(mapped);
  }

  static bool _looksLikeWrappedList(Map<dynamic, dynamic> data) {
    for (final String key in <String>[
      'data',
      'content',
      'users',
      'result',
      'items',
      'list',
    ]) {
      if (data[key] is List) {
        return true;
      }
    }
    return false;
  }

  static List<dynamic>? _asList(dynamic data) {
    if (data is List) {
      return data;
    }
    if (data is Map) {
      for (final String key in <String>[
        'data',
        'content',
        'users',
        'result',
        'items',
        'list',
      ]) {
        final dynamic nested = data[key];
        if (nested is List) {
          return nested;
        }
      }
    }
    return null;
  }

  static List<RfiDropdownItem> dedupeById(List<RfiDropdownItem> items) {
    final Map<String, RfiDropdownItem> unique = <String, RfiDropdownItem>{};
    for (final RfiDropdownItem item in items) {
      unique.putIfAbsent(item.id, () => item);
    }
    return unique.values.toList();
  }

  static RfiDropdownItem fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['id'] ??
        json['userId'] ??
        json['user_id'] ??
        json['value'] ??
        json['projectId'] ??
        json['workId'] ??
        json['contractIdFk'] ??
        json['contractId'] ??
        json['structureTypeId'] ??
        json['structureId'] ??
        json['componentId'] ??
        json['elementId'] ??
        json['activityId'] ??
        json['rfiDescription'] ??
        json['username'] ??
        json['login'] ??
        json['emailId'] ??
        json['email'] ??
        '';

    final dynamic nameValue = json['name'] ??
        json['userName'] ??
        json['user_name'] ??
        json['fullName'] ??
        json['fullname'] ??
        json['displayName'] ??
        json['text'] ??
        json['label'] ??
        json['title'] ??
        json['projectName'] ??
        json['workName'] ??
        json['contractShortName'] ??
        json['contractName'] ??
        json['structureType'] ??
        json['structure'] ??
        json['component'] ??
        json['element'] ??
        json['activity'] ??
        json['rfiDescription'] ??
        json['username'] ??
        json['login'] ??
        _combinedPersonName(json) ??
        json['emailId'] ??
        json['email'] ??
        json['value'] ??
        '';

    final List<String> enclosures = <String>[];
    final dynamic rawEnclosures = json['enclosures'];
    if (rawEnclosures is List) {
      for (final dynamic entry in rawEnclosures) {
        final String value = entry.toString().trim();
        if (value.isNotEmpty) {
          enclosures.add(value);
        }
      }
    }

    int? p6ActivityIdFk;
    final dynamic rawP6 = json['p6ActivityIdFk'] ??
        json['p6ActivityId'] ??
        json['p6_activity_id_fk'];
    if (rawP6 is int) {
      p6ActivityIdFk = rawP6;
    } else if (rawP6 is num) {
      p6ActivityIdFk = rawP6.toInt();
    } else if (rawP6 != null) {
      p6ActivityIdFk = int.tryParse(rawP6.toString());
    }

    final String? pmisCalcFk =
        json['pmisCalcFk']?.toString() ?? json['pmis_calc_fk']?.toString();

    String id = idValue.toString().trim();
    String name = nameValue.toString().trim();
    if (id.isEmpty && name.isNotEmpty) {
      id = name;
    }
    if (name.isEmpty && id.isNotEmpty) {
      name = id;
    }

    return RfiDropdownItem(
      id: id,
      name: name,
      enclosures: enclosures,
      p6ActivityIdFk: p6ActivityIdFk,
      pmisCalcFk: pmisCalcFk,
      email: _nullableTrim(json['email'] ?? json['emailId']),
      dyHodUserId: _nullableTrim(json['dyHodUserId']),
      dyHodUserName: _nullableTrim(json['dyHodUserName']),
      dyHodEmail: _nullableTrim(json['dyHodEmail']),
      hodUserId: _nullableTrim(json['hodUserId']),
      hodUserName: _nullableTrim(json['hodUserName']),
      hodEmail: _nullableTrim(json['hodEmail']),
      caoUserId: _nullableTrim(json['caoUserId']),
      caoUserName: _nullableTrim(json['caoUserName']),
      caoEmail: _nullableTrim(json['caoEmail']),
    );
  }

  static String? _nullableTrim(dynamic value) {
    if (value == null) {
      return null;
    }
    final String text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String? _combinedPersonName(Map<String, dynamic> json) {
    final String first = (json['firstName'] ?? json['firstname'] ?? '')
        .toString()
        .trim();
    final String last =
        (json['lastName'] ?? json['lastname'] ?? '').toString().trim();
    final String combined = '$first $last'.trim();
    return combined.isEmpty ? null : combined;
  }
}
