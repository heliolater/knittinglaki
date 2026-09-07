import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database.dart';
import '../../../providers.dart';

class CounterTile extends ConsumerWidget {
  const CounterTile({
    super.key,
    required this.counter,
    required this.dragIndex,
  });

  final Counter counter;

  /// Position in the list (0-based). Also drives the drag listener.
  final int dragIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(projectRepositoryProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Zähler ${dragIndex + 1}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Zurück auf 0',
                  icon: const Icon(Icons.restart_alt),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    repo.reset(counter.id);
                  },
                ),
                IconButton(
                  tooltip: 'Zähler löschen',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(context, ref),
                ),
                ReorderableDragStartListener(
                  index: dragIndex,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.drag_handle),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _BigButton(
                    icon: Icons.remove,
                    tonal: true,
                    semanticLabel: 'Runde weg',
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      repo.decrement(counter.id);
                    },
                  ),
                ),
                SizedBox(
                  width: 96,
                  child: Text(
                    '${counter.value}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall,
                  ),
                ),
                Expanded(
                  child: _BigButton(
                    icon: Icons.add,
                    semanticLabel: 'Runde dazu',
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      repo.increment(counter.id);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
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

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.tonal = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String semanticLabel;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 72)),
    );
    final child = Icon(icon, size: 32, semanticLabel: semanticLabel);
    return tonal
        ? FilledButton.tonal(onPressed: onPressed, style: style, child: child)
        : FilledButton(onPressed: onPressed, style: style, child: child);
  }
}
