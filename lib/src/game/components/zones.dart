import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../physics/body_defs.dart';
import 'enemy_body.dart';
import 'physics_prop.dart';
import 'player_body.dart';

/// Static sensor box. Subclasses get [onEnter]/[onExit] for each
/// component that starts or stops touching the zone.
abstract class DwZone extends BodyComponent with ContactCallbacks {
  DwZone({
    required this.center,
    this.w = 1,
    this.h = 1,
    this.reactsToPlayer = true,
    this.reactsToProps = false,
    this.reactsToEnemies = false,
  });

  @override
  final Vector2 center;
  final double w;
  final double h;
  final bool reactsToPlayer;
  final bool reactsToProps;
  final bool reactsToEnemies;

  void onEnter(Object other) {}
  void onExit(Object other) {}

  bool _accepts(Object other) =>
      (other is PlayerBody && reactsToPlayer) ||
      (other is PhysicsProp && reactsToProps) ||
      (other is EnemyBody && reactsToEnemies);

  @override
  void beginContact(Object other, Contact contact) {
    if (_accepts(other)) onEnter(other);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (_accepts(other)) onExit(other);
  }

  @override
  Body createBody() {
    final b = world.createBody(
        staticBodyDef(center.x, center.y, userData: this));
    b.createShape(
      boxShape(w / 2, h / 2),
      shapeDef(isSensor: true, category: DwBits.sensor, userData: this),
    );
    return b;
  }
}

/// The way out. Fires [tryExit] once when the player steps in; the game
/// decides whether the goal is met.
class ExitZone extends DwZone {
  ExitZone({required super.center, this.tryExit})
      : super(w: 1.8, h: 3.2);

  void Function()? tryExit;
  double _cooldown = 0;

  @override
  void onEnter(Object other) {
    if (_cooldown > 0) return;
    _cooldown = 0.8;
    tryExit?.call();
  }

  @override
  void update(double dt) {
    _cooldown = (_cooldown - dt).clamp(0.0, 1.0);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      Paint()..color = const Color(0xFF7CFF6B).withValues(alpha: 0.10),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      Paint()
        ..color = const Color(0xFF7CFF6B).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.06,
    );
  }
}

/// Spikes / lava. Damage per second to anyone standing in it.
class HazardZone extends DwZone {
  HazardZone({required super.center, this.dps = 18})
      : super(w: 2, h: 0.9, reactsToEnemies: true);

  final double dps;
  final _inside = <Object>{};

  @override
  void onEnter(Object other) => _inside.add(other);
  @override
  void onExit(Object other) => _inside.remove(other);

  @override
  void update(double dt) {
    for (final o in _inside.toList()) {
      if (o is PlayerBody) {
        o.damage(dps * dt, from: center);
      } else if (o is EnemyBody) {
        o.damage(dps * dt);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFFF4D5E);
    for (var i = 0; i < 3; i++) {
      final x = -w / 2 + w * (i + 0.5) / 3;
      final path = Path()
        ..moveTo(x - w / 6, h / 2)
        ..lineTo(x, -h / 2)
        ..lineTo(x + w / 6, h / 2)
        ..close();
      canvas.drawPath(path, paint);
    }
  }
}

/// Zero-G pocket: bodies inside float.
class GravityZone extends DwZone {
  GravityZone({required super.center, double radius = 3.0})
      : super(w: radius * 2, h: radius * 2, reactsToProps: true);

  final _inside = <BodyComponent, double>{};

  @override
  void onEnter(Object other) {
    if (other is BodyComponent) {
      _inside[other] = other.body.gravityScale;
      other.body.gravityScale = 0;
    }
  }

  @override
  void onExit(Object other) {
    if (other is BodyComponent) {
      other.body.gravityScale = _inside.remove(other) ?? 1;
    }
  }

  @override
  void update(double dt) {
    _inside.removeWhere(
        (c, _) => !c.isMounted || !c.body.isValid);
    for (final c in _inside.keys) {
      c.body.applyForce(Vector2(0, -1.5) * c.body.mass);
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF4DE8FF).withValues(alpha: 0.12);
    canvas.drawCircle(Offset.zero, w / 2, paint);
    canvas.drawCircle(
      Offset.zero,
      w / 2,
      Paint()
        ..color = const Color(0xFF4DE8FF).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.05,
    );
  }
}

/// One-shot pickup (keycard, slow-time charge, gachapon, flashlight).
class PickupZone extends DwZone {
  PickupZone({
    required super.center,
    required this.kind,
    this.onPickup,
  }) : super(w: 1.2, h: 1.2);

  final String kind;
  void Function(String kind)? onPickup;
  bool _taken = false;
  double _t = 0;

  @override
  void onEnter(Object other) {
    if (_taken) return;
    _taken = true;
    onPickup?.call(kind);
    removeFromParent();
  }

  @override
  void update(double dt) => _t += dt;

  @override
  void render(Canvas canvas) {
    final bob = (0.08 * (1 + _t).remainder(1)).abs();
    canvas.save();
    canvas.translate(0, -bob);
    switch (kind) {
      case 'keycard':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(-0.3, -0.2, 0.6, 0.4),
              const Radius.circular(0.04)),
          Paint()..color = const Color(0xFFF2C230),
        );
      case 'slowmo':
        canvas.drawCircle(
            Offset.zero, 0.22, Paint()..color = const Color(0xFF4DE8FF));
        canvas.drawCircle(
            Offset.zero,
            0.22,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.6)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.04);
      case 'flashlight':
        canvas.drawRect(const Rect.fromLTWH(-0.2, -0.12, 0.4, 0.24),
            Paint()..color = const Color(0xFF9B94B8));
        canvas.drawCircle(const Offset(0.2, 0), 0.1,
            Paint()..color = const Color(0xFFFFF7C9));
      default: // gachapon
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(-0.22, -0.28, 0.44, 0.56),
              const Radius.circular(0.16)),
          Paint()..color = const Color(0xFFB44DFF),
        );
        canvas.drawRect(const Rect.fromLTWH(-0.22, -0.02, 0.44, 0.08),
            Paint()..color = Colors.black54);
    }
    canvas.restore();
  }
}

/// Bin mouth. Archive bins sort marked props; reclamation bins reclaim
/// them into the player's unlock catalog.
class BinZone extends DwZone {
  BinZone({
    required super.center,
    required this.isReclaim,
    this.onPropIn,
  }) : super(w: 2.4, h: 1.6, reactsToPlayer: false, reactsToProps: true);

  final bool isReclaim;
  void Function(PhysicsProp prop)? onPropIn;

  @override
  void onEnter(Object other) {
    if (other is PhysicsProp && !other.held) {
      onPropIn?.call(other);
    }
  }

  @override
  void render(Canvas canvas) {
    final c = isReclaim ? const Color(0xFF4DE8FF) : const Color(0xFFB44DFF);
    final bin = Paint()..color = c.withValues(alpha: 0.35);
    final rim = Paint()..color = c;
    // bin body open at the top
    canvas.drawRect(Rect.fromLTWH(-w / 2, -h / 2 + 0.25, w, h - 0.25), bin);
    canvas.drawRect(Rect.fromLTWH(-w / 2, -h / 2 + 0.1, 0.08, 0.2), rim);
    canvas.drawRect(Rect.fromLTWH(w / 2 - 0.08, -h / 2 + 0.1, 0.08, 0.2), rim);
    canvas.drawRect(Rect.fromLTWH(-w / 2, -h / 2 + 0.1, w, 0.06), rim);
  }
}

/// Socket that accepts one specific quest item (battery or energy core).
class SocketZone extends DwZone {
  SocketZone({
    required super.center,
    required this.acceptsItem,
    this.onPowered,
  }) : super(w: 1.6, h: 1.6, reactsToPlayer: false, reactsToProps: true);

  final String acceptsItem;
  void Function(PhysicsProp prop)? onPowered;
  bool powered = false;

  @override
  void onEnter(Object other) {
    if (powered || other is! PhysicsProp || other.held) return;
    if (other.item.id == acceptsItem) {
      powered = true;
      onPowered?.call(other);
    }
  }

  @override
  void render(Canvas canvas) {
    final c = powered
        ? const Color(0xFF7CFF6B)
        : const Color(0xFF5E5878).withValues(alpha: 0.8);
    canvas.drawCircle(Offset.zero, w / 2,
        Paint()
          ..color = c.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.15));
    canvas.drawCircle(Offset.zero, w / 2 - 0.05,
        Paint()..color = const Color(0xFF12101E));
    canvas.drawCircle(
      Offset.zero,
      w / 2 - 0.05,
      Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.08,
    );
  }
}
