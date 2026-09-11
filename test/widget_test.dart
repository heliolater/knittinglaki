import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knittinglaki/core/pill_fab.dart';
import 'package:knittinglaki/core/theme.dart';
import 'package:knittinglaki/data/database.dart';
import 'package:knittinglaki/features/projects/project_list_screen.dart';
import 'package:knittinglaki/features/projects/widgets/wordmark.dart';
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
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          home: const ProjectListScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Wordmark), findsOneWidget);
    expect(find.text('Noch keine Projekte — tippe auf +'), findsOneWidget);
    expect(find.byType(PillFab), findsOneWidget);
  });
}
