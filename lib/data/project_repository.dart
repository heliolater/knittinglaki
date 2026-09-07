import 'package:drift/drift.dart';

import 'database.dart';

/// All reads and writes for projects and their counters go through here.
///
/// Reads are exposed as streams so the UI rebuilds automatically whenever the
/// underlying tables change.
class ProjectRepository {
  ProjectRepository(this._db);

  final AppDatabase _db;

  // --- Projects -------------------------------------------------------------

  Stream<List<Project>> watchProjects() {
    return (_db.select(_db.projects)
          ..orderBy([
            (p) => OrderingTerm(expression: p.sortOrder),
            (p) => OrderingTerm(expression: p.createdAt),
          ]))
        .watch();
  }

  Stream<Project> watchProject(int projectId) {
    return (_db.select(_db.projects)..where((p) => p.id.equals(projectId)))
        .watchSingle();
  }

  /// Live count of counters per project id, for the list subtitle.
  Stream<Map<int, int>> watchCounterCounts() {
    final countExpr = _db.counters.id.count();
    final query = _db.selectOnly(_db.counters)
      ..addColumns([_db.counters.projectId, countExpr])
      ..groupBy([_db.counters.projectId]);
    return query.watch().map(
          (rows) => {
            for (final row in rows)
              row.read(_db.counters.projectId)!: row.read(countExpr)!,
          },
        );
  }

  /// Creates a project and gives it its first counter straight away, so it is
  /// never opened empty.
  Future<int> createProject(String name) {
    return _db.transaction(() async {
      final id = await _db.into(_db.projects).insert(
            ProjectsCompanion.insert(name: name.trim()),
          );
      await _db.into(_db.counters).insert(
            CountersCompanion.insert(projectId: id),
          );
      return id;
    });
  }

  Future<void> renameProject(int projectId, String name) {
    return (_db.update(_db.projects)..where((p) => p.id.equals(projectId)))
        .write(ProjectsCompanion(name: Value(name.trim())));
  }

  Future<void> deleteProject(int projectId) {
    // Counters are removed by ON DELETE CASCADE.
    return (_db.delete(_db.projects)..where((p) => p.id.equals(projectId)))
        .go();
  }

  /// Persists a new manual order. [orderedIds] is the full list, top to bottom.
  Future<void> reorderProjects(List<int> orderedIds) {
    return _db.batch((batch) {
      for (var i = 0; i < orderedIds.length; i++) {
        batch.update(
          _db.projects,
          ProjectsCompanion(sortOrder: Value(i)),
          where: (p) => p.id.equals(orderedIds[i]),
        );
      }
    });
  }

  // --- Counters -----------------------------------------------------------

  Stream<List<Counter>> watchCounters(int projectId) {
    return (_db.select(_db.counters)
          ..where((c) => c.projectId.equals(projectId))
          ..orderBy([
            (c) => OrderingTerm(expression: c.sortOrder),
            (c) => OrderingTerm(expression: c.createdAt),
          ]))
        .watch();
  }

  Future<int> createCounter(int projectId) {
    return _db.into(_db.counters).insert(
          CountersCompanion.insert(projectId: projectId),
        );
  }

  Future<void> deleteCounter(int counterId) {
    return (_db.delete(_db.counters)..where((c) => c.id.equals(counterId)))
        .go();
  }

  Future<void> reorderCounters(List<int> orderedIds) {
    return _db.batch((batch) {
      for (var i = 0; i < orderedIds.length; i++) {
        batch.update(
          _db.counters,
          CountersCompanion(sortOrder: Value(i)),
          where: (c) => c.id.equals(orderedIds[i]),
        );
      }
    });
  }

  // --- Counter value ----------------------------------------------------------

  Future<void> increment(int counterId) {
    return _db.customUpdate(
      'UPDATE counters SET value = value + 1 WHERE id = ?',
      variables: [Variable.withInt(counterId)],
      updates: {_db.counters},
    );
  }

  /// Decrements, clamping at 0 – negative rounds make no sense.
  Future<void> decrement(int counterId) {
    return _db.customUpdate(
      'UPDATE counters SET value = MAX(value - 1, 0) WHERE id = ?',
      variables: [Variable.withInt(counterId)],
      updates: {_db.counters},
    );
  }

  Future<void> reset(int counterId) {
    return (_db.update(_db.counters)..where((c) => c.id.equals(counterId)))
        .write(const CountersCompanion(value: Value(0)));
  }
}
