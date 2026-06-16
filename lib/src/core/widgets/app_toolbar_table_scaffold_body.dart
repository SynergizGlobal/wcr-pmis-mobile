import 'package:flutter/material.dart';

/// Toolbar above an expandable table region. Scrolls the toolbar vertically when
/// space is tight (landscape or short viewports) to avoid [Column] overflows.
class AppToolbarTableScaffoldBody extends StatelessWidget {
  const AppToolbarTableScaffoldBody({
    super.key,
    required this.toolbar,
    required this.table,
    this.padding = const EdgeInsets.all(12),
    this.spacing = 10,
    this.compactHeightThreshold = 520,
    this.toolbarMaxHeightFraction = 0.45,
  });

  final Widget toolbar;
  final Widget table;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double compactHeightThreshold;
  final double toolbarMaxHeightFraction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Orientation orientation = MediaQuery.orientationOf(context);
        final bool compactToolbar =
            orientation == Orientation.landscape ||
            constraints.maxHeight < compactHeightThreshold;

        final Widget toolbarSection = compactToolbar
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * toolbarMaxHeightFraction,
                ),
                child: SingleChildScrollView(child: toolbar),
              )
            : toolbar;

        return Padding(
          padding: padding,
          child: Column(
            children: <Widget>[
              toolbarSection,
              SizedBox(height: spacing),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: table,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
