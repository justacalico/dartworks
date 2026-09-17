import 'dart:async';

import 'package:flame/components.dart' show Anchor, Component;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../data/enemies.dart';
import '../data/items.dart';
import '../data/level_data.dart';
import '../data/notes.dart';
import '../meta/progress_store.dart';
import 'components/bullet.dart';
import 'components/darkness_overlay.dart';
import 'components/enemy_body.dart';
import 'components/monomat.dart';
import 'components/physics_prop.dart';
import 'components/player_body.dart';
import 'components/zones.dart';
import 'game_events.dart';
import 'hud_state.dart';
import 'level_assembler.dart';
import 'systems/goal_tracker.dart';
import 'systems/input_state.dart';
import 'systems/inventory.dart';
import 'systems/wave_manager.dart';
import 'tile_map.dart';

/// Top-level game: owns the physics world, routes input into the player,
/// wires component callbacks into goals, economy and persistence, and
/// keeps the HUD snapshot current.
class DartworksGame extends Forge2DGame {
  DartworksGame({
    required this.level,
    required this.store,
    required this.events,
  }) : super(gravity: Vector2(0, 28), metersToPixels: 34);

  final LevelData level;
  final ProgressStore store;
  final GameEvents events;

  final input = InputState();
  final hud = HudState();

  late final GoalTracker goal;
  late final WaveManager waves;
  AssembledLevel? _lvl;
  DarknessOverlay? _darkness;

  double _elapsed = 0;
  double _timeScale = 1;
  bool _ended = false;
  bool _slowmoToggled = false;
  int _notesFound = 0;
  final _waveEnemies = <EnemyBody>{};
  final _props = <PhysicsProp>{};
  final _enemies = <EnemyBody>{};

  PlayerBody get player => _lvl!.player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.center;

    final assembled = await assembleLevel(
      world: world,
      level: level,
      input: input,
    );
    _lvl = assembled;
    goal = GoalTracker(_effectiveGoal(level.goal, assembled.map));
    waves = WaveManager(level.waves);
    _wire(assembled);

    if (level.palette.darkness > 0) {
      _darkness = DarknessOverlay(
        player: assembled.player,
        darkness: level.palette.darkness,
        bounds: Vector2(
            assembled.map.worldWidth, assembled.map.worldHeight),
      );
      await world.add(_darkness!);
    }

    player.inventory.looseAmmo = level.ammoStart;
    hud.setObjective(goal.describe(), done: false);
  }

  /// Goals whose target count comes from the map, not the data file.
  LevelGoal _effectiveGoal(LevelGoal g, ParsedMap map) => switch (g.type) {
        LevelGoalType.clearEnemies =>
          LevelGoal(g.type, count: map.enemies.length),
        LevelGoalType.timeTrial =>
          LevelGoal(g.type, count: map.targets.length),
        LevelGoalType.repairCore =>
          LevelGoal(g.type, count: map.coreSockets.length),
        LevelGoalType.surviveRounds =>
          LevelGoal(g.type, count: level.waves.length),
        _ => g,
      };

  void _wire(AssembledLevel a) {
    final p = a.player;
    p.onFire = _playerFire;
    p.onSlotChange = _slotChanged;
    p.findGrabbable = _findGrabbable;
    p.onHolster = _tryHolster;
    p.onDeath = _playerDied;

    for (final zone in a.zones) {
      if (zone is ExitZone) {
        zone.tryExit = _tryExit;
      } else if (zone is BinZone) {
        zone.onPropIn = (prop) =>
            zone.isReclaim ? _reclaim(prop) : _archive(prop);
      } else if (zone is SocketZone) {
        zone.onPowered = (prop) => _socketPowered(zone.acceptsItem, prop);
      } else if (zone is PickupZone) {
        zone.onPickup = _pickup;
      } else if (zone is MonomatZone) {
        zone.onPlayerNear = (m) => hud.openMonomat = m;
        zone.onPlayerLeft = (m) {
          if (hud.openMonomat == m) hud.openMonomat = null;
        };
      }
    }
    for (final t in a.targets) {
      t.onHit = () {
        goal.targetHit();
        _toast('TARGET DOWN ${goal.progress}/${goal.goal.count}');
        _maybeUnlockByTargets();
      };
    }
    for (final e in a.enemies) {
      _wireEnemy(e);
    }
    for (final prop in a.props) {
      _wireProp(prop);
    }
  }

  void _wireEnemy(EnemyBody e) {
    e.player = player;
    e.onFireBolt = (who, dir) => _spawnBullet(
          who.body.position + dir * 0.8,
          dir,
          damage: who.def.boltDamage,
          friendly: false,
          speed: who.def.boltSpeed,
          color: const Color(0xFFFF4D5E),
        );
    e.onThrowProp = (who, dir) {
      final prop = PhysicsProp(
        item: kItems['crate']!,
        spawn: who.body.position + dir * 1.2 + Vector2(0, -0.5),
        hp: 12,
      )
        ..initialVelocity = dir * who.def.boltSpeed + Vector2(0, -3);
      _props.add(prop);
      _add(prop);
    };
    e.onDeath = (who) {
      _enemies.remove(who);
      final wasWave = _waveEnemies.remove(who);
      if (wasWave) {
        waves.enemyDown();
        if (waves.alive == 0) goal.waveCleared();
      }
      if (goal.goal.type == LevelGoalType.clearEnemies && !wasWave) {
        goal.enemyKilled();
      }
      if (goal.goal.type == LevelGoalType.bossFight &&
          who.def.behavior == EnemyBehavior.boss) {
        goal.bossDefeated();
      }
      _toast('${who.def.name} DOWN');
    };
    _enemies.add(e);
  }

  void _wireProp(PhysicsProp prop) {
    prop.onCollect = _collectQuest;
    prop.onImpactDamage = _impactDamage;
    prop.onDestroyed = (p) {
      if (p.dropId != null) {
        _spawnDrop(p.dropId!, p.body.position);
      }
      _props.remove(p);
      p.removeFromParent();
    };
    _props.add(prop);
  }

  // -- gameplay events ------------------------------------------------------

  void _playerFire(Vector2 pos, Vector2 dir, InventorySlot slot) {
    _spawnBullet(
      pos,
      dir,
      damage: slot.item.damage,
      friendly: true,
      speed: 26 + slot.item.damage * 0.2,
    );
  }

  PhysicsProp? _findGrabbable(Vector2 from, Vector2 dir) {
    PhysicsProp? best;
    var bestScore = 0.5; // min dot with aim
    for (final prop in _props) {
      if (prop.isDestroyed || prop.held) continue;
      final to = prop.body.position - from;
      final dist = to.length;
      if (dist > PlayerBody.grabRange || dist < 0.01) continue;
      final dot = to.normalized().dot(dir);
      // loose grab when aiming vaguely toward it; precise when close
      final score = dot + (1 - dist / PlayerBody.grabRange) * 0.6;
      if (score > bestScore) {
        best = prop;
        bestScore = score;
      }
    }
    return best;
  }

  void _slotChanged(int slot, ItemDef? item) {
    final p = player;
    final old = p.equippedProp;
    if (old != null) {
      _props.remove(old);
      old.removeFromParent();
      p.equippedProp = null;
    }
    if (item != null) {
      final prop = PhysicsProp(item: item, spawn: p.handPos);
      _props.add(prop);
      p.equippedProp = prop;
      _add(prop);
    }
  }

  /// `world.add` returns FutureOr — fire and forget for sync callers.
  void _add(Component component) {
    final result = world.add(component);
    if (result is Future<void>) unawaited(result);
  }

  void _spawnBullet(
    Vector2 pos,
    Vector2 dir, {
    required double damage,
    required bool friendly,
    double speed = 28,
    Color color = const Color(0xFFFFF3B0),
  }) {
    _add(Bullet(
        spawn: pos, dir: dir, damage: damage, friendly: friendly,
        speed: speed, color: color));
  }

  void _collectQuest(PhysicsProp prop) {
    if (prop.isRemoving) return;
    if (prop.noteId != null) {
      final note = kNotes.where((n) => n.id == prop.noteId).firstOrNull;
      if (note == null) {
        _props.remove(prop);
        prop.removeFromParent();
        return;
      }
      _notesFound++;
      store.addNote(note.id);
      events.onNote?.call(note);
      _toast('NOTE RECOVERED: ${note.title}');
    } else if (prop.moduleTarget != null) {
      store.unlockLevel(prop.moduleTarget!);
      events.onUnlock?.call(prop.moduleTarget!);
      _toast('MODULE CLAIMED — NEW SIMULATION UNLOCKED');
    } else if (prop.item.id == 'keycard') {
      player.inventory.keycards++;
      _toast('KEYCARD ACQUIRED');
    } else if (prop.item.id == 'gachapon') {
      store.reclaimItem('gachapon');
      player.inventory.looseAmmo += 15;
      _toast('GACHAPON +15 ROUNDS');
    } else {
      return;
    }
    _props.remove(prop);
    prop.removeFromParent();
  }

  void _impactDamage(PhysicsProp prop, Object other, double speed) {
    if (other is EnemyBody && !other.dead) {
      other.damage(prop.impactDamage + speed * 0.8, from: prop.body.position);
    } else if (other is PlayerBody && prop.item.mass > 2) {
      other.damage(speed * 0.6, from: prop.body.position);
    }
  }

  void _spawnDrop(String dropId, Vector2 at) {
    if (dropId.startsWith('module:')) {
      final p = PhysicsProp(
        item: kItems['module']!,
        spawn: at,
        moduleTarget: dropId.substring(7),
      );
      _wireProp(p);
      _add(p);
      return;
    }
    final item = kItems[dropId];
    if (item == null) return;
    final p = PhysicsProp(item: item, spawn: at);
    _wireProp(p);
    _add(p);
  }

  void _archive(PhysicsProp prop) {
    if (prop.isRemoving || prop.held || prop.grabbed) return;
    goal.itemSorted();
    _props.remove(prop);
    prop.removeFromParent();
    _toast('OBJECT ARCHIVED ${goal.progress}/${goal.goal.count}');
  }

  void _reclaim(PhysicsProp prop) {
    if (prop.isRemoving || prop.held || prop.grabbed) return;
    store.reclaimItem(prop.item.id);
    if (prop.moduleTarget != null) {
      store.unlockLevel(prop.moduleTarget!);
      events.onUnlock?.call(prop.moduleTarget!);
    }
    _props.remove(prop);
    prop.removeFromParent();
    _toast('${prop.item.name} RECLAIMED');
  }

  void _socketPowered(String itemId, PhysicsProp prop) {
    // The zone flagged itself; the game owns the prop cleanup so no
    // dangling references point at a destroyed body.
    _props.remove(prop);
    if (player.grabbed == prop) player.grabbed = null;
    if (player.equippedProp == prop) player.equippedProp = null;
    prop.removeFromParent();
    if (itemId == 'battery') {
      for (final d in _lvl!.lockedDoors) {
        d.unlock();
      }
      _toast('POWER RESTORED — BULKHEAD OPEN');
    } else {
      goal.coreLoaded();
      _toast('CORE LOADED ${goal.progress}/${goal.goal.count}');
    }
  }

  void _pickup(String kind) {
    switch (kind) {
      case 'keycard':
        player.inventory.keycards++;
        _toast('KEYCARD ACQUIRED');
      case 'slowmo':
        player.slowCharge = 1;
        _toast('SLOW-TIME CHARGED');
      case 'gachapon':
        store.reclaimItem('gachapon');
        player.inventory.looseAmmo += 15;
        _toast('GACHAPON +15 ROUNDS');
      case 'flashlight':
        player.lightBoost++;
        _toast('FLASHLIGHT EQUIPPED');
    }
  }

  /// Redacted chamber: every target down opens the bulkhead.
  void _maybeUnlockByTargets() {
    if (_lvl == null) return;
    final targets = _lvl!.targets;
    if (targets.isNotEmpty && targets.every((t) => t.down)) {
      for (final d in _lvl!.lockedDoors) {
        d.unlock();
      }
    }
  }

  void _tryExit() {
    if (_ended) return;
    if (!goal.isComplete) {
      _toast('LOCKED — ${goal.describe()}');
      return;
    }
    _ended = true;
    store.completeLevel(level.id);
    events.onComplete?.call(LevelResult(
      levelId: level.id,
      timeSeconds: _elapsed,
      notesFound: _notesFound,
      notesTotal: _lvl?.notesTotal ?? 0,
      won: true,
    ));
  }

  void _playerDied() {
    if (_ended) return;
    _ended = true;
    events.onDeath?.call();
  }

  /// Player pressed interact on the monomat listing.
  void buyFromMonomat(int index) {
    final m = hud.openMonomat;
    if (m == null) return;
    final inv = player.inventory;
    final bought = m.stock.buy(index, inv.looseAmmo);
    if (bought == null) {
      _toast('INSUFFICIENT ROUNDS');
      return;
    }
    final offer = m.stock.offers[index];
    inv.looseAmmo -= offer.price;
    final item = kItems[bought];
    if (item == null) return;
    final slotIndex = item.isHoldable ? inv.store(item) : null;
    if (slotIndex != null) {
      inv.select(slotIndex);
      _slotChanged(slotIndex, item);
    } else {
      _spawnDrop(bought, m.body.position + Vector2(0, 1.2));
    }
    _toast('${item.name} DISPENSED');
    hud.refresh();
  }

  /// Interact pressed — throws a held prop, or drops the equipped
  /// weapon back into the world as a loose prop.
  void interact() {
    final p = player;
    if (p.grabbed != null) {
      p.throwGrabbed();
      return;
    }
    final dropped = p.inventory.dropActive();
    if (dropped == null) return;
    final prop = PhysicsProp(item: dropped, spawn: p.handPos);
    _wireProp(prop);
    _add(prop);
    _toast('${dropped.name} DROPPED');
  }

  /// Grab on a weapon prop holsters it instead of a physical grab.
  bool _tryHolster(PhysicsProp prop) {
    if (!prop.isWeapon) return false;
    final inv = player.inventory;
    final index = inv.store(prop.item);
    if (index == null) return false;
    inv.select(index);
    _props.remove(prop);
    prop.removeFromParent();
    _toast('${prop.item.name} HOLSTERED');
    return true;
  }

  void _toast(String msg) {
    hud.showToast(msg);
    events.onToast?.call(msg);
  }

  // -- per-frame ------------------------------------------------------------

  @override
  void update(double dt) {
    final a = _lvl;
    if (a == null) {
      super.update(dt);
      return;
    }
    hud.tick(dt);

    if (paused || _ended) {
      super.update(dt);
      input.clearEdges();
      return;
    }

    // Slow-time: physics and components run on the scaled clock.
    final p = player;
    if (!p.isLoaded) {
      super.update(dt);
      return;
    }
    if (input.slowmoEdge) _slowmoToggled = !_slowmoToggled;
    final wantSlow =
        (input.slowmo || _slowmoToggled) && p.slowCharge > 0;
    _timeScale = wantSlow ? 0.35 : 1.0;
    final sdt = dt * _timeScale;
    _elapsed += sdt;
    hud.slowmoActive = wantSlow;
    p.slowCharge = (p.slowCharge + (wantSlow ? -0.3 : 0.06) * sdt)
        .clamp(0.0, 1.0);
    super.update(sdt);
    dt = sdt;

    if (input.interactEdge) interact();

    // Keycard swipe on locked doors.
    for (final d in a.lockedDoors) {
      if (!d.unlocked &&
          p.inventory.keycards > 0 &&
          (p.body.position.x - d.x).abs() < 2.6 &&
          (p.body.position.y - (d.top + d.height / 2)).abs() <
              d.height.toDouble()) {
        p.inventory.keycards--;
        d.unlock();
        _toast('KEYCARD ACCEPTED');
      }
    }

    // King Ford crown: glued to his head until ripped off.
    for (final e in _enemies) {
      final crown = e.crown;
      if (crown != null && !e.crownTaken && !e.dead) {
        if (p.grabbed == crown) {
          if ((crown.body.position - e.body.position).length > 1.6) {
            e.takeCrown();
            if (goal.goal.type == LevelGoalType.bossFight) {
              goal.bossDefeated();
            }
            _toast('THE CROWN IS YOURS — KING FORD STANDS DOWN');
          }
        } else {
          if (!crown.grabbed && crown.isMounted) crown.grab();
          crown.anchor = e.body.position + Vector2(0, -e.def.sizeY * 0.62);
        }
      }
    }

    // Wave spawner.
    final spawn = waves.update(dt);
    if (spawn != null) {
      if (a.map.waveSpawns.isEmpty) {
        // No spawn points: drain the wave so the goal can still clear.
        for (var i = 0; i < spawn.length; i++) {
          waves.enemyDown();
        }
        if (waves.alive == 0) goal.waveCleared();
      } else {
        var i = 0;
        for (final id in spawn) {
          final cell = a.map.waveSpawns[i % a.map.waveSpawns.length];
          final def = kEnemies[id];
          if (def == null) {
            waves.enemyDown();
            continue;
          }
          final e = EnemyBody(
              def: def, spawn: feetAt(cell, def.sizeY / 2))
            ..player = p;
          _wireEnemy(e);
          _waveEnemies.add(e);
          _add(e);
          i++;
        }
        _toast('WAVE ${waves.currentWave} INBOUND');
      }
    }

    // Prune destroyed props.
    for (final prop in _props.where((p) => p.isDestroyed).toList()) {
      prop.onDestroyed?.call(prop);
    }

    // Camera follows with a little aim lookahead.
    final vp = camera.visibleWorldRect;
    final viewW = vp.width / 2;
    final viewH = vp.height / 2;
    final look = p.body.position + p.aimDir * 1.6 + Vector2(0, -0.6);
    final minX = viewW;
    final maxX = a.map.worldWidth - viewW;
    final minY = viewH;
    final maxY = a.map.worldHeight - viewH;
    camera.viewfinder.position = Vector2(
      maxX > minX ? look.x.clamp(minX, maxX) : a.map.worldWidth / 2,
      maxY > minY ? look.y.clamp(minY, maxY) : a.map.worldHeight / 2,
    );

    // Held weapon tracks the hand.
    p.driveWeapon();
    _darkness?.extraLight = p.lightBoost;

    _syncHud();
    input.clearEdges();
  }

  @override
  void onRemove() {
    world.physicsWorld.destroy();
    super.onRemove();
  }

  void _syncHud() {
    final p = player;
    hud
      ..hp = p.hp
      ..maxHp = p.maxHp
      ..slowCharge = p.slowCharge
      ..keycards = p.inventory.keycards
      ..looseAmmo = p.inventory.looseAmmo
      ..activeSlot = p.inventory.activeSlot
      ..slot0Item = p.inventory.slots[0]?.item
      ..slot1Item = p.inventory.slots[1]?.item
      ..slotItem = p.inventory.active?.item
      ..slotAmmo = p.inventory.active?.ammo ?? 0
      ..setObjective(goal.describe(), done: goal.isComplete);
    hud.refresh();
  }
}
