import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../../data/items.dart';
import '../systems/monomat_economy.dart';
import 'physics_prop.dart';
import 'player_body.dart';
import 'zones.dart';

/// Monomat vending terminal. The player browses when standing close;
/// purchases are handled by the game via [stock].
class MonomatZone extends DwZone {
  MonomatZone({
    required super.center,
    required this.stock,
    this.onPlayerNear,
    this.onPlayerLeft,
  }) : super(w: 2.4, h: 2.6);

  final MonomatStock stock;
  void Function(MonomatZone who)? onPlayerNear;
  void Function(MonomatZone who)? onPlayerLeft;
  bool playerNear = false;

  @override
  void onEnter(Object other) {
    if (other is PlayerBody && !playerNear) {
      playerNear = true;
      onPlayerNear?.call(this);
    }
  }

  @override
  void onExit(Object other) {
    if (other is PlayerBody) {
      playerNear = false;
      onPlayerLeft?.call(this);
    }
  }

  @override
  void render(Canvas canvas) {
    final body = Paint()..color = const Color(0xFF1B1830);
    final screen = Paint()..color = const Color(0xFF4DE8FF).withValues(alpha: 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-0.45, -1.0, 0.9, 2.0), const Radius.circular(0.1)),
      body,
    );
    canvas.drawRect(const Rect.fromLTWH(-0.35, -0.85, 0.7, 0.6), screen);
    // blinking stock rows
    for (var i = 0; i < stock.offers.length && i < 3; i++) {
      final sold = stock.isSold(i);
      canvas.drawRect(
        Rect.fromLTWH(-0.3, -0.78 + i * 0.18, 0.6, 0.12),
        Paint()
          ..color = sold
              ? const Color(0xFFFF4D5E).withValues(alpha: 0.6)
              : const Color(0xFF12101E),
      );
    }
    canvas.drawRect(const Rect.fromLTWH(-0.35, -0.1, 0.7, 0.5),
        Paint()..color = const Color(0xFF12101E));
    canvas.drawRect(const Rect.fromLTWH(-0.3, 0.5, 0.6, 0.3),
        Paint()..color = const Color(0xFF2A2440));
    // output slot glow
    canvas.drawRect(
      const Rect.fromLTWH(-0.25, 0.55, 0.5, 0.2),
      Paint()..color = const Color(0xFF4DE8FF).withValues(alpha: 0.3),
    );
  }
}

/// Thrown prop from a zombish thrower — just a physics prop spawned
/// with velocity; defined here so the game file stays lean.
PhysicsProp makeThrownProp(ItemDef item, Vector2 at) =>
    PhysicsProp(item: item, spawn: at);
