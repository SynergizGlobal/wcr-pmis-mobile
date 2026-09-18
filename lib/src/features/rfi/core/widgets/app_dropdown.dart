import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/common/filter_option.dart';

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

  /// Prefer a single entry per logical option (FilterOption → by id).
  List<T> _uniqueItems(List<T> source) {
    if (source.isEmpty) return source;

    if (source.first is FilterOption) {
      final Map<String, FilterOption> byId = <String, FilterOption>{};
      for (final T item in source) {
        final FilterOption option = item as FilterOption;
        final String id = option.id.trim();
        if (id.isEmpty) continue;
        final FilterOption? existing = byId[id];
        if (existing == null ||
            (existing.name == existing.id && option.name != option.id) ||
            option.name.length > existing.name.length) {
          byId[id] = option;
        }
      }
      return byId.values.toList().cast<T>();
    }

    final List<T> unique = <T>[];
    for (final T item in source) {
      if (!unique.contains(item)) {
        unique.add(item);
      }
    }
    return unique;
  }

  String _itemsIdentityKey(List<T> uniqueItems) {
    if (uniqueItems.isEmpty) return 'empty';
    if (uniqueItems.first is FilterOption) {
      return uniqueItems
          .map((T e) => (e as FilterOption).id)
          .join('|');
    }
    return uniqueItems.map((T e) => e.hashCode).join('|');
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<T> uniqueItems = _uniqueItems(items);
    final T? resolvedValue = _resolveValue(value, uniqueItems);

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
          // Reset FormField when options change so a stale value cannot
          // assert against a rebuilt items list.
          key: ValueKey<String>('dd-${_itemsIdentityKey(uniqueItems)}'),
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
                      color: identical(item, resolvedValue) || item == resolvedValue
                          ? scheme.primary
                          : scheme.onSurface,
                      fontWeight:
                          identical(item, resolvedValue) || item == resolvedValue
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

  // FilterOption: match by id, return the exact instance from [options].
  if (selected is FilterOption) {
    final String selectedId = selected.id.trim();
    if (selectedId.isEmpty) return null;
    for (final T option in options) {
      if (option is FilterOption && option.id == selectedId) {
        return option;
      }
    }
    return null;
  }

  for (final T option in options) {
    if (option == selected) {
      return option;
    }
  }
  return null;
}
