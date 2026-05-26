import 'package:flutter/material.dart';

class AppFormFieldStyle {
  const AppFormFieldStyle._();

  static const double borderRadius = 12;

  static bool hasText({String? value, TextEditingController? controller}) {
    final String raw = controller?.text ?? value ?? '';
    return raw.trim().isNotEmpty;
  }

  static TextStyle labelStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall!.copyWith(
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle valueStyle(
    BuildContext context, {
    required bool filled,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontWeight: filled ? FontWeight.w600 : FontWeight.w500,
      color: filled ? scheme.onSurface : scheme.onSurfaceVariant,
    );
  }

  static TextStyle hintStyle(BuildContext context) {
    return valueStyle(context, filled: false);
  }

  static InputDecoration decoration(
    BuildContext context, {
    required bool filled,
    bool enabled = true,
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    bool isDense = false,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color borderColor = filled
        ? scheme.primary.withValues(alpha: 0.40)
        : scheme.outlineVariant;
    final OutlineInputBorder outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: borderColor),
    );

    return InputDecoration(
      isDense: isDense,
      filled: true,
      fillColor: filled
          ? scheme.primary.withValues(alpha: 0.07)
          : scheme.surface,
      hintText: hintText,
      hintStyle: hintStyle(context),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      contentPadding: contentPadding,
      border: outline,
      enabledBorder: outline,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: scheme.primary, width: 1.4),
      ),
      disabledBorder: outline.copyWith(
        borderSide: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      enabled: enabled,
    );
  }
}
