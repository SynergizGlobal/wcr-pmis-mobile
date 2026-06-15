import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/data/repositories/rfi_repository_impl.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_list_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/rfi_list_kind.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/providers/rfi_providers.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/providers/inspection/inspection_provider.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';

class DeleteRfiDialog extends ConsumerStatefulWidget {
  const DeleteRfiDialog({
    super.key,
    required this.item,
    this.isClose = false,
    this.onSuccess,
  });

  final RfiListItem item;
  final bool isClose;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<DeleteRfiDialog> createState() => _DeleteRfiDialogState();
}

class _DeleteRfiDialogState extends ConsumerState<DeleteRfiDialog> {
  final TextEditingController _reasonController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _invalidateRfiCaches() {
    ref.invalidate(rfiDashboardProvider);
    ref.invalidate(rfiHandoffProvider);
    for (final RfiListKind kind in RfiListKind.values) {
      ref.invalidate(rfiListProvider(kind));
    }
    ref.read(inspectionProvider.notifier).fetchInspections();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final repository = ref.read(rfiRepositoryProvider);
      if (widget.isClose) {
        await repository.closeRfi(widget.item.rfiId);
      } else {
        await repository.deleteRfi(
          widget.item.rfiId,
          _reasonController.text.trim(),
        );
      }
      if (!mounted) {
        return;
      }
      _invalidateRfiCaches();
      widget.onSuccess?.call();
      Navigator.pop(context);
      await AppDialog.show(
        context: context,
        title: 'Success',
        message: widget.isClose
            ? 'RFI closed successfully.'
            : 'RFI deleted successfully.',
        type: AppDialogType.success,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: 'Error',
        message: userFriendlyErrorMessage(e),
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color actionColor =
        widget.isClose ? scheme.primary : scheme.error;
    final bool canSubmit = widget.isClose ||
        _reasonController.text.trim().isNotEmpty;

    return AlertDialog(
      title: Text(
        widget.isClose ? 'Close RFI' : 'Delete RFI',
        style: textTheme.titleLarge,
      ),
      content: widget.isClose
          ? Text(
              'Do you really want to close this RFI?',
              style: textTheme.bodyMedium,
            )
          : TextField(
              controller: _reasonController,
              maxLength: 300,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for delete',
                hintText: 'Enter reason here…',
              ),
              onChanged: (_) => setState(() {}),
            ),
      actions: <Widget>[
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: actionColor,
            foregroundColor: widget.isClose ? scheme.onPrimary : scheme.onError,
          ),
          onPressed: _loading || !canSubmit ? null : _submit,
          child: _loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.isClose ? scheme.onPrimary : scheme.onError,
                  ),
                )
              : Text(widget.isClose ? 'Close' : 'Delete'),
        ),
      ],
    );
  }
}
