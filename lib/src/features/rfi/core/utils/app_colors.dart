import 'package:flutter/material.dart';

/// WCR-aligned brand colors for ported RFI widgets (use [primary] with [BuildContext]).
abstract final class AppColors {
  /// WCR PMIS primary — matches [ColorScheme.primary] in app theme.
  static const Color wcrPrimary = Color(0xFF50589C);

  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color onPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
}
