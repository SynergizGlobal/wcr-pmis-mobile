// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validation_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ValidationItemImpl _$$ValidationItemImplFromJson(Map<String, dynamic> json) =>
    _$ValidationItemImpl(
      stringRfiId: json['stringRfiId'] as String,
      longRfiId: (json['longRfiId'] as num).toInt(),
      longRfiValidateId: (json['longRfiValidateId'] as num).toInt(),
      status: json['status'] as String?,
      remarks: json['remarks'] as String?,
      valdationAuth: json['valdationAuth'] as String?,
      comment: json['comment'] as String?,
      txnId: json['txnId'] as String?,
    );

Map<String, dynamic> _$$ValidationItemImplToJson(
  _$ValidationItemImpl instance,
) => <String, dynamic>{
  'stringRfiId': instance.stringRfiId,
  'longRfiId': instance.longRfiId,
  'longRfiValidateId': instance.longRfiValidateId,
  'status': instance.status,
  'remarks': instance.remarks,
  'valdationAuth': instance.valdationAuth,
  'comment': instance.comment,
  'txnId': instance.txnId,
};
