import 'package:dartworks/src/game/systems/input_state.dart';
import 'package:dartworks/src/ui/game/touch_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fonts.dart';

void main() {
  setUpAll(loadTestFonts);

  Widget host(InputState input, {VoidCallback? onPause}) {
    return MaterialApp(
      home: Scaffold(body: TouchControls(input: input, onPause: onPause)),
    );
  }

  testWidgets('pause button calls onPause', (tester) async {
    var paused = false;
    await tester.pumpWidget(host(InputState(), onPause: () => paused = true));
    await tester.tap(find.text('II'));
    expect(paused, isTrue);
  });

  Finder sticks() => find.byWidgetPredicate((w) =>
      w is Container &&
      w.decoration is BoxDecoration &&
      (w.decoration! as BoxDecoration).shape == BoxShape.circle &&
      (w.decoration! as BoxDecoration).border != null);

  testWidgets('left stick moves and crouches', (tester) async {
    final input = InputState();
    await tester.pumpWidget(host(input));
    final g =
        await tester.startGesture(tester.getCenter(sticks().first));
    await g.moveBy(const Offset(60, 50));
    await tester.pump();
    expect(input.moveAxis, greaterThan(0));
    expect(input.crouch, isTrue);
    await g.up();
  });

  testWidgets('left stick up jumps and release clears', (tester) async {
    final input = InputState();
    await tester.pumpWidget(host(input));
    final gesture =
        await tester.startGesture(tester.getCenter(sticks().first));
    await gesture.moveBy(const Offset(0, -60));
    await tester.pump();
    expect(input.jump, isTrue);
    expect(input.jumpEdge, isTrue);
    await gesture.up();
    await tester.pump();
    expect(input.jump, isFalse);
    expect(input.moveAxis, 0);
  });

  testWidgets('aim stick fires when pushed far', (tester) async {
    final input = InputState();
    await tester.pumpWidget(host(input));
    final g =
        await tester.startGesture(tester.getCenter(sticks().last));
    await g.moveBy(const Offset(60, 0));
    await tester.pump();
    expect(input.aimX, greaterThan(0.5));
    expect(input.fire, isTrue);
    await g.up();
  });

  testWidgets('hold buttons set and clear flags', (tester) async {
    final input = InputState();
    await tester.pumpWidget(host(input));
    final grab = find.text('GRAB');
    final g = await tester.startGesture(tester.getCenter(grab));
    await tester.pump();
    expect(input.grab, isTrue);
    await g.up();
    await tester.pump();
    expect(input.grab, isFalse);

    final slow = find.text('SLOW');
    final s = await tester.startGesture(tester.getCenter(slow));
    await tester.pump();
    expect(input.slowmo, isTrue);
    await s.up();
    await tester.pump();
    expect(input.slowmo, isFalse);
  });

  testWidgets('USE sets interact edge', (tester) async {
    final input = InputState();
    await tester.pumpWidget(host(input));
    await tester.tap(find.text('USE'));
    expect(input.interactEdge, isTrue);
  });
}
