import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_dropdown_item.dart';

abstract final class RfiDropdownMapper {
  static List<RfiDropdownItem> fromList(dynamic data) {
    if (data is! List || data.isEmpty) {
      return const <RfiDropdownItem>[];
    }
    final List<RfiDropdownItem> mapped;
    if (data.first is String) {
      mapped = data
          .map(
            (dynamic value) => RfiDropdownItem(
              id: value.toString(),
              name: value.toString(),
            ),
          )
          .toList();
    } else {
      mapped = data
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
        '';

    final dynamic nameValue = json['name'] ??
        json['userName'] ??
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
    final String name = nameValue.toString().trim();
    if (id.isEmpty && name.isNotEmpty) {
      id = name;
    }

    return RfiDropdownItem(
      id: id,
      name: name,
      enclosures: enclosures,
      p6ActivityIdFk: p6ActivityIdFk,
      pmisCalcFk: pmisCalcFk,
    );
  }
}
