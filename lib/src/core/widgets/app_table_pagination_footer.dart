import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_bar.dart';

/// Sticky footer wrapper around [AppTablePaginationBar] for paginated tables.
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

  /// Kept for screens that referenced the old static style.
  static ButtonStyle compactNavButtonStyle(BuildContext context) {
    return AppTablePaginationStyles.compactNavButtonStyle(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppTablePaginationBar(
      total: total,
      startIndex: startIndex,
      endIndex: endIndex,
      currentPage: currentPage,
      pageCount: pageCount,
      onPrevious: onPrevious,
      onNext: onNext,
      pageSize: pageSize,
      pageSizeOptions: pageSizeOptions,
      onPageSizeChanged: onPageSizeChanged,
    );
  }
}
