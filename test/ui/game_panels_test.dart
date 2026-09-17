import 'package:dartworks/src/data/level_data.dart';
import 'package:dartworks/src/data/notes.dart';
import 'package:dartworks/src/game/components/monomat.dart';
import 'package:dartworks/src/game/dartworks_game.dart';
import 'package:dartworks/src/game/game_events.dart';
import 'package:dartworks/src/game/hud_state.dart';
import 'package:dartworks/src/game/systems/monomat_economy.dart';
import 'package:dartworks/src/ui/game/game_panels.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fonts.dart';
import '../helpers/fake_store.dart';
import '../helpers/mini_level.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  setUpAll(loadTestFonts);

  group('panels', () {
    testWidgets('pause menu buttons fire callbacks', (tester) async {
      var resumed = false;
      var quit = false;
      await tester.pumpWidget(_wrap(PauseMenu(
          onResume: () => resumed = true, onQuit: () => quit = true)));
      expect(find.text('SIMULATION PAUSED'), findsOneWidget);
      await tester.tap(find.text('RESUME'));
      expect(resumed, isTrue);
      await tester.tap(find.text('ABANDON RUN'));
      expect(quit, isTrue);
    });

    testWidgets('death screen fires retry and quit', (tester) async {
      var retried = false;
      var quit = false;
      await tester.pumpWidget(_wrap(DeathScreen(
          onRetry: () => retried = true, onQuit: () => quit = true)));
      expect(find.text('CONSTRUCT TERMINATED'), findsOneWidget);
      await tester.tap(find.text('RE-ENTER'));
      expect(retried, isTrue);
      await tester.tap(find.text('ABANDON'));
      expect(quit, isTrue);
    });

    testWidgets('complete screen shows time and notes', (tester) async {
      var done = false;
      await tester.pumpWidget(_wrap(CompleteScreen(
        result: const LevelResult(
            levelId: 'museum',
            timeSeconds: 95.4,
            notesFound: 2,
            notesTotal: 5,
            won: true),
        onDone: () => done = true,
      )));
      expect(find.text('SIMULATION COMPLETE'), findsOneWidget);
      expect(find.textContaining('1m'), findsOneWidget);
      expect(find.textContaining('2/5'), findsOneWidget);
      await tester.tap(find.text('CONTINUE'));
      expect(done, isTrue);
    });

    testWidgets('note popup closes on tap', (tester) async {
      var closed = false;
      await tester.pumpWidget(_wrap(NotePopup(
        note: const NoteInfo(
            id: 'n1',
            levelId: 'museum',
            title: 'TEST LOG',
            author: 'ford',
            body: 'lore body text'),
        onClose: () => closed = true,
      )));
      expect(find.text('TEST LOG'), findsOneWidget);
      expect(find.text('lore body text'), findsOneWidget);
      await tester.tap(find.byType(NotePopup));
      expect(closed, isTrue);
    });

    testWidgets('monomat panel lists offers and buys', (tester) async {
      final hud = HudState();
      final game = DartworksGame(
        level: miniLevel(['#####', '#P..#', '#####']),
        store: FakeProgressStore(),
        events: const GameEvents(),
      );
      final zone = MonomatZone(
        center: Vector2(5, 5),
        stock: MonomatStock(const [MonomatOffer('p350', 10)]),
      );
      await tester.pumpWidget(_wrap(MonomatPanel(hud: hud, onBuy: (_) {})));
      // hidden until a monomat opens
      expect(find.text('MONOMAT'), findsNothing);
      hud.openMonomat = zone;
      await tester.pump();
      expect(find.text('MONOMAT'), findsOneWidget);
      expect(find.text('BUY'), findsOneWidget);
      var bought = -1;
      await tester.pumpWidget(
          _wrap(MonomatPanel(hud: hud, onBuy: (i) => bought = i)));
      await tester.tap(find.text('BUY'));
      expect(bought, 0);
      game.onRemove();
    });

    testWidgets('hud state toasts and ticks', (tester) async {
      final hud = HudState();
      hud.showToast('HELLO');
      expect(hud.toast, 'HELLO');
      for (var i = 0; i < 200; i++) {
        hud.tick(1 / 60);
      }
      expect(hud.toast, isNull);
    });
  });
}
