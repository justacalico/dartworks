import 'package:dartworks/src/ui/screens/level_select_screen.dart';
import 'package:dartworks/src/ui/screens/main_menu_screen.dart';
import 'package:dartworks/src/ui/screens/notes_archive_screen.dart';
import 'package:dartworks/src/ui/screens/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fonts.dart';
import '../helpers/test_app.dart';

void main() {
  setUpAll(loadTestFonts);
  testWidgets('golden: main menu', (tester) async {
    await pumpApp(tester);
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(MainMenuScreen),
      matchesGoldenFile('main_menu.png'),
    );
  });

  testWidgets('golden: campaign level select', (tester) async {
    await pumpApp(
      tester,
      initialRoute: '/levels',
      completed: {'breakroom', 'museum'},
    );
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(LevelSelectScreen),
      matchesGoldenFile('level_select_campaign.png'),
    );
  });

  testWidgets('golden: sandbox level select', (tester) async {
    await pumpApp(
      tester,
      initialRoute: '/levels?tab=sandbox',
      unlocked: {'museum_basement'},
    );
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(LevelSelectScreen),
      matchesGoldenFile('level_select_sandbox.png'),
    );
  });

  testWidgets('golden: monochats archive', (tester) async {
    await pumpApp(
      tester,
      initialRoute: '/notes',
      notes: {'breakroom_1', 'streets_2', 'runoff_2', 'tower_2'},
    );
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(NotesArchiveScreen),
      matchesGoldenFile('notes_archive.png'),
    );
  });

  testWidgets('golden: settings', (tester) async {
    await pumpApp(tester, initialRoute: '/settings');
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(SettingsScreen),
      matchesGoldenFile('settings.png'),
    );
  });
}
