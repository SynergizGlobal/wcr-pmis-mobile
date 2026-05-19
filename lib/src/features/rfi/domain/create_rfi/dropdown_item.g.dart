// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dropdown_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DropdownItemImpl _$$DropdownItemImplFromJson(Map<String, dynamic> json) =>
    _$DropdownItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      enclosures: (json['enclosures'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      p6ActivityIdFk: (json['p6ActivityIdFk'] as num?)?.toInt(),
      pmisCalcFk: json['pmisCalcFk'] as String?,
    );

Map<String, dynamic> _$$DropdownItemImplToJson(_$DropdownItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'enclosures': instance.enclosures,
      'p6ActivityIdFk': instance.p6ActivityIdFk,
      'pmisCalcFk': instance.pmisCalcFk,
    };
