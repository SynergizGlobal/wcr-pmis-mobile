import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/rfi_log/rfi_log_repository.dart';
import '../../domain/rfi_log/rfi_report_details.dart';

part 'rfi_report_details_provider.g.dart';

@riverpod
Future<RfiReportDetailsData> rfiReportDetails(
  RfiReportDetailsRef ref,
  String id,
) async {
  final repository = ref.read(rfiLogRepositoryProvider);
  return repository.fetchRfiReportDetails(id);
}
