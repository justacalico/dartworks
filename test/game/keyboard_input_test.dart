import 'package:dartworks/src/game/keyboard_input.dart';
import 'package:dartworks/src/game/systems/input_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

KeyEvent down(LogicalKeyboardKey key) => KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.keyA,
      logicalKey: key,
      timeStamp: Duration.zero,
    );

KeyEvent up(LogicalKeyboardKey key) => KeyUpEvent(
      physicalKey: PhysicalKeyboardKey.keyA,
      logicalKey: key,
      timeStamp: Duration.zero,
    );

void main() {
  group('KeyboardInputMapper', () {
    test('left and right keys drive moveAxis', () {
      final input = InputState();
      final m = KeyboardInputMapper(input);
      m.handleKey(down(LogicalKeyboardKey.keyA));
      expect(input.moveAxis, -1);
      m.handleKey(down(LogicalKeyboardKey.keyD));
      expect(input.moveAxis, 0);
      m.handleKey(up(LogicalKeyboardKey.keyA));
      expect(input.moveAxis, 1);
      m.handleKey(up(LogicalKeyboardKey.keyD));
      expect(input.moveAxis, 0);
    });

    test('arrow keys mirror wasd', () {
      final input = InputState();
      final m = KeyboardInputMapper(input);
      m.handleKey(down(LogicalKeyboardKey.arrowLeft));
      expect(input.moveAxis, -1);
      m.handleKey(up(LogicalKeyboardKey.arrowLeft));
      m.handleKey(down(LogicalKeyboardKey.arrowRight));
      expect(input.moveAxis, 1);
    });

    test('jump is held plus an edge on press', () {
      final input = InputState();
      final m = KeyboardInputMapper(input);
      m.handleKey(down(LogicalKeyboardKey.space));
      expect(input.jump, isTrue);
      expect(input.jumpEdge, isTrue);
      input.clearEdges();
      expect(input.jumpEdge, isFalse);
      m.handleKey(up(LogicalKeyboardKey.space));
      expect(input.jump, isFalse);
    });

    test('crouch, grab and slowmo hold state', () {
      final input = InputState();
      final m = KeyboardInputMapper(input);
      m.handleKey(down(LogicalKeyboardKey.keyS));
      expect(input.crouch, isTrue);
      m.handleKey(down(LogicalKeyboardKey.keyE));
      expect(input.grab, isTrue);
      m.handleKey(down(LogicalKeyboardKey.shiftLeft));
      expect(input.slowmo, isTrue);
      m.handleKey(up(LogicalKeyboardKey.keyS));
      m.handleKey(up(LogicalKeyboardKey.keyE));
      m.handleKey(up(LogicalKeyboardKey.shiftLeft));
      expect(input.crouch, isFalse);
      expect(input.grab, isFalse);
      expect(input.slowmo, isFalse);
    });

    test('interact, pause, slots and slowmo toggle edges', () {
      final input = InputState();
      final m = KeyboardInputMapper(input);
      m.handleKey(down(LogicalKeyboardKey.keyF));
      expect(input.interactEdge, isTrue);
      input.clearEdges();
      m.handleKey(down(LogicalKeyboardKey.escape));
      expect(input.pauseEdge, isTrue);
      input.clearEdges();
      m.handleKey(down(LogicalKeyboardKey.keyP));
      expect(input.pauseEdge, isTrue);
      m.handleKey(down(LogicalKeyboardKey.digit1));
      expect(input.slot1, isTrue);
      m.handleKey(down(LogicalKeyboardKey.digit2));
      expect(input.slot2, isTrue);
      m.handleKey(down(LogicalKeyboardKey.keyQ));
      expect(input.slowmoEdge, isTrue);
      m.handleKey(down(LogicalKeyboardKey.keyR));
      expect(input.interactEdge, isTrue);
    });

    test('key repeat counts as held without new edges', () {
      final input = InputState();
      final m = KeyboardInputMapper(input);
      m.handleKey(down(LogicalKeyboardKey.space));
      input.clearEdges();
      m.handleKey(KeyRepeatEvent(
        physicalKey: PhysicalKeyboardKey.keyA,
        logicalKey: LogicalKeyboardKey.space,
        timeStamp: Duration.zero,
      ));
      expect(input.jump, isTrue);
      expect(input.jumpEdge, isFalse);
    });

    test('setAim, setFire and clear reset derived state', () {
      final input = InputState();
      final m = KeyboardInputMapper(input);
      m.setAim(0.5, -0.5);
      expect(input.aimX, 0.5);
      expect(input.aimY, -0.5);
      m.setFire(true);
      expect(input.fire, isTrue);
      m.handleKey(down(LogicalKeyboardKey.keyD));
      m.handleKey(down(LogicalKeyboardKey.space));
      m.clear();
      expect(input.moveAxis, 0);
      expect(input.jump, isFalse);
      expect(input.fire, isFalse);
    });
  });
}
