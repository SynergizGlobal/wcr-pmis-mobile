import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/update_form_item.dart';

final updateFormsProvider = FutureProvider<List<UpdateFormItem>>((ref) async {
  final Map<String, dynamic> json = await ref
      .watch(dashboardRemoteDataSourceProvider)
      .fetchUpdateForms();
  final List<dynamic> rows = json['data'] as List<dynamic>? ?? <dynamic>[];

  final List<UpdateFormItem> forms =
      rows
          .whereType<Map<String, dynamic>>()
          .map(UpdateFormItem.fromJson)
          .where((UpdateFormItem item) => item.displayInMobile)
          .toList()
        ..sort(
          (UpdateFormItem a, UpdateFormItem b) =>
              a.priority.compareTo(b.priority),
        );

  return forms;
});
