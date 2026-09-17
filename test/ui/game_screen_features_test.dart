import 'package:dartworks/src/data/items.dart';
import 'package:dartworks/src/data/notes.dart';
import 'package:dartworks/src/game/dartworks_game.dart';
import 'package:dartworks/src/game/game_events.dart';
import 'package:dartworks/src/ui/screens/game_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fonts.dart';
import '../helpers/test_app.dart';

void main() {
  setUpAll(loadTestFonts);

  DartworksGame gameOf(WidgetTester tester) {
    final state =
        tester.state(find.byType(GameScreen)) as dynamic;
    return state.game as DartworksGame;
  }

  group('GameScreen features', () {
    testWidgets('mouse aims, fires and grabs', (tester) async {
      await pumpApp(tester, initialRoute: '/game?id=breakroom');
      await tester.pump(const Duration(milliseconds: 300));
      final game = gameOf(tester);

      final mouse =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(500, 300));
      await mouse.moveTo(const Offset(900, 300));
      await tester.pump();
      expect(game.input.aimX * game.input.aimX +
          game.input.aimY * game.input.aimY, greaterThan(0.01));

      await mouse.down(const Offset(900, 300));
      await tester.pump();
      expect(game.input.fire, isTrue);
      await mouse.up();
      await tester.pump();
      expect(game.input.fire, isFalse);

      await mouse.removePointer();
      final rmb = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
          buttons: kSecondaryMouseButton);
      await rmb.addPointer(location: const Offset(700, 300));
      await rmb.down(const Offset(700, 300));
      await tester.pump();
      expect(game.input.grab, isTrue);
      await rmb.up();
      await tester.pump();
      expect(game.input.grab, isFalse);
      await rmb.removePointer();
    });

    testWidgets('losing focus clears held input', (tester) async {
      await pumpApp(tester, initialRoute: '/game?id=breakroom');
      await tester.pump(const Duration(milliseconds: 300));
      final game = gameOf(tester);
      game.input.moveAxis = 1;
      game.input.grab = true;
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(game.input.moveAxis, 0);
      expect(game.input.grab, isFalse);
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });

    testWidgets('death screen retries the level', (tester) async {
      await pumpApp(tester, initialRoute: '/game?id=breakroom');
      await tester.pump(const Duration(milliseconds: 300));
      final game = gameOf(tester);
      game.events.onDeath?.call();
      await tester.pump();
      expect(find.text('CONSTRUCT TERMINATED'), findsOneWidget);
      await tester.tap(find.text('RE-ENTER'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('CONSTRUCT TERMINATED'), findsNothing);
      expect(gameOf(tester).player.hp, greaterThan(0));
    });

    testWidgets('quit from death screen returns to the menu',
        (tester) async {
      await pumpApp(tester, initialRoute: '/game?id=breakroom');
      await tester.pump(const Duration(milliseconds: 300));
      gameOf(tester).events.onDeath?.call();
      await tester.pump();
      await tester.tap(find.text('ABANDON'));
      await tester.pump();
      expect(find.text('DARTWORKS'), findsWidgets);
    });

    testWidgets('note popup opens and closes', (tester) async {
      await pumpApp(tester, initialRoute: '/game?id=breakroom');
      await tester.pump(const Duration(milliseconds: 300));
      gameOf(tester).events.onNote?.call(
        const NoteInfo(
          id: 'n1',
          levelId: 'breakroom',
          title: 'FIELD NOTE',
          author: 'sys',
          body: 'words',
        ),
      );
      await tester.pump();
      expect(find.text('FIELD NOTE'), findsOneWidget);
      await tester.tap(find.text('TAP TO FILE'));
      await tester.pump();
      expect(find.text('FIELD NOTE'), findsNothing);
    });

    testWidgets('complete screen reports the run', (tester) async {
      await pumpApp(tester, initialRoute: '/game?id=breakroom');
      await tester.pump(const Duration(milliseconds: 300));
      gameOf(tester).events.onComplete?.call(
        const LevelResult(
          levelId: 'breakroom',
          timeSeconds: 12.5,
          notesFound: 1,
          notesTotal: 2,
          won: true,
        ),
      );
      await tester.pump();
      expect(find.text('SIMULATION COMPLETE'), findsOneWidget);
      await tester.tap(find.text('CONTINUE'));
      await tester.pump();
      expect(find.text('DARTWORKS'), findsWidgets);
    });

    testWidgets('hud shows toast, keycards and gun ammo',
        (tester) async {
      await pumpApp(tester, initialRoute: '/game?id=breakroom');
      await tester.pump(const Duration(milliseconds: 300));
      final game = gameOf(tester);
      // pause the engine so _syncHud does not overwrite these fields
      game.paused = true;
      final hud = game.hud;
      hud.keycards = 2;
      hud.looseAmmo = 30;
      hud.slotItem = kItems['p350'];
      hud.slotAmmo = 7;
      hud.showToast('PING');
      await tester.pump();
      expect(find.text('PING'), findsOneWidget);
      expect(find.text('KEYCARD x2'), findsOneWidget);
      expect(find.text('7 / 30'), findsOneWidget);
    });
  });
}
