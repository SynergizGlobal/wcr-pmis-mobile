import 'package:flutter/material.dart';

class RfiTableSearchHeader extends StatelessWidget {
  const RfiTableSearchHeader({
    super.key,
    required this.onSearchChanged,
    this.searchHint = 'Search RFI…',
  });

  final ValueChanged<String> onSearchChanged;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return TextField(
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: searchHint,
        prefixIcon: Icon(Icons.search, color: scheme.onSurfaceVariant),
      ),
    );
  }
}
