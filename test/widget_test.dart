import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knittinglaki/data/database.dart';
import 'package:knittinglaki/features/projects/project_list_screen.dart';
import 'package:knittinglaki/providers.dart';

void main() {
  testWidgets('project list shows the empty state when there are no projects',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectsProvider
              .overrideWith((ref) => Stream.value(const <Project>[])),
        ],
        child: const MaterialApp(home: ProjectListScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Knittinglaki'), findsOneWidget);
    expect(find.text('Noch keine Projekte'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
