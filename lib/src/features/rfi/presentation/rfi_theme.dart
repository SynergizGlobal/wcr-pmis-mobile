import 'package:flutter/material.dart';

abstract final class RfiTheme {
  static ColorScheme schemeOf(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color scaffoldBackground(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static BoxDecoration surfaceCardDecoration(ColorScheme scheme) {
    return BoxDecoration(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: scheme.shadow.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration surfaceCardDecorationSmall(ColorScheme scheme) {
    return BoxDecoration(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(8),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: scheme.shadow.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static AppBar rfiAppBar(BuildContext context, String title) {
    return AppBar(
      title: Text(title),
    );
  }

  static Color tableHeaderBackground(ColorScheme scheme) => scheme.primary;

  static Color tableHeaderForeground(ColorScheme scheme) => scheme.onPrimary;

  static Color tableRowBackground(ColorScheme scheme, {required bool even}) {
    return even
        ? scheme.primary.withValues(alpha: 0.08)
        : scheme.surface;
  }

  static TextStyle? tableHeaderTextStyle(TextTheme textTheme, ColorScheme scheme) {
    return textTheme.labelLarge?.copyWith(
      color: scheme.onPrimary,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle? tableCellTextStyle(TextTheme textTheme, ColorScheme scheme) {
    return textTheme.bodySmall?.copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w600,
    );
  }

  static Color actionView(ColorScheme scheme) => scheme.primary;

  static Color actionEdit(ColorScheme scheme) => scheme.tertiary;

  static Color actionDelete(ColorScheme scheme) => scheme.error;

  static Color actionClose(ColorScheme scheme) => scheme.primary;

  static Color actionDefault(ColorScheme scheme) => scheme.primary;

  static Color metricCreated(ColorScheme scheme) => scheme.tertiary;

  static Color metricScheduled(ColorScheme scheme) => scheme.secondary;

  static Color metricSubmitted(ColorScheme scheme) => scheme.primary;

  static Color metricApproved(ColorScheme scheme) => scheme.tertiary;

  static Color metricRejected(ColorScheme scheme) => scheme.error;

  static Color metricClosed(ColorScheme scheme) => scheme.onSurfaceVariant;

  static Color metricRescheduled(ColorScheme scheme) => scheme.secondary;

  static Color actionMenuBackground(ColorScheme scheme) => scheme.surface;

  static Color actionMenuIconBackground(ColorScheme scheme) =>
      scheme.surfaceContainerHighest;

  static Color actionMenuIconBorder(ColorScheme scheme) => scheme.outlineVariant;

  static Color foregroundOnAccent(ColorScheme scheme, Color accent) {
    if (accent == scheme.tertiary) {
      return scheme.onTertiary;
    }
    if (accent == scheme.error) {
      return scheme.onError;
    }
    return scheme.onPrimary;
  }

  static Widget dataTable(
    BuildContext context, {
    required List<DataColumn> columns,
    required List<DataRow> rows,
    double columnSpacing = 20,
    double horizontalMargin = 12,
    double dividerThickness = 1,
    double? dataRowMinHeight,
    double? dataRowMaxHeight,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: scheme.outlineVariant,
          dataTableTheme: DataTableThemeData(
            headingRowColor: WidgetStateProperty.all(tableHeaderBackground(scheme)),
            headingTextStyle: tableHeaderTextStyle(textTheme, scheme),
            dataTextStyle: tableCellTextStyle(textTheme, scheme),
            dividerThickness: dividerThickness,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: columnSpacing,
            horizontalMargin: horizontalMargin,
            dividerThickness: dividerThickness,
            dataRowMinHeight: dataRowMinHeight,
            dataRowMaxHeight: dataRowMaxHeight,
            headingRowColor: WidgetStateProperty.all(tableHeaderBackground(scheme)),
            headingTextStyle: tableHeaderTextStyle(textTheme, scheme),
            dataTextStyle: tableCellTextStyle(textTheme, scheme),
            columns: columns,
            rows: rows,
          ),
        ),
      ),
    );
  }

  static ButtonStyle primaryElevated(ColorScheme scheme) {
    return ElevatedButton.styleFrom(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
      disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
    );
  }

  static ButtonStyle destructiveElevated(ColorScheme scheme) {
    return ElevatedButton.styleFrom(
      backgroundColor: scheme.error,
      foregroundColor: scheme.onError,
    );
  }

  static ButtonStyle secondaryOutlined(ColorScheme scheme) {
    return OutlinedButton.styleFrom(
      foregroundColor: scheme.onSurface,
      side: BorderSide(color: scheme.outline),
    );
  }

  static InputDecoration searchFieldDecoration(
    BuildContext context, {
    String? hintText,
    Widget? prefixIcon,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    );
  }

  static ShapeBorder dialogShape() => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      );

  static BoxDecoration elevatedCardDecoration(ColorScheme scheme) {
    return BoxDecoration(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(12),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: scheme.shadow.withValues(alpha: 0.08),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration insetPanelDecoration(ColorScheme scheme) {
    return BoxDecoration(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: scheme.outlineVariant),
    );
  }

  static BoxDecoration primaryTintCardDecoration(ColorScheme scheme) {
    return BoxDecoration(
      color: scheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
    );
  }

  static TextStyle? cardTitleStyle(TextTheme textTheme, ColorScheme scheme) {
    return textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: scheme.primary,
    );
  }

  static TextStyle? cardLabelStyle(TextTheme textTheme, ColorScheme scheme) {
    return textTheme.labelMedium?.copyWith(
      color: scheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle? cardValueStyle(TextTheme textTheme, ColorScheme scheme) {
    return textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    );
  }

  static Widget dialogHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: scheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: scheme.onPrimary, size: 28),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  static Color statusChipColor(ColorScheme scheme, String statusKey) {
    switch (statusKey) {
      case 'error':
      case 'rejected':
        return scheme.error;
      case 'success':
      case 'open':
      case 'approved':
        return scheme.tertiary;
      case 'closed':
      case 'info':
        return scheme.primary;
      case 'warning':
        return scheme.secondary;
      default:
        return scheme.onSurfaceVariant;
    }
  }
}

