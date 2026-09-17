import 'dart:math' as math;

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../../data/items.dart';
import '../physics/body_defs.dart';
import '../render/item_painter.dart';
import 'enemy_body.dart';
import 'player_body.dart';

/// A physical item: props, weapons, quest objects and pickups all share
/// this body. Grab/held state is driven by the player; breakables die
/// on hard impacts; quest pickups report their collection upward.
class PhysicsProp extends BodyComponent with ContactCallbacks {
  PhysicsProp({
    required this.item,
    required Vector2 spawn,
    this.noteId,
    this.moduleTarget,
    this.dropId,
    this.hp,
    this.onCollect,
    this.onImpactDamage,
    this.onDestroyed,
  })  : spawnPos = spawn.clone(),
        super(renderBody: false);

  final ItemDef item;
  final String? noteId;
  final String? moduleTarget;

  /// Item to spawn when this breakable is smashed (boneboxes).
  final String? dropId;
  void Function(PhysicsProp prop)? onCollect;
  void Function(PhysicsProp prop)? onDestroyed;

  /// Called with (this prop, the thing it hit, impact speed) for
  /// impact-damage bookkeeping by the game layer.
  void Function(PhysicsProp prop, Object other, double speed)?
      onImpactDamage;

  final Vector2 spawnPos;

  /// Velocity applied right after the body is created (thrown props).
  Vector2? initialVelocity;

  /// Remaining integrity for breakables (boneboxes, crates). Null means
  /// indestructible.
  double? hp;

  /// Set while the player's hand holds this prop.
  bool grabbed = false;

  /// Set while this prop is the equipped weapon — it tracks the hand.
  bool held = false;

  /// Enemies currently touching the prop, for melee swings.
  final _touchingEnemies = <EnemyBody>{};
  final _swungThisSwing = <EnemyBody>{};
  bool _swinging = false;
  bool get swinging => _swinging;

  /// Velocity snapshot from the previous tick. Contact events arrive
  /// post-solve, when the solver has already absorbed the impact, so
  /// [beginContact] reads this instead of the live velocity.
  final _preVel = Vector2.zero();

  /// Begin a melee swing: hits anything already touching plus new
  /// contacts until [stopSwing].
  void startSwing() {
    _swinging = true;
    _swungThisSwing.clear();
    for (final e in _touchingEnemies) {
      if (!e.dead && _swungThisSwing.add(e)) {
        e.damage(item.damage, from: body.position);
      }
    }
  }

  void stopSwing() {
    _swinging = false;
    _swungThisSwing.clear();
  }

  /// World-space point the prop is steered toward while held/grabbed.
  Vector2? anchor;

  /// Desired facing while equipped as a weapon.
  double aimAngle = 0;

  /// Weight in impact damage so heavy props hurt more when thrown.
  double get impactDamage => 4 + item.mass * 2.5;

  bool get isWeapon =>
      item.category == ItemCategory.gun || item.category == ItemCategory.melee;

  bool get isBreakable => hp != null;

  bool get isCollectibleQuest =>
      noteId != null ||
      moduleTarget != null ||
      item.id == 'keycard' ||
      item.id == 'gachapon';

  bool get isRound =>
      {'basketball', 'melon', 'gachapon', 'energy_core'}.contains(item.id);

  Vector2 get pos => body.position;

  void grab() {
    grabbed = true;
    body.gravityScale = 0;
    body.linearDamping = 2;
    body.angularDamping = 4;
    _retarget(DwBits.heldItem);
  }

  void release({Vector2? throwImpulse}) {
    grabbed = false;
    body.gravityScale = 1;
    body.linearDamping = 0.05;
    body.angularDamping = 0.4;
    _retarget(DwBits.prop);
    if (throwImpulse != null) {
      body.applyLinearImpulse(throwImpulse * body.mass);
      body.angularVelocity = 3;
    }
  }

  /// Equipped as the active weapon — pinned to the hand.
  void equip() {
    held = true;
    body.gravityScale = 0;
    body.linearDamping = 4;
    body.angularDamping = 8;
    body.fixedRotation = false;
    _retarget(DwBits.heldItem);
  }

  void unequip() {
    held = false;
    stopSwing();
    _touchingEnemies.clear();
    body.fixedRotation = true;
    _retarget(DwBits.prop);
  }

  /// Held items stop colliding with the player so the hand doesn't push
  /// the body around.
  void _retarget(int category) {
    final heldMask = Filter.allCategories & ~DwBits.player;
    for (final s in body.shapes) {
      s.filter = Filter(
        categoryBits: category,
        maskBits: category == DwBits.heldItem
            ? heldMask
            : Filter.allCategories,
      );
    }
  }

  void damage(double amount) {
    if (hp == null) return;
    hp = hp! - amount;
  }

  bool get isDestroyed => hp != null && hp! <= 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (!isLoaded) return;
    _preVel.setFrom(body.linearVelocity);
    if (!((grabbed || held) && anchor != null)) return;
    final to = anchor! - body.position;
    if (held) {
      // Equipped weapons track the hand rigidly.
      body.linearVelocity = to / math.max(dt, 1e-4);
      var diff = aimAngle - body.rotation.angle;
      while (diff > 3.14159) {
        diff -= 6.28318;
      }
      while (diff < -3.14159) {
        diff += 6.28318;
      }
      body.angularVelocity = diff * 12 - body.angularVelocity * 0.3;
      return;
    }
    final force = to * 55 * body.mass - body.linearVelocity * 6 * body.mass;
    body.applyForce(force);
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (other is EnemyBody && !other.dead) {
      _touchingEnemies.add(other);
      if (_swinging && _swungThisSwing.add(other)) {
        other.damage(item.damage, from: body.position);
      }
    }
    if (!contact.isSensorEvent && !_swinging && !held) {
      final rel = (_preVel -
              (other is BodyComponent
                  ? other.body.linearVelocity
                  : Vector2.zero()))
          .length;
      if (rel > 4) {
        onImpactDamage?.call(this, other, rel);
        if (isBreakable) damage(rel * 1.6);
      }
    }
    if (isCollectibleQuest && other is PlayerBody) {
      onCollect?.call(this);
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    super.endContact(other, contact);
    if (other is EnemyBody) _touchingEnemies.remove(other);
  }

  @override
  Body createBody() {
    final b = world.createBody(
      dynamicBodyDef(spawnPos.x, spawnPos.y,
          fixedRotation: !isRound, userData: this),
    );
    b.createShape(
      isRound
          ? circleShape(item.sizeX / 2)
          : boxShape(item.sizeX / 2, item.sizeY / 2),
      shapeDef(
        density: item.mass / (item.sizeX * item.sizeY),
        friction: 0.5,
        restitution: isRound ? 0.5 : 0.05,
        category: DwBits.prop,
        userData: this,
      ),
    );
    if (initialVelocity != null) {
      b.linearVelocity = initialVelocity!;
      initialVelocity = null;
    }
    return b;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(
        -item.sizeX / 2, -item.sizeY / 2 - (isCollectibleQuest ? 0.15 : 0));
    if (isCollectibleQuest) {
      canvas.drawRect(
        Rect.fromLTWH(-0.1, -0.1, item.sizeX + 0.2, item.sizeY + 0.2),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.04,
      );
    }
    paintItem(canvas, item, Size(item.sizeX, item.sizeY));
    canvas.restore();
  }
}
