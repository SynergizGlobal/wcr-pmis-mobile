import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pending FCM `data.type` from a notification tap before auth is ready.
/// Resolved to a route only after login, using the real user role.
final pendingNotificationTypeProvider = StateProvider<String?>((ref) => null);
