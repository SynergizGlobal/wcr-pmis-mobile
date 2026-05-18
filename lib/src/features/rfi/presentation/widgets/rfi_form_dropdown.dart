import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/data/mappers/rfi_dropdown_mapper.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_dropdown_item.dart';

class RfiFormDropdown extends StatelessWidget {
  const RfiFormDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint = 'Select…',
    this.enabled = true,
  });

  final String label;
  final List<RfiDropdownItem> items;
  final RfiDropdownItem? value;
  final ValueChanged<RfiDropdownItem?> onChanged;
  final String hint;
  final bool enabled;

  static RfiDropdownItem? _resolveSelected(
    RfiDropdownItem? selected,
    List<RfiDropdownItem> options,
  ) {
    if (selected == null || options.isEmpty) {
      return null;
    }
    for (final RfiDropdownItem option in options) {
      if (identical(option, selected)) {
        return option;
      }
    }
    for (final RfiDropdownItem option in options) {
      if (option.id == selected.id) {
        return option;
      }
    }
    for (final RfiDropdownItem option in options) {
      if (option.name == selected.name) {
        return option;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<RfiDropdownItem> options =
        RfiDropdownMapper.dedupeById(items);
    final RfiDropdownItem? selected = _resolveSelected(value, options);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        DropdownButtonFormField<RfiDropdownItem>(
          value: selected,
          isExpanded: true,
          hint: Text(hint),
          decoration: const InputDecoration(),
          items: options
              .map(
                (RfiDropdownItem item) => DropdownMenuItem<RfiDropdownItem>(
                  value: item,
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}

class RfiFormStringDropdown extends StatelessWidget {
  const RfiFormStringDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint = 'Select…',
    this.enabled = true,
  });

  final String label;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<String> options = items.toSet().toList();
    final String? selected =
        value != null && options.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: selected,
          isExpanded: true,
          hint: Text(hint),
          decoration: const InputDecoration(),
          items: options
              .map(
                (String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
