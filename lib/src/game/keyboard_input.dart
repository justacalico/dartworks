import 'package:flutter/services.dart';

import 'systems/input_state.dart';

/// Maps raw key/mouse events onto [InputState]. Desktop uses WASD +
/// mouse aim; the mapper is platform-agnostic so tests can drive it.
class KeyboardInputMapper {
  KeyboardInputMapper(this.input);

  final InputState input;
  final _held = <LogicalKeyboardKey>{};

  static final _left = {
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.arrowLeft,
  };
  static final _right = {
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.arrowRight,
  };
  static final _jump = {
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.arrowUp,
  };
  static final _crouch = {
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.controlLeft,
  };
  static final _grab = {LogicalKeyboardKey.keyE};
  static final _interact = {LogicalKeyboardKey.keyF};
  static final _slowmo = {
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.keyQ,
  };

  bool handleKey(KeyEvent event) {
    final key = event.logicalKey;
    final down = event is KeyDownEvent || event is KeyRepeatEvent;
    if (down) {
      _held.add(key);
    } else {
      _held.remove(key);
    }

    if (event is KeyDownEvent) {
      if (_jump.contains(key)) input.jumpEdge = true;
      if (_interact.contains(key)) input.interactEdge = true;
      if (key == LogicalKeyboardKey.digit1) input.slot1 = true;
      if (key == LogicalKeyboardKey.digit2) input.slot2 = true;
      if (key == LogicalKeyboardKey.escape ||
          key == LogicalKeyboardKey.keyP) {
        input.pauseEdge = true;
      }
      if (key == LogicalKeyboardKey.keyR) input.interactEdge = true;
    }

    input.moveAxis = (_held.any(_right.contains) ? 1.0 : 0.0) -
        (_held.any(_left.contains) ? 1.0 : 0.0);
    input.jump = _held.any(_jump.contains);
    input.crouch = _held.any(_crouch.contains);
    input.grab = _held.any(_grab.contains);
    input.slowmo = _held.any(_slowmo.contains);
    return true;
  }

  void setAim(double x, double y) {
    input.aimX = x;
    input.aimY = y;
  }

  void setFire(bool firing) => input.fire = firing;

  void clear() => _held.clear();
}
