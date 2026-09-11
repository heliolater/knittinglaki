import 'package:flutter/foundation.dart';

/// Surfaces the most recent uncaught error on screen (see [main.dart] and
/// `app.dart`'s banner). Kevin has no Mac, so Safari's Web Inspector is
/// never available to debug the iPhone build — this is the only way to read
/// an error message off the device itself.
class AppErrors {
  AppErrors._();

  static final ValueNotifier<String?> latest = ValueNotifier<String?>(null);

  static void report(Object error, StackTrace? stack) {
    latest.value = '$error';
    // Also visible via `flutter run` / the browser console, if available.
    debugPrint('Unhandled error: $error\n$stack');
  }

  static void dismiss() => latest.value = null;
}
