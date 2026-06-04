import 'package:flutter/material.dart';

class AppTablePaginationFooter extends StatelessWidget {
  const AppTablePaginationFooter({
    super.key,
    required this.total,
    required this.startIndex,
    required this.endIndex,
    required this.currentPage,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
    this.pageSize,
    this.pageSizeOptions = const <int>[5, 10, 25, 50],
    this.onPageSizeChanged,
  });

  final int total;
  final int startIndex;
  final int endIndex;
  final int currentPage;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final int? pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int>? onPageSizeChanged;

  static ButtonStyle get compactNavButtonStyle => OutlinedButton.styleFrom(
        minimumSize: const Size(68, 32),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      );

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final TextStyle? metaStyle = tt.bodySmall?.copyWith(
      color: cs.onSurfaceVariant.withValues(alpha: 0.88),
      fontWeight: FontWeight.w600,
      fontSize: 12,
    );
    final int displayStart = total == 0 ? 0 : startIndex + 1;
    final int displayEnd = total == 0 ? 0 : endIndex;
    final int displayPage = total == 0 ? 0 : currentPage + 1;
    final int displayPages = pageCount == 0 ? 1 : pageCount;
    final String summary = total == 0
        ? 'Showing 0 to 0 of 0 entries'
        : 'Showing $displayStart to $displayEnd of $total entries';

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(
            top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (pageSize != null && onPageSizeChanged != null) ...<Widget>[
                  Text('Show', style: metaStyle),
                  const SizedBox(width: 6),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: pageSize,
                      isDense: true,
                      style: metaStyle,
                      items: pageSizeOptions
                          .map(
                            (int size) => DropdownMenuItem<int>(
                              value: size,
                              child: Text('$size'),
                            ),
                          )
                          .toList(),
                      onChanged: (int? value) {
                        if (value != null) {
                          onPageSizeChanged!(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('entries', style: metaStyle),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    summary,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: metaStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: onPrevious,
                  style: compactNavButtonStyle,
                  icon: const Icon(Icons.chevron_left_rounded, size: 18),
                  label: const Text('Prev', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Page $displayPage of $displayPages',
                    style: tt.bodySmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onNext,
                  style: compactNavButtonStyle,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.chevron_right_rounded, size: 18),
                  label: const Text('Next', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
