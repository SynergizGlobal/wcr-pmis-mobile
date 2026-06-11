import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcr_pmis_mobile/src/app/theme/app_theme.dart';

class AuthFormField extends StatelessWidget {
  const AuthFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.letterSpacing,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final int? maxLength;
  final TextAlign textAlign;
  final double? letterSpacing;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppPalette palette =
        Theme.of(context).extension<AppPalette>() ?? AppPalette.light;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasValue = controller.text.isNotEmpty;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      validator: validator,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      style: TextStyle(
        color: colorScheme.onSurface,
        letterSpacing: letterSpacing,
        fontSize: letterSpacing != null ? 22 : null,
        fontWeight: letterSpacing != null ? FontWeight.w600 : null,
      ),
      cursorColor: colorScheme.onSurface,
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        hintStyle: TextStyle(color: palette.loginSecondaryText),
        prefixIcon: Icon(prefixIcon, color: palette.loginSecondaryText),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? colorScheme.outlineVariant : Colors.white,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasValue
                ? colorScheme.primary
                : (isDark ? colorScheme.outlineVariant : Colors.white),
            width: hasValue ? 1.4 : 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette =
        Theme.of(context).extension<AppPalette>() ?? AppPalette.light;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.loginButton,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(45),
        disabledBackgroundColor: palette.loginButton.withValues(alpha: 0.70),
        disabledForegroundColor: Colors.white70,
      ),
      child: isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
