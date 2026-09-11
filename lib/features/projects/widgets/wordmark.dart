import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/dashed_line.dart';

/// The "Knittinglaki" app title: logo tile + two-line wordmark with a dashed
/// yarn thread ending in a knot. Shown only in the project list's AppBar.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/logo/icon-1024.png',
            width: 38,
            height: 38,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 11),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Knitting',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.045 * 26,
                      height: 1,
                      color: colors.ink,
                    ),
                  ),
                  TextSpan(
                    text: 'laki',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.02 * 26,
                      height: 1,
                      color: colors.thread,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DashedLine(width: 112, color: colors.thread),
                const SizedBox(width: 5),
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.thread,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
