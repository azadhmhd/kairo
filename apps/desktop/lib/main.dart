import 'package:flutter/widgets.dart';

import 'bootstrap/bootstrap.dart';
import 'features/character/presentation/character_window.dart';

/// The main window, and with it the whole of Kairo's runtime.
Future<void> main() => bootstrap();

/// The character window, run by a second `FlutterEngine` on its own isolate.
///
/// Shares nothing with [main] — no providers, no event bus, no database — so it
/// starts no services and simply draws.
///
/// The annotation is required: nothing in Dart calls this, so without it tree
/// shaking removes it from a release build and the window comes up blank.
@pragma('vm:entry-point')
void characterWindowMain() {
  runApp(const CharacterWindow());
}
