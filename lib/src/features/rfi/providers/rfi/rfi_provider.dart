import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/dio_provider.dart';
import '../../data/rfi/rfi_api.dart';
import '../../data/rfi/rfi_repository.dart';
import '../../domain/rfi/status_counts.dart';

part 'rfi_provider.g.dart';

@riverpod
RfiRepository rfiRepository(RfiRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return RfiRepository(RfiApi(dio));
}

@riverpod
Future<StatusCounts> statusCounts(StatusCountsRef ref) {
  final repository = ref.watch(rfiRepositoryProvider);
  return repository.getStatusCounts();
}

@riverpod
Future<int> rfiCount(RfiCountRef ref) {
  final repository = ref.watch(rfiRepositoryProvider);
  return repository.getRfiCount();
}
