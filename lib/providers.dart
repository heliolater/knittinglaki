import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'data/project_repository.dart';

/// The single app-wide database instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(ref.watch(databaseProvider));
});

/// All projects, ordered, kept live.
final projectsProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchProjects();
});

/// Map of project id -> number of counters, for the list subtitle.
final counterCountsProvider = StreamProvider<Map<int, int>>((ref) {
  return ref.watch(projectRepositoryProvider).watchCounterCounts();
});

/// A single project by id (for the detail screen title).
final projectProvider = StreamProvider.family<Project, int>((ref, projectId) {
  return ref.watch(projectRepositoryProvider).watchProject(projectId);
});

/// All counters of a project, ordered, kept live.
final countersProvider =
    StreamProvider.family<List<Counter>, int>((ref, projectId) {
  return ref.watch(projectRepositoryProvider).watchCounters(projectId);
});
