import 'dart:ui' show PictureRecorder;

import 'package:dartworks/src/app_scope.dart';
import 'package:dartworks/src/data/items.dart';
import 'package:dartworks/src/game/render/item_painter.dart';
import 'package:dartworks/src/ui/screens/game_screen.dart';
import 'package:dartworks/src/ui/game/touch_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_store.dart';
import '../helpers/fonts.dart';
import '../helpers/test_app.dart';

void main() {
  setUpAll(loadTestFonts);

  group('menu navigation', () {
    testWidgets('sandbox button opens the level list on the tab',
        (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('SANDBOX'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.text('DESTINATIONS // MYTHOS ACCESS'), findsOneWidget);
      expect(find.text('BLANKBOX'), findsOneWidget);
    });

    testWidgets('monochats button opens the archive', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('MONOCHATS'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.text('MONOCHATS // RECOVERED DATA'), findsOneWidget);
    });

    testWidgets('settings button opens settings', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('SETTINGS'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.text('WIPE SAVE DATA'), findsWidgets);
    });
  });

  group('level select', () {
    testWidgets('back button returns to the menu', (tester) async {
      await pumpApp(tester, initialRoute: '/levels');
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.text('DARTWORKS'), findsWidgets);
    });

    testWidgets('tab chip switches between campaign and sandbox',
        (tester) async {
      await pumpApp(tester, initialRoute: '/levels');
      await tester.tap(find.text('SANDBOX').last);
      await tester.pump();
      expect(find.text('TUSCANY'), findsOneWidget);
      await tester.tap(find.text('CAMPAIGN').first);
      await tester.pump();
      expect(find.text('BREAKROOM'), findsOneWidget);
    });

    testWidgets('tapping an unlocked level starts the run',
        (tester) async {
      await pumpApp(tester, initialRoute: '/levels');
      await tester.tap(find.text('BREAKROOM'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('locked levels do not open', (tester) async {
      await pumpApp(tester, initialRoute: '/levels');
      await tester.tap(find.text('THRONE ROOM'));
      await tester.pump();
      expect(find.byType(GameScreen), findsNothing);
    });
  });

  group('settings', () {
    testWidgets('wipe dialog cancel keeps the save', (tester) async {
      await pumpApp(tester, initialRoute: '/settings');
      await tester.tap(find.text('WIPE SAVE DATA'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.text('WIPE SAVE DATA?'), findsOneWidget);
      await tester.tap(find.text('CANCEL'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.text('WIPE SAVE DATA?'), findsNothing);
    });

    testWidgets('confirming the wipe clears the save', (tester) async {
      final store = await pumpApp(tester,
          initialRoute: '/settings', completed: {'breakroom'});
      expect(store.isLevelComplete('breakroom'), isTrue);
      await tester.tap(find.text('WIPE SAVE DATA'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.tap(find.text('WIPE'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(store.isLevelComplete('breakroom'), isFalse);
    });

    testWidgets('back button returns to the menu', (tester) async {
      await pumpApp(tester, initialRoute: '/settings');
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.text('DARTWORKS'), findsWidgets);
    });

    testWidgets('license link opens the license page', (tester) async {
      await pumpApp(tester, initialRoute: '/settings');
      await tester.tap(find.text('VIEW LICENSES'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.byType(LicensePage), findsOneWidget);
    });
  });

  group('notes archive', () {
    testWidgets('back button returns to the menu', (tester) async {
      await pumpApp(tester, initialRoute: '/notes');
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.text('DARTWORKS'), findsWidgets);
    });
  });

  group('game screen', () {
    testWidgets('mobile builds the touch overlay', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await pumpApp(tester, initialRoute: '/game?id=breakroom');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(TouchControls), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('module unlock events reach the screen', (tester) async {
      await pumpApp(tester, initialRoute: '/game?id=breakroom');
      await tester.pump(const Duration(milliseconds: 300));
      final state =
          tester.state(find.byType(GameScreen)) as dynamic;
      (state.game as dynamic).events.onUnlock?.call('blankbox');
      await tester.pump();
    });
  });

  group('catalog helpers', () {
    test('item lookup and category flags', () {
      expect(itemById('p350')?.isGun, isTrue);
      expect(itemById('crowbar')?.isWeapon, isTrue);
      expect(itemById('nope'), isNull);
      expect(kItems['keycard']!.isHoldable, isFalse);
      expect(kItems['p350']!.isHoldable, isTrue);
    });

    test('quest painter falls back for unknown ids', () {
      final recorder = PictureRecorder();
      paintItem(
        Canvas(recorder),
        const ItemDef(
          id: 'relic',
          name: 'RELIC',
          category: ItemCategory.quest,
          color: 0xFFFFFFFF,
        ),
        const Size(1, 1),
      );
      recorder.endRecording();
    });
  });

  group('app scope', () {
    testWidgets('notifies only when the store changes', (tester) async {
      final store = FakeProgressStore();
      final scope =
          AppScope(progress: store, child: const SizedBox());
      expect(
          scope.updateShouldNotify(
              AppScope(progress: store, child: const SizedBox())),
          isFalse);
      expect(
          scope.updateShouldNotify(AppScope(
              progress: FakeProgressStore(),
              child: const SizedBox())),
          isTrue);
    });
  });
}
