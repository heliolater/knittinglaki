import 'package:flutter/material.dart';

/// A horizontal dashed line, used under the wordmark as the "yarn thread".
class DashedLine extends StatelessWidget {
  const DashedLine({
    super.key,
    required this.width,
    required this.color,
    this.strokeWidth = 3,
    this.dashWidth = 5,
    this.gapWidth = 4,
  });

  final double width;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double gapWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: strokeWidth,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: color,
          strokeWidth: strokeWidth,
          dashWidth: dashWidth,
          gapWidth: gapWidth,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.gapWidth,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double gapWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    final y = size.height / 2;
    var x = 0.0;
    while (x < size.width) {
      final end = (x + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dashWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      dashWidth != oldDelegate.dashWidth ||
      gapWidth != oldDelegate.gapWidth;
}
