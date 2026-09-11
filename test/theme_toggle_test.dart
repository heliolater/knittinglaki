import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knittinglaki/core/theme.dart';
import 'package:knittinglaki/core/theme_mode_controller.dart';
import 'package:knittinglaki/features/projects/widgets/theme_toggle_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Exercises exactly what app.dart wires up (themeModeProvider driving
/// MaterialApp.themeMode) without the real app shell (go_router, the drift
/// database) — those bring in real async/isolate machinery that doesn't play
/// well with the test harness's fake-async pump loop.
Widget _harness() {
  return ProviderScope(
    child: Consumer(
      builder: (context, ref, _) {
        final mode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
        return MaterialApp(
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: mode,
          home: const Scaffold(body: Center(child: ThemeToggleButton())),
        );
      },
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Brightness currentBrightness(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Scaffold))).brightness;

  testWidgets('tapping the toggle switches theme and persists the choice',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    // Test harness defaults to a light platform brightness, and no stored
    // preference yet -> starts on the system (light) theme.
    expect(currentBrightness(tester), Brightness.light);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pumpAndSettle();

    expect(currentBrightness(tester), Brightness.dark);
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
  });
}
