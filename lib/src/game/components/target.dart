import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../physics/body_defs.dart';
import 'bullet.dart';
import 'physics_prop.dart';
import 'player_body.dart';

/// Shooting-range target. Falls when a bullet, fast prop or the player
/// hits it. Reports the knockdown once.
class RangeTarget extends BodyComponent with ContactCallbacks {
  RangeTarget({required this.center, this.onHit});

  @override
  final Vector2 center;
  void Function()? onHit;

  bool down = false;
  double _fall = 0;

  @override
  Body createBody() {
    final b = world.createBody(
        staticBodyDef(center.x, center.y, userData: this));
    b.createShape(
      boxShape(0.35, 0.5),
      shapeDef(isSensor: true, category: DwBits.sensor, userData: this),
    );
    return b;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (down) return;
    final fast = other is PhysicsProp && other.body.linearVelocity.length > 4;
    if (other is Bullet || other is PlayerBody || fast) {
      down = true;
      onHit?.call();
    }
  }

  @override
  void update(double dt) {
    if (down && _fall < 1) _fall = (_fall + dt * 4).clamp(0.0, 1.0);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.rotate(_fall * 1.4);
    final ring = Paint()..color = const Color(0xFFFF4D5E);
    final mid = Paint()..color = const Color(0xFFEDEBF5);
    canvas.drawCircle(const Offset(0, -0.15), 0.32, ring);
    canvas.drawCircle(const Offset(0, -0.15), 0.2, mid);
    canvas.drawCircle(const Offset(0, -0.15), 0.08, ring);
    canvas.drawRect(Rect.fromLTWH(-0.03, 0.15, 0.06, 0.35),
        Paint()..color = const Color(0xFF5E5878));
    canvas.restore();
  }
}
