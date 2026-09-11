import 'package:flutter/material.dart';

/// Design tokens from the Knittinglaki UI handoff (Claude Design project
/// f70ef8e1-d608-447c-8bee-a7605dd1f227, Turn 1). Not derived from a Material
/// seed color — every value below is a fixed, hand-picked hex from the
/// handoff's design-token table.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.card,
    required this.ink,
    required this.muted,
    required this.line,
    required this.hover,
    required this.mint,
    required this.mintDeep,
    required this.mintLine,
    required this.mintInk,
    required this.thread,
    required this.accent,
    required this.accentSoft,
    required this.accentSoftInk,
  });

  final Color bg;
  final Color card;
  final Color ink;
  final Color muted;
  final Color line;
  final Color hover;
  final Color mint;
  final Color mintDeep;
  final Color mintLine;
  final Color mintInk;
  final Color thread;
  final Color accent;
  final Color accentSoft;
  final Color accentSoftInk;

  static const light = AppColors(
    bg: Color(0xFFFAF3EC),
    card: Color(0xFFFFFDFA),
    ink: Color(0xFF4A2C1B),
    muted: Color(0xFF7A6151),
    line: Color(0xFFEADCCE),
    hover: Color(0x0F4A2C1B), // rgba(74,44,27,.06)
    mint: Color(0xFFA9E0CE),
    mintDeep: Color(0xFF78C2AC),
    mintLine: Color(0x291F5A50), // rgba(31,90,80,.16)
    mintInk: Color(0xFF1F5A50),
    thread: Color(0xFF1F7E6B),
    accent: Color(0xFFD6503C),
    accentSoft: Color(0xFFCFEBD8),
    accentSoftInk: Color(0xFF1C6F65),
  );

  static const dark = AppColors(
    bg: Color(0xFF1B1512),
    card: Color(0xFF261E19),
    ink: Color(0xFFF5E7DA),
    muted: Color(0xFFA99284),
    line: Color(0xFF3D2F26),
    hover: Color(0x14F5E7DA), // rgba(245,231,218,.08)
    mint: Color(0xFF8CD3BC),
    mintDeep: Color(0xFF5CA792),
    mintLine: Color(0x38103636), // rgba(16,54,46,.22)
    mintInk: Color(0xFF14332C),
    thread: Color(0xFF8CD3BC),
    accent: Color(0xFFDE5B44),
    accentSoft: Color(0xFF2A3A31),
    accentSoftInk: Color(0xFF9AD7B4),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? card,
    Color? ink,
    Color? muted,
    Color? line,
    Color? hover,
    Color? mint,
    Color? mintDeep,
    Color? mintLine,
    Color? mintInk,
    Color? thread,
    Color? accent,
    Color? accentSoft,
    Color? accentSoftInk,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      card: card ?? this.card,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      hover: hover ?? this.hover,
      mint: mint ?? this.mint,
      mintDeep: mintDeep ?? this.mintDeep,
      mintLine: mintLine ?? this.mintLine,
      mintInk: mintInk ?? this.mintInk,
      thread: thread ?? this.thread,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      accentSoftInk: accentSoftInk ?? this.accentSoftInk,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      mintDeep: Color.lerp(mintDeep, other.mintDeep, t)!,
      mintLine: Color.lerp(mintLine, other.mintLine, t)!,
      mintInk: Color.lerp(mintInk, other.mintInk, t)!,
      thread: Color.lerp(thread, other.thread, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentSoftInk: Color.lerp(accentSoftInk, other.accentSoftInk, t)!,
    );
  }
}

/// Shorthand for `Theme.of(context).extension<AppColors>()!`.
extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
