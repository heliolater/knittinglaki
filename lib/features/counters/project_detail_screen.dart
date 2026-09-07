import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/name_dialog.dart';
import '../../providers.dart';
import 'widgets/counter_tile.dart';

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
    final projectName =
        ref.watch(projectProvider(widget.projectId)).value?.name;
    final countersAsync = ref.watch(countersProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: Text(projectName ?? 'Projekt'),
        actions: [
          if (projectName != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'rename') _renameProject(projectName);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'rename',
                  child: Text('Projekt umbenennen'),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCounter,
        icon: const Icon(Icons.add),
        label: const Text('Zähler'),
      ),
      body: countersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Fehler beim Laden: $error')),
        data: (counters) {
          if (counters.isEmpty) return const _EmptyCounters();
          return ReorderableListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 96),
            buildDefaultDragHandles: false,
            itemCount: counters.length,
            onReorderItem: (oldIndex, newIndex) {
              final ids = counters.map((c) => c.id).toList();
              ids.insert(newIndex, ids.removeAt(oldIndex));
              ref.read(projectRepositoryProvider).reorderCounters(ids);
            },
            itemBuilder: (context, index) {
              final counter = counters[index];
              return CounterTile(
                key: ValueKey(counter.id),
                counter: counter,
                dragIndex: index,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addCounter() async {
    await ref.read(projectRepositoryProvider).createCounter(widget.projectId);
  }

  Future<void> _renameProject(String currentName) async {
    final name = await showNameDialog(
      context,
      title: 'Projekt umbenennen',
      initialValue: currentName,
    );
    if (name != null) {
      await ref
          .read(projectRepositoryProvider)
          .renameProject(widget.projectId, name);
    }
  }
}

class _EmptyCounters extends StatelessWidget {
  const _EmptyCounters();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.exposure_plus_1_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Noch keine Zähler',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Tippe auf + für den ersten Zähler, z. B. „Bund".',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
