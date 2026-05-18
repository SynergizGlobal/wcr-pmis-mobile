import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.loginBackground,
    required this.loginTitle,
    required this.loginSecondaryText,
    required this.actionLink,
    required this.loginButton,
    required this.avatarFill,
    required this.avatarText,
  });

  final Color loginBackground;
  final Color loginTitle;
  final Color loginSecondaryText;
  final Color actionLink;
  final Color loginButton;
  final Color avatarFill;
  final Color avatarText;

  static const AppPalette light = AppPalette(
    loginBackground: Color(0xFFA4B7D4),
    loginTitle: Color(0xFF111111),
    loginSecondaryText: Color(0xFF5D677A),
    actionLink: Color(0xFF1229D9),
    loginButton: Color(0xFF565DA8),
    avatarFill: Color(0xFFDDE3F5),
    avatarText: Colors.black,
  );

  static const AppPalette dark = AppPalette(
    loginBackground: Color(0xFF1D2334),
    loginTitle: Color(0xFFF2F4FA),
    loginSecondaryText: Color(0xFFB8C0D6),
    actionLink: Color(0xFF89A0FF),
    loginButton: Color(0xFF6A73C8),
    avatarFill: Color(0xFF2A324A),
    avatarText: Color(0xFFF2F4FA),
  );

  @override
  AppPalette copyWith({
    Color? loginBackground,
    Color? loginTitle,
    Color? loginSecondaryText,
    Color? actionLink,
    Color? loginButton,
    Color? avatarFill,
    Color? avatarText,
  }) {
    return AppPalette(
      loginBackground: loginBackground ?? this.loginBackground,
      loginTitle: loginTitle ?? this.loginTitle,
      loginSecondaryText: loginSecondaryText ?? this.loginSecondaryText,
      actionLink: actionLink ?? this.actionLink,
      loginButton: loginButton ?? this.loginButton,
      avatarFill: avatarFill ?? this.avatarFill,
      avatarText: avatarText ?? this.avatarText,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }
    return AppPalette(
      loginBackground: Color.lerp(loginBackground, other.loginBackground, t)!,
      loginTitle: Color.lerp(loginTitle, other.loginTitle, t)!,
      loginSecondaryText:
          Color.lerp(loginSecondaryText, other.loginSecondaryText, t)!,
      actionLink: Color.lerp(actionLink, other.actionLink, t)!,
      loginButton: Color.lerp(loginButton, other.loginButton, t)!,
      avatarFill: Color.lerp(avatarFill, other.avatarFill, t)!,
      avatarText: Color.lerp(avatarText, other.avatarText, t)!,
    );
  }
}

class AppTheme {
  const AppTheme._();

  static const Color brandPrimary = Color(0xFF50589C);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandPrimary,
    ).copyWith(
      primary: brandPrimary,
      onPrimary: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        toolbarHeight: 66,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.20),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.primary,
        indicatorColor: colorScheme.onPrimary.withValues(alpha: 0.20),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          return TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          return IconThemeData(color: colorScheme.onPrimary);
        }),
      ),
      extensions: const <ThemeExtension<dynamic>>[AppPalette.light],
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF7D86DB),
      onPrimary: Colors.white,
      surface: const Color(0xFF161B28),
      onSurface: const Color(0xFFF2F4FA),
      onSurfaceVariant: const Color(0xFFB8C0D6),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF111623),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B2232),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        toolbarHeight: 66,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.30),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.24),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          return TextStyle(
            color: colorScheme.onSurface,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          return IconThemeData(color: colorScheme.onSurface);
        }),
      ),
      extensions: const <ThemeExtension<dynamic>>[AppPalette.dark],
    );
  }
}
