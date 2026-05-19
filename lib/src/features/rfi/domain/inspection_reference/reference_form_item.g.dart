// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_form_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReferenceFormItemImpl _$$ReferenceFormItemImplFromJson(
  Map<String, dynamic> json,
) => _$ReferenceFormItemImpl(
  id: (json['id'] as num).toInt(),
  activity: json['activity'] as String? ?? '',
  rfiDescription: json['rfiDescription'] as String? ?? '',
  enclosures: json['enclosures'] as String? ?? '',
);

Map<String, dynamic> _$$ReferenceFormItemImplToJson(
  _$ReferenceFormItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'activity': instance.activity,
  'rfiDescription': instance.rfiDescription,
  'enclosures': instance.enclosures,
};
