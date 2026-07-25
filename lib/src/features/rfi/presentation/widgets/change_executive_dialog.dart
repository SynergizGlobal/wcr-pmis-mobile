import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_engineer_option.dart';
import '../../providers/inspection/change_executive_provider.dart';
import '../../providers/inspection/inspection_provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/global_alert_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';

class ChangeExecutiveDialog extends ConsumerStatefulWidget {
  final String rfiId;
  final String contractId;
  final VoidCallback? onSuccess;

  const ChangeExecutiveDialog({
    super.key,
    required this.rfiId,
    required this.contractId,
    this.onSuccess,
  });

  @override
  ConsumerState<ChangeExecutiveDialog> createState() =>
      _ChangeExecutiveDialogState();
}

class _ChangeExecutiveDialogState extends ConsumerState<ChangeExecutiveDialog>
    with SingleTickerProviderStateMixin {
  RfiEngineerOption? _selectedPerson;
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

    Future.microtask(() {
      final authState = ref.read(authNotifierProvider);
      final userId = authState.value?['userId']?.toString() ?? '';
      ref
          .read(changeExecutiveProvider.notifier)
          .fetchEngineerNames(userId, widget.contractId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changeExecutiveProvider);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

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
              title: 'Change Executive',
              icon: Icons.person_add_rounded,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choose the person you want to reassign this RFI to.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  if (state.isLoading)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ))
                  else if (state.error != null)
                    ErrorStateWidget(
                      compact: true,
                      title: 'Unable to load executives',
                      message: state.error!,
                      onRetry: () {
                        final authState = ref.read(authNotifierProvider);
                        final userId =
                            authState.value?['userId']?.toString() ?? '';
                        ref.read(changeExecutiveProvider.notifier).fetchEngineerNames(
                              userId,
                              widget.contractId,
                            );
                      },
                    )
                  else
                    DropdownButtonFormField<RfiEngineerOption>(
                      value: _selectedPerson,
                      borderRadius: BorderRadius.circular(16),
                      dropdownColor: scheme.surface,
                      style: textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
                      iconEnabledColor: scheme.onSurfaceVariant,
                      decoration: InputDecoration(
                        labelText: 'Select Person',
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      hint: Text(
                        'Search or select a person',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      isExpanded: true,
                      items: state.engineers.map((RfiEngineerOption engineer) {
                        final bool selected = _selectedPerson == engineer;
                        return DropdownMenuItem<RfiEngineerOption>(
                          value: engineer,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.account_circle_rounded,
                                size: 22,
                                color: selected
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  engineer.name,
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: selected
                                        ? scheme.primary
                                        : scheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (RfiEngineerOption? value) {
                        setState(() {
                          _selectedPerson = value;
                        });
                      },
                    ),

                  const SizedBox(height: 32),

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
                          onPressed: _selectedPerson == null || state.isLoading
                              ? null
                              : () async {
                            if (!mounted) return;
                            final success = await ref
                                .read(changeExecutiveProvider.notifier)
                                .assignExecutive(
                                  rfiId: widget.rfiId,
                                  engineer: _selectedPerson!,
                                );

                            if (!mounted) return;
                            if (!context.mounted) return;
                            if (success) {
                              if (!context.mounted) return;
                              GlobalAlertDialog.show(
                                context,
                                title: 'Success',
                                message:
                                    state.successMessage ?? 'Assigned successfully',
                                type: DialogType.success,
                              );
                              
                              if (widget.onSuccess != null) {
                                widget.onSuccess!();
                              } else {
                                ref
                                    .read(inspectionProvider.notifier)
                                    .fetchInspections();
                              }
                              
                              if (!context.mounted) return;
                              Navigator.pop(context);
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
                          child: state.isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: scheme.onPrimary,
                                  ),
                                )
                              : const Text(
                                  'Confirm',
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
