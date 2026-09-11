import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds the app theme from the fixed [AppColors] tokens (handoff-specified
/// hex values, not a Material seed palette).
ThemeData buildTheme(Brightness brightness) {
  final colors = brightness == Brightness.light
      ? AppColors.light
      : AppColors.dark;

  final base = brightness == Brightness.light
      ? ColorScheme.light(
          primary: colors.mintInk,
          onPrimary: colors.card,
          surface: colors.bg,
          onSurface: colors.ink,
          error: colors.accent,
        )
      : ColorScheme.dark(
          primary: colors.mint,
          onPrimary: colors.mintInk,
          surface: colors.bg,
          onSurface: colors.ink,
          error: colors.accent,
        );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'DM Sans',
    colorScheme: base,
    scaffoldBackgroundColor: colors.bg,
    canvasColor: colors.bg,
    extensions: [colors],
    appBarTheme: AppBarTheme(
      backgroundColor: colors.bg,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colors.ink,
      elevation: 0,
      centerTitle: false,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.card,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: 'DM Sans',
        fontWeight: FontWeight.w500,
        fontSize: 19,
        color: colors.ink,
      ),
      contentTextStyle: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        color: colors.muted,
      ),
    ),
    textTheme: TextTheme(bodyMedium: TextStyle(color: colors.muted)).apply(
      bodyColor: colors.ink,
      displayColor: colors.ink,
    ),
  );
}
