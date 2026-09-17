import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../../data/items.dart';
import '../physics/body_defs.dart';
import '../systems/input_state.dart';
import '../systems/inventory.dart';
import 'physics_prop.dart';

/// The player's physical body: movement, jumping, grabbing, weapon use.
/// The game supplies [input] every frame and answers callbacks for
/// firing, slot changes and prop queries.
class PlayerBody extends BodyComponent with ContactCallbacks {
  PlayerBody({
    required Vector2 spawn,
    required this.input,
    this.onFire,
    this.onSlotChange,
    this.findGrabbable,
    this.onHolster,
    this.onDeath,
  })  : spawnPos = spawn.clone(),
        super(renderBody: false);

  final Vector2 spawnPos;
  final InputState input;

  /// Game hooks.
  void Function(Vector2 pos, Vector2 dir, InventorySlot slot)? onFire;
  void Function(int slot, ItemDef? item)? onSlotChange;
  PhysicsProp? Function(Vector2 from, Vector2 dir)? findGrabbable;

  /// Called when the player grabs a weapon prop; return true if the
  /// game holstered it (skip the physical grab).
  bool Function(PhysicsProp prop)? onHolster;
  void Function()? onDeath;

  final inventory = Inventory();
  double hp = 100;
  final double maxHp = 100;
  bool isDead = false;

  /// 0..1, drains while slow-time is active.
  double slowCharge = 1;
  int lightBoost = 0;

  /// Prop currently held in the hand (crate, barrel, crown...).
  PhysicsProp? grabbed;

  /// Physical prop shadowing the active weapon slot.
  PhysicsProp? equippedProp;

  static const moveSpeed = 5.6;
  static const accel = 46.0;
  static const jumpSpeed = 11.6;
  static const grabRange = 3.4;

  double _coyote = 0;
  double _jumpBuffer = 0;
  double _fireCooldown = 0;
  double _swingTimer = 0;
  double _regenTimer = 0;
  double _hurtFlash = 0;
  int _lastSlot = -1;
  ItemDef? _lastItem;
  bool _wasGrabHeld = false;
  bool _wasFireHeld = false;

  /// Bodies the feet currently rest on. Pruned for unmounted members
  /// each tick — destroyed bodies never deliver endContact.
  final _ground = <Object>{};

  bool get isGrounded => _ground.isNotEmpty || _coyote > 0;

  Vector2 get aimDir {
    final v = Vector2(input.aimX, input.aimY);
    return v.length2 > 0.01 ? v.normalized() : Vector2(facing, 0);
  }

  double get facing => aimDir.x >= 0 ? 1.0 : -1.0;

  /// Where the hand holds things — ahead of the chest, toward the aim.
  Vector2 get handPos =>
      body.position + aimDir * 1.15 + Vector2(0, -0.25);

  void damage(double amount, {Vector2? from}) {
    if (isDead) return;
    hp -= amount;
    _hurtFlash = 0.2;
    _regenTimer = 0;
    if (from != null) {
      final dir = body.position - from;
      if (dir.length2 > 0) {
        body.applyLinearImpulse(dir.normalized() * body.mass * 4);
      }
    }
    if (hp <= 0) {
      hp = 0;
      isDead = true;
      dropGrab();
      equippedProp?.unequip();
      equippedProp = null;
      onDeath?.call();
    }
  }

  void heal(double amount) => hp = (hp + amount).clamp(0, maxHp);

  void dropGrab({Vector2? impulse}) {
    grabbed?.release(throwImpulse: impulse);
    grabbed = null;
  }

  @override
  Body createBody() {
    final b = world.createBody(
      dynamicBodyDef(spawnPos.x, spawnPos.y,
          fixedRotation: true,
          enableSleep: false,
          gravityScale: 1,
          userData: this),
    );
    b.createShape(
      boxShape(0.32, 0.78),
      shapeDef(
          density: 1.6,
          friction: 0.25,
          category: DwBits.player,
          userData: this),
    );
    b.createShape(
      circleShape(0.3, Vector2(0, 0.78)),
      shapeDef(isSensor: true, category: DwBits.sensor, userData: this),
    );
    return b;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isLoaded) return;
    _hurtFlash = (_hurtFlash - dt).clamp(0.0, 1.0);
    if (isDead) return;

    _timers(dt);
    _move(dt);
    _grab();
    _fire(dt);
    _slots();

    // Slow regen after 5 s without damage.
    _regenTimer += dt;
    if (_regenTimer > 5 && hp < maxHp) heal(9 * dt);
  }

  void _timers(double dt) {
    _ground.removeWhere((o) => o is Component && !o.isMounted);
    _coyote = _ground.isNotEmpty ? 0.11 : _coyote - dt;
    _jumpBuffer -= dt;
    _fireCooldown -= dt;
    if (_swingTimer > 0) {
      _swingTimer -= dt;
      if (_swingTimer <= 0) equippedProp?.swinging = false;
    }
    if (input.jumpEdge) _jumpBuffer = 0.13;
  }

  void _move(double dt) {
    final target = input.moveAxis * (input.crouch ? moveSpeed * 0.45 : moveSpeed);
    final vx = body.linearVelocity.x;
    final nvx = vx + (target - vx).clamp(-accel * dt, accel * dt);
    body.linearVelocity = Vector2(nvx, body.linearVelocity.y);

    if (_jumpBuffer > 0 && isGrounded) {
      _jumpBuffer = 0;
      _coyote = 0;
      body.linearVelocity = Vector2(nvx, -jumpSpeed);
    }
  }

  void _grab() {
    final held = input.grab;
    if (held && !_wasGrabHeld) {
      if (grabbed != null) {
        dropGrab();
      } else {
        final target = findGrabbable?.call(body.position, aimDir);
        if (target != null && (onHolster?.call(target) ?? false)) {
          // weapon went straight into a holster slot
        } else {
          grabbed = target?..grab();
        }
      }
    }
    _wasGrabHeld = held;
    if (grabbed != null) {
      if (!held) {
        dropGrab();
      } else {
        grabbed!.anchor = handPos;
      }
    }
  }

  /// Release-with-flick throws the held prop along the aim.
  void throwGrabbed() {
    if (grabbed == null) return;
    dropGrab(impulse: aimDir * 14 + Vector2(0, -2));
  }

  void _fire(double dt) {
    final slot = inventory.active;
    final wantsFire = input.fire;
    if (slot == null || !wantsFire) {
      _wasFireHeld = wantsFire;
      return;
    }
    final item = slot.item;
    final isAuto = item.fireRate > 4;
    final mayFire = _fireCooldown <= 0 && (isAuto || !_wasFireHeld);
    _wasFireHeld = wantsFire;

    if (!mayFire) return;
    if (item.isGun) {
      if (slot.ammo <= 0) return;
      slot.ammo--;
      onFire?.call(handPos, aimDir, slot);
      _fireCooldown = 1 / item.fireRate;
    } else if (item.isMelee && equippedProp != null) {
      equippedProp!.swinging = true;
      _swingTimer = 0.3;
      equippedProp!.body.angularVelocity = 18 * facing;
      _fireCooldown = 1 / item.fireRate;
    } else {
      _fireCooldown = 0.4;
    }
  }

  void _slots() {
    if (input.slot1) inventory.select(0);
    if (input.slot2) inventory.select(1);
    final item = inventory.active?.item;
    if (inventory.activeSlot != _lastSlot || item != _lastItem) {
      _lastSlot = inventory.activeSlot;
      _lastItem = item;
      onSlotChange?.call(inventory.activeSlot, item);
    }
  }

  /// Called by the game after it spawns/removes [equippedProp].
  void driveWeapon() {
    final prop = equippedProp;
    if (prop == null || !prop.isMounted) return;
    if (!prop.held) prop.equip();
    prop.anchor = handPos;
    prop.aimAngle = math.atan2(aimDir.y, aimDir.x);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (!contact.isSensorEvent &&
        (other is GroundSurface || other is PhysicsProp)) {
      _ground.add(other);
    }
    if (other is PhysicsProp && other.isCollectibleQuest) {
      other.onCollect?.call(other);
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    _ground.remove(other);
  }

  @override
  void render(Canvas canvas) {
    const suit = Color(0xFF232338);
    const visor = Color(0xFF4DE8FF);
    final flash = _hurtFlash > 0 ? 0.7 : 0.0;
    final suitPaint = Paint()
      ..color = Color.lerp(suit, Colors.red, flash)!;
    final crouch = input.crouch ? 0.78 : 1.0;

    canvas.save();
    canvas.scale(1, crouch);
    // legs
    canvas.drawRect(
        Rect.fromLTWH(-0.3, 0.28 / crouch, 0.22, 0.5 / crouch), suitPaint);
    canvas.drawRect(
        Rect.fromLTWH(0.08, 0.28 / crouch, 0.22, 0.5 / crouch), suitPaint);
    // torso
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-0.32, -0.42, 0.64, 0.72),
          const Radius.circular(0.14)),
      suitPaint,
    );
    // head + visor
    canvas.drawCircle(const Offset(0, -0.58), 0.26, suitPaint);
    final dir = aimDir;
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(dir.x * 0.06, -0.58 + dir.y * 0.05), radius: 0.2),
      dir.x >= 0 ? -1.2 : 1.94,
      1.2,
      false,
      Paint()
        ..color = visor
        ..strokeWidth = 0.07
        ..style = PaintingStyle.stroke,
    );
    // arm toward the aim
    final hand = aimDir * 0.55;
    canvas.drawLine(
      Offset(0, -0.2),
      Offset(hand.x, -0.2 + hand.y),
      Paint()
        ..color = const Color(0xFF9B94B8)
        ..strokeWidth = 0.12
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    // hurt vignette ring
    if (_hurtFlash > 0) {
      canvas.drawCircle(
        Offset.zero,
        1.1,
        Paint()
          ..color = Colors.red.withValues(alpha: _hurtFlash * 1.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.06,
      );
    }
  }
}
