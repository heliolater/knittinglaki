import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The "yarn ball" `+` button — the app's single most important control.
///
/// A filled mint circle with two rotated yarn-thread ellipses, sitting on a
/// solid (zero-blur) pedestal shadow that reads as its own "underside". On
/// press it slides down onto that pedestal and the shadow flattens.
class PlusButton extends StatefulWidget {
  const PlusButton({
    super.key,
    required this.diameter,
    required this.iconSize,
    required this.fill,
    required this.iconColor,
    required this.ellipseColor,
    required this.ellipseBorderWidth,
    required this.pedestalColor,
    required this.restOffsetY,
    required this.restBlurColor,
    required this.restBlurOffsetY,
    required this.restBlurRadius,
    required this.pressedOffsetY,
    required this.pressedTranslateY,
    this.pressedBlurColor,
    this.pressedBlurOffsetY,
    this.pressedBlurRadius,
    required this.onPressed,
    this.semanticLabel = 'Runde zählen',
  });

  final double diameter;
  final double iconSize;
  final Color fill;
  final Color iconColor;
  final Color ellipseColor;
  final double ellipseBorderWidth;
  final Color pedestalColor;
  final double restOffsetY;
  final Color restBlurColor;
  final double restBlurOffsetY;
  final double restBlurRadius;
  final double pressedOffsetY;
  final double pressedTranslateY;
  final Color? pressedBlurColor;
  final double? pressedBlurOffsetY;
  final double? pressedBlurRadius;
  final VoidCallback onPressed;
  final String semanticLabel;

  @override
  State<PlusButton> createState() => _PlusButtonState();
}

class _PlusButtonState extends State<PlusButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.diameter;
    final shadows = _pressed
        ? [
            BoxShadow(
              color: widget.pedestalColor,
              offset: Offset(0, widget.pressedOffsetY),
            ),
            if (widget.pressedBlurColor != null)
              BoxShadow(
                color: widget.pressedBlurColor!,
                offset: Offset(0, widget.pressedBlurOffsetY ?? 0),
                blurRadius: widget.pressedBlurRadius ?? 0,
              ),
          ]
        : [
            BoxShadow(
              color: widget.pedestalColor,
              offset: Offset(0, widget.restOffsetY),
            ),
            BoxShadow(
              color: widget.restBlurColor,
              offset: Offset(0, widget.restBlurOffsetY),
              blurRadius: widget.restBlurRadius,
            ),
          ];

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onPressed();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
            0,
            _pressed ? widget.pressedTranslateY : 0,
            0,
          ),
          width: d,
          height: d,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.fill,
            boxShadow: shadows,
          ),
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _yarnEllipse(
                  left: -0.18 * d,
                  top: 0.08 * d,
                  width: 1.50 * d,
                  height: 0.84 * d,
                  angleDeg: -24,
                ),
                _yarnEllipse(
                  left: 0.08 * d,
                  top: -0.16 * d,
                  width: 0.84 * d,
                  height: 1.48 * d,
                  angleDeg: -16,
                ),
                Icon(
                  Icons.add_rounded,
                  size: widget.iconSize,
                  color: widget.iconColor,
                  weight: 600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _yarnEllipse({
    required double left,
    required double top,
    required double width,
    required double height,
    required double angleDeg,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Transform.rotate(
        angle: angleDeg * 3.14159265 / 180,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.ellipseColor,
              width: widget.ellipseBorderWidth,
            ),
            borderRadius: BorderRadius.all(
              Radius.elliptical(width / 2, height / 2),
            ),
          ),
        ),
      ),
    );
  }
}
