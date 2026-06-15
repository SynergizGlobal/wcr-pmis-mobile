import 'package:flutter/material.dart';

class TableSearchHeader extends StatelessWidget {
  const TableSearchHeader({
    super.key,
    required this.onSearchChanged,
    this.searchHint = 'Search...',
  });

  final ValueChanged<String> onSearchChanged;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return TextField(
      onChanged: onSearchChanged,
      style: Theme.of(context).textTheme.bodySmall,
      decoration: InputDecoration(
        hintText: searchHint,
        hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
        prefixIcon: Icon(
          Icons.search,
          color: scheme.onSurfaceVariant,
          size: 20,
        ),
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
