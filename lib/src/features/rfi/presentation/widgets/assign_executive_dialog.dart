import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  String? selectedExecutive;

  @override
  void initState() {
    super.initState();
    selectedExecutive = widget.item.assignedPersonClient;
  }

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
        error: (err, stack) => Text('Error loading executives: $err'),
        data: (names) {
          if (names.isEmpty) {
            return const Text('No executives found for this contract.');
          }
          final uniqueNames = names.toSet().toList(); // Ensure unique
          if (selectedExecutive != null &&
              selectedExecutive!.isNotEmpty &&
              !uniqueNames.contains(selectedExecutive)) {
            uniqueNames.insert(0,
                selectedExecutive!); // keep current value even if not in list
          }

          return DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue:
                (selectedExecutive != null && selectedExecutive!.isNotEmpty)
                    ? selectedExecutive
                    : null,
            decoration: const InputDecoration(
              labelText: 'Select Executive',
              border: OutlineInputBorder(),
            ),
            items: uniqueNames.map((name) {
              return DropdownMenuItem(
                value: name,
                child: Text(name),
              );
            }).toList(),
            onChanged: (val) {
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
          onPressed: (assignState.isLoading ||
                  selectedExecutive == null ||
                  selectedExecutive!.isEmpty)
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
                      message: 'Error: ${state.error}',
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
