import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../../data/enemies.dart';
import '../physics/body_defs.dart';
import '../systems/enemy_ai.dart';
import 'physics_prop.dart';
import 'player_body.dart';

/// Physical enemy. Movement and attack decisions come from
/// [decideIntent]; this class applies them to a body and draws it.
class EnemyBody extends BodyComponent with ContactCallbacks {
  EnemyBody({
    required this.def,
    required Vector2 spawn,
    this.player,
    this.onFireBolt,
    this.onThrowProp,
    this.onDeath,
    this.crown,
  })  : spawnPos = spawn.clone(),
        hp = def.hp,
        super(renderBody: false);

  final EnemyDef def;
  final Vector2 spawnPos;

  /// Assigned by the game once the player body exists.
  PlayerBody? player;
  void Function(EnemyBody who, Vector2 dir)? onFireBolt;
  void Function(EnemyBody who, Vector2 dir)? onThrowProp;
  void Function(EnemyBody who)? onDeath;

  /// Boss crown prop; pulling it off makes the boss surrender.
  PhysicsProp? crown;
  bool crownTaken = false;

  double hp;
  double _hurtFlash = 0;
  double _deadTimer = -1;
  bool dead = false;
  final _grounded = <Object>{};
  var _knock = Vector2.zero();
  double _cooldown = 0;
  final _rng = math.Random();

  bool get isTurret => def.behavior == EnemyBehavior.turret;
  bool get isFlyer => def.behavior == EnemyBehavior.flyer;
  bool get surrendered => crownTaken;

  double get hpFraction => (hp / def.hp).clamp(0.0, 1.0);

  void damage(double amount, {Vector2? from}) {
    if (dead) return;
    hp -= amount;
    _hurtFlash = 0.15;
    if (from != null) {
      final dir = body.position - from;
      if (dir.length2 > 0) {
        _knock += dir.normalized() * 5;
      }
    }
    if (hp <= 0) {
      dead = true;
      _deadTimer = 0;
      crown?.release();
      body.gravityScale = 1;
      body.angularVelocity = 2;
      for (final s in body.shapes) {
        final f = s.filter;
        s.filter =
            Filter(categoryBits: DwBits.prop, maskBits: f.maskBits);
      }
      onDeath?.call(this);
    }
  }

  void takeCrown() {
    crownTaken = true;
    crown = null;
    body.linearVelocity = Vector2.zero();
  }

  @override
  Body createBody() {
    final b = world.createBody(
      isTurret
          ? staticBodyDef(spawnPos.x, spawnPos.y, userData: this)
          : dynamicBodyDef(
              spawnPos.x,
              spawnPos.y,
              fixedRotation: true,
              enableSleep: false,
              gravityScale: isFlyer ? 0 : 1,
              userData: this,
            ),
    );
    b.createShape(
      boxShape(def.sizeX / 2, def.sizeY / 2),
      shapeDef(
        density: 1.2,
        friction: 0.3,
        category: isTurret ? DwBits.terrain : DwBits.enemy,
        mask: isTurret
            ? Filter.allCategories
            : DwBits.terrain |
                DwBits.player |
                DwBits.enemy |
                DwBits.bullet |
                DwBits.prop |
                DwBits.heldItem |
                DwBits.sensor,
        userData: this,
      ),
    );
    if (!isTurret) {
      b.createShape(
        circleShape(def.sizeX / 2 + 0.05, Vector2(0, def.sizeY / 2)),
        shapeDef(
            isSensor: true, category: DwBits.sensor, userData: this),
      );
    }
    return b;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isLoaded) return;
    if (dead) {
      _deadTimer += dt;
      if (_deadTimer > 2.5) removeFromParent();
      return;
    }
    _hurtFlash = (_hurtFlash - dt).clamp(0.0, 1.0);
    _cooldown -= dt;

    final p = player;
    if (p == null || p.isDead || crownTaken) return;

    final myPos = body.position;
    final toPlayer = p.body.position - myPos;
    final intent = decideIntent(
      def,
      distX: toPlayer.x,
      distY: toPlayer.y,
      cooldown: _cooldown,
      rng: _rng.nextDouble(),
    );

    _grounded.removeWhere((o) => o is Component && !o.isMounted);
    _knock.x -= _knock.x * 9 * dt;
    if (!isTurret) {
      body.linearVelocity = Vector2(
        intent.moveX * def.speed + _knock.x,
        isFlyer ? intent.moveY * def.speed : body.linearVelocity.y,
      );
      if (intent.jump && _grounded.isNotEmpty) {
        body.applyLinearImpulse(
            Vector2(intent.moveX * 2, -def.speed * 1.8) * body.mass);
        _cooldown = def.attackCooldown;
      }
      // Flyers hold a hover altitude above the player.
      if (isFlyer) {
        final targetY = p.body.position.y - 3.4;
        body.linearVelocity = Vector2(
          body.linearVelocity.x,
          ((targetY - myPos.y) * 2.2).clamp(-def.speed, def.speed),
        );
      }
    }

    if (intent.attack && _cooldown <= 0) {
      p.damage(def.damage, from: myPos);
      _cooldown = def.attackCooldown;
    }
    if (intent.shoot && _cooldown <= 0) {
      final dir = toPlayer.length2 > 0 ? toPlayer.normalized() : Vector2(1, 0);
      if (def.behavior == EnemyBehavior.thrower) {
        onThrowProp?.call(this, dir);
      } else {
        onFireBolt?.call(this, dir);
      }
      _cooldown = def.attackCooldown;
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (!contact.isSensorEvent &&
        (other is GroundSurface || other is PhysicsProp)) {
      _grounded.add(other);
    }
    if (dead) return;
    if (other is PlayerBody && !crownTaken) {
      final intent = decideIntent(
        def,
        distX: other.body.position.x - body.position.x,
        distY: other.body.position.y - body.position.y,
        cooldown: _cooldown,
      );
      if (intent.attack) {
        other.damage(def.damage, from: body.position);
        _cooldown = def.attackCooldown;
      }
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    super.endContact(other, contact);
    _grounded.remove(other);
  }

  @override
  void render(Canvas canvas) {
    final c = Color(def.color);
    final fade = dead ? (1 - _deadTimer / 2.5).clamp(0.0, 1.0) : 1.0;
    final flash = _hurtFlash > 0 ? 0.6 : 0.0;
    final paint = Paint()
      ..color = Color.lerp(c, Colors.white, flash)!
          .withValues(alpha: fade * (crownTaken ? 0.55 : 1));

    if (isTurret) {
      _renderTurret(canvas, paint);
      return;
    }

    final w = def.sizeX;
    final h = def.sizeY;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(0, -h * 0.1), width: w, height: h * 0.62),
        Radius.circular(w * 0.18),
      ),
      paint,
    );
    canvas.drawCircle(Offset(0, -h * 0.38), w * 0.34, paint);
    canvas.drawRect(
        Rect.fromLTWH(-w * 0.42, h * 0.12, w * 0.3, h * 0.38), paint);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.12, h * 0.12, w * 0.3, h * 0.38), paint);

    final eye = Paint()
      ..color = Colors.white.withValues(alpha: fade)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.06);
    final lookDir =
        (player?.body.position.x ?? 0) > body.position.x ? 1.0 : -1.0;
    canvas.drawCircle(
        Offset(lookDir * w * 0.1 - w * 0.12, -h * 0.4), w * 0.07, eye);
    canvas.drawCircle(
        Offset(lookDir * w * 0.1 + w * 0.12, -h * 0.4), w * 0.07, eye);

    if (!dead && (def.behavior == EnemyBehavior.boss || _hurtFlash > 0)) {
      final top = -h * 0.62;
      canvas.drawRect(
        Rect.fromLTWH(-w / 2, top, w, 0.08),
        Paint()..color = Colors.black54,
      );
      canvas.drawRect(
        Rect.fromLTWH(-w / 2, top, w * hpFraction, 0.08),
        Paint()..color = c,
      );
    }
    if (crownTaken) {
      canvas.drawRect(
        Rect.fromLTWH(-w * 0.4, -h * 0.62, w * 0.8, 0.08),
        Paint()..color = Colors.white.withValues(alpha: 0.7 * fade),
      );
    }
  }

  void _renderTurret(Canvas canvas, Paint paint) {
    final w = def.sizeX;
    canvas.drawRect(Rect.fromLTWH(-w / 2, -w * 0.2, w, w * 0.7), paint);
    canvas.drawCircle(Offset(0, -w * 0.2), w * 0.35, paint);
    final p = player;
    if (p != null) {
      final dir = p.body.position - body.position;
      if (dir.length2 > 0) {
        final n = dir.normalized();
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset(n.x * w * 0.45, -w * 0.2 + n.y * w * 0.45),
              width: w * 0.5,
              height: w * 0.14),
          Paint()..color = Colors.black87,
        );
      }
    }
  }
}
