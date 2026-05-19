import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_form_dialog.dart';
import '../../../domain/inspection_reference/enclosure_name.dart';
import '../../../providers/inspection_reference/inspection_reference_provider.dart';
import '../../../core/widgets/global_alert_dialog.dart';

class EnclosureFormDialog {
  static Future<void> show(BuildContext parentContext, WidgetRef ref,
      [EnclosureName? item]) async {
    final isEdit = item != null;
    final nameController =
        TextEditingController(text: item?.encloserName ?? '');
    String actionType = item?.action ?? 'Open';

    await showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateSB) {
          return AppFormDialog(
            title: isEdit ? 'Edit Enclosure' : 'Add New Enclosure',
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Enclosure Name *',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter enclosure name',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppDropdown<String>(
                    label: 'Action Type *',
                    hint: 'Select Action',
                    value: actionType.toUpperCase(),
                    items: const ['OPEN', 'UPLOAD'],
                    itemLabel: (v) => v,
                    onChanged: (v) {
                      if (v != null) setStateSB(() => actionType = v);
                    },
                  ),
                ],
              ),
            ),
            onConfirm: () async {
              if (nameController.text.trim().isEmpty) {
                if (parentContext.mounted) {
                  GlobalAlertDialog.show(
                    parentContext,
                    title: 'Missing information',
                    message: 'Please enter an enclosure name',
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
                success = await notifier.updateEnclosure(
                    item.id, nameController.text.trim(), actionType);
              } else {
                success = await notifier.addEnclosure(
                    nameController.text.trim(), actionType);
              }

              if (parentContext.mounted) {
                if (success) {
                  GlobalAlertDialog.show(
                    parentContext,
                    title: 'Success',
                    message: isEdit
                        ? 'Enclosure updated successfully'
                        : 'Enclosure added successfully',
                    type: DialogType.success,
                  );
                } else {
                  GlobalAlertDialog.show(
                    parentContext,
                    title: 'Save failed',
                    message: 'Failed to save enclosure',
                    type: DialogType.error,
                  );
                }
              }
            },
          );
        });
      },
    );
  }
}
