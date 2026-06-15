import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_form_field_style.dart';

class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    super.key,
    required this.label,
    this.controller,
    this.hintText = 'Enter here...',
    this.readOnly = false,
    this.enabled = true,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.focusNode,
    this.prefixIcon,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController? controller;
  final String hintText;
  final bool readOnly;
  final bool enabled;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  FocusNode? _ownedFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? _ownedFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _ownedFocusNode = FocusNode();
    }
    widget.controller?.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant AppTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_rebuild);
      widget.controller?.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_rebuild);
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool filled = AppFormFieldStyle.hasText(
      controller: widget.controller,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.label.trim().isNotEmpty) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              widget.label,
              style: AppFormFieldStyle.labelStyle(context),
            ),
          ),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          onChanged: widget.onChanged,
          style: AppFormFieldStyle.valueStyle(context, filled: filled),
          buildCounter: widget.maxLength == null
              ? null
              : (
                  BuildContext context, {
                  required int currentLength,
                  required bool isFocused,
                  required int? maxLength,
                }) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$currentLength/${maxLength ?? widget.maxLength}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
          decoration: AppFormFieldStyle.decoration(
            context,
            filled: filled,
            enabled: widget.enabled,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
          ),
        ),
      ],
    );
  }
}
