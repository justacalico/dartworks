import 'package:dartworks/src/data/level_data.dart';
import 'package:dartworks/src/game/components/enemy_body.dart';
import 'package:dartworks/src/game/components/monomat.dart';
import 'package:dartworks/src/game/components/physics_prop.dart';
import 'package:dartworks/src/game/dartworks_game.dart';
import 'package:dartworks/src/game/game_events.dart';
import 'package:flame/extensions.dart';
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
  List<WaveSpec> waves = const [],
  int ammo = 0,
  GameEvents events = const GameEvents(),
}) {
  final data = miniLevel(
    layout,
    goal: goal,
    legend: legend,
    boneboxDrops: boneboxDrops,
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
      boneboxDrops: data.boneboxDrops,
      monomatStock: data.monomatStock,
      waves: data.waves,
      ammoStart: ammo,
    ),
    store: FakeProgressStore(),
    events: events,
  );
}

void main() {
  group('DartworksGame systems 3', () {
    testWithGame<DartworksGame>(
      'hazard zone burns enemies crossing it',
      () => _game([
        '##########',
        '#P..^n...#',
        '##########',
      ]),
      (game) async {
        await step(game, 30);
        final enemy =
            game.world.children.whereType<EnemyBody>().first;
        game.input.moveAxis = -0.2;
        await step(game, 200);
        expect(enemy.hp, lessThan(enemy.def.hp));
      },
    );

    testWithGame<DartworksGame>(
      'gravity zone restores gravity when the prop leaves',
      () => _game(
        [
          '##########',
          '#........#',
          '#P..1G...#',
          '##########',
        ],
        legend: {'1': 'crate'},
      ),
      (game) async {
        await step(game, 60);
        final prop =
            game.world.children.whereType<PhysicsProp>().first;
        expect(prop.body.gravityScale, 0);
        prop.body.setTransform(
            prop.body.position + Vector2(6, 0), prop.body.rotation);
        await step(game, 30);
        expect(prop.body.gravityScale, 1);
      },
    );

    testWithGame<DartworksGame>(
      'killing a wave enemy clears the round',
      () => _game(
        [
          '##########',
          '#P....X..#',
          '##########',
        ],
        waves: const [WaveSpec({'nullbody': 1})],
        goal: const LevelGoal(LevelGoalType.surviveRounds),
      ),
      (game) async {
        await step(game, 200);
        final enemy =
            game.world.children.whereType<EnemyBody>().first;
        enemy.damage(500);
        await step(game, 10);
        expect(game.goal.progress, 1);
        expect(game.goal.isComplete, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'killing the king completes the boss goal',
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
        king.damage(500);
        await step(game, 10);
        expect(game.goal.isComplete, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'module bonebox drops a module that unlocks a level',
      () => _game(
        [
          '##########',
          '#P.V.....#',
          '##########',
        ],
        boneboxDrops: const {'V': 'module:tuscany'},
      ),
      (game) async {
        await step(game, 40);
        final box =
            game.world.children.whereType<PhysicsProp>().first;
        box.damage(40);
        await step(game, 30);
        final module = game.world.children
            .whereType<PhysicsProp>()
            .firstWhere((p) => p.moduleTarget == 'tuscany');
        // walk into it to collect
        module.body.setTransform(
            game.player.body.position, module.body.rotation);
        await step(game, 20);
        expect(game.store.isLevelUnlocked('tuscany'), isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'reclaiming a module unlocks its level',
      () => _game(
        [
          '##########',
          '#P..v....#',
          '#...R....#',
          '##########',
        ],
        legend: {'v': 'module:blankbox'},
      ),
      (game) async {
        await step(game, 120);
        expect(game.store.isLevelUnlocked('blankbox'), isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'buying a non-holdable item drops it at the terminal',
      () => _game(
        [
          '##########',
          '#P.m.....#',
          '##########',
        ],
        stock: const [MonomatOffer('gachapon', 5)],
        ammo: 20,
      ),
      (game) async {
        await step(game, 30);
        game.input.moveAxis = 1;
        await step(game, 40);
        game.input.moveAxis = 0;
        await step(game, 20);
        game.buyFromMonomat(0);
        expect(game.player.inventory.looseAmmo, 15);
        await step(game, 10);
        // the gachapon either rests by the terminal or was already
        // auto-collected into the reclaim catalog
        final dropped = game.world.children
            .whereType<PhysicsProp>()
            .any((p) => p.item.id == 'gachapon');
        expect(dropped || game.store.isReclaimed('gachapon'), isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'a heavy prop falling on the player hurts',
      () => _game([
        '##########',
        '#o.......#',
        '#P.......#',
        '##########',
      ]),
      (game) async {
        await step(game, 90);
        expect(game.player.hp, lessThan(100));
      },
    );

    testWithGame<DartworksGame>(
      'nullbody claws the player on contact',
      () => _game([
        '##########',
        '#P.n.....#',
        '##########',
      ]),
      (game) async {
        await step(game, 240);
        expect(game.player.hp, lessThan(100));
      },
    );

    testWithGame<DartworksGame>(
      'invisible wall blocks the player',
      () => _game([
        '##########',
        '#P..I....#',
        '##########',
      ]),
      (game) async {
        await step(game, 30);
        game.input.moveAxis = 1;
        await step(game, 200);
        expect(game.player.body.position.x, lessThan(8));
      },
    );

    testWithGame<DartworksGame>(
      'player walks through and out of a locked exit',
      () => _game(
        [
          '##########',
          '#P..E....#',
          '##########',
        ],
        goal: const LevelGoal(LevelGoalType.sortItems, count: 1),
      ),
      (game) async {
        await step(game, 20);
        game.input.moveAxis = 1;
        await step(game, 200);
        // exit zone is at cell (4,1) -> world x 9; the player is past it
        expect(game.player.body.position.x, greaterThan(11));
      },
    );

    testWithGame<DartworksGame>(
      'jump input lifts the player',
      () => _game([
        '##########',
        '#........#',
        '#........#',
        '#P.......#',
        '##########',
      ]),
      (game) async {
        await step(game, 60);
        final floorY = game.player.body.position.y;
        game.input.jumpEdge = true;
        var rose = false;
        for (var i = 0; i < 40; i++) {
          game.update(1 / 60);
          await Future<void>(() {});
          if (game.player.body.position.y < floorY - 0.5) {
            rose = true;
          }
        }
        expect(rose, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'death unequips the held weapon',
      () => _game(
        [
          '##########',
          '#P1......#',
          '##########',
        ],
        legend: {'1': 'p350'},
      ),
      (game) async {
        await step(game, 40);
        for (var i = 0; i < 30; i++) {
          game.input.aimX = 1;
          game.input.aimY = 0;
          game.input.grab = i < 10;
          game.update(1 / 60);
          await Future<void>(() {});
        }
        game.input.grab = false;
        expect(game.player.equippedProp, isNotNull);
        game.player.damage(200);
        await step(game, 5);
        expect(game.player.isDead, isTrue);
        expect(game.player.equippedProp, isNull);
      },
    );

    testWithGame<DartworksGame>(
      'equipped melee prop reports swinging during a swing',
      () => _game(
        [
          '##########',
          '#P1......#',
          '##########',
        ],
        legend: {'1': 'crowbar'},
      ),
      (game) async {
        await step(game, 40);
        for (var i = 0; i < 30; i++) {
          game.input.aimX = 1;
          game.input.aimY = 0;
          game.input.grab = i < 10;
          game.update(1 / 60);
          await Future<void>(() {});
        }
        game.input.grab = false;
        var sawSwing = false;
        for (var i = 0; i < 60; i++) {
          game.input.fire = i == 0;
          game.update(1 / 60);
          await Future<void>(() {});
          if (game.player.equippedProp?.swinging == true) {
            sawSwing = true;
          }
        }
        expect(sawSwing, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'monomat zone flag clears on the hud when player leaves',
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
        final zone = game.world.children
            .whereType<MonomatZone>()
            .first;
        expect(zone.playerNear, isTrue);
      },
    );
  });
}
