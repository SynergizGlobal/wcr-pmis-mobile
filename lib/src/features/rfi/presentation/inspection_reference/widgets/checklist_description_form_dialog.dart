import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_form_dialog.dart';
import '../../../domain/inspection_reference/checklist_detail.dart';
import '../../../providers/inspection_reference/inspection_reference_provider.dart';
import '../../../core/widgets/global_alert_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';

class ChecklistDescriptionFormDialog {
  static Future<void> show(BuildContext parentContext, WidgetRef ref,
      [ChecklistDetail? item]) async {
    final isEdit = item != null;
    final descController =
        TextEditingController(text: item?.checklistDescription ?? '');

    await showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (ctx) {
        return AppFormDialog(
          title: isEdit
              ? 'Edit Checklist Description'
              : 'Add New Checklist Description',
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Checklist Description *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(ctx).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  style: TextStyle(
                    color: Theme.of(ctx).colorScheme.onSurface,
                  ),
                  decoration: RfiTheme.dialogFieldDecoration(
                    Theme.of(ctx).colorScheme,
                    hintText: 'Enter description',
                  ),
                ),
              ],
            ),
          ),
          onConfirm: () async {
            if (descController.text.trim().isEmpty) {
              if (parentContext.mounted) {
                GlobalAlertDialog.show(
                  parentContext,
                  title: 'Missing information',
                  message: 'Please enter a description',
                  type: DialogType.info,
                );
              }
              return;
            }
            Navigator.pop(ctx);

            final notifier =
                ref.read(inspectionReferenceNotifierProvider.notifier);
            bool success;
            if (isEdit) {
              success = await notifier.updateChecklistDescription(
                  item.id, descController.text.trim());
            } else {
              success = await notifier
                  .addChecklistDescription(descController.text.trim());
            }

            if (parentContext.mounted) {
              if (success) {
                GlobalAlertDialog.show(
                  parentContext,
                  title: 'Success',
                  message: isEdit
                      ? 'Checklist description updated successfully'
                      : 'Checklist description added successfully',
                  type: DialogType.success,
                );
              } else {
                GlobalAlertDialog.show(
                  parentContext,
                  title: 'Save failed',
                  message: 'Failed to save checklist description',
                  type: DialogType.error,
                );
              }
            }
          },
        );
      },
    );
  }
}
