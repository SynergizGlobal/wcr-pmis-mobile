import 'package:flutter/material.dart';

/// Shared compact style for pagination navigation buttons.
class AppTablePaginationStyles {
  const AppTablePaginationStyles._();

  static ButtonStyle compactNavButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      minimumSize: const Size(68, 32),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  static TextStyle metaTextStyle(BuildContext context, {bool compact = false}) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          color: cs.onSurfaceVariant.withValues(alpha: 0.88),
          fontWeight: FontWeight.w600,
          fontSize: compact ? 11 : 12,
        ) ??
        TextStyle(
          color: cs.onSurfaceVariant.withValues(alpha: 0.88),
          fontWeight: FontWeight.w600,
          fontSize: compact ? 11 : 12,
        );
  }
}

/// "Show [dropdown] entries" control used in table pagination bars.
class AppTablePageSizeSelector extends StatelessWidget {
  const AppTablePageSizeSelector({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.textStyle,
    this.compact = false,
  });

  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;
  final TextStyle? textStyle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final TextStyle style =
        textStyle ?? AppTablePaginationStyles.metaTextStyle(context, compact: compact);

    final Widget selector = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Show', style: style),
        SizedBox(width: compact ? 2 : 6),
        DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: value,
            isDense: true,
            style: style,
            items: options
                .map(
                  (int size) => DropdownMenuItem<int>(
                    value: size,
                    child: Text('$size'),
                  ),
                )
                .toList(),
            onChanged: (int? next) {
              if (next != null) {
                onChanged(next);
              }
            },
          ),
        ),
        if (!compact) ...<Widget>[
          const SizedBox(width: 4),
          Text('entries', style: style),
        ],
      ],
    );

    if (compact) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: selector,
      );
    }
    return selector;
  }
}

/// Formats the "Showing X to Y of Z entries" summary line.
class AppTablePaginationSummaryText {
  const AppTablePaginationSummaryText._();

  static String label({
    required int total,
    required int startIndex,
    required int endIndex,
    bool compact = false,
  }) {
    if (total == 0) {
      return compact ? '0 of 0' : 'Showing 0 to 0 of 0 entries';
    }
    final int displayStart = startIndex + 1;
    final int displayEnd = endIndex;
    if (compact) {
      return '$displayStart-$displayEnd of $total';
    }
    return 'Showing $displayStart to $displayEnd of $total entries';
  }
}

/// Top row: page-size selector (optional) + entry summary, always one row.
class AppTablePaginationMetaRow extends StatelessWidget {
  const AppTablePaginationMetaRow({
    super.key,
    required this.total,
    required this.startIndex,
    required this.endIndex,
    this.pageSize,
    this.pageSizeOptions = const <int>[5, 10, 25, 50],
    this.onPageSizeChanged,
  });

  final int total;
  final int startIndex;
  final int endIndex;
  final int? pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int>? onPageSizeChanged;

  bool get _hasPageSize =>
      pageSize != null && onPageSizeChanged != null;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final bool compactControls = width < 400;
        final bool compactSummary = width < 480;
        final TextStyle metaStyle = AppTablePaginationStyles.metaTextStyle(
          context,
          compact: compactControls,
        );
        final String summary = AppTablePaginationSummaryText.label(
          total: total,
          startIndex: startIndex,
          endIndex: endIndex,
          compact: compactSummary,
        );

        final Widget summaryText = Text(
          summary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: metaStyle,
        );

        final double summaryReserve = compactSummary ? 108.0 : 220.0;

        if (!_hasPageSize) {
          return Align(
            alignment: Alignment.centerRight,
            child: summaryText,
          );
        }

        return SizedBox(
          width: width,
          height: 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: summaryReserve,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AppTablePageSizeSelector(
                      value: pageSize!,
                      options: pageSizeOptions,
                      onChanged: onPageSizeChanged!,
                      textStyle: metaStyle,
                      compact: compactControls,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(child: summaryText),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Bottom row: Prev, page indicator, Next.
class AppTablePaginationNavRow extends StatelessWidget {
  const AppTablePaginationNavRow({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.total,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int pageCount;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final int displayPage = total == 0 ? 0 : currentPage + 1;
    final int displayPages = pageCount == 0 ? 1 : pageCount;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 360;
        final Widget nav = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: onPrevious,
              style: AppTablePaginationStyles.compactNavButtonStyle(context),
              icon: Icon(Icons.chevron_left_rounded, size: compact ? 16 : 18),
              label: Text('Prev', style: TextStyle(fontSize: compact ? 11 : 12)),
            ),
            SizedBox(width: compact ? 6 : 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Page $displayPage of $displayPages',
                style: tt.bodySmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 11 : 12,
                ),
              ),
            ),
            SizedBox(width: compact ? 6 : 8),
            OutlinedButton.icon(
              onPressed: onNext,
              style: AppTablePaginationStyles.compactNavButtonStyle(context),
              iconAlignment: IconAlignment.end,
              icon: Icon(Icons.chevron_right_rounded, size: compact ? 16 : 18),
              label: Text('Next', style: TextStyle(fontSize: compact ? 11 : 12)),
            ),
          ],
        );

        if (!compact) {
          return nav;
        }
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: nav,
        );
      },
    );
  }
}

/// Reusable sticky table pagination bar:
/// 1) page-size + summary row
/// 2) prev / next row
class AppTablePaginationBar extends StatelessWidget {
  const AppTablePaginationBar({
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

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppTablePaginationMetaRow(
              total: total,
              startIndex: startIndex,
              endIndex: endIndex,
              pageSize: pageSize,
              pageSizeOptions: pageSizeOptions,
              onPageSizeChanged: onPageSizeChanged,
            ),
            const SizedBox(height: 8),
            AppTablePaginationNavRow(
              total: total,
              currentPage: currentPage,
              pageCount: pageCount,
              onPrevious: onPrevious,
              onNext: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
