import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    this.label,
    this.hint = '-- Select --',
    required this.value,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.width,
    this.enabled = true,
  });

  final String? label;
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?)? onChanged;
  final double? width;
  final bool enabled;

  List<T> _uniqueItems(List<T> source) {
    final unique = <T>[];
    for (final item in source) {
      if (!unique.contains(item)) {
        unique.add(item);
      }
    }
    return unique;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final uniqueItems = _uniqueItems(items);
    final resolvedValue = _resolveValue(value, uniqueItems);

    final Widget dropdown = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (label != null) ...<Widget>[
          Text(
            label!,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
        ],
        DropdownButtonFormField<T>(
          value: resolvedValue,
          isExpanded: true,
          hint: Text(
            hint,
            style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
          dropdownColor: scheme.surface,
          iconEnabledColor: scheme.onSurfaceVariant,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: enabled
                ? scheme.surfaceContainerHighest
                : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: scheme.primary, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          items: uniqueItems
              .map(
                (T item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: textTheme.bodyMedium?.copyWith(
                      color: item == resolvedValue
                          ? scheme.primary
                          : scheme.onSurface,
                      fontWeight: item == resolvedValue
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );

    if (width != null) {
      return SizedBox(width: width, child: dropdown);
    }
    return dropdown;
  }

}

T? _resolveValue<T>(T? selected, List<T> options) {
  if (selected == null || options.isEmpty) {
    return null;
  }
  for (final T option in options) {
    if (option == selected) {
      return option;
    }
  }
  return null;
}
