import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/round_icon_button.dart';
import '../../../core/theme_mode_controller.dart';

/// Toggles between light and dark mode. Starts following the system setting;
/// the first tap pins an explicit choice, persisted across launches.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RoundIconButton(
      icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
      diameter: 44,
      iconSize: 21,
      color: colors.muted,
      hoverColor: colors.hover,
      semanticLabel: isDark ? 'Hellen Modus verwenden' : 'Dunklen Modus verwenden',
      onPressed: () => ref
          .read(themeModeProvider.notifier)
          .setMode(isDark ? ThemeMode.light : ThemeMode.dark),
    );
  }
}
