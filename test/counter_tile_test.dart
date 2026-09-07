import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knittinglaki/data/database.dart';
import 'package:knittinglaki/data/project_repository.dart';
import 'package:knittinglaki/features/counters/widgets/counter_tile.dart';
import 'package:knittinglaki/providers.dart';

/// Records which value operations the tile triggers, without touching a stream.
class _SpyRepository extends ProjectRepository {
  _SpyRepository(super.db);

  final List<String> calls = [];

  @override
  Future<void> increment(int counterId) async => calls.add('increment');

  @override
  Future<void> decrement(int counterId) async => calls.add('decrement');

  @override
  Future<void> reset(int counterId) async => calls.add('reset');

  @override
  Future<void> deleteCounter(int counterId) async => calls.add('delete');
}

void main() {
  testWidgets('+ / - / reset trigger the matching repository calls',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _SpyRepository(db);

    final counter = Counter(
      id: 1,
      projectId: 1,
      value: 7,
      sortOrder: 0,
      createdAt: DateTime(2024),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [projectRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          home: Scaffold(
            body: CounterTile(counter: counter, dragIndex: 0),
          ),
        ),
      ),
    );

    expect(find.text('Zähler 1'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.remove));
    await tester.tap(find.byIcon(Icons.restart_alt));
    await tester.pump();

    expect(repo.calls, ['increment', 'decrement', 'reset']);
  });
}
