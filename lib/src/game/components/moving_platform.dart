import 'dart:math' as math;

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../physics/body_defs.dart';

/// Kinematic platform oscillating on one axis. `q` rides vertically,
/// `Q` slides horizontally.
class MovingPlatform extends BodyComponent {
  MovingPlatform({
    required this.center,
    required this.vertical,
    this.range = 5.2,
    this.period = 4.0,
  });

  @override
  final Vector2 center;
  final bool vertical;
  final double range;
  final double period;

  double _t = 0;

  @override
  Body createBody() {
    final b = world.createBody(
        kinematicBodyDef(center.x, center.y, userData: this));
    b.createShape(
      boxShape(1.25, 0.18),
      shapeDef(friction: 0.9, category: DwBits.terrain, userData: this),
    );
    return b;
  }

  @override
  void update(double dt) {
    _t += dt;
    final phase = math.sin(_t * 2 * math.pi / period);
    final offset = phase * range;
    final next = vertical
        ? Vector2(center.x, center.y + offset)
        : Vector2(center.x + offset, center.y);
    // Velocity-based move so riders get carried along.
    body.linearVelocity =
        (next - body.position) / math.max(dt, 1e-4);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-1.25, -0.18, 2.5, 0.36),
          const Radius.circular(0.08)),
      Paint()..color = const Color(0xFF2A2440),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-1.25, -0.18, 2.5, 0.07),
      Paint()..color = const Color(0xFF4DE8FF),
    );
    canvas.drawRect(
      Rect.fromLTWH(-1.25, 0.11, 2.5, 0.07),
      Paint()..color = const Color(0xFF4DE8FF).withValues(alpha: 0.4),
    );
  }
}
