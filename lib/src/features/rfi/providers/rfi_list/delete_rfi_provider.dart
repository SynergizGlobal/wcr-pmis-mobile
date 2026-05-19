import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../rfi/rfi_provider.dart';

part 'delete_rfi_provider.g.dart';

@riverpod
class DeleteRfiController extends _$DeleteRfiController {
  @override
  FutureOr<void> build() {}

  Future<void> delete(int rfiId, String description) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(rfiRepositoryProvider);
      await repo.deleteRfi(rfiId, description);
    });
  }

  Future<void> close(int rfiId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(rfiRepositoryProvider);
      await repo.closeRfi(rfiId);
    });
  }
}
