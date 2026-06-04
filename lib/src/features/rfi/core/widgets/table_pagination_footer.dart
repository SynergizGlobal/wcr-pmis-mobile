import 'package:flutter/material.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_table_pagination_footer.dart';

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
    return AppTablePaginationFooter(
      total: totalItems,
      startIndex: startIndex,
      endIndex: endIndex,
      currentPage: currentPage - 1,
      pageCount: totalPages,
      onPrevious: currentPage > 1
          ? () => onPageChanged(currentPage - 1)
          : null,
      onNext: currentPage < totalPages
          ? () => onPageChanged(currentPage + 1)
          : null,
    );
  }
}
