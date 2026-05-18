import 'package:flutter/material.dart';

class RfiTableSearchHeader extends StatelessWidget {
  const RfiTableSearchHeader({
    super.key,
    required this.rowsPerPage,
    required this.onRowsPerPageChanged,
    required this.onSearchChanged,
    this.availableRowsPerPage = const <int>[5, 10, 25, 50],
    this.searchHint = 'Search RFI…',
  });

  final int rowsPerPage;
  final ValueChanged<int?> onRowsPerPageChanged;
  final ValueChanged<String> onSearchChanged;
  final List<int> availableRowsPerPage;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: searchHint,
            prefixIcon: Icon(Icons.search, color: scheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 12),
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.6)),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Text('Show', style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            )),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: rowsPerPage,
              items: availableRowsPerPage
                  .map(
                    (int value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value'),
                    ),
                  )
                  .toList(),
              onChanged: onRowsPerPageChanged,
            ),
            const SizedBox(width: 8),
            Text('entries', style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ],
    );
  }
}
