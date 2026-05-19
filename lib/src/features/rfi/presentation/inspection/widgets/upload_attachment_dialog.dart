import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../providers/inspection/inspection_provider.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/global_alert_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';

class UploadAttachmentDialog extends ConsumerStatefulWidget {
  final int rfiId;
  const UploadAttachmentDialog({super.key, required this.rfiId});

  @override
  ConsumerState<UploadAttachmentDialog> createState() =>
      _UploadAttachmentDialogState();
}

class _UploadAttachmentDialogState extends ConsumerState<UploadAttachmentDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _descriptionController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
    
    _descriptionController.addListener(() {
      setState(() {}); // Rebuild to update button enabled state
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      // We attempt to pick. If it fails due to permissions, we'll catch it.
      // Most modern Android versions will work directly.
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          _selectedFile = result.files.single;
        });
      }
    } catch (e) {
      if (mounted) {
        GlobalAlertDialog.show(
          context,
          title: 'Error',
          message: 'Error picking file: $e',
          type: DialogType.error,
        );
      }
    }
  }

  bool get _isValid =>
      _descriptionController.text.trim().isNotEmpty && _selectedFile != null;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        elevation: 10,
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        shape: RfiTheme.dialogShape(),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            RfiTheme.dialogHeader(
              context,
              title: 'Upload Attachment',
              icon: Icons.cloud_upload_rounded,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: 'Description *',
                    hintText: 'Enter a detailed description...',
                    controller: _descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Attach File *',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedFile != null
                              ? scheme.primary
                              : scheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedFile != null ? Icons.insert_drive_file_rounded : Icons.add_circle_outline_rounded,
                            color: _selectedFile != null
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFile != null
                                  ? _selectedFile!.name
                                  : 'Select from local device',
                              style: TextStyle(
                                color: _selectedFile != null
                                    ? scheme.onSurface
                                    : scheme.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: _selectedFile != null ? FontWeight.w500 : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: RfiTheme.secondaryOutlined(scheme).copyWith(
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(vertical: 16),
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: !_isValid || _isUploading
                              ? null
                              : () async {
                                  setState(() => _isUploading = true);
                                  try {
                                    final message = await ref
                                        .read(inspectionProvider.notifier)
                                        .uploadAttachment(
                                          rfiId: widget.rfiId,
                                          description: _descriptionController.text.trim(),
                                          file: _selectedFile!,
                                        );

                                    if (!context.mounted) return;
                                    if (message.toLowerCase().contains('success')) {
                                      GlobalAlertDialog.show(
                                        context,
                                        title: 'Success',
                                        message: message,
                                        type: DialogType.success,
                                      );
                                    } else {
                                      GlobalAlertDialog.show(
                                        context,
                                        title: 'Upload failed',
                                        message: message,
                                        type: DialogType.error,
                                      );
                                    }
                                    if (message.toLowerCase().contains('success')) {
                                      Navigator.pop(context);
                                    }
                                  } catch (e) {
                                     if (!context.mounted) return;
                                     GlobalAlertDialog.show(
                                       context,
                                       title: 'Error',
                                       message: 'Error: $e',
                                       type: DialogType.error,
                                     );
                                  } finally {
                                    if (mounted) setState(() => _isUploading = false);
                                  }
                                },
                          style: RfiTheme.primaryElevated(scheme).copyWith(
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(vertical: 16),
                            ),
                            elevation: const WidgetStatePropertyAll(0),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          child: _isUploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Upload',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
