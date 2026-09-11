import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The outline-style "+ Projekt" / "+ Zähler" pill button.
///
/// Deliberately understated (outline, not filled) so it never competes with
/// the mint `+` on the counter cards for attention. Built as a plain
/// `Positioned` widget rather than `Scaffold.floatingActionButton` so its
/// shadow, radius and border match the handoff exactly.
class PillFab extends StatelessWidget {
  const PillFab({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: colors.card,
      shape: StadiumBorder(side: BorderSide(color: colors.line, width: 1.5)),
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
      elevation: 3,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: Container(
          height: 60,
          padding: const EdgeInsets.fromLTRB(20, 0, 24, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 26, color: colors.ink),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
