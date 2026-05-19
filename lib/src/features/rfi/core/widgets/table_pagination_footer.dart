import 'package:flutter/material.dart';

class TablePaginationFooter extends StatelessWidget {
  const TablePaginationFooter({
    super.key,
    required this.startIndex,
    required this.endIndex,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int startIndex;
  final int endIndex;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color primaryColor = scheme.primary;
    final bool isNoItems = totalItems == 0;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                children: <InlineSpan>[
                  const TextSpan(text: 'Showing '),
                  TextSpan(
                    text: '${isNoItems ? 0 : startIndex + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const TextSpan(text: ' to '),
                  TextSpan(
                    text: '$endIndex',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const TextSpan(text: ' of '),
                  TextSpan(
                    text: '$totalItems',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const TextSpan(text: ' entries'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildNavButton(
                  context: context,
                  onPressed: currentPage > 1
                      ? () => onPageChanged(currentPage - 1)
                      : null,
                  icon: Icons.arrow_back_ios_new_rounded,
                  label: 'Prev',
                  isForward: false,
                  primaryColor: primaryColor,
                ),
                const SizedBox(width: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                      children: <InlineSpan>[
                        const TextSpan(text: 'Page '),
                        TextSpan(
                          text: '$currentPage',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const TextSpan(text: ' of '),
                        TextSpan(
                          text: '${totalPages == 0 ? 1 : totalPages}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                _buildNavButton(
                  context: context,
                  onPressed: currentPage < totalPages
                      ? () => onPageChanged(currentPage + 1)
                      : null,
                  icon: Icons.arrow_forward_ios_rounded,
                  label: 'Next',
                  isForward: true,
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required bool isForward,
    required Color primaryColor,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isEnabled = onPressed != null;
    final Color disabledColor = scheme.onSurfaceVariant.withValues(alpha: 0.4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: isEnabled ? primaryColor : scheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isEnabled
                ? Colors.transparent
                : scheme.surfaceContainerHighest,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (!isForward)
                Icon(
                  icon,
                  size: 18,
                  color: isEnabled ? primaryColor : disabledColor,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isEnabled ? primaryColor : disabledColor,
                      ),
                ),
              ),
              if (isForward)
                Icon(
                  icon,
                  size: 18,
                  color: isEnabled ? primaryColor : disabledColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
