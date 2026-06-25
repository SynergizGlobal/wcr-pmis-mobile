import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/update_form_item.dart';

final reportFormsProvider = FutureProvider<List<UpdateFormItem>>((ref) async {
  final List<Map<String, dynamic>> rows = await ref
      .watch(dashboardRemoteDataSourceProvider)
      .fetchReportForms();

  final List<UpdateFormItem> forms =
      rows.map(UpdateFormItem.fromJson).toList()
        ..sort(
          (UpdateFormItem a, UpdateFormItem b) =>
              a.priority.compareTo(b.priority),
        );

  return forms;
});
