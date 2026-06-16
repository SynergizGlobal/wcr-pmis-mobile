import 'package:flutter/material.dart';

/// Horizontally scrollable table with a fixed leading column that stays visible
/// while the remaining columns scroll.
class AppStickyLeadingColumnTable extends StatefulWidget {
  const AppStickyLeadingColumnTable({
    super.key,
    required this.leadingWidth,
    required this.scrollableWidth,
    required this.leadingHeader,
    required this.scrollableHeader,
    required this.itemCount,
    required this.leadingRowBuilder,
    required this.scrollableRowBuilder,
    this.emptyPlaceholder,
    this.rowExtent = 52,
  });

  final double leadingWidth;
  final double scrollableWidth;
  final Widget leadingHeader;
  final Widget scrollableHeader;
  final int itemCount;
  final Widget Function(BuildContext context, int index) leadingRowBuilder;
  final Widget Function(BuildContext context, int index) scrollableRowBuilder;
  final Widget? emptyPlaceholder;
  final double rowExtent;

  @override
  State<AppStickyLeadingColumnTable> createState() =>
      _AppStickyLeadingColumnTableState();
}

class _AppStickyLeadingColumnTableState
    extends State<AppStickyLeadingColumnTable> {
  late final ScrollController _dataVerticalController;
  late final ScrollController _leadingVerticalController;
  bool _syncingScroll = false;

  @override
  void initState() {
    super.initState();
    _dataVerticalController = ScrollController();
    _leadingVerticalController = ScrollController();
    _dataVerticalController.addListener(_syncLeadingColumnScroll);
  }

  @override
  void dispose() {
    _dataVerticalController.removeListener(_syncLeadingColumnScroll);
    _dataVerticalController.dispose();
    _leadingVerticalController.dispose();
    super.dispose();
  }

  void _syncLeadingColumnScroll() {
    if (_syncingScroll || !_leadingVerticalController.hasClients) {
      return;
    }
    _syncingScroll = true;
    _leadingVerticalController.jumpTo(_dataVerticalController.offset);
    _syncingScroll = false;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (widget.itemCount == 0 && widget.emptyPlaceholder != null) {
      return SizedBox.expand(child: widget.emptyPlaceholder!);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              right: BorderSide(color: colorScheme.outlineVariant),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.12),
                offset: const Offset(2, 0),
                blurRadius: 4,
              ),
            ],
          ),
          child: SizedBox(
            width: widget.leadingWidth,
            child: Column(
              children: <Widget>[
                widget.leadingHeader,
                Expanded(
                  child: ListView.builder(
                    controller: _leadingVerticalController,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 10),
                    itemExtent: widget.rowExtent,
                    itemCount: widget.itemCount,
                    itemBuilder: widget.leadingRowBuilder,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: widget.scrollableWidth,
              child: Column(
                children: <Widget>[
                  widget.scrollableHeader,
                  Expanded(
                    child: ListView.builder(
                      controller: _dataVerticalController,
                      padding: const EdgeInsets.only(bottom: 10),
                      itemExtent: widget.rowExtent,
                      itemCount: widget.itemCount,
                      itemBuilder: widget.scrollableRowBuilder,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
