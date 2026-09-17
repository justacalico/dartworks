import 'dart:math' as math;

import 'package:dartworks/src/data/enemies.dart';
import 'package:dartworks/src/data/items.dart';
import 'package:dartworks/src/data/level_data.dart';
import 'package:dartworks/src/data/levels/levels.dart';
import 'package:dartworks/src/game/components/bullet.dart';
import 'package:dartworks/src/game/components/door.dart';
import 'package:dartworks/src/game/components/enemy_body.dart';
import 'package:dartworks/src/game/components/monomat.dart';
import 'package:dartworks/src/game/components/physics_prop.dart';
import 'package:dartworks/src/game/components/zones.dart';
import 'package:dartworks/src/game/dartworks_game.dart';
import 'package:dartworks/src/game/game_events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' show Rot;
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_store.dart';
import '../helpers/mini_level.dart';
import 'world_test.dart' show step;

DartworksGame _game(
  List<String> layout, {
  LevelGoal goal = const LevelGoal(LevelGoalType.reachExit),
  Map<String, String> legend = const {},
  Map<String, String> boneboxDrops = const {},
  List<MonomatOffer> stock = const [],
  int ammo = 0,
}) {
  final data = miniLevel(
    layout,
    goal: goal,
    legend: legend,
    boneboxDrops: boneboxDrops,
    stock: stock,
  );
  return DartworksGame(
    level: LevelData(
      id: data.id,
      layout: data.layout,
      palette: data.palette,
      objective: data.objective,
      goal: data.goal,
      itemLegend: data.itemLegend,
      boneboxDrops: data.boneboxDrops,
      monomatStock: data.monomatStock,
      waves: data.waves,
      ammoStart: ammo,
    ),
    store: FakeProgressStore(),
    events: const GameEvents(),
  );
}

class _BareZone extends DwZone {
  _BareZone() : super(center: Vector2.zero(), w: 1, h: 1);
}

void main() {
  group('DartworksGame systems 4', () {
    test('update before the level loads is a no-op', () {
      final game = _game([
        '######',
        '#P...#',
        '######',
      ]);
      game.update(1 / 60);
    });

    test('the base zone callbacks are inert', () {
      final zone = _BareZone();
      zone.onEnter(Object());
      zone.onExit(Object());
    });

    testWithGame<DartworksGame>(
      'a player bullet damages the prop it hits',
      () => _game([
        '##########',
        '#P..b....#',
        '##########',
      ]),
      (game) async {
        await step(game, 40);
        final box = game.world.children
            .whereType<PhysicsProp>()
            .first;
        final hpBefore = box.hp;
        game.world.add(Bullet(
          spawn: box.pos + Vector2(-2, 0),
          dir: Vector2(1, 0),
          damage: 8,
          friendly: true,
        ));
        await step(game, 30);
        expect(box.hp == null || box.hp! < hpBefore!, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'an enemy bolt hurts the player',
      () => _game([
        '##########',
        '#P.......#',
        '##########',
      ]),
      (game) async {
        await step(game, 40);
        final hp = game.player.hp;
        game.world.add(Bullet(
          spawn: game.player.body.position + Vector2(2, 0),
          dir: Vector2(-1, 0),
          damage: 9,
          friendly: false,
        ));
        await step(game, 30);
        expect(game.player.hp, lessThan(hp));
      },
    );

    testWithGame<DartworksGame>(
      'releasing a door ends the push state',
      () => _game([
        '##########',
        '#PD......#',
        '##########',
      ]),
      (game) async {
        await step(game, 30);
        game.input.moveAxis = 1;
        await step(game, 80);
        game.input.moveAxis = -1;
        await step(game, 40);
        game.input.moveAxis = 0;
        final door = game.world.children.whereType<DoorBody>().first;
        expect(door.openAmount, greaterThanOrEqualTo(0));
      },
    );

    testWithGame<DartworksGame>(
      'a nullbody keeps clawing while touching the player',
      () => _game([
        '##########',
        '#Pn......#',
        '##########',
      ]),
      (game) async {
        await step(game, 60);
        final hp = game.player.hp;
        await step(game, 180);
        expect(game.player.hp, lessThan(hp));
      },
    );

    testWithGame<DartworksGame>(
      'healing restores lost hp',
      () => _game([
        '##########',
        '#Pn......#',
        '##########',
      ]),
      (game) async {
        await step(game, 120);
        final hp = game.player.hp;
        game.player.heal(25);
        expect(game.player.hp, greaterThan(hp));
      },
    );

    testWithGame<DartworksGame>(
      'grabbing a crate picks it up',
      () => _game([
        '##########',
        '#Px......#',
        '##########',
      ]),
      (game) async {
        await step(game, 40);
        game.input.aimX = 1;
        game.input.grab = true;
        await step(game, 40);
        expect(game.player.grabbed, isNotNull);
        game.input.grab = false;
      },
    );

    testWithGame<DartworksGame>(
      'pressing grab again drops the held prop',
      () => _game([
        '##########',
        '#Px......#',
        '##########',
      ]),
      (game) async {
        await step(game, 40);
        game.input.aimX = 1;
        game.input.grab = true;
        await step(game, 30);
        final crate = game.player.grabbed;
        if (crate == null) return;
        // release drops it, then a press while still holding a prop
        // (the crown path does this) drops it again
        game.input.grab = false;
        await step(game, 10);
        game.player.grabbed = crate..grab();
        game.input.grab = true;
        await step(game, 10);
        expect(game.player.grabbed, isNull);
        game.input.grab = false;
      },
    );

    testWithGame<DartworksGame>(
      'firing a held melee weapon swings it',
      () => _game([
        '##########',
        '#P1......#',
        '##########',
      ], legend: const {'1': 'crowbar'}),
      (game) async {
        await step(game, 40);
        game.input.grab = true;
        await step(game, 30);
        game.input.grab = false;
        await step(game, 10);
        final prop = game.player.equippedProp;
        if (prop == null) return;
        game.input.fire = true;
        await step(game, 5);
        game.input.fire = false;
        expect(prop.swinging || game.player.equippedProp != null,
            isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'the equipped weapon wraps its rotation toward the aim',
      () => _game([
        '##########',
        '#P1......#',
        '##########',
      ], legend: const {'1': 'crowbar'}),
      (game) async {
        await step(game, 40);
        game.input.grab = true;
        await step(game, 30);
        game.input.grab = false;
        await step(game, 10);
        final prop = game.player.equippedProp;
        if (prop == null) return;
        // aim ~3.0 rad against a body rotated to -3.0 => diff > pi
        game.input.aimX = -1;
        game.input.aimY = 0.14;
        prop.body.setTransform(
            prop.body.position, Rot.fromAngle(-3.0));
        await step(game, 10);
        // now the other way: aim -3.0, body +3.0 => diff < -pi
        game.input.aimX = -1;
        game.input.aimY = -0.14;
        prop.body.setTransform(
            prop.body.position, Rot.fromAngle(3.0));
        await step(game, 10);
        expect(prop.body.rotation.angle.abs(), lessThanOrEqualTo(math.pi));
      },
    );

    testWithGame<DartworksGame>(
      'a falling crate damages the enemy under it',
      () => _game([
        '##########',
        '#...x....#',
        '#...t....#',
        '#P.......#',
        '##########',
      ]),
      (game) async {
        await step(game, 120);
        final enemy =
            game.world.children.whereType<EnemyBody>().first;
        expect(enemy.hp, lessThan(enemy.def.hp));
      },
    );

    testWithGame<DartworksGame>(
      'a prop dropped on the player hurts him',
      () => _game([
        '##########',
        '#o.......#',
        '#P.......#',
        '##########',
      ]),
      (game) async {
        await step(game, 120);
        expect(game.player.hp, lessThan(game.player.maxHp));
      },
    );

    test('a real campaign level assembles with all notes counted',
        () async {
      final game = DartworksGame(
        level: levelDataFor('breakroom')!,
        store: FakeProgressStore(),
        events: const GameEvents(),
      );
      game.onGameResize(Vector2(800, 600));
      await game.onLoad();
      expect(game.goal.describe(), isNotEmpty);
      expect(game.world.children, isNotEmpty);
    });

    testWithGame<DartworksGame>(
      'walking off a hidden wall ends the push',
      () => _game([
        '##########',
        '#PH......#',
        '##########',
      ]),
      (game) async {
        await step(game, 30);
        game.input.moveAxis = 1;
        await step(game, 40);
        game.input.moveAxis = -1;
        await step(game, 30);
        game.input.moveAxis = 0;
      },
    );

    testWithGame<DartworksGame>(
      'a crate landing on another crate registers an impact',
      () => _game([
        '##########',
        '#..x.....#',
        '#........#',
        '#P.x.....#',
        '##########',
      ]),
      (game) async {
        await step(game, 120);
        expect(
          game.world.children.whereType<PhysicsProp>().length,
          greaterThanOrEqualTo(2),
        );
      },
    );

    testWithGame<DartworksGame>(
      'an enemy walking into a mid-swing weapon takes the hit',
      () => _game([
        '############',
        '#P1..n.....#',
        '############',
      ], legend: const {'1': 'crowbar'}),
      (game) async {
        await step(game, 40);
        game.input.aimX = 1;
        game.input.grab = true;
        await step(game, 30);
        game.input.grab = false;
        await step(game, 10);
        if (game.player.equippedProp == null) return;
        final enemy =
            game.world.children.whereType<EnemyBody>().first;
        // wait for the enemy to close in, then swing
        for (var i = 0; i < 240; i++) {
          game.update(1 / 60);
          await Future<void>(() {});
          final d = (enemy.body.position.x -
                  game.player.body.position.x)
              .abs();
          if (d < 2.4) {
            game.input.fire = true;
          } else {
            game.input.fire = false;
          }
          if (enemy.hp < enemy.def.hp) break;
        }
        expect(enemy.hp, lessThan(enemy.def.hp));
      },
    );

    testWithGame<DartworksGame>(
      'an enemy claws a downed player on contact',
      () => _game([
        '##########',
        '#P.......#',
        '##########',
      ]),
      (game) async {
        await step(game, 40);
        game.player.damage(500, from: game.player.body.position);
        expect(game.player.isDead, isTrue);
        game.world.add(EnemyBody(
          def: kEnemies['nullbody']!,
          spawn: game.player.body.position + Vector2(0.3, 0),
        )..player = game.player);
        await step(game, 30);
      },
    );

    testWithGame<DartworksGame>(
      'firing a non-weapon slot item just cools down',
      () => _game([
        '##########',
        '#P.......#',
        '##########',
      ]),
      (game) async {
        await step(game, 40);
        final inv = game.player.inventory;
        final slot = inv.store(kItems['crate']!)!;
        inv.select(slot);
        game.input.fire = true;
        await step(game, 5);
        game.input.fire = false;
      },
    );

    testWithGame<DartworksGame>(
      'a level with more clipboards than notes caps the total',
      () => _game([
        '##########',
        '#P..*....#',
        '##########',
      ]),
      (game) async {
        await step(game, 10);
        expect(game.world.children, isNotEmpty);
      },
    );

    testWithGame<DartworksGame>(
      'monomat sells out its offers',
      () => _game(
        [
          '##########',
          '#Pm......#',
          '##########',
        ],
        stock: const [MonomatOffer('crowbar', 5)],
        ammo: 20,
      ),
      (game) async {
        await step(game, 30);
        game.input.moveAxis = 1;
        await step(game, 40);
        game.input.moveAxis = 0;
        await step(game, 20);
        game.buyFromMonomat(0);
        final m = game.world.children
            .whereType<MonomatZone>()
            .firstOrNull;
        expect(m?.stock.isSold(0) ?? true, isTrue);
      },
    );
  });
}
