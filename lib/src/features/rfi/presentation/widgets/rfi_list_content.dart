import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wcr_pmis_mobile/src/core/network/user_friendly_error_message.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_list_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/rfi_list_kind.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/utils/rfi_user_role.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/providers/rfi_providers.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_list_actions.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_list_table_config.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_theme.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/widgets/rfi_action_menu.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/widgets/rfi_table_pagination_footer.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/widgets/rfi_table_search_header.dart';

class RfiListContent extends ConsumerStatefulWidget {
  const RfiListContent({
    super.key,
    required this.kind,
    this.padding = const EdgeInsets.fromLTRB(12, 0, 12, 0),
  });

  final RfiListKind kind;
  final EdgeInsets padding;

  @override
  ConsumerState<RfiListContent> createState() => _RfiListContentState();
}

class _RfiListContentState extends ConsumerState<RfiListContent> {
  String _search = '';
  int _rowsPerPage = 10;
  int _currentPage = 1;

  void _refreshList() {
    ref.invalidate(rfiListProvider(widget.kind));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AsyncValue<List<RfiListItem>> listAsync =
        ref.watch(rfiListProvider(widget.kind));
    final RfiUserRole role = RfiListActions.roleFromSession(
      ref.watch(authControllerProvider).valueOrNull,
    );
    final List<RfiTableColumn> columns =
        RfiListTableConfig.columnsFor(widget.kind);

    return listAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.error_outline, size: 48, color: scheme.error),
              const SizedBox(height: 12),
              Text(
                'Failed to load RFIs',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                userFriendlyErrorMessage(error),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _refreshList,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (List<RfiListItem> items) {
        final List<RfiListItem> filtered = items
            .where((RfiListItem item) => item.matchesSearch(_search))
            .toList();
        final int total = filtered.length;
        final int totalPages = total == 0 ? 1 : (total / _rowsPerPage).ceil();
        if (_currentPage > totalPages) {
          _currentPage = totalPages;
        }
        if (_currentPage < 1) {
          _currentPage = 1;
        }
        final int start = total == 0 ? 0 : (_currentPage - 1) * _rowsPerPage;
        final int end = total == 0
            ? 0
            : (start + _rowsPerPage).clamp(0, total);
        final List<RfiListItem> pageItems = total == 0
            ? const <RfiListItem>[]
            : filtered.sublist(start, end);

        return Column(
          children: <Widget>[
            Padding(
              padding: widget.padding.copyWith(top: 12, bottom: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: RfiTableSearchHeader(
                    onSearchChanged: (String value) {
                      setState(() {
                        _search = value.trim();
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _refreshList();
                  await ref.read(rfiListProvider(widget.kind).future);
                },
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double tableWidth = columns.fold<double>(
                          0,
                          (double sum, RfiTableColumn c) => sum + c.width,
                        ) +
                        RfiListTableConfig.actionWidth;
                    final EdgeInsets tablePadding =
                        widget.padding.copyWith(bottom: 8);
                    final double minScrollWidth =
                        tableWidth + tablePadding.horizontal;
                    return SizedBox(
                      height: constraints.maxHeight,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: math.max(constraints.maxWidth, minScrollWidth),
                          child: Padding(
                            padding: tablePadding,
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              margin: EdgeInsets.zero,
                              child: _RfiDataTable(
                                columns: columns,
                                items: pageItems,
                                role: role,
                                onRefresh: _refreshList,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            RfiTablePaginationFooter(
              startIndex: start,
              endIndex: end,
              totalItems: total,
              currentPage: _currentPage,
              totalPages: totalPages,
              pageSize: _rowsPerPage,
              onPageSizeChanged: (int value) => setState(() {
                _rowsPerPage = value;
                _currentPage = 1;
              }),
              onPageChanged: (int page) => setState(() => _currentPage = page),
            ),
          ],
        );
      },
    );
  }
}

class _RfiDataTable extends StatelessWidget {
  const _RfiDataTable({
    required this.columns,
    required this.items,
    required this.role,
    required this.onRefresh,
  });

  final List<RfiTableColumn> columns;
  final List<RfiListItem> items;
  final RfiUserRole role;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (items.isEmpty) {
      return SizedBox(
        height: 200,
        width: columns.fold<double>(
              0,
              (double sum, RfiTableColumn c) => sum + c.width,
            ) +
            RfiListTableConfig.actionWidth,
        child: Center(
          child: Text(
            'No RFIs match your filters.',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          color: RfiTheme.tableHeaderBackground(scheme),
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: <Widget>[
              for (final RfiTableColumn column in columns)
                _headerCell(context, column.label, column.width),
              _headerCell(context, 'Action', RfiListTableConfig.actionWidth),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                color: RfiTheme.tableRowBackground(scheme, even: index.isEven),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final RfiTableColumn column in columns)
                      _dataCellText(
                        context,
                        column.value(items[index]),
                        column.width,
                      ),
                    _dataCellWidget(
                      context,
                      RfiActionMenu(
                        actions: RfiListActions.build(
                          context: context,
                          item: items[index],
                          role: role,
                          onRefresh: onRefresh,
                        ),
                      ),
                      RfiListTableConfig.actionWidth,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _headerCell(BuildContext context, String text, double width) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextStyle? style = RfiTheme.tableHeaderTextStyle(
      Theme.of(context).textTheme,
      scheme,
    );
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ),
    );
  }

  Widget _dataCellWidget(BuildContext context, Widget child, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Center(child: child),
      ),
    );
  }

  Widget _dataCellText(BuildContext context, String text, double width) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextStyle? style = RfiTheme.tableCellTextStyle(
      Theme.of(context).textTheme,
      scheme,
    );
    return _dataCellWidget(
      context,
      Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
      width,
    );
  }
}
