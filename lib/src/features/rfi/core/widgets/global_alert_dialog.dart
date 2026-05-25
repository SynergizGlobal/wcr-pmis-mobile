import 'package:flutter/material.dart';

enum DialogType { info, error, confirm, success }

class GlobalAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final DialogType dialogType;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String cancelText;

  const GlobalAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.dialogType = DialogType.info,
    this.onConfirm,
    this.onCancel,
    this.confirmText = 'OK',
    this.cancelText = 'Cancel',
  });

  static String sanitizeMessage(String raw, {int maxLength = 400}) {
    var text = raw.trim();
    if (text.isEmpty) return text;

    final lower = text.toLowerCase();
    if (lower.contains('<!doctype') ||
        lower.contains('<html') ||
        lower.contains('nginx error')) {
      return 'Server returned an error page. Please try again later.';
    }

    text = text.replaceAll(RegExp(r'\s+'), ' ');
    if (text.length > maxLength) {
      return '${text.substring(0, maxLength)}…';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final displayMessage = sanitizeMessage(message);
    final maxDialogHeight = MediaQuery.sizeOf(context).height * 0.75;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    Color getHeaderColor() {
      switch (dialogType) {
        case DialogType.error:
          return scheme.error;
        case DialogType.success:
          return scheme.tertiary;
        case DialogType.confirm:
          return scheme.primary;
        case DialogType.info:
          return scheme.primary;
      }
    }

    IconData getIcon() {
      switch (dialogType) {
        case DialogType.error:
          return Icons.error_outline;
        case DialogType.success:
          return Icons.check_circle_outline;
        case DialogType.confirm:
          return Icons.help_outline;
        case DialogType.info:
          return Icons.info_outline;
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      backgroundColor: scheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: maxDialogHeight,
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 24, bottom: 16, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                getIcon(),
                size: 48,
                color: getHeaderColor(),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    displayMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (dialogType == DialogType.confirm) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: scheme.outlineVariant),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (onCancel != null) onCancel!();
                      },
                      child: Text(
                        cancelText,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getHeaderColor(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onConfirm != null) onConfirm!();
                    },
                    child: Text(
                      confirmText,
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    DialogType type = DialogType.info,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: type != DialogType.error &&
          type !=
              DialogType.success, // Errors & success require explicit OK
      builder: (BuildContext context) {
        return GlobalAlertDialog(
          title: title,
          message: sanitizeMessage(message),
          dialogType: type,
          onConfirm: onConfirm,
          onCancel: onCancel,
          confirmText: confirmText ?? 'OK',
          cancelText: cancelText ?? 'Cancel',
        );
      },
    );
  }
}
