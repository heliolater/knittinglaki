import 'package:flutter/material.dart';

enum CounterCardLayout { row, columnBig }

/// Exact sizing/shadow numbers per counter-card size, taken verbatim from the
/// handoff's `CounterCardRound` component (`circle`, `circle-sm`,
/// `circle-big` — the other variants in that file were rejected explorations
/// and are not implemented).
class CounterCardVariant {
  const CounterCardVariant({
    required this.layout,
    required this.minusDiameter,
    required this.minusIconSize,
    required this.plusDiameter,
    required this.plusIconSize,
    required this.ellipseBorderWidth,
    required this.numberFontSize,
    required this.numberLetterSpacingEm,
    required this.restOffsetY,
    required this.restBlurOffsetY,
    required this.restBlurRadius,
    required this.restBlurAlpha,
    required this.pressedOffsetY,
    required this.pressedTranslateY,
    this.pressedBlurOffsetY,
    this.pressedBlurRadius,
    this.pressedBlurAlpha,
    this.listGap = 14,
  });

  final CounterCardLayout layout;

  /// Gap between cards in the counter list for this variant.
  final double listGap;
  final double minusDiameter;
  final double minusIconSize;
  final double plusDiameter;
  final double plusIconSize;
  final double ellipseBorderWidth;
  final double numberFontSize;
  final double numberLetterSpacingEm;
  final double restOffsetY;
  final double restBlurOffsetY;
  final double restBlurRadius;
  final double restBlurAlpha;
  final double pressedOffsetY;
  final double pressedTranslateY;
  final double? pressedBlurOffsetY;
  final double? pressedBlurRadius;
  final double? pressedBlurAlpha;

  /// Single counter, or the reference default for a project detail screen.
  static const circle = CounterCardVariant(
    layout: CounterCardLayout.row,
    minusDiameter: 52,
    minusIconSize: 24,
    plusDiameter: 166,
    plusIconSize: 84,
    ellipseBorderWidth: 3,
    numberFontSize: 50,
    numberLetterSpacingEm: -0.04,
    restOffsetY: 6,
    restBlurOffsetY: 12,
    restBlurRadius: 22,
    restBlurAlpha: 0.22,
    pressedOffsetY: 1,
    pressedTranslateY: 5,
    pressedBlurOffsetY: 4,
    pressedBlurRadius: 10,
    pressedBlurAlpha: 0.2,
  );

  /// Three or more counters in one project.
  static const circleSm = CounterCardVariant(
    layout: CounterCardLayout.row,
    minusDiameter: 50,
    minusIconSize: 23,
    plusDiameter: 112,
    plusIconSize: 58,
    ellipseBorderWidth: 3,
    numberFontSize: 46,
    numberLetterSpacingEm: -0.04,
    restOffsetY: 6,
    restBlurOffsetY: 12,
    restBlurRadius: 20,
    restBlurAlpha: 0.2,
    pressedOffsetY: 1,
    pressedTranslateY: 5,
    listGap: 10,
  );

  /// Maximal one-handed layout. Not auto-selected today — kept for a future
  /// "focus" mode.
  static const circleBig = CounterCardVariant(
    layout: CounterCardLayout.columnBig,
    minusDiameter: 56,
    minusIconSize: 26,
    plusDiameter: 254,
    plusIconSize: 132,
    ellipseBorderWidth: 4,
    numberFontSize: 88,
    numberLetterSpacingEm: -0.05,
    restOffsetY: 8,
    restBlurOffsetY: 18,
    restBlurRadius: 30,
    restBlurAlpha: 0.22,
    pressedOffsetY: 1,
    pressedTranslateY: 7,
  );

  /// 1–2 counters → [circle] (2×240px card height + gap fits the screen
  /// without scrolling); 3+ → [circleSm] (3×180px still fits, more scrolls).
  static CounterCardVariant forCount(int count) =>
      count <= 2 ? circle : circleSm;

  Color restBlurColor() => Color.fromRGBO(31, 110, 98, restBlurAlpha);

  Color? pressedBlurColor() =>
      pressedBlurAlpha == null ? null : Color.fromRGBO(31, 110, 98, pressedBlurAlpha!);
}

/// Convenience: em-based letter spacing at a given font size, matching CSS
/// `letter-spacing: <em>`.
double letterSpacingPx(double fontSize, double em) => fontSize * em;
