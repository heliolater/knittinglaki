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
  });

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
    expect(await counters(pid), hasLength(3)); // 1 auto + 2 added

    await repo.deleteProject(pid);
    expect(await db.select(db.counters).get(), isEmpty);
  });

  test('watchCounterCounts reports per-project totals', () async {
    final p1 = await repo.createProject('P1');
    final p2 = await repo.createProject('P2');
    await repo.createCounter(p1);

    final counts = await repo.watchCounterCounts().first;
    expect(counts[p1], 2); // 1 auto + 1 added
    expect(counts[p2], 1); // 1 auto
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
