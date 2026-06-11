import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

final projectListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final Map<String, dynamic> json = await ref
      .watch(dashboardRemoteDataSourceProvider)
      .fetchProjectOverview();
  final List<dynamic> rows = json['data'] as List<dynamic>? ?? <dynamic>[];
  return rows
      .whereType<Map>()
      .map(
        (Map row) => row.map(
          (dynamic key, dynamic value) => MapEntry(key.toString(), value),
        ),
      )
      .toList();
});
