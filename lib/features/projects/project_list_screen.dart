import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/name_dialog.dart';
import '../../core/pill_fab.dart';
import '../../providers.dart';
import 'widgets/project_card.dart';
import 'widgets/wordmark.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(alignment: Alignment.centerLeft, child: Wordmark()),
        ),
      ),
      body: Stack(
        children: [
          Column(
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
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
                      buildDefaultDragHandles: false,
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
                        return Padding(
                          key: ValueKey(project.id),
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProjectCard(project: project, dragIndex: index),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 30,
            child: PillFab(
              label: 'Projekt',
              onPressed: () => _addProject(context, ref),
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

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects();

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
                  const TextSpan(text: 'Noch keine Projekte — tippe auf '),
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
    final colors = context.colors;
    return Material(
      color: colors.accentSoft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Icon(Icons.ios_share_rounded, color: colors.accentSoftInk),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tipp: Über „Teilen → Zum Home-Bildschirm" installieren – '
                'dann bleiben deine Zähler dauerhaft gespeichert.',
                style: TextStyle(color: colors.accentSoftInk),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded, color: colors.accentSoftInk),
              onPressed: () => setState(() => _dismissed = true),
            ),
          ],
        ),
      ),
    );
  }
}
