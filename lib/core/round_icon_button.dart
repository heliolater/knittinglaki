import 'package:flutter/material.dart';

/// A transparent circular icon button with an exact diameter and a
/// `hover`-token highlight on press — used for reset/delete/sort/rename/minus
/// across project and counter cards.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.diameter,
    required this.iconSize,
    required this.color,
    required this.hoverColor,
    this.onPressed,
    this.border,
    this.semanticLabel,
  });

  final IconData icon;
  final double diameter;
  final double iconSize;
  final Color color;
  final Color hoverColor;
  final VoidCallback? onPressed;
  final BoxBorder? border;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(shape: BoxShape.circle, border: border),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          overlayColor: WidgetStatePropertyAll(hoverColor),
          onTap: onPressed,
          child: Center(
            child: Icon(icon, size: iconSize, color: color, semanticLabel: semanticLabel),
          ),
        ),
      ),
    );
    return content;
  }
}
