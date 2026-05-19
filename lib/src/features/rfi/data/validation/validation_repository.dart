import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/dio_provider.dart';
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

    return rawData.map((json) {
      return ValidationItem.fromJson(json);
    }).toList();
  }

  Future<RfiReportDetailsData> fetchRfiReportDetails(int id) async {
    final rawData = await api.getRfiReportDetail(id);
    return RfiReportDetailsData.fromJson(rawData);
  }

  Future<void> validateRfi(Map<String, dynamic> data) async {
    await api.validateRfi(data);
  }
}
