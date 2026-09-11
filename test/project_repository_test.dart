import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knittinglaki/data/database.dart';
import 'package:knittinglaki/data/project_repository.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late AppDatabase db;
  late ProjectRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ProjectRepository(db);
  });

  tearDown(() => db.close());

  Future<List<Counter>> counters(int projectId) =>
      repo.watchCounters(projectId).first;

  test('project create / rename / delete', () async {
    final id = await repo.createProject('  Socken  ');
    expect((await repo.watchProjects().first).single.name, 'Socken');

    await repo.renameProject(id, 'Wollsocken');
    expect((await repo.watchProjects().first).single.name, 'Wollsocken');

    await repo.deleteProject(id);
    expect(await repo.watchProjects().first, isEmpty);
  });

  test('a new project starts with exactly one counter', () async {
    final pid = await repo.createProject('Schal');
    final list = await counters(pid);
    expect(list, hasLength(1));
    expect(list.single.value, 0);
    expect(list.single.name, 'Zähler 1');
  });

  test('renameCounter changes the name without touching anything else',
      () async {
    final pid = await repo.createProject('Schal');
    final counter = (await counters(pid)).single;

    await repo.renameCounter(counter.id, '  Bund  ');

    final renamed = (await counters(pid)).single;
    expect(renamed.name, 'Bund');
    expect(renamed.value, counter.value);
  });

  test(
    'a new counter is named after the current count, even once others are '
    'renamed or reordered',
    () async {
      final pid = await repo.createProject('Schal');
      final first = (await counters(pid)).single; // "Zähler 1"
      final secondId = await repo.createCounter(pid); // "Zähler 2"
      await repo.renameCounter(first.id, 'Ferse');
      await repo.renameCounter(secondId, 'Bund');

      await repo.createCounter(pid);

      final names = (await counters(pid)).map((c) => c.name).toList();
      expect(names, ['Ferse', 'Bund', 'Zähler 3']);
    },
  );

  test('increment / decrement clamps at 0 / reset', () async {
    final pid = await repo.createProject('Schal');
    final cid = (await counters(pid)).single.id;

    Future<int> value() async => (await counters(pid)).single.value;

    await repo.decrement(cid); // already 0 -> stays 0
    expect(await value(), 0);

    await repo.increment(cid);
    await repo.increment(cid);
    await repo.increment(cid);
    expect(await value(), 3);

    await repo.decrement(cid);
    expect(await value(), 2);

    await repo.reset(cid);
    expect(await value(), 0);
  });

  test('added counters and cascade delete', () async {
    final pid = await repo.createProject('Mütze');
    await repo.createCounter(pid);
    await repo.createCounter(pid);
    final list = await counters(pid);
    expect(list, hasLength(3)); // 1 auto + 2 added
    expect(list.map((c) => c.name), ['Zähler 1', 'Zähler 2', 'Zähler 3']);

    await repo.deleteProject(pid);
    expect(await db.select(db.counters).get(), isEmpty);
  });

  test('reorderCounters persists the new order', () async {
    final pid = await repo.createProject('P');
    final a = (await counters(pid)).single.id;
    final b = await repo.createCounter(pid);
    final c = await repo.createCounter(pid);

    await repo.reorderCounters([c, a, b]);

    final ids = (await counters(pid)).map((counter) => counter.id).toList();
    expect(ids, [c, a, b]);
  });

  test('reorderProjects persists the new order', () async {
    final a = await repo.createProject('A');
    final b = await repo.createProject('B');
    final c = await repo.createProject('C');

    await repo.reorderProjects([c, a, b]);

    final names =
        (await repo.watchProjects().first).map((p) => p.name).toList();
    expect(names, ['C', 'A', 'B']);
  });

  test(
    'self-heals an on-device database that predates the counters.name column',
    () async {
      // Simulates a real device: a database created by an old build, before
      // `name` existed, still tagged schema version 1 (that never changed
      // across the column being removed and re-added — see database.dart).
      final raw = sqlite3.openInMemory();
      raw.execute('''
        CREATE TABLE projects (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          sort_order INTEGER NOT NULL DEFAULT 0
        );
      ''');
      raw.execute('''
        CREATE TABLE counters (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          project_id INTEGER NOT NULL REFERENCES projects (id) ON DELETE CASCADE,
          value INTEGER NOT NULL DEFAULT 0,
          sort_order INTEGER NOT NULL DEFAULT 0,
          -- Real on-device tables have a SQL-level default here (from
          -- `dateTime().withDefault(currentDateAndTime)`), which is what lets
          -- ProjectRepository.createCounter omit created_at. Any default
          -- satisfies this test; the exact value isn't asserted on.
          created_at INTEGER NOT NULL DEFAULT 0
        );
      ''');
      final now = DateTime.now().millisecondsSinceEpoch;
      raw.execute(
        "INSERT INTO projects (id, name, created_at, sort_order) "
        "VALUES (1, 'Schal', $now, 0)",
      );
      raw.execute(
        'INSERT INTO counters (id, project_id, value, sort_order, created_at) '
        "VALUES (1, 1, 5, 0, $now), (2, 1, 0, 1, $now)",
      );
      raw.execute('PRAGMA user_version = 1');

      final legacyDb = AppDatabase.forTesting(NativeDatabase.opened(raw));
      addTearDown(legacyDb.close);
      final legacyRepo = ProjectRepository(legacyDb);

      // Opening it must not throw, and existing rows get backfilled names in
      // their existing order.
      final existing = await legacyRepo.watchCounters(1).first;
      expect(existing.map((c) => c.name), ['Zähler 1', 'Zähler 2']);

      // And creating a new counter works again (this used to throw
      // "table counters has no column named name").
      final newId = await legacyRepo.createCounter(1);
      final all = await legacyRepo.watchCounters(1).first;
      expect(all.firstWhere((c) => c.id == newId).name, 'Zähler 3');
    },
  );
}
