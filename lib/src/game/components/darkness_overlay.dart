import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'player_body.dart';

/// Draws a dark veil over the visible world with a light hole punched
/// around the player. Rendered above everything in world space.
class DarknessOverlay extends PositionComponent {
  DarknessOverlay({
    required this.player,
    required this.darkness,
    required this.bounds,
  }) : super(priority: 90);

  final PlayerBody player;
  final double darkness;
  final Vector2 bounds;
  int _extraLight = 0;

  set extraLight(int v) => _extraLight = v;

  double get _radius => 4.2 + _extraLight * 1.6;

  @override
  void render(Canvas canvas) {
    if (darkness <= 0) return;
    final rect = Offset(-20, -20) &
        Size(bounds.x + 40, bounds.y + 40);
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(
        rect, Paint()..color = Colors.black.withValues(alpha: darkness));
    // light holes: player + a soft halo
    final p = player.body.position.toOffset();
    canvas.drawCircle(
      p,
      _radius,
      Paint()..blendMode = BlendMode.dstOut,
    );
    canvas.drawCircle(
      p,
      _radius * 0.55,
      Paint()..blendMode = BlendMode.dstOut,
    );
    canvas.restore();
  }
}
