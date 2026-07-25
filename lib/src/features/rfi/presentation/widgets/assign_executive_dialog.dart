import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_engineer_option.dart';

import '../../domain/rfi_list/rfi_list_item.dart';
import '../../providers/rfi_list/assign_client_person_provider.dart';
import '../../providers/rfi_list/rfi_list_provider.dart';
import '../../core/widgets/global_alert_dialog.dart';

class AssignExecutiveDialog extends ConsumerStatefulWidget {
  final RfiListItem item;

  const AssignExecutiveDialog({super.key, required this.item});

  @override
  ConsumerState<AssignExecutiveDialog> createState() =>
      _AssignExecutiveDialogState();
}

class _AssignExecutiveDialogState extends ConsumerState<AssignExecutiveDialog> {
  RfiEngineerOption? selectedExecutive;

  @override
  Widget build(BuildContext context) {
    final contractId = widget.item.contract ?? '';
    final namesAsync = ref.watch(assignExecutiveNamesProvider(contractId));
    final assignState = ref.watch(assignClientPersonControllerProvider);

    return AlertDialog(
      title: const Text('Assign Executive'),
      content: namesAsync.when(
        loading: () => const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (Object err, StackTrace stack) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            userFriendlyErrorMessage(err),
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        data: (engineers) {
          if (engineers.isEmpty) {
            return const Text('No executives found for this contract.');
          }

          return DropdownButtonFormField<RfiEngineerOption>(
            isExpanded: true,
            initialValue: selectedExecutive,
            decoration: const InputDecoration(
              labelText: 'Select Executive',
              border: OutlineInputBorder(),
            ),
            items: engineers.map((RfiEngineerOption engineer) {
              return DropdownMenuItem<RfiEngineerOption>(
                value: engineer,
                child: Text(engineer.name),
              );
            }).toList(),
            onChanged: (RfiEngineerOption? val) {
              setState(() {
                selectedExecutive = val;
              });
            },
          );
        },
      ),
      actions: [
        TextButton(
          onPressed:
              assignState.isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (assignState.isLoading || selectedExecutive == null)
              ? null
              : () async {
                  await ref
                      .read(assignClientPersonControllerProvider.notifier)
                      .assign(widget.item.rfiNo, selectedExecutive!);

                  final state = ref.read(assignClientPersonControllerProvider);
                  if (!state.hasError && context.mounted) {
                    ref.read(rfiListNotifierProvider.notifier).fetchRfiList();
                    Navigator.pop(context);
                    GlobalAlertDialog.show(
                      context,
                      title: 'Success',
                      message: 'Executive assigned successfully!',
                      type: DialogType.success,
                    );
                  } else if (state.hasError && context.mounted) {
                    GlobalAlertDialog.show(
                      context,
                      title: 'Error',
                      message: userFriendlyErrorMessage(state.error!),
                      type: DialogType.error,
                    );
                  }
                },
          child: assignState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Update'),
        ),
      ],
    );
  }
}
