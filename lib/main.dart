import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/error_reporting.dart';

void main() {
  // Surface every crash on screen instead of a blank/frozen page — there's
  // no Mac to open Safari's Web Inspector on, so this is the only debugging
  // channel the iPhone build has.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppErrors.report(details.exception, details.stack);
  };
  ErrorWidget.builder = (details) => Material(
    color: Colors.red.shade50,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText(
            'Fehler beim Anzeigen:\n\n${details.exceptionAsString()}',
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ),
    ),
  );

  runZonedGuarded(
    () => runApp(const ProviderScope(child: KnittinglakiApp())),
    AppErrors.report,
  );
}
