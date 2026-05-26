import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_form_field_style.dart';

class AppCompactTextFormField extends StatefulWidget {
  const AppCompactTextFormField({
    super.key,
    required this.controller,
    this.hintText = 'Enter here...',
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  State<AppCompactTextFormField> createState() =>
      _AppCompactTextFormFieldState();
}

class _AppCompactTextFormFieldState extends State<AppCompactTextFormField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
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

    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      style: AppFormFieldStyle.valueStyle(context, filled: filled).copyWith(
        fontSize: 13,
      ),
      decoration: AppFormFieldStyle.decoration(
        context,
        filled: filled,
        enabled: widget.enabled,
        hintText: widget.hintText,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }
}

class AppCompactDropdownField<T> extends StatelessWidget {
  const AppCompactDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    this.hintText = 'Select',
    this.enabled = true,
    this.onChanged,
  });

  final T? value;
  final List<T> items;
  final String Function(T item) itemLabelBuilder;
  final String hintText;
  final bool enabled;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final bool filled = value != null;
    final TextStyle itemStyle = AppFormFieldStyle.valueStyle(
      context,
      filled: true,
    ).copyWith(fontSize: 13);

    return DropdownButtonFormField<T>(
      isExpanded: true,
      value: value,
      iconSize: 20,
      hint: Text(
        hintText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppFormFieldStyle.hintStyle(context).copyWith(fontSize: 13),
      ),
      decoration: AppFormFieldStyle.decoration(
        context,
        filled: filled,
        enabled: enabled,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      selectedItemBuilder: (BuildContext context) {
        return items
            .map(
              (T item) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  itemLabelBuilder(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: itemStyle,
                ),
              ),
            )
            .toList();
      },
      items: items
          .map(
            (T item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabelBuilder(item),
                style: itemStyle,
              ),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}
