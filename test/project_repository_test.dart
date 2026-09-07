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

  Future<int> counterValue(int projectId) async =>
      (await repo.watchCounters(projectId).first).single.value;

  test('project create / rename / delete', () async {
    final id = await repo.createProject('  Socken  ');
    expect((await repo.watchProjects().first).single.name, 'Socken');

    await repo.renameProject(id, 'Wollsocken');
    expect((await repo.watchProjects().first).single.name, 'Wollsocken');

    await repo.deleteProject(id);
    expect(await repo.watchProjects().first, isEmpty);
  });

  test('counter increment / decrement clamps at 0 / reset', () async {
    final pid = await repo.createProject('Schal');
    final cid = await repo.createCounter(pid, 'Hauptteil');

    expect(await counterValue(pid), 0);

    await repo.decrement(cid); // already 0 -> stays 0
    expect(await counterValue(pid), 0);

    await repo.increment(cid);
    await repo.increment(cid);
    await repo.increment(cid);
    expect(await counterValue(pid), 3);

    await repo.decrement(cid);
    expect(await counterValue(pid), 2);

    await repo.reset(cid);
    expect(await counterValue(pid), 0);
  });

  test('deleting a project cascades to its counters', () async {
    final pid = await repo.createProject('Mütze');
    await repo.createCounter(pid, 'A');
    await repo.createCounter(pid, 'B');
    expect((await repo.watchCounters(pid).first).length, 2);

    await repo.deleteProject(pid);

    expect(await db.select(db.counters).get(), isEmpty);
  });

  test('watchCounterCounts reports per-project totals', () async {
    final p1 = await repo.createProject('P1');
    final p2 = await repo.createProject('P2');
    await repo.createCounter(p1, 'a');
    await repo.createCounter(p1, 'b');
    await repo.createCounter(p2, 'c');

    final counts = await repo.watchCounterCounts().first;
    expect(counts[p1], 2);
    expect(counts[p2], 1);
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

  test('reorderCounters persists the new order', () async {
    final pid = await repo.createProject('P');
    final a = await repo.createCounter(pid, 'A');
    final b = await repo.createCounter(pid, 'B');
    final c = await repo.createCounter(pid, 'C');

    await repo.reorderCounters([b, c, a]);

    final names =
        (await repo.watchCounters(pid).first).map((c) => c.name).toList();
    expect(names, ['B', 'C', 'A']);
  });
}
