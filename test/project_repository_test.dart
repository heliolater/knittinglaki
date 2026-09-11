import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knittinglaki/data/database.dart';
import 'package:knittinglaki/data/project_repository.dart';

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
}
