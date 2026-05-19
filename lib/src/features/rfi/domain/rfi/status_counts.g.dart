// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_counts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StatusCountsImpl _$$StatusCountsImplFromJson(Map<String, dynamic> json) =>
    _$StatusCountsImpl(
      inspectedByCon: (json['INSPECTED_BY_CON'] as num?)?.toInt() ?? 0,
      pending: (json['PENDING'] as num?)?.toInt() ?? 0,
      approved: (json['APPROVED'] as num?)?.toInt() ?? 0,
      rejected: (json['REJECTED'] as num?)?.toInt() ?? 0,
      rescheduled: (json['RESCHEDULED'] as num?)?.toInt() ?? 0,
      closed: (json['CLOSED'] as num?)?.toInt() ?? 0,
      conInspOngoing: (json['CON_INSP_ONGOING'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$StatusCountsImplToJson(_$StatusCountsImpl instance) =>
    <String, dynamic>{
      'INSPECTED_BY_CON': instance.inspectedByCon,
      'PENDING': instance.pending,
      'APPROVED': instance.approved,
      'REJECTED': instance.rejected,
      'RESCHEDULED': instance.rescheduled,
      'CLOSED': instance.closed,
      'CON_INSP_ONGOING': instance.conInspOngoing,
    };
