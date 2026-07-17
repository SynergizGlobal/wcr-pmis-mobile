import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_form_dialog.dart';
import '../../../core/widgets/app_multi_select_dropdown.dart';
import '../../../domain/inspection_reference/enclosure_name.dart';
import '../../../domain/inspection_reference/reference_form_item.dart';
import '../../../providers/inspection_reference/inspection_reference_provider.dart';
import '../../../core/widgets/global_alert_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';

class ReferenceFormDialog {
  static Future<void> show(BuildContext parentContext, WidgetRef ref,
      [ReferenceFormItem? item]) async {
    final isEdit = item != null;
    final activityController =
        TextEditingController(text: item?.activity ?? '');
    final descController =
        TextEditingController(text: item?.rfiDescription ?? '');

    List<EnclosureName>? selectedEnclosures;

    await showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final allEnclosures =
                ref.watch(inspectionReferenceNotifierProvider).enclosureList;

            if (selectedEnclosures == null && allEnclosures.isNotEmpty) {
              if (isEdit && item.enclosures.isNotEmpty) {
                final names = item.enclosures
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toSet();
                selectedEnclosures = allEnclosures
                    .where((e) => names.contains(e.encloserName))
                    .toList();
              } else {
                selectedEnclosures = [];
              }
            }

            return StatefulBuilder(builder: (context, setStateSB) {
              final effectiveSelected = selectedEnclosures ?? [];

              return AppFormDialog(
                title:
                    isEdit ? 'Edit Reference Form' : 'Add New Reference Form',
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Activity *',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: activityController,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: RfiTheme.dialogFieldDecoration(
                          Theme.of(context).colorScheme,
                          hintText: 'Enter activity',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'RFI Description *',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descController,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: RfiTheme.dialogFieldDecoration(
                          Theme.of(context).colorScheme,
                          hintText: 'Enter RFI description',
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppMultiSelectDropdown<EnclosureName>(
                        label: 'Enclosures *',
                        hint: 'Select Enclosures',
                        items: allEnclosures,
                        itemLabel: (e) => e.encloserName,
                        selectedItems: effectiveSelected,
                        onChanged: (values) {
                          setStateSB(() => selectedEnclosures = values);
                        },
                      ),
                    ],
                  ),
                ),
                onConfirm: () async {
                  if (activityController.text.trim().isEmpty ||
                      descController.text.trim().isEmpty ||
                      effectiveSelected.isEmpty) {
                    if (parentContext.mounted) {
                      GlobalAlertDialog.show(
                        parentContext,
                        title: 'Missing information',
                        message: 'Please fill all fields',
                        type: DialogType.info,
                      );
                    }
                    return;
                  }

                  final enclosuresCsv =
                      effectiveSelected.map((e) => e.encloserName).join(',');

                  Navigator.pop(ctx);

                  final notifier =
                      ref.read(inspectionReferenceNotifierProvider.notifier);
                  bool success;
                  if (isEdit) {
                    success = await notifier.updateReferenceForm(
                        item.id,
                        activityController.text.trim(),
                        descController.text.trim(),
                        enclosuresCsv);
                  } else {
                    success = await notifier.addReferenceForm(
                        activityController.text.trim(),
                        descController.text.trim(),
                        enclosuresCsv);
                  }

                  if (parentContext.mounted) {
                    if (success) {
                      GlobalAlertDialog.show(
                        parentContext,
                        title: 'Success',
                        message: isEdit
                            ? 'Reference Form updated successfully'
                            : 'Reference Form added successfully',
                        type: DialogType.success,
                      );
                    } else {
                      GlobalAlertDialog.show(
                        parentContext,
                        title: 'Save failed',
                        message: 'Failed to save Reference Form',
                        type: DialogType.error,
                      );
                    }
                  }
                },
              );
            });
          },
        );
      },
    );
  }
}
