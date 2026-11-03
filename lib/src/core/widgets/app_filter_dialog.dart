import 'package:flutter/material.dart';

/// Mobile-friendly full-width filter dialog for [showDialog].
///
/// Uses tight horizontal [Dialog.insetPadding] so content is not squeezed into
/// a narrow column with large side gutters (default [AlertDialog] behavior).
class AppFilterDialog extends StatelessWidget {
  const AppFilterDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.insetPadding,
    this.titlePadding,
    this.contentPadding,
    this.actionsPadding,
    this.maxHeightFactor = 0.85,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;
  final EdgeInsets? insetPadding;
  final EdgeInsets? titlePadding;
  final EdgeInsets? contentPadding;
  final EdgeInsets? actionsPadding;
  final double maxHeightFactor;

  static const EdgeInsets defaultInsetPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 24,
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double maxHeight =
        MediaQuery.sizeOf(context).height * maxHeightFactor;

    return Dialog(
      insetPadding: insetPadding ?? defaultInsetPadding,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding:
                  titlePadding ?? const EdgeInsets.fromLTRB(20, 12, 4, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: Text(
                        title,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding:
                    contentPadding ??
                    const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: content,
              ),
            ),
            Padding(
              padding:
                  actionsPadding ?? const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
