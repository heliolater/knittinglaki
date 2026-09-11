import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/plus_button.dart';
import '../../../core/round_icon_button.dart';
import '../../../data/database.dart';
import '../../../providers.dart';
import 'counter_card_variant.dart';

class CounterCard extends ConsumerWidget {
  const CounterCard({
    super.key,
    required this.counter,
    required this.dragIndex,
    required this.variant,
  });

  final Counter counter;

  /// Position in the list (0-based) — also the counter's display number and
  /// the drag listener's index. Counters have no editable title.
  final int dragIndex;
  final CounterCardVariant variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(projectRepositoryProvider);
    final colors = context.colors;

    final plus = PlusButton(
      diameter: variant.plusDiameter,
      iconSize: variant.plusIconSize,
      fill: colors.mint,
      iconColor: colors.mintInk,
      ellipseColor: colors.mintLine,
      ellipseBorderWidth: variant.ellipseBorderWidth,
      pedestalColor: colors.mintDeep,
      restOffsetY: variant.restOffsetY,
      restBlurColor: variant.restBlurColor(),
      restBlurOffsetY: variant.restBlurOffsetY,
      restBlurRadius: variant.restBlurRadius,
      pressedOffsetY: variant.pressedOffsetY,
      pressedTranslateY: variant.pressedTranslateY,
      pressedBlurColor: variant.pressedBlurColor(),
      pressedBlurOffsetY: variant.pressedBlurOffsetY,
      pressedBlurRadius: variant.pressedBlurRadius,
      onPressed: () => repo.increment(counter.id),
    );

    final minus = RoundIconButton(
      icon: Icons.remove_rounded,
      diameter: variant.minusDiameter,
      iconSize: variant.minusIconSize,
      color: colors.muted,
      hoverColor: colors.hover,
      border: Border.all(color: colors.line, width: 2),
      semanticLabel: 'Eins zurück',
      onPressed: () {
        HapticFeedback.selectionClick();
        repo.decrement(counter.id);
      },
    );

    final number = Text(
      '${counter.value}',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: variant.numberFontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: letterSpacingPx(
          variant.numberFontSize,
          variant.numberLetterSpacingEm,
        ),
        height: 1,
        color: colors.ink,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(dragIndex: dragIndex, onReset: () {
            HapticFeedback.mediumImpact();
            repo.reset(counter.id);
          }, onDelete: () => _delete(context, ref)),
          const SizedBox(height: 10),
          if (variant.layout == CounterCardLayout.row)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                minus,
                const SizedBox(width: 8),
                Expanded(child: number),
                const SizedBox(width: 8),
                plus,
              ],
            )
          else
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      minus,
                      const SizedBox(width: 10),
                      Expanded(child: number),
                      const SizedBox(width: 10),
                      SizedBox(width: variant.minusDiameter),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Center(child: plus),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Zähler ${dragIndex + 1} löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(projectRepositoryProvider).deleteCounter(counter.id);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.dragIndex,
    required this.onReset,
    required this.onDelete,
  });

  final int dragIndex;
  final VoidCallback onReset;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.mintDeep,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ZÄHLER ${dragIndex + 1}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 11 * 0.11,
                  color: colors.muted,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        RoundIconButton(
          icon: Icons.refresh_rounded,
          diameter: 42,
          iconSize: 20,
          color: colors.muted,
          hoverColor: colors.hover,
          semanticLabel: 'Zurücksetzen',
          onPressed: onReset,
        ),
        RoundIconButton(
          icon: Icons.delete_outline_rounded,
          diameter: 42,
          iconSize: 20,
          color: colors.muted,
          hoverColor: colors.hover,
          semanticLabel: 'Löschen',
          onPressed: onDelete,
        ),
        ReorderableDragStartListener(
          index: dragIndex,
          child: RoundIconButton(
            icon: Icons.drag_indicator_rounded,
            diameter: 42,
            iconSize: 20,
            color: colors.muted,
            hoverColor: colors.hover,
            semanticLabel: 'Sortieren',
            onPressed: null,
          ),
        ),
      ],
    );
  }
}
