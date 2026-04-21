import 'package:flutter/material.dart';

enum AppDialogType { error, info, success }

class AppDialogAction {
  const AppDialogAction({
    required this.label,
    this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
}

class AppDialog {
  const AppDialog._();

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    AppDialogType type = AppDialogType.info,
    List<AppDialogAction>? actions,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final (iconData, accentColor) = switch (type) {
      AppDialogType.error => (Icons.error_outline_rounded, Colors.red.shade600),
      AppDialogType.success => (
        Icons.check_circle_outline_rounded,
        Colors.green.shade600,
      ),
      AppDialogType.info => (
        Icons.info_outline_rounded,
        colorScheme.primary,
      ),
    };
    final List<AppDialogAction> dialogActions =
        actions ??
        <AppDialogAction>[
          const AppDialogAction(label: 'OK', isPrimary: true),
        ];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Icon(iconData, color: accentColor, size: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: SingleChildScrollView(
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(dialogActions.length, (
                        int index,
                      ) {
                        final AppDialogAction action = dialogActions[index];
                        final Widget button = action.isPrimary
                            ? FilledButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  action.onPressed?.call();
                                },
                                child: Text(action.label),
                              )
                            : OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  action.onPressed?.call();
                                },
                                child: Text(action.label),
                              );
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: index == 0 ? 0 : 6,
                              right:
                                  index == dialogActions.length - 1 ? 0 : 6,
                            ),
                            child: button,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
