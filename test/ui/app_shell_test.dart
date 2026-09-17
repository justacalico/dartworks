import 'package:dartworks/src/ui/screens/game_screen.dart';
import 'package:dartworks/src/ui/screens/level_select_screen.dart';
import 'package:dartworks/src/ui/screens/main_menu_screen.dart';
import 'package:dartworks/src/ui/screens/notes_archive_screen.dart';
import 'package:dartworks/src/ui/screens/settings_screen.dart';
import 'package:dartworks/src/ui/widgets/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('main menu shows logo and all destinations', (tester) async {
    await pumpApp(tester);
    expect(find.text('DARTWORKS'), findsNWidgets(3)); // logo layers
    expect(find.text('CAMPAIGN'), findsOneWidget);
    expect(find.text('SANDBOX'), findsOneWidget);
    expect(find.text('MONOCHATS'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(
      find.text('UNOFFICIAL FAN PROJECT - NOT FOR PRODUCTION'),
      findsOneWidget,
    );
  });

  testWidgets('campaign button opens level select on campaign tab',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.widgetWithText(MenuButton, 'CAMPAIGN'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(LevelSelectScreen), findsOneWidget);
    expect(find.text('BREAKROOM'), findsOneWidget);
    expect(find.text('THRONE ROOM'), findsOneWidget);
  });

  testWidgets('sandbox tab shows locked modules with hints',
      (tester) async {
    await pumpApp(tester, initialRoute: '/levels?tab=sandbox');
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('MUSEUM BASEMENT'), findsOneWidget);
    expect(find.text('FANTASY ARENA'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
  });

  testWidgets('tapping a locked level shows its unlock hint',
      (tester) async {
    await pumpApp(tester, initialRoute: '/levels?tab=sandbox');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('BLANKBOX'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text(
            'Find the hidden room in the Museum. Push the wrong panel.'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('unlocked levels navigate to the game screen',
      (tester) async {
    await pumpApp(tester, initialRoute: '/levels');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('BREAKROOM'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('BREAKROOM'), findsWidgets);
  });

  testWidgets('monochats archive shows found and redacted notes',
      (tester) async {
    await pumpApp(
      tester,
      initialRoute: '/notes',
      notes: {'breakroom_1', 'streets_3'},
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(NotesArchiveScreen), findsOneWidget);
    expect(find.text('SORTING PROTOCOL'), findsOneWidget);
    expect(find.text('re: ford'), findsOneWidget);
    expect(find.textContaining('[DATA FRAGMENT]'), findsWidgets);
    expect(find.text('2/${30}'), findsNothing); // count shown as x/N
  });

  testWidgets('settings shows controls and wipe flow', (tester) async {
    final store = await pumpApp(tester, initialRoute: '/settings');
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('CONTROL REFERENCE'), findsOneWidget);
    expect(find.text('Slow motion'), findsOneWidget);

    await store.addNote('museum_1');
    await tester.tap(find.widgetWithText(MenuButton, 'WIPE SAVE DATA'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('WIPE SAVE DATA?'), findsOneWidget);
    await tester.tap(find.text('WIPE'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(store.hasNote('museum_1'), isFalse);
  });

  testWidgets('unknown routes fall back to the main menu', (tester) async {
    await pumpApp(tester, initialRoute: '/nope');
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(MainMenuScreen), findsOneWidget);
  });
}
