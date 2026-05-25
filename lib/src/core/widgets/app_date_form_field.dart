import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_form_field_style.dart';

class AppDateFormField extends StatelessWidget {
  const AppDateFormField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder = 'Select date',
    this.enabled = true,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final String placeholder;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool filled = value != null;
    final String display =
        filled ? _formatDate(value!) : placeholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        InkWell(
          borderRadius: BorderRadius.circular(AppFormFieldStyle.borderRadius),
          onTap: enabled ? onTap : null,
          child: InputDecorator(
            decoration: AppFormFieldStyle.decoration(
              context,
              filled: filled,
              enabled: enabled,
              suffixIcon: const Icon(Icons.calendar_today_rounded),
            ),
            child: Text(
              display,
              style: AppFormFieldStyle.valueStyle(context, filled: filled),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
