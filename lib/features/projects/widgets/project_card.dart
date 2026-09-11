import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_colors.dart';
import '../../../core/name_dialog.dart';
import '../../../core/round_icon_button.dart';
import '../../../data/database.dart';
import '../../../providers.dart';

class ProjectCard extends ConsumerWidget {
  const ProjectCard({super.key, required this.project, required this.dragIndex});

  final Project project;
  final int dragIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final count = ref.watch(countersProvider(project.id)).value?.length;
    final meta = count == null
        ? ''
        : count == 1
        ? '1 Zähler'
        : '$count Zähler';

    return Container(
      height: 80,
      padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push('/project/${project.id}'),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        color: colors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      meta,
                      style: TextStyle(fontSize: 13, color: colors.muted),
                    ),
                  ],
                ),
              ),
              RoundIconButton(
                icon: Icons.edit_outlined,
                diameter: 44,
                iconSize: 21,
                color: colors.muted,
                hoverColor: colors.hover,
                semanticLabel: 'Umbenennen',
                onPressed: () => _rename(context, ref),
              ),
              RoundIconButton(
                icon: Icons.delete_outline_rounded,
                diameter: 44,
                iconSize: 21,
                color: colors.muted,
                hoverColor: colors.hover,
                semanticLabel: 'Löschen',
                onPressed: () => _delete(context, ref),
              ),
              ReorderableDragStartListener(
                index: dragIndex,
                child: RoundIconButton(
                  icon: Icons.drag_indicator_rounded,
                  diameter: 44,
                  iconSize: 21,
                  color: colors.muted,
                  hoverColor: colors.hover,
                  semanticLabel: 'Sortieren',
                  onPressed: null,
                ),
              ),
            ],
          ),
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
