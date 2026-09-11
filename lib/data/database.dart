import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Projects, Counters])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  /// Constructor for tests: pass an in-memory or custom executor.
  AppDatabase.forTesting(super.executor);

  // NOTE: this stayed at 1 through two real schema changes to Counters
  // (name removed, then re-added) before shipping — so an on-device database
  // tagged "version 1" can legitimately be in either shape. `beforeOpen`
  // below checks the actual column set rather than trusting the version
  // number, and self-heals either way. Bump this on the next *real* change
  // and add a matching branch in `onUpgrade` instead of relying on that
  // check alone.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // Drift requires an onUpgrade strategy whenever schemaVersion goes
        // up. The real self-healing work is in _ensureCounterNameColumn,
        // called here *and* from beforeOpen (idempotent either way) so it
        // also fixes a database that reports a version drift never actually
        // sees change (see the NOTE above schemaVersion).
        onUpgrade: (m, from, to) => _ensureCounterNameColumn(),
        beforeOpen: (details) async {
          // Required for the ON DELETE CASCADE on Counters.projectId.
          await customStatement('PRAGMA foreign_keys = ON');
          await _ensureCounterNameColumn();
        },
      );

  /// Adds `counters.name` if an older on-device database predates it, and
  /// backfills existing rows with the same "Zähler N" numbering new counters
  /// get, ordered the way the app already lists them (sort order, then
  /// insertion order).
  Future<void> _ensureCounterNameColumn() async {
    final hasName = await customSelect(
      "SELECT 1 FROM pragma_table_info('counters') WHERE name = 'name'",
    ).get();
    if (hasName.isNotEmpty) return;

    await customStatement(
      "ALTER TABLE counters ADD COLUMN name TEXT NOT NULL DEFAULT ''",
    );
    await customStatement('''
      UPDATE counters
      SET name = 'Zähler ' || (
        SELECT COUNT(*) FROM counters c2
        WHERE c2.project_id = counters.project_id
          AND (c2.sort_order < counters.sort_order
               OR (c2.sort_order = counters.sort_order AND c2.id <= counters.id))
      )
      WHERE name = ''
    ''');
  }

  static QueryExecutor _open() {
    return driftDatabase(
      name: 'knittinglaki',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
