import 'package:dartworks/src/data/level_data.dart';
import 'package:dartworks/src/game/components/bullet.dart';
import 'package:dartworks/src/game/components/door.dart';
import 'package:dartworks/src/game/components/enemy_body.dart';
import 'package:dartworks/src/game/components/moving_platform.dart';
import 'package:dartworks/src/game/components/physics_prop.dart';
import 'package:dartworks/src/game/components/target.dart';
import 'package:dartworks/src/game/components/zones.dart';
import 'package:dartworks/src/game/dartworks_game.dart';
import 'package:dartworks/src/game/game_events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_store.dart';
import '../helpers/mini_level.dart';
import 'world_test.dart' show step;

LevelResult? _result;
String? _unlocked;

DartworksGame _game(
  List<String> layout, {
  LevelGoal goal = const LevelGoal(LevelGoalType.reachExit),
  Map<String, String> legend = const {},
  List<MonomatOffer> stock = const [],
  List<WaveSpec> waves = const [],
  int ammo = 0,
  GameEvents events = const GameEvents(),
}) {
  final data = miniLevel(
    layout,
    goal: goal,
    legend: legend,
    stock: stock,
    waves: waves,
  );
  return DartworksGame(
    level: LevelData(
      id: data.id,
      layout: data.layout,
      palette: data.palette,
      objective: data.objective,
      goal: data.goal,
      itemLegend: data.itemLegend,
      monomatStock: data.monomatStock,
      waves: data.waves,
      ammoStart: ammo,
    ),
    store: FakeProgressStore(),
    events: events,
  );
}

void main() {
  group('DartworksGame systems', () {
    testWithGame<DartworksGame>(
      'reaching the exit completes the level',
      () {
        _result = null;
        return _game(
          [
            '##########',
            '#P......E#',
            '##########',
          ],
          events: GameEvents(onComplete: (r) => _result = r),
        );
      },
      (game) async {
        await step(game, 20);
        game.input.moveAxis = 1;
        await step(game, 300);
        expect(_result, isNotNull);
        expect(_result!.won, isTrue);
        expect(game.store.isLevelComplete('test_mini'), isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'incomplete goal keeps the exit locked',
      () => _game(
        [
          '##########',
          '#P......E#',
          '##########',
        ],
        goal: const LevelGoal(LevelGoalType.sortItems, count: 1),
      ),
      (game) async {
        await step(game, 20);
        game.input.moveAxis = 1;
        await step(game, 300);
        expect(game.goal.isComplete, isFalse);
        expect(game.hud.toast, startsWith('LOCKED'));
      },
    );

    testWithGame<DartworksGame>(
      'pickup zones grant keycard, gachapon, slowmo and flashlight',
      () => _game([
        '##########',
        '#PskgF...#',
        '##########',
      ]),
      (game) async {
        await step(game, 20);
        game.player.slowCharge = 0.3;
        game.input.moveAxis = 1;
        await step(game, 300);
        expect(game.player.inventory.keycards, 1);
        expect(game.player.inventory.looseAmmo, 15);
        expect(game.player.slowCharge, greaterThan(0.9));
        expect(game.player.lightBoost, greaterThan(0));
        expect(game.store.isReclaimed('gachapon'), isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'quest props collect: module unlocks, keycard and gachapon count',
      () {
        _unlocked = null;
        return _game(
          [
            '##########',
            '#P.v.w.u.#',
            '##########',
          ],
          legend: {
            'v': 'module:handgun_range',
            'w': 'keycard',
            'u': 'gachapon',
          },
          events: GameEvents(onUnlock: (id) => _unlocked = id),
        );
      },
      (game) async {
        await step(game, 40);
        game.input.moveAxis = 1;
        await step(game, 300);
        expect(game.store.isLevelUnlocked('handgun_range'), isTrue);
        expect(_unlocked, 'handgun_range');
        expect(game.player.inventory.keycards, 1);
        expect(game.player.inventory.looseAmmo, 15);
      },
    );

    testWithGame<DartworksGame>(
      'archive bin sorts a dropped crate',
      () => _game(
        [
          '##########',
          '#P..x....#',
          '#...A....#',
          '##########',
        ],
        goal: const LevelGoal(LevelGoalType.sortItems, count: 1),
      ),
      (game) async {
        await step(game, 120);
        expect(game.goal.progress, 1);
        expect(game.goal.isComplete, isTrue);
        expect(game.world.children.whereType<PhysicsProp>(), isEmpty);
      },
    );

    testWithGame<DartworksGame>(
      'reclaim bin reclaims a dropped crate',
      () => _game([
        '##########',
        '#P..x....#',
        '#...R....#',
        '##########',
      ]),
      (game) async {
        await step(game, 120);
        expect(game.store.isReclaimed('crate'), isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'battery socket powers locked doors',
      () => _game([
        '##########',
        '#P..y.K..#',
        '#...!....#',
        '##########',
      ]),
      (game) async {
        await step(game, 150);
        final socket =
            game.world.children.whereType<SocketZone>().first;
        expect(socket.powered, isTrue);
        final door = game.world.children
            .whereType<DoorBody>()
            .firstWhere((d) => d.locked);
        expect(door.unlocked, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'energy core socket advances repair goal',
      () => _game(
        [
          '##########',
          '#P..e....#',
          '#...0....#',
          '##########',
        ],
        goal: const LevelGoal(LevelGoalType.repairCore),
      ),
      (game) async {
        await step(game, 150);
        expect(game.goal.progress, 1);
        expect(game.goal.isComplete, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'falling crate damages the enemy below',
      () => _game([
        '##########',
        '#P..x....#',
        '#...t....#',
        '##########',
      ]),
      (game) async {
        await step(game, 90);
        final enemy =
            game.world.children.whereType<EnemyBody>().first;
        expect(enemy.hp, lessThan(enemy.def.hp));
      },
    );

    testWithGame<DartworksGame>(
      'turret shoots the player in range',
      () => _game([
        '##########',
        '#P..t....#',
        '##########',
      ]),
      (game) async {
        await step(game, 300);
        expect(game.player.hp, lessThan(100));
      },
    );

    testWithGame<DartworksGame>(
      'zombish thrower lobs a crate',
      () => _game([
        '##########',
        '#P..h....#',
        '##########',
      ]),
      (game) async {
        var sawThrown = false;
        for (var i = 0; i < 240; i++) {
          game.update(1 / 60);
          await Future<void>(() {});
          if (game.world.children
              .whereType<PhysicsProp>()
              .any((p) => p.item.id == 'crate')) {
            sawThrown = true;
            break;
          }
        }
        expect(sawThrown, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'omniprojector fires bolts at the player',
      () => _game([
        '##########',
        '#........#',
        '#P..O....#',
        '##########',
      ]),
      (game) async {
        var sawBolt = false;
        for (var i = 0; i < 300; i++) {
          game.update(1 / 60);
          await Future<void>(() {});
          if (game.world.children
              .whereType<Bullet>()
              .any((b) => !b.friendly)) {
            sawBolt = true;
            break;
          }
        }
        expect(sawBolt || game.player.hp < 100, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'crablet hops toward the player',
      () => _game([
        '##########',
        '#P.c.....#',
        '##########',
      ]),
      (game) async {
        await step(game, 30);
        final enemy =
            game.world.children.whereType<EnemyBody>().first;
        var hopped = false;
        for (var i = 0; i < 240; i++) {
          game.update(1 / 60);
          await Future<void>(() {});
          if (enemy.body.linearVelocity.y < -2) {
            hopped = true;
            break;
          }
        }
        expect(hopped, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'pulling the crown makes King Ford stand down',
      () => _game(
        [
          '##########',
          '#P...B...#',
          '##########',
        ],
        goal: const LevelGoal(LevelGoalType.bossFight),
      ),
      (game) async {
        await step(game, 40);
        final king =
            game.world.children.whereType<EnemyBody>().first;
        // Hold grab first so assigning grabbed doesn't toggle a drop.
        game.input.grab = true;
        await step(game, 5);
        final crown = king.crown!;
        crown.grab();
        game.player.grabbed = crown;
        crown.body.setTransform(
          king.body.position + Vector2(4, 0),
          crown.body.rotation,
        );
        await step(game, 3);
        game.input.grab = false;
        expect(king.crownTaken, isTrue);
        expect(king.surrendered, isTrue);
        expect(game.goal.isComplete, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'Q toggles slow motion',
      () => _game([
        '##########',
        '#P.......#',
        '##########',
      ]),
      (game) async {
        await step(game, 30);
        game.input.slowmoEdge = true;
        game.update(1 / 60);
        await Future<void>(() {});
        expect(game.hud.slowmoActive, isTrue);
        await step(game, 30);
        expect(game.player.slowCharge, lessThan(1));
        game.input.slowmoEdge = true;
        game.update(1 / 60);
        await Future<void>(() {});
        expect(game.hud.slowmoActive, isFalse);
      },
    );

    testWithGame<DartworksGame>(
      'wave markers spawn wave enemies',
      () => _game(
        [
          '##########',
          '#P....X..#',
          '##########',
        ],
        waves: const [
          WaveSpec({'nullbody': 1}),
        ],
        goal: const LevelGoal(LevelGoalType.surviveRounds),
      ),
      (game) async {
        await step(game, 200);
        expect(
            game.world.children.whereType<EnemyBody>(), isNotEmpty);
      },
    );

    testWithGame<DartworksGame>(
      'waves without markers drain and clear the round',
      () => _game(
        [
          '##########',
          '#P.......#',
          '##########',
        ],
        waves: const [
          WaveSpec({'nullbody': 2}),
        ],
        goal: const LevelGoal(LevelGoalType.surviveRounds),
      ),
      (game) async {
        await step(game, 200);
        expect(game.goal.progress, 1);
        expect(game.goal.isComplete, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'monomat rejects a broke customer',
      () => _game(
        [
          '##########',
          '#P.m.....#',
          '##########',
        ],
        stock: const [MonomatOffer('p350', 5)],
      ),
      (game) async {
        await step(game, 30);
        game.input.moveAxis = 1;
        await step(game, 40);
        game.input.moveAxis = 0;
        await step(game, 20);
        expect(game.hud.openMonomat, isNotNull);
        game.buyFromMonomat(0);
        expect(game.hud.toast, 'INSUFFICIENT ROUNDS');
      },
    );

    testWithGame<DartworksGame>(
      'interact throws the grabbed prop',
      () => _game(
        [
          '##########',
          '#P.1.....#',
          '##########',
        ],
        legend: {'1': 'crate'},
      ),
      (game) async {
        await step(game, 40);
        final prop =
            game.world.children.whereType<PhysicsProp>().first;
        prop.grab();
        game.player.grabbed = prop;
        game.interact();
        expect(prop.grabbed, isFalse);
        expect(game.player.grabbed, isNull);
      },
    );

    testWithGame<DartworksGame>(
      'smashing a bonebox drops its contents',
      () => _game([
        '##########',
        '#P..b....#',
        '##########',
      ]),
      (game) async {
        await step(game, 40);
        final box =
            game.world.children.whereType<PhysicsProp>().first;
        expect(box.item.id, 'bonebox');
        box.damage(40);
        await step(game, 10);
        await step(game, 30);
        expect(
          game.world.children
              .whereType<PhysicsProp>()
              .any((p) => p.item.id == 'gachapon'),
          isTrue,
        );
      },
    );

    testWithGame<DartworksGame>(
      'all targets down opens locked doors',
      () => _game(
        [
          '##########',
          '#P..T.K..#',
          '##########',
        ],
        goal: const LevelGoal(LevelGoalType.timeTrial, count: 1),
      ),
      (game) async {
        await step(game, 30);
        game.input.moveAxis = 1;
        await step(game, 200);
        final target =
            game.world.children.whereType<RangeTarget>().first;
        expect(target.down, isTrue);
        final door = game.world.children
            .whereType<DoorBody>()
            .firstWhere((d) => d.locked);
        expect(door.unlocked, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'clearEnemies goal completes when the last enemy dies',
      () => _game(
        [
          '##########',
          '#P..n.E..#',
          '##########',
        ],
        goal: const LevelGoal(LevelGoalType.clearEnemies),
      ),
      (game) async {
        await step(game, 40);
        final enemy =
            game.world.children.whereType<EnemyBody>().first;
        enemy.damage(500);
        await step(game, 10);
        expect(game.goal.isComplete, isTrue);
        game.input.moveAxis = 1;
        await step(game, 200);
      },
    );

    testWithGame<DartworksGame>(
      'auto door opens when the player approaches',
      () => _game([
        '##########',
        '#P...D...#',
        '##########',
      ]),
      (game) async {
        await step(game, 30);
        final door =
            game.world.children.whereType<DoorBody>().first;
        expect(door.locked, isFalse);
        game.input.moveAxis = 1;
        await step(game, 120);
        expect(door.openAmount, greaterThan(0.3));
      },
    );

    testWithGame<DartworksGame>(
      'hidden wall dissolves when pushed',
      () => _game([
        '##########',
        '#P...H...#',
        '##########',
      ]),
      (game) async {
        await step(game, 30);
        game.input.moveAxis = 1;
        await step(game, 200);
        final wall = game.world.children
            .whereType<HiddenWall>()
            .firstOrNull;
        expect(wall == null || wall.gone, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'horizontal mover slides sideways',
      () => _game([
        '##########',
        '#P.......#',
        '#...Q....#',
        '##########',
      ]),
      (game) async {
        await step(game, 60);
        final plat =
            game.world.children.whereType<MovingPlatform>().first;
        final startX = plat.body.position.x;
        await step(game, 40);
        expect(plat.body.position.x, isNot(startX));
      },
    );

    testWithGame<DartworksGame>(
      'monomat closes when the player walks away',
      () => _game(
        [
          '##########',
          '#P.m.....#',
          '##########',
        ],
        stock: const [MonomatOffer('p350', 5)],
        ammo: 20,
      ),
      (game) async {
        await step(game, 30);
        game.input.moveAxis = 1;
        await step(game, 40);
        game.input.moveAxis = 0;
        await step(game, 20);
        expect(game.hud.openMonomat, isNotNull);
        game.input.moveAxis = 1;
        await step(game, 200);
        game.input.moveAxis = 0;
        await step(game, 30);
        expect(game.hud.openMonomat, isNull);
      },
    );
  });
}
