import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/app_colors.dart';
import '../../core/pill_fab.dart';
import '../../core/round_icon_button.dart';
import '../../providers.dart';
import 'widgets/counter_card.dart';
import 'widgets/counter_card_variant.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final int projectId;

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Keep the screen on while counting.
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final projectName =
        ref.watch(projectProvider(widget.projectId)).value?.name;
    final countersAsync = ref.watch(countersProvider(widget.projectId));

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              RoundIconButton(
                icon: Icons.arrow_back_rounded,
                diameter: 48,
                iconSize: 24,
                color: colors.ink,
                hoverColor: colors.hover,
                semanticLabel: 'Zurück',
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  projectName ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 23,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.01 * 23,
                    color: colors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          countersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('Fehler beim Laden: $error')),
            data: (counters) {
              if (counters.isEmpty) return const _EmptyCounters();
              final variant = CounterCardVariant.forCount(counters.length);
              return ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
                buildDefaultDragHandles: false,
                itemCount: counters.length,
                onReorderItem: (oldIndex, newIndex) {
                  final ids = counters.map((c) => c.id).toList();
                  ids.insert(newIndex, ids.removeAt(oldIndex));
                  ref.read(projectRepositoryProvider).reorderCounters(ids);
                },
                itemBuilder: (context, index) {
                  final counter = counters[index];
                  return Padding(
                    key: ValueKey(counter.id),
                    padding: EdgeInsets.only(bottom: variant.listGap),
                    child: CounterCard(
                      counter: counter,
                      dragIndex: index,
                      variant: variant,
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            right: 20,
            bottom: 30,
            child: PillFab(label: 'Zähler', onPressed: _addCounter),
          ),
        ],
      ),
    );
  }

  Future<void> _addCounter() async {
    await ref.read(projectRepositoryProvider).createCounter(widget.projectId);
  }
}

class _EmptyCounters extends StatelessWidget {
  const _EmptyCounters();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 0, 48, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colors.accentSoft,
                borderRadius: BorderRadius.circular(38),
              ),
              child: Icon(
                Icons.gesture_rounded,
                size: 36,
                color: colors.accentSoftInk,
              ),
            ),
            const SizedBox(height: 18),
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 17, height: 1.5, color: colors.muted),
                children: [
                  const TextSpan(text: 'Noch keine Zähler — tippe auf '),
                  TextSpan(
                    text: '+',
                    style: TextStyle(
                      color: colors.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
