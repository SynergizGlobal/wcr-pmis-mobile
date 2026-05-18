import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_dropdown_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/create_rfi/create_rfi_notifier.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/create_rfi/create_rfi_state.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/widgets/rfi_form_dropdown.dart';

class CreateRfiPage extends ConsumerWidget {
  const CreateRfiPage({super.key, this.embedded = false});

  static const String routeName = 'rfi-create';
  static const String routePath = '/rfi/create';

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CreateRfiState state = ref.watch(createRfiNotifierProvider);
    final CreateRfiNotifier notifier = ref.read(createRfiNotifierProvider.notifier);

    final Widget body = Column(
      children: <Widget>[
        _CreateRfiStepper(currentStep: state.currentStep),
        if (state.isLoadingItems)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: RefreshIndicator(
            onRefresh: notifier.retryInitialLoad,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: switch (state.currentStep) {
                0 => _ScopeStep(state: state, notifier: notifier),
                1 => _InspectionPlanStep(state: state, notifier: notifier),
                _ => _EnclosuresStep(
                    key: ValueKey<String>(state.selectedRfiDescription?.id ?? ''),
                    state: state,
                    notifier: notifier,
                  ),
              },
            ),
          ),
        ),
        _CreateRfiFooter(
          state: state,
          notifier: notifier,
          onSubmitted: () async {
            final String? error = await notifier.submitRfi();
            if (!context.mounted) {
              return;
            }
            if (error != null) {
              await AppDialog.show(
                context: context,
                title: 'Could not submit',
                message: error,
                type: AppDialogType.error,
              );
              return;
            }
            await AppDialog.show(
              context: context,
              title: 'Success',
              message: 'Your RFI was submitted successfully.',
              type: AppDialogType.success,
              actions: <AppDialogAction>[
                AppDialogAction(
                  label: 'OK',
                  isPrimary: true,
                  onPressed: () {
                    if (!embedded && context.canPop()) {
                      context.pop();
                    }
                    notifier.resetForm();
                  },
                ),
              ],
            );
          },
        ),
      ],
    );

    if (embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (state.currentStep > 0) {
              notifier.previousStep();
            } else if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: const Text('Add RFI Details'),
      ),
      body: body,
    );
  }
}

class _CreateRfiStepper extends StatelessWidget {
  const _CreateRfiStepper({required this.currentStep});

  final int currentStep;

  static const List<String> _labels = <String>[
    'RFI Scope',
    'Inspection Plan',
    'Enclosures & Notes',
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: List<Widget>.generate(_labels.length, (int index) {
          final bool completed = currentStep > index;
          final bool active = currentStep == index;
          return Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 15,
                        backgroundColor:
                            completed ? scheme.primary : scheme.surface,
                        child: completed
                            ? Icon(Icons.check, size: 18, color: scheme.onPrimary)
                            : Text(
                                '${index + 1}',
                                style: textTheme.labelLarge?.copyWith(
                                  color: active
                                      ? scheme.primary
                                      : scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _labels[index],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < _labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 22),
                      color: currentStep > index
                          ? scheme.primary
                          : scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ScopeStep extends StatelessWidget {
  const _ScopeStep({required this.state, required this.notifier});

  final CreateRfiState state;
  final CreateRfiNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (state.initialLoadError != null) ...<Widget>[
          Card(
            color: scheme.errorContainer.withValues(alpha: 0.35),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Icon(Icons.wifi_off_rounded, color: scheme.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.initialLoadError!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: state.isLoadingItems
                        ? null
                        : notifier.retryInitialLoad,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        RfiFormDropdown(
          label: 'Project *',
          items: state.projects,
          value: state.selectedProject,
          onChanged: notifier.selectProject,
        ),
        const SizedBox(height: 16),
        RfiFormDropdown(
          label: 'Contract *',
          items: state.contracts,
          value: state.selectedContract,
          onChanged: notifier.selectContract,
          enabled: state.selectedProject != null,
          hint: state.selectedProject == null
              ? 'Select project first…'
              : 'Select…',
        ),
        const SizedBox(height: 16),
        RfiFormDropdown(
          label: 'Structure Type *',
          items: state.structureTypes,
          value: state.selectedStructureType,
          onChanged: notifier.selectStructureType,
          enabled: state.selectedContract != null,
        ),
        const SizedBox(height: 16),
        RfiFormDropdown(
          label: 'Structure *',
          items: state.structures,
          value: state.selectedStructure,
          onChanged: notifier.selectStructure,
          enabled: state.selectedStructureType != null,
        ),
        const SizedBox(height: 16),
        RfiFormDropdown(
          label: 'Component *',
          items: state.components,
          value: state.selectedComponent,
          onChanged: notifier.selectComponent,
          enabled: state.selectedStructure != null,
        ),
        const SizedBox(height: 16),
        RfiFormDropdown(
          label: 'Element *',
          items: state.elements,
          value: state.selectedElement,
          onChanged: notifier.selectElement,
          enabled: state.selectedComponent != null,
        ),
        const SizedBox(height: 16),
        RfiFormDropdown(
          label: 'Activity *',
          items: state.activities,
          value: state.selectedActivity,
          onChanged: notifier.selectActivity,
          enabled: state.selectedElement != null,
        ),
        const SizedBox(height: 16),
        RfiFormDropdown(
          label: 'RFI Description *',
          items: state.rfiDescriptions,
          value: state.selectedRfiDescription,
          onChanged: notifier.selectRfiDescription,
          enabled: state.selectedActivity != null,
        ),
      ],
    );
  }
}

class _InspectionPlanStep extends StatelessWidget {
  const _InspectionPlanStep({required this.state, required this.notifier});

  final CreateRfiState state;
  final CreateRfiNotifier notifier;

  String _todayDmy() {
    final DateTime now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime minInspection = state.typeOfRfi == 'Regular RFI'
        ? now.add(const Duration(hours: 48))
        : now;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RfiFormStringDropdown(
          label: 'Action',
          items: const <String>['Inspect', 'Review', 'Approve'],
          value: state.action,
          onChanged: notifier.setAction,
          enabled: false,
          hint: '- Select Action -',
        ),
        const SizedBox(height: 16),
        RfiFormStringDropdown(
          label: 'Type of RFI *',
          items: const <String>['Regular RFI', 'Spot RFI'],
          value: state.typeOfRfi,
          onChanged: notifier.setTypeOfRfi,
        ),
        const SizedBox(height: 16),
        RfiFormStringDropdown(
          label: 'Name of Contractor\'s Representative *',
          items: state.representatives.map((RfiDropdownItem e) => e.name).toList(),
          value: state.contractorRepresentative,
          onChanged: notifier.setContractorRepresentative,
        ),
        const SizedBox(height: 16),
        _DateField(
          label: 'Date of Submission of RFI *',
          value: state.dateOfSubmission ?? _todayDmy(),
          enabled: false,
          onChanged: notifier.setDateOfSubmission,
        ),
        const SizedBox(height: 16),
        _TimeField(
          label: 'Time Of Inspection *',
          value: state.timeOfInspection,
          onChanged: notifier.setTimeOfInspection,
        ),
        const SizedBox(height: 16),
        _DateField(
          label: 'Date of Inspection *',
          value: state.dateOfInspection,
          firstDate: minInspection,
          onChanged: notifier.setDateOfInspection,
        ),
      ],
    );
  }
}

class _EnclosuresStep extends StatefulWidget {
  const _EnclosuresStep({
    super.key,
    required this.state,
    required this.notifier,
  });

  final CreateRfiState state;
  final CreateRfiNotifier notifier;

  @override
  State<_EnclosuresStep> createState() => _EnclosuresStepState();
}

class _EnclosuresStepState extends State<_EnclosuresStep> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.state.rfiDescriptionText ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _EnclosuresStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String? next = widget.state.rfiDescriptionText;
    if (next != null &&
        next != _notesController.text &&
        next != oldWidget.state.rfiDescriptionText) {
      _notesController.text = next;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> enclosures =
        widget.state.selectedRfiDescription?.enclosures ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (enclosures.isNotEmpty) ...<Widget>[
          Text(
            'Enclosures *',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: enclosures.map((String enclosure) {
                final bool selected =
                    widget.state.selectedEnclosures.contains(enclosure);
                return CheckboxListTile(
                  value: selected,
                  onChanged: (_) => widget.notifier.toggleEnclosure(enclosure),
                  title: Text(enclosure),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'Description',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 5,
          onChanged: widget.notifier.setRfiDescriptionText,
          decoration: const InputDecoration(
            hintText: 'Enter additional notes…',
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.onChanged,
    this.value,
    this.enabled = true,
    this.firstDate,
  });

  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final DateTime? firstDate;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: !enabled
              ? null
              : () async {
                  final DateTime initial = _parseDmy(value) ?? DateTime.now();
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: initial.isBefore(firstDate ?? initial)
                        ? (firstDate ?? initial)
                        : initial,
                    firstDate: firstDate ?? DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    onChanged(
                      '${picked.day.toString().padLeft(2, '0')}-'
                      '${picked.month.toString().padLeft(2, '0')}-'
                      '${picked.year}',
                    );
                  }
                },
          child: InputDecorator(
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.calendar_today_outlined),
            ),
            child: Text(value?.isNotEmpty == true ? value! : 'dd-mm-yyyy'),
          ),
        ),
      ],
    );
  }

  DateTime? _parseDmy(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final List<String> parts = raw.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return null;
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.onChanged,
    this.value,
  });

  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final TimeOfDay initial = _parseTime(value) ?? TimeOfDay.now();
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: initial,
            );
            if (picked != null) {
              final String hour = picked.hourOfPeriod == 0
                  ? '12'
                  : picked.hourOfPeriod.toString();
              final String minute = picked.minute.toString().padLeft(2, '0');
              final String period = picked.period == DayPeriod.am ? 'AM' : 'PM';
              onChanged('$hour:$minute $period');
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.access_time_rounded),
            ),
            child: Text(value?.isNotEmpty == true ? value! : '--:--'),
          ),
        ),
      ],
    );
  }

  TimeOfDay? _parseTime(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final List<String> parts = raw.split(RegExp(r'\s+'));
      final List<String> hm = parts[0].split(':');
      var hour = int.parse(hm[0]);
      final int minute = int.parse(hm[1]);
      if (parts.length > 1) {
        if (parts[1].toUpperCase() == 'PM' && hour < 12) {
          hour += 12;
        }
        if (parts[1].toUpperCase() == 'AM' && hour == 12) {
          hour = 0;
        }
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }
}

class _CreateRfiFooter extends ConsumerWidget {
  const _CreateRfiFooter({
    required this.state,
    required this.notifier,
    required this.onSubmitted,
  });

  final CreateRfiState state;
  final CreateRfiNotifier notifier;
  final Future<void> Function() onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? blocker = notifier.validationBlockerForPrimaryAction();
    final bool canProceed = blocker == null && !state.isSubmitting;
    final bool isLast = state.currentStep == 2;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: <Widget>[
            OutlinedButton(
              onPressed: state.isDraftSaving ? null : notifier.saveDraft,
              child: state.isDraftSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save draft'),
            ),
            const SizedBox(width: 8),
            if (state.currentStep > 0)
              OutlinedButton(
                onPressed: notifier.previousStep,
                child: const Text('Back'),
              ),
            const Spacer(),
            FilledButton(
              onPressed: canProceed
                  ? () async {
                      if (isLast) {
                        await onSubmitted();
                        return;
                      }
                      final String? stepError =
                          notifier.validationBlockerForPrimaryAction();
                      if (stepError != null) {
                        await AppDialog.show(
                          context: context,
                          title: 'Missing information',
                          message: stepError,
                          type: AppDialogType.info,
                        );
                        return;
                      }
                      notifier.advanceStep();
                    }
                  : null,
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isLast ? 'Submit' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}
