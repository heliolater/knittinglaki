import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/name_dialog.dart';
import '../../data/database.dart';
import '../../providers.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Knittinglaki')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addProject(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Projekt'),
      ),
      body: Column(
        children: [
          const _AddToHomeScreenHint(),
          Expanded(
            child: projectsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Fehler beim Laden: $error')),
              data: (projects) {
                if (projects.isEmpty) return const _EmptyProjects();
                return ReorderableListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 96),
                  itemCount: projects.length,
                  onReorderItem: (oldIndex, newIndex) {
                    final ids = projects.map((p) => p.id).toList();
                    ids.insert(newIndex, ids.removeAt(oldIndex));
                    ref
                        .read(projectRepositoryProvider)
                        .reorderProjects(ids);
                  },
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return _ProjectCard(
                      key: ValueKey(project.id),
                      project: project,
                      dragIndex: index,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addProject(BuildContext context, WidgetRef ref) async {
    final name = await showNameDialog(
      context,
      title: 'Neues Projekt',
      hintText: 'z. B. Socken',
      confirmLabel: 'Anlegen',
    );
    if (name != null) {
      await ref.read(projectRepositoryProvider).createProject(name);
    }
  }
}

class _ProjectCard extends ConsumerWidget {
  const _ProjectCard({
    super.key,
    required this.project,
    required this.dragIndex,
  });

  final Project project;
  final int dragIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        onTap: () => context.push('/project/${project.id}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Umbenennen',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _rename(context, ref),
            ),
            IconButton(
              tooltip: 'Projekt löschen',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref),
            ),
            ReorderableDragStartListener(
              index: dragIndex,
              child: const Padding(
                padding: EdgeInsets.only(left: 4, right: 8),
                child: Icon(Icons.drag_handle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final name = await showNameDialog(
      context,
      title: 'Projekt umbenennen',
      initialValue: project.name,
    );
    if (name != null) {
      await ref
          .read(projectRepositoryProvider)
          .renameProject(project.id, name);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('„${project.name}" löschen?'),
        content: const Text(
          'Das Projekt und alle seine Zähler werden entfernt.',
        ),
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
      await ref.read(projectRepositoryProvider).deleteProject(project.id);
    }
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.grid_view_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Noch keine Projekte',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Tippe auf + und lege dein erstes Projekt an, z. B. „Socken".',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToHomeScreenHint extends StatefulWidget {
  const _AddToHomeScreenHint();

  @override
  State<_AddToHomeScreenHint> createState() => _AddToHomeScreenHintState();
}

class _AddToHomeScreenHintState extends State<_AddToHomeScreenHint> {
  bool _dismissed = false;

  bool get _isIosWeb =>
      kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    if (!_isIosWeb || _dismissed) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Icon(Icons.ios_share, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tipp: Über „Teilen → Zum Home-Bildschirm" installieren – '
                'dann bleiben deine Zähler dauerhaft gespeichert.',
                style: TextStyle(color: scheme.onSecondaryContainer),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              color: scheme.onSecondaryContainer,
              onPressed: () => setState(() => _dismissed = true),
            ),
          ],
        ),
      ),
    );
  }
}
