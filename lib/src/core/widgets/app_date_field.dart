import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_form_field_style.dart';

class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.placeholderText = 'dd/mm/yyyy',
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final bool enabled;
  final String placeholderText;
  final DateTime? firstDate;
  final DateTime? lastDate;

  static final DateFormat displayFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat apiFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool filled = value != null;
    final String display = filled
        ? displayFormat.format(value!)
        : placeholderText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: !enabled ? null : () => _pickDate(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (label.trim().isNotEmpty) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 8),
                child: Text(
                  label,
                  style: AppFormFieldStyle.labelStyle(context),
                ),
              ),
            ],
            InputDecorator(
              decoration: AppFormFieldStyle.decoration(
                context,
                filled: filled,
                enabled: enabled,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 22),
              ),
              child: Text(
                display,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFormFieldStyle.valueStyle(context, filled: filled)
                    .copyWith(
                  color: filled
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(now.year - 20),
      lastDate: lastDate ?? DateTime(now.year + 20),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }
}
