import 'package:flutter/foundation.dart';

/// Notifies [GoRouter] when auth/session state changes so [redirect] re-runs.
class GoRouterRefresh extends ChangeNotifier {
  void notifyAuthChanged() => notifyListeners();
}
