import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knittinglaki/core/theme.dart';
import 'package:knittinglaki/data/database.dart';
import 'package:knittinglaki/data/project_repository.dart';
import 'package:knittinglaki/features/counters/widgets/counter_card.dart';
import 'package:knittinglaki/features/counters/widgets/counter_card_variant.dart';
import 'package:knittinglaki/providers.dart';

/// Records which value operations the card triggers, without touching a stream.
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

  final List<String> renamedTo = [];

  @override
  Future<void> renameCounter(int counterId, String name) async =>
      renamedTo.add(name);
}

void main() {
  Future<void> pumpCard(
    WidgetTester tester,
    _SpyRepository repo,
    Counter counter,
    CounterCardVariant variant,
  ) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [projectRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          home: Scaffold(
            body: CounterCard(counter: counter, dragIndex: 0, variant: variant),
          ),
        ),
      ),
    );
  }

  testWidgets('+ / - / reset / delete trigger the matching repository calls',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _SpyRepository(db);

    final counter = Counter(
      id: 1,
      projectId: 1,
      name: 'Zähler 1',
      value: 7,
      sortOrder: 0,
      createdAt: DateTime(2024),
    );

    await pumpCard(tester, repo, counter, CounterCardVariant.circle);

    expect(find.text('ZÄHLER 1'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pump();
    expect(repo.calls, ['increment', 'decrement', 'reset']);

    // Delete asks for confirmation first.
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();

    expect(repo.calls, ['increment', 'decrement', 'reset', 'delete']);
  });

  testWidgets('rename dialog is pre-filled and saves the new name',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _SpyRepository(db);

    final counter = Counter(
      id: 3,
      projectId: 1,
      name: 'Zähler 2',
      value: 0,
      sortOrder: 1,
      createdAt: DateTime(2024),
    );

    await pumpCard(tester, repo, counter, CounterCardVariant.circle);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Zähler 2'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Ferse');
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    expect(repo.renamedTo, ['Ferse']);
  });

  testWidgets('renders the columnBig layout without overflow', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = _SpyRepository(db);

    final counter = Counter(
      id: 2,
      projectId: 1,
      name: 'Zähler 1',
      value: 128,
      sortOrder: 0,
      createdAt: DateTime(2024),
    );

    await pumpCard(tester, repo, counter, CounterCardVariant.circleBig);

    expect(tester.takeException(), isNull);
    expect(find.text('128'), findsOneWidget);
  });
}
