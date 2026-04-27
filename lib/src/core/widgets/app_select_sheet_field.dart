import 'package:flutter/material.dart';

class AppSelectSheetField<T> extends StatelessWidget {
  const AppSelectSheetField({
    super.key,
    required this.label,
    required this.title,
    required this.items,
    required this.itemLabelBuilder,
    required this.value,
    required this.onChanged,
    this.leadingIcon,
    this.enabled = true,
    this.placeholderText = 'Select',
  });

  final String label;
  final String title;
  final List<T> items;
  final String Function(T value) itemLabelBuilder;
  final T? value;
  final ValueChanged<T> onChanged;
  final IconData? leadingIcon;
  final bool enabled;
  final String placeholderText;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String selectedLabel = value != null
        ? itemLabelBuilder(value as T)
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: !enabled
            ? null
            : () async {
                final T? selected = await showModalBottomSheet<T>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  showDragHandle: false,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    final TextTheme textTheme = Theme.of(context).textTheme;
                    final bool isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    final double maxSheetHeight =
                        MediaQuery.of(context).size.height * 0.58;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxSheetHeight),
                        child: Material(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 10),
                              Center(
                                child: Container(
                                  width: 46,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  16,
                                  10,
                                ),
                                child: Text(
                                  title,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: Theme.of(context).dividerColor,
                              ),
                              Expanded(
                                child: ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    10,
                                    10,
                                    14,
                                  ),
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: items.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const SizedBox(height: 8),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                        final T item = items[index];
                                        final String label = itemLabelBuilder(
                                          item,
                                        );
                                        final bool isSelected = item == value;
                                        final Color selectedTileColor = isDark
                                            ? colorScheme.primary.withValues(
                                                alpha: 0.22,
                                              )
                                            : colorScheme.primary.withValues(
                                                alpha: 0.22,
                                              );
                                        final Color unselectedTileColor = isDark
                                            ? colorScheme
                                                  .surfaceContainerHighest
                                                  .withValues(alpha: 0.20)
                                            : colorScheme
                                                  .surfaceContainerHighest
                                                  .withValues(alpha: 0.10);
                                        return ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 6,
                                              ),
                                          tileColor: isSelected
                                              ? selectedTileColor
                                              : unselectedTileColor,
                                          title: Text(
                                            label,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                          trailing: isSelected
                                              ? Icon(
                                                  Icons.check_circle_rounded,
                                                  color: colorScheme.primary,
                                                )
                                              : null,
                                          onTap: () =>
                                              Navigator.of(context).pop(item),
                                        );
                                      },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
                if (selected != null) {
                  onChanged(selected);
                }
              },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (label.trim().isNotEmpty) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 8),
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
            InputDecorator(
              decoration: InputDecoration(
                prefixIcon: leadingIcon != null ? Icon(leadingIcon) : null,
                suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabled: enabled,
              ),
              child: Text(
                selectedLabel.isEmpty ? placeholderText : selectedLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selectedLabel.isEmpty
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
