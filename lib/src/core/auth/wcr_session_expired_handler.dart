import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/auth/wcr_unauthorized.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/pages/login_page.dart';

bool _sessionExpiredDialogActive = false;

Future<void> handleWcrSessionExpired({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  if (_sessionExpiredDialogActive) {
    return;
  }
  _sessionExpiredDialogActive = true;
  try {
    await ref.read(authControllerProvider.notifier).logout();
    if (!context.mounted) {
      return;
    }
    await AppDialog.show(
      context: context,
      title: 'Session Expired',
      message: sessionExpiredLoginMessage,
      type: AppDialogType.error,
      actions: <AppDialogAction>[
        AppDialogAction(
          label: 'Sign In',
          isPrimary: true,
          onPressed: () {
            if (context.mounted) {
              context.go(LoginPage.routePath);
            }
          },
        ),
      ],
    );
  } finally {
    _sessionExpiredDialogActive = false;
  }
}
