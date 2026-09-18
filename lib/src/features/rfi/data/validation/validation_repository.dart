import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/dio_provider.dart';
import '../../domain/common/filter_option.dart';
import '../../domain/validation/validation_item.dart';
import '../../domain/rfi_log/rfi_report_details.dart';
import 'validation_api.dart';

part 'validation_repository.g.dart';

@riverpod
ValidationRepository validationRepository(ValidationRepositoryRef ref) {
  final dio = ref.read(dioProvider);
  return ValidationRepository(ValidationApi(dio));
}

class ValidationRepository {
  final ValidationApi api;

  ValidationRepository(this.api);

  Future<List<ValidationItem>> getRfiValidations() async {
    final rawData = await api.getRfiValidations();

    return rawData.whereType<Map>().map((json) {
      final Map<String, dynamic> row = Map<String, dynamic>.from(json);
      row['project'] ??= row['projectName'];
      row['contract'] ??= row['contractName'];
      return ValidationItem.fromJson(row);
    }).toList();
  }

  Future<List<FilterOption>> getFilterProjects({
    String project = '',
    String contract = '',
  }) async {
    final raw = await api.filterProjects(
      project: project,
      contract: contract,
    );
    return FilterOption.parseList(raw, isProject: true);
  }

  Future<List<FilterOption>> getFilterContracts({
    String project = '',
    String contract = '',
  }) async {
    final raw = await api.filterContracts(
      project: project,
      contract: contract,
    );
    return FilterOption.parseList(raw, isProject: false);
  }

  Future<RfiReportDetailsData> fetchRfiReportDetails(int id) async {
    final rawData = await api.getRfiReportDetail(id);
    return RfiReportDetailsData.fromJson(rawData);
  }

  Future<void> validateRfi(Map<String, dynamic> data) async {
    await api.validateRfi(data);
  }
}
