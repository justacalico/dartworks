import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'data/level_info.dart';
import 'meta/progress_store.dart';
import 'theme.dart';
import 'ui/screens/game_screen.dart';
import 'ui/screens/level_select_screen.dart';
import 'ui/screens/main_menu_screen.dart';
import 'ui/screens/notes_archive_screen.dart';
import 'ui/screens/settings_screen.dart';

class DartworksApp extends StatelessWidget {
  const DartworksApp({
    super.key,
    required this.progress,
    this.initialRoute = '/',
  });

  final ProgressStore progress;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      progress: progress,
      child: MaterialApp(
        title: 'DARTWORKS',
        debugShowCheckedModeBanner: false,
        theme: DwTheme.dark,
        initialRoute: initialRoute,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }
}

Route<dynamic> _onGenerateRoute(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '/');
  final Widget page = switch (uri.path) {
    '/levels' => LevelSelectScreen(
        startTab: uri.queryParameters['tab'] == 'sandbox'
            ? LevelKind.sandbox
            : LevelKind.campaign,
      ),
    '/notes' => const NotesArchiveScreen(),
    '/settings' => const SettingsScreen(),
    '/game' => GameScreen(levelId: uri.queryParameters['id'] ?? ''),
    _ => const MainMenuScreen(),
  };
  return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
}
