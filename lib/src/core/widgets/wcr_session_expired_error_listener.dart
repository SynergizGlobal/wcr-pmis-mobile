import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/auth/wcr_session_expired_handler.dart';
import 'package:wcr_pmis_mobile/src/core/auth/wcr_unauthorized.dart';

/// Shows a session-expired dialog and routes to login when [error] indicates 401.
class WcrSessionExpiredErrorListener extends ConsumerStatefulWidget {
  const WcrSessionExpiredErrorListener({
    super.key,
    required this.child,
    this.error,
  });

  final Widget child;
  final Object? error;

  @override
  ConsumerState<WcrSessionExpiredErrorListener> createState() =>
      _WcrSessionExpiredErrorListenerState();
}

class _WcrSessionExpiredErrorListenerState
    extends ConsumerState<WcrSessionExpiredErrorListener> {
  String? _lastHandledErrorKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleIfNeeded(widget.error);
    });
  }

  @override
  void didUpdateWidget(WcrSessionExpiredErrorListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleIfNeeded(widget.error);
  }

  void _handleIfNeeded(Object? error) {
    if (error == null) {
      return;
    }
    if (!isWcrSessionExpiredError(error)) {
      return;
    }
    final String errorKey = error.toString();
    if (errorKey == _lastHandledErrorKey) {
      return;
    }
    _lastHandledErrorKey = errorKey;
    handleWcrSessionExpired(context: context, ref: ref);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
