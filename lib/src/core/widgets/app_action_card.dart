import 'package:flutter/material.dart';

class AppActionCard extends StatelessWidget {
  const AppActionCard({
    super.key,
    required this.title,
    this.icon,
    this.leftPlaceholder,
    this.rightPlaceholder,
    this.onTap,
    this.showLeading = true,
    this.titleMaxLines = 1,
  });

  final String title;
  final IconData? icon;
  final Widget? leftPlaceholder;
  final Widget? rightPlaceholder;
  final VoidCallback? onTap;
  final bool showLeading;
  final int titleMaxLines;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: <Widget>[
              if (showLeading) ...<Widget>[
                if (leftPlaceholder != null)
                  leftPlaceholder!
                else
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: colorScheme.primary.withValues(alpha: 0.14),
                    ),
                    child: Icon(
                      icon ?? Icons.widgets_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  maxLines: titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              rightPlaceholder ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
