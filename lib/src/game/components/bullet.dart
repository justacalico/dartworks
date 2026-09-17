import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../physics/body_defs.dart';
import 'enemy_body.dart';
import 'physics_prop.dart';
import 'player_body.dart';
import 'zones.dart';

/// Fast projectile. Player shots hurt enemies, break boneboxes and
/// knock targets; enemy bolts hurt the player.
class Bullet extends BodyComponent with ContactCallbacks {
  Bullet({
    required Vector2 spawn,
    required Vector2 dir,
    required this.damage,
    required this.friendly,
    this.speed = 28,
    this.color = const Color(0xFFFFF3B0),
    this.gravityScale = 0,
  })  : spawnPos = spawn.clone(),
        direction = dir.normalized(),
        super(renderBody: false);

  final Vector2 spawnPos;
  final Vector2 direction;
  final double damage;
  final bool friendly;
  final double speed;
  final Color color;
  final double gravityScale;

  double _life = 3;
  bool _hit = false;

  @override
  Body createBody() {
    final b = world.createBody(
      dynamicBodyDef(
        spawnPos.x,
        spawnPos.y,
        fixedRotation: true,
        isBullet: true,
        gravityScale: gravityScale,
        linearVelocity: direction * speed,
        userData: this,
      ),
    );
    b.createShape(
      circleShape(0.08),
      shapeDef(
        density: 0.2,
        isSensor: true,
        category: DwBits.bullet,
        mask: DwBits.terrain |
            DwBits.enemy |
            DwBits.player |
            DwBits.prop |
            DwBits.sensor,
        userData: this,
      ),
    );
    return b;
  }

  @override
  void update(double dt) {
    _life -= dt;
    if (_life <= 0 || _hit) {
      if (!isRemoving) removeFromParent();
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (_hit) return;
    if (friendly && other is PlayerBody) return;
    if (!friendly && other is EnemyBody) return;
    // Zones are sensor volumes; targets detect hits on their own side.
    if (other is DwZone) return;
    _hit = true;
    if (friendly) {
      switch (other) {
        case EnemyBody e:
          e.damage(damage, from: body.position);
        case PhysicsProp p:
          p.damage(damage);
          p.body.applyLinearImpulse(direction * 3 * p.body.mass);
      }
    } else if (other is PlayerBody) {
      other.damage(damage, from: body.position);
    }
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset.zero,
      0.14,
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.1),
    );
    canvas.drawCircle(Offset.zero, 0.06, Paint()..color = color);
  }
}
