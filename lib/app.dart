import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/error_banner.dart';
import 'core/theme.dart';
import 'features/counters/project_detail_screen.dart';
import 'features/projects/project_list_screen.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ProjectListScreen(),
    ),
    GoRoute(
      path: '/project/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) return const ProjectListScreen();
        return ProjectDetailScreen(projectId: id);
      },
    ),
  ],
);

class KnittinglakiApp extends StatelessWidget {
  const KnittinglakiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Knittinglaki',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      routerConfig: _router,
      builder: (context, child) => Stack(children: [?child, const ErrorBanner()]),
    );
  }
}
