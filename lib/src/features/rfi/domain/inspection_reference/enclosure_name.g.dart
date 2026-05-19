// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EnclosureNameImpl _$$EnclosureNameImplFromJson(Map<String, dynamic> json) =>
    _$EnclosureNameImpl(
      id: (json['id'] as num).toInt(),
      encloserName: json['encloserName'] as String,
      checkListTitle: json['checkListTitle'] as String?,
      action: json['action'] as String?,
    );

Map<String, dynamic> _$$EnclosureNameImplToJson(_$EnclosureNameImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'encloserName': instance.encloserName,
      'checkListTitle': instance.checkListTitle,
      'action': instance.action,
    };
