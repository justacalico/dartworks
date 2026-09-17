import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../physics/body_defs.dart';
import 'player_body.dart';

/// Sliding slab covering one or more vertical cells. Auto doors sense
/// the player; locked doors wait for [unlock] from the game.
class DoorBody extends BodyComponent {
  DoorBody({
    required this.x,
    required this.top,
    required this.height,
    required this.locked,
    this.player,
  });

  final double x;
  final double top;
  final int height;
  final bool locked;
  PlayerBody? player;

  bool unlocked = false;
  double _open = 0;
  double get openAmount => _open;

  void unlock() => unlocked = true;

  @override
  Body createBody() {
    final b = world.createBody(
        kinematicBodyDef(x, top + height / 2, userData: this));
    b.createShape(
      boxShape(0.45, height / 2),
      shapeDef(
          density: 5, friction: 0.2,
          category: DwBits.terrain, userData: this),
    );
    return b;
  }

  @override
  void update(double dt) {
    final wantsOpen = unlocked ||
        (!locked &&
            player != null &&
            (player!.body.position.x - x).abs() < 3 &&
            (player!.body.position.y - top - height / 2).abs() <
                height + 1);
    _open = (_open + (wantsOpen ? dt * 2.5 : -dt * 2.5)).clamp(0.0, 1.0);
    final target = Vector2(x, top + height / 2 - _open * (height + 0.2));
    body.linearVelocity =
        (target - body.position) / (dt < 1e-4 ? 1e-4 : dt);
  }

  @override
  void render(Canvas canvas) {
    final h = height.toDouble();
    final c = locked ? const Color(0xFFFF4D5E) : const Color(0xFF4DE8FF);
    canvas.drawRect(
      Rect.fromLTWH(-0.45, -h / 2, 0.9, h),
      Paint()..color = const Color(0xFF1B1830),
    );
    canvas.drawRect(
      Rect.fromLTWH(-0.45, -h / 2, 0.9, h),
      Paint()
        ..color = c.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.05,
    );
    for (var i = 0; i < h; i++) {
      canvas.drawRect(
        Rect.fromLTWH(-0.3, -h / 2 + i + 0.3, 0.6, 0.05),
        Paint()..color = c.withValues(alpha: 0.3),
      );
    }
    if (locked) {
      canvas.drawRect(
        Rect.fromLTWH(-0.12, -0.25, 0.24, 0.5),
        Paint()..color = unlocked ? const Color(0xFF7CFF6B) : c,
      );
    }
  }
}

/// Secret wall that dissolves after the player pushes on it.
class HiddenWall extends BodyComponent with ContactCallbacks {
  HiddenWall({required this.x, required this.y});

  final double x;
  final double y;

  double _pushTime = 0;
  bool _pushing = false;
  bool gone = false;

  @override
  Body createBody() {
    final b =
        world.createBody(staticBodyDef(x + 1, y + 1, userData: this));
    b.createShape(
      boxShape(1, 1),
      shapeDef(
          category: DwBits.terrain, friction: 0.8, userData: this),
    );
    return b;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is PlayerBody) _pushing = true;
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is PlayerBody) _pushing = false;
  }

  @override
  void update(double dt) {
    if (_pushing && !gone) {
      _pushTime += dt;
      if (_pushTime > 1.1) {
        gone = true;
        removeFromParent();
      }
    } else {
      _pushTime = (_pushTime - dt * 0.5).clamp(0.0, 1.1);
    }
  }

  @override
  void render(Canvas canvas) {
    final crack = _pushTime / 1.1;
    canvas.drawRect(
      const Rect.fromLTWH(-0.5, -0.5, 1, 1),
      Paint()..color = const Color(0xFF2A2440),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-0.5, -0.5, 1, 1),
      Paint()
        ..color = const Color(0xFF9B94B8).withValues(alpha: 0.25 + crack * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.04,
    );
    if (crack > 0.2) {
      canvas.drawLine(
        const Offset(-0.3, -0.4),
        Offset(0.2, -0.4 + crack * 0.8),
        Paint()
          ..color = const Color(0xFF7CFF6B).withValues(alpha: 0.6)
          ..strokeWidth = 0.04,
      );
    }
  }
}
