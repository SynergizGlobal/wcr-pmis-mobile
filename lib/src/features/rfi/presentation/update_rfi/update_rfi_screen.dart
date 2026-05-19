import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/rfi_list/rfi_list_item.dart';
import '../../providers/update_rfi/update_rfi_provider.dart';
import '../../providers/update_rfi/update_rfi_state.dart';
import '../../core/widgets/app_dropdown.dart';
import '../../core/widgets/global_alert_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';

class UpdateRfiScreen extends ConsumerStatefulWidget {
  final RfiListItem item;

  const UpdateRfiScreen({super.key, required this.item});

  @override
  ConsumerState<UpdateRfiScreen> createState() => _UpdateRfiScreenState();
}

class _UpdateRfiScreenState extends ConsumerState<UpdateRfiScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule initialization after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(updateRfiFormProvider.notifier).initialize(widget.item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateRfiFormProvider);
    final notifier = ref.read(updateRfiFormProvider.notifier);

    // Show loading indicator until item is initialized in state to prevent null errors
    if (state.initialItem == null ||
        state.initialItem!.rfiId != widget.item.rfiId) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: RfiTheme.scaffoldBackground(context),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (state.currentStep > 0) {
              notifier.previousStep();
            } else {
              if (context.canPop()) context.pop();
            }
          },
        ),
        title: const Text('Update RFI Details',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildStepper(context, state.currentStep),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: state.currentStep == 0
                  ? _buildStep1Form(state)
                  : state.currentStep == 1
                      ? _buildStep2Form(context, state, notifier, widget.item)
                      : _buildStep3Form(context, state, notifier),
            ),
          ),
          _buildFooter(context, state, notifier),
        ],
      ),
    );
  }

  Widget _buildFooter(
      BuildContext context, UpdateRfiState state, UpdateRfiForm notifier) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: scheme.surface,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: state.currentStep == 0
              ? MainAxisAlignment.end
              : MainAxisAlignment.spaceBetween,
          children: [
            if (state.currentStep > 0)
              OutlinedButton(
                onPressed: () {
                  notifier.previousStep();
                },
                style: RfiTheme.secondaryOutlined(scheme).copyWith(
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                child: const Text('Back'),
              ),
            ElevatedButton(
              onPressed: state.isSubmitting
                  ? null
                  : () async {
                      if (state.currentStep == 0) {
                        notifier.nextStep();
                      } else if (state.currentStep == 1) {
                        if (state.action == null) {
                          GlobalAlertDialog.show(
                            context,
                            title: 'Missing information',
                            message: 'Please select an action first',
                            type: DialogType.info,
                          );
                          return;
                        }
                        notifier.nextStep();
                      } else if (state.currentStep == 2) {
                        final success = await notifier.updateRfi();
                        if (context.mounted) {
                          if (success) {
                            GlobalAlertDialog.show(
                              context,
                              title: 'Success',
                              message: 'RFI Updated Successfully!',
                              type: DialogType.success,
                              onConfirm: () {
                                if (context.mounted) {
                                  context.pop();
                                }
                              },
                            );
                          } else {
                            GlobalAlertDialog.show(
                              context,
                              title: 'Update failed',
                              message: 'Failed to update RFI. Please try again.',
                              type: DialogType.error,
                            );
                          }
                        }
                      }
                    },
              style: RfiTheme.primaryElevated(scheme).copyWith(
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              child: state.isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: scheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(state.currentStep == 2 ? 'Update' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Form(UpdateRfiState state) {
    // In Update mode, all Step 1 fields are disabled and pre-filled.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
                child: _buildDisabledField(
                    'Project', state.selectedProject?.name)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildDisabledField('Work', state.selectedWork?.name)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildDisabledField(
                    'Contract', state.selectedContract?.name)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildDisabledField(
                    'Structure Type', state.selectedStructureType?.name)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildDisabledField(
                    'Structure', state.selectedStructure?.name)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildDisabledField(
                    'Component', state.selectedComponent?.name)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildDisabledField(
                    'Element', state.selectedElement?.name)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildDisabledField(
                    'Activity', state.selectedActivity?.name)),
          ],
        ),
        const SizedBox(height: 16),
        _buildDisabledField(
            'RFI Description', state.selectedRfiDescription?.name),
      ],
    );
  }

  Widget _buildDisabledField(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black87, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value?.isNotEmpty == true ? value! : 'N/A',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Form(BuildContext context, UpdateRfiState state,
      UpdateRfiForm notifier, RfiListItem original) {
    // Dynamic logic flags
    final isReassign = state.action == 'Reassign';
    final isReschedule = state.action == 'Reschedule';

    // According to specs, Action is enabled.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStringDropdown(
          label: 'Action *',
          value: state.action,
          items: const ['Reschedule', 'Update', 'Reassign'],
          onChanged: (val) {
            notifier.setAction(val);
            // Optionally reset values here if needed, but keeping them as defaults is fine
          },
          hint: '- Select Action -',
          enabled: true,
        ),
        const SizedBox(height: 16),
        _buildStringDropdown(
          label: 'Type of RFI *',
          value: state.typeOfRfi,
          items: const ['Regular RFI', 'SPOT RFI'],
          onChanged: notifier.setTypeOfRfi,
          hint: 'Select...',
          enabled: false,
        ),
        const SizedBox(height: 16),

        // Allowed to edit ONLY if Reassign is selected
        _buildStringDropdown(
          label: 'Name of Contractor\'s Representative *',
          value: state.contractorRepresentative,
          items: state.representatives.map((e) => e.name).toList(),
          onChanged: notifier.setContractorRepresentative,
          hint: 'Select Representative...',
          enabled: isReassign,
        ),
        const SizedBox(height: 16),

        // Usually locked to original submission date, but following create logic
        _buildDateField(
          context: context,
          label: 'Date of Submission of RFI *',
          value: state.dateOfSubmission,
          onChanged: notifier.setDateOfSubmission,
          hint: 'dd-mm-yyyy',
          enabled: false,
        ),
        const SizedBox(height: 16),

        // Allowed to edit ONLY if Reschedule is selected
        _buildTimeField(
          context: context,
          label: 'Time Of Inspection *',
          value: state.timeOfInspection,
          onChanged: notifier.setTimeOfInspection,
          hint: '--:--',
          enabled: isReschedule,
        ),
        const SizedBox(height: 16),

        // Allowed to edit ONLY if Reschedule is selected
        _buildDateField(
          context: context,
          label: 'Date of Inspection *',
          value: state.dateOfInspection,
          onChanged: notifier.setDateOfInspection,
          hint: 'dd-mm-yyyy',
          firstDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          enabled: isReschedule,
        ),
      ],
    );
  }

  Widget _buildStep3Form(
      BuildContext context, UpdateRfiState state, UpdateRfiForm notifier) {
    // Same as Create, optionally allow description changes on 'Update'
    final List<String> enclosures = state.rfiDescriptions.isNotEmpty
        ? (state.rfiDescriptions.first.enclosures ??
            ['Level Sheet', 'Drawing', 'Material specs'])
        : ['Level Sheet', 'Drawing', 'Material specs'];

    final isUpdate = state.action == 'Update';

    // Assuming user wants to change desc & enclosures regardless of action, but spec emphasizes Update.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (enclosures.isNotEmpty) ...[
          const Text('Enclosures *',
              style: TextStyle(color: Colors.black87, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
              color: isUpdate ? Colors.transparent : Colors.grey.shade100,
            ),
            child: Column(
              children: enclosures.map((enclosure) {
                final isSelected = state.selectedEnclosures.contains(enclosure);
                final isLast = enclosure == enclosures.last;
                return Column(
                  children: [
                    InkWell(
                      onTap: isUpdate
                          ? () => notifier.toggleEnclosure(enclosure)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: isUpdate
                                  ? (isSelected
                                      ? const Color(0xFF1976D2)
                                      : Colors.grey.shade600)
                                  : Colors.grey.shade400,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                                child: Text(enclosure,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87))),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                          height: 1, color: Colors.grey.shade300, thickness: 1),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        const Text('Description:',
            style: TextStyle(color: Colors.black87, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: state.rfiDescriptionText,
          onChanged: notifier.setRfiDescriptionText,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Enter Description',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  // --- Common UI Helpers --- //

  Widget _buildStepper(BuildContext context, int currentStep) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepCircle(context, '1', isActive: currentStep >= 0),
          _buildStepLine(context, isActive: currentStep >= 1),
          _buildStepCircle(context, '2', isActive: currentStep >= 1),
          _buildStepLine(context, isActive: currentStep >= 2),
          _buildStepCircle(context, '3', isActive: currentStep >= 2),
        ],
      ),
    );
  }

  Widget _buildStepCircle(
    BuildContext context,
    String number, {
    required bool isActive,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? scheme.onPrimary : scheme.onPrimary.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: TextStyle(
          color: isActive ? scheme.primary : scheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStepLine(BuildContext context, {required bool isActive}) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: 60,
      height: 2,
      color: isActive
          ? scheme.onPrimary
          : scheme.onPrimary.withValues(alpha: 0.5),
    );
  }

  Widget _buildStringDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String hint,
    required bool enabled,
  }) {
    return AppDropdown<String>(
      label: label,
      value: items.contains(value) ? value : null,
      items: items,
      onChanged: onChanged,
      hint: hint,
      enabled: enabled,
      itemLabel: (item) => item,
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required String? value,
    required void Function(String) onChanged,
    required String hint,
    required bool enabled,
    DateTime? firstDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll(' *', ''),
            style: const TextStyle(color: Colors.black87, fontSize: 13),
            children: [
              if (label.contains('*'))
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled
              ? () async {
                  final now = DateTime.now();
                  final lastDate = DateTime(now.year + 5);
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: firstDate ?? DateTime(2000),
                    lastDate: lastDate,
                  );
                  if (picked != null) {
                    final formatted =
                        "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                    onChanged(formatted);
                  }
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey.shade100,
              border: Border.all(
                  color: enabled ? Colors.grey.shade400 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value ?? hint,
                      style: TextStyle(
                        fontSize: 14,
                        color: !enabled
                            ? Colors.grey.shade600
                            : (value != null
                                ? Colors.black87
                                : Colors.grey.shade500),
                      ),
                    ),
                  ),
                ),
                Icon(Icons.calendar_today,
                    size: 20,
                    color:
                        enabled ? Colors.grey.shade600 : Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required BuildContext context,
    required String label,
    required String? value,
    required void Function(String) onChanged,
    required String hint,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll(' *', ''),
            style: const TextStyle(color: Colors.black87, fontSize: 13),
            children: [
              if (label.contains('*'))
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled
              ? () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null && context.mounted) {
                    onChanged(picked.format(context));
                  }
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey.shade100,
              border: Border.all(
                  color: enabled ? Colors.grey.shade400 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value ?? hint,
                      style: TextStyle(
                        fontSize: 14,
                        color: !enabled
                            ? Colors.grey.shade600
                            : (value != null
                                ? Colors.black87
                                : Colors.grey.shade500),
                      ),
                    ),
                  ),
                ),
                Icon(Icons.access_time,
                    size: 20,
                    color:
                        enabled ? Colors.grey.shade600 : Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
