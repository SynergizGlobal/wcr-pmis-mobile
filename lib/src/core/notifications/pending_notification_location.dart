import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pending FCM navigation payload before auth is ready.
class PendingNotificationNav {
  const PendingNotificationNav({
    this.type,
    this.referenceType,
  });

  final String? type;
  final String? referenceType;
}

final pendingNotificationNavProvider =
    StateProvider<PendingNotificationNav?>((ref) => null);
