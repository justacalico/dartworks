import 'package:dartworks/src/ui/game/hud_overlay.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fonts.dart';
import '../helpers/test_app.dart';

void main() {
  setUpAll(loadTestFonts);

  group('GameScreen', () {
    testWidgets('renders HUD and level title', (tester) async {
      await pumpApp(tester, initialRoute: '/game?id=breakroom');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('BREAKROOM'), findsWidgets);
      expect(find.byType(HudOverlay), findsOneWidget);
    });

    testWidgets('unknown level shows fallback instead of crashing',
        (tester) async {
      await pumpApp(tester, initialRoute: '/game?id=nope');
      await tester.pump();
      expect(find.text('UNKNOWN SECTOR'), findsOneWidget);
    });

    testWidgets('escape opens pause menu, resume hides it',
        (tester) async {
      await pumpApp(tester, initialRoute: '/game?id=breakroom');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.text('SIMULATION PAUSED'), findsOneWidget);
      await tester.tap(find.text('RESUME'));
      await tester.pump();
      expect(find.text('SIMULATION PAUSED'), findsNothing);
    });

    testWidgets('quit returns to the menu', (tester) async {
      await pumpApp(tester, initialRoute: '/game?id=breakroom');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.tap(find.text('ABANDON RUN'));
      await tester.pump();
      expect(find.text('DARTWORKS'), findsWidgets);
    });
  });
}
