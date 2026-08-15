import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

/// The root widget: theme, routing, and nothing else.
class KairoApp extends ConsumerWidget {
  /// Creates the root widget.
  const KairoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Kairo',
      debugShowCheckedModeBanner: false,
      theme: kairoTheme,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
