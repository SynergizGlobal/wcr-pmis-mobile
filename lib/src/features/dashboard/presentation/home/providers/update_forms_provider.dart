import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/entities/update_form_item.dart';

final updateFormsProvider = FutureProvider<List<UpdateFormItem>>((ref) async {
  final Map<String, dynamic> json = await ref
      .watch(dashboardRemoteDataSourceProvider)
      .fetchUpdateForms();

  final List<Map<String, dynamic>> rows = _parseUpdateFormRows(json);

  final List<UpdateFormItem> forms = rows.map(UpdateFormItem.fromJson).toList()
    ..sort(
      (UpdateFormItem a, UpdateFormItem b) =>
          a.priority.compareTo(b.priority),
    );

  return forms;
});

List<Map<String, dynamic>> _parseUpdateFormRows(Map<String, dynamic> json) {
  dynamic raw = json['data'] ?? json['result'] ?? json['forms'];
  if (raw is! List) {
    return const <Map<String, dynamic>>[];
  }
  return raw
      .whereType<Map>()
      .map(
        (Map<dynamic, dynamic> item) => Map<String, dynamic>.from(
          item.map(
            (dynamic key, dynamic value) => MapEntry(key.toString(), value),
          ),
        ),
      )
      .toList();
}
