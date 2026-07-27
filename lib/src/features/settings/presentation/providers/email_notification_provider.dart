import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/core/notifications/email_notification_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/providers/rfi_providers.dart';

final emailNotificationProvider =
    AsyncNotifierProvider<EmailNotificationNotifier, bool>(
  EmailNotificationNotifier.new,
);

class EmailNotificationNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    await ref.watch(rfiHandoffProvider.future);
    return ref.read(emailNotificationDataSourceProvider).getEnabled();
  }

  /// Optimistically updates the switch; rolls back if the API fails.
  Future<String?> setEnabled(bool enabled) async {
    final bool? previous = state.valueOrNull;
    state = AsyncData<bool>(enabled);
    try {
      await ref.read(rfiHandoffProvider.future);
      final bool ok = await ref
          .read(emailNotificationDataSourceProvider)
          .updateEnabled(enabled);
      if (!ok) {
        if (previous != null) {
          state = AsyncData<bool>(previous);
        } else {
          ref.invalidateSelf();
        }
        return 'Could not update email notification preference.';
      }
      return null;
    } catch (error) {
      if (previous != null) {
        state = AsyncData<bool>(previous);
      } else {
        ref.invalidateSelf();
      }
      return userFriendlyErrorMessage(error);
    }
  }
}
