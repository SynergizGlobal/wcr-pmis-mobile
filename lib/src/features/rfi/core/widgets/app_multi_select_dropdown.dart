import 'package:flutter/material.dart';

class AppMultiSelectDropdown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final List<T> items;
  final String Function(T) itemLabel;
  final List<T> selectedItems;
  final void Function(List<T>) onChanged;

  const AppMultiSelectDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.itemLabel,
    required this.selectedItems,
    required this.onChanged,
  });

  @override
  AppMultiSelectDropdownState<T> createState() =>
      AppMultiSelectDropdownState<T>();
}

class AppMultiSelectDropdownState<T> extends State<AppMultiSelectDropdown<T>> {
  late List<T> _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = List.from(widget.selectedItems);
  }

  @override
  void didUpdateWidget(AppMultiSelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItems != oldWidget.selectedItems) {
      _localSelected = List.from(widget.selectedItems);
    }
  }

  void _showMultiSelect(BuildContext context) async {
    final List<T>? results = await showDialog<List<T>>(
      context: context,
      builder: (BuildContext context) {
        return _MultiSelectDialog<T>(
          items: widget.items,
          initialSelectedItems: _localSelected,
          itemLabel: widget.itemLabel,
        );
      },
    );

    if (results != null) {
      setState(() {
        _localSelected = results;
      });
      widget.onChanged(_localSelected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final displayString = _localSelected.isEmpty
        ? widget.hint
        : _localSelected.map((e) => widget.itemLabel(e)).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showMultiSelect(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(4),
              color: scheme.surfaceContainerHighest,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    displayString,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: _localSelected.isEmpty
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MultiSelectDialog<T> extends StatefulWidget {
  final List<T> items;
  final List<T> initialSelectedItems;
  final String Function(T) itemLabel;

  const _MultiSelectDialog({
    required this.items,
    required this.initialSelectedItems,
    required this.itemLabel,
  });

  @override
  _MultiSelectDialogState<T> createState() => _MultiSelectDialogState<T>();
}

class _MultiSelectDialogState<T> extends State<_MultiSelectDialog<T>> {
  late Set<T> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.initialSelectedItems.toSet();
  }

  void _onItemCheckedChange(T item, bool checked) {
    setState(() {
      if (checked) {
        _selectedItems.add(item);
      } else {
        _selectedItems.remove(item);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedItems.toList());
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      title: Text(
        'Select items',
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      contentPadding: const EdgeInsets.only(top: 12, bottom: 4),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = widget.items[index];
            return CheckboxListTile(
              value: _selectedItems.contains(item),
              title: Text(
                widget.itemLabel(item),
                style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (checked) =>
                  _onItemCheckedChange(item, checked ?? false),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _onCancelTap,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onSubmitTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text('Ok'),
        ),
      ],
    );
  }
}
