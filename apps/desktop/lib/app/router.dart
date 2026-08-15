import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/character/presentation/character_gallery_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/reminders/presentation/reminders_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

/// Route paths, so navigation never depends on a string literal at a call site.
abstract final class KairoRoutes {
  KairoRoutes._();

  /// How today is going, and what is coming next. The landing surface.
  static const String dashboard = '/';

  /// What Kairo reminds the user about, and how often.
  static const String reminders = '/reminders';

  /// How the last week or month has gone.
  static const String reports = '/reports';

  /// How Kairo should behave, and what to do with the data it keeps.
  static const String settings = '/settings';

  /// Every state the character rig can draw, for checking it against the
  /// character sheet. Development scaffolding: nothing in the interface links
  /// here.
  static const String characterGallery = '/character-gallery';
}

/// The application's [GoRouter].
final Provider<GoRouter> routerProvider = Provider<GoRouter>(
  (Ref ref) => GoRouter(
    initialLocation: KairoRoutes.dashboard,
    routes: <RouteBase>[
      GoRoute(
        path: KairoRoutes.dashboard,
        builder: (_, _) => const DashboardScreen(),
      ),
      GoRoute(
        path: KairoRoutes.reminders,
        builder: (_, _) => const RemindersScreen(),
      ),
      GoRoute(
        path: KairoRoutes.reports,
        builder: (_, _) => const ReportsScreen(),
      ),
      GoRoute(
        path: KairoRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: KairoRoutes.characterGallery,
        builder: (_, _) => const CharacterGalleryScreen(),
      ),
    ],
  ),
);
