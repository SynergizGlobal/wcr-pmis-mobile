import 'package:flutter/material.dart';
import 'app_dropdown.dart';

class TableSearchHeader extends StatelessWidget {
  const TableSearchHeader({
    super.key,
    required this.rowsPerPage,
    required this.onRowsPerPageChanged,
    required this.onSearchChanged,
    this.availableRowsPerPage = const <int>[5, 10, 25, 50],
    this.searchHint = 'Search...',
  });

  final int rowsPerPage;
  final ValueChanged<int?> onRowsPerPageChanged;
  final ValueChanged<String> onSearchChanged;
  final List<int> availableRowsPerPage;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        ),
        const SizedBox(height: 16),
        Divider(height: 1, color: scheme.outlineVariant),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Show',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(width: 8),
            AppDropdown<int>(
              value: rowsPerPage,
              items: availableRowsPerPage,
              itemLabel: (int v) => v.toString(),
              width: 80,
              onChanged: onRowsPerPageChanged,
            ),
            const SizedBox(width: 8),
            Text(
              'entries',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
