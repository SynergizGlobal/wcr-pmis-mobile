import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/auth/wcr_unauthorized.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/providers/auth_token_provider.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/data/datasources/rfi_handoff_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/data/repositories/rfi_repository_impl.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_list_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/rfi_list_kind.dart';

final rfiHandoffProvider = FutureProvider<void>((ref) async {
  try {
    final RfiHandoffResult result =
        await ref.read(rfiHandoffDataSourceProvider).performRedirect();
    ref.read(rfiAuthTokenProvider.notifier).state = result.token;
  } on DioException catch (error) {
    if (isWcrUnauthorizedError(error)) {
      await ref.read(authControllerProvider.notifier).logout();
    }
    rethrow;
  }
});

final rfiDashboardProvider = FutureProvider<RfiDashboardSnapshot>((ref) async {
  await ref.watch(rfiHandoffProvider.future);
  return ref.read(rfiRepositoryProvider).fetchDashboard();
});

final rfiListProvider = FutureProvider.family<List<RfiListItem>, RfiListKind>((
  ref,
  RfiListKind kind,
) async {
  await ref.watch(rfiHandoffProvider.future);
  final String? requestedFormName = switch (kind) {
    RfiListKind.created => 'CreatedRfi',
    _ => null,
  };
  final List<RfiListItem> items = await ref
      .read(rfiRepositoryProvider)
      .fetchRfiList(requestedFormName: requestedFormName);
  return kind.filter(items);
});

final rfiDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, int id) async {
  await ref.watch(rfiHandoffProvider.future);
  return ref.read(rfiRepositoryProvider).fetchRfiDetail(id);
});
