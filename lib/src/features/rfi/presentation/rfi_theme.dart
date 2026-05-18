import 'package:flutter/material.dart';

abstract final class RfiTheme {
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
}
