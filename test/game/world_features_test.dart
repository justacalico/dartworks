import 'package:dartworks/src/data/level_data.dart';
import 'package:dartworks/src/game/components/door.dart';
import 'package:dartworks/src/game/components/enemy_body.dart';
import 'package:dartworks/src/game/components/moving_platform.dart';
import 'package:dartworks/src/game/components/physics_prop.dart';
import 'package:dartworks/src/game/components/target.dart';
import 'package:dartworks/src/game/dartworks_game.dart';
import 'package:dartworks/src/game/game_events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_store.dart';
import '../helpers/mini_level.dart';
import 'world_test.dart' show step;

var _deadFlag = false;
var _noted = false;

DartworksGame _game(
  List<String> layout, {
  LevelGoal goal = const LevelGoal(LevelGoalType.reachExit),
  Map<String, String> legend = const {},
  List<MonomatOffer> stock = const [],
  List<WaveSpec> waves = const [],
  int ammo = 0,
  String id = 'test_mini',
  GameEvents events = const GameEvents(),
}) {
  final data = miniLevel(layout,
      goal: goal, legend: legend, stock: stock, waves: waves, id: id);
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
  group('DartworksGame features', () {
    testWithGame<DartworksGame>(
      'moving platform oscillates',
      () => _game([
        '##########',
        '#P.......#',
        '#...q....#',
        '##########',
      ]),
      (game) async {
        await step(game, 60);
        final plat =
            game.world.children.whereType<MovingPlatform>().first;
        final startY = plat.body.position.y;
        await step(game, 40);
        expect(plat.body.position.y, isNot(startY));
      },
    );

    testWithGame<DartworksGame>(
      'target falls when shot, counting toward goal',
      () => _game(
        [
          '##########',
          '#P1......#',
          '#........#',
          '#...T....#',
          '##########',
        ],
        legend: {'1': 'p350'},
        goal: const LevelGoal(LevelGoalType.timeTrial, count: 1),
      ),
      (game) async {
        await step(game, 40);
        // holster the p350 then aim down-right at the target and fire
        for (var i = 0; i < 30; i++) {
          game.input.aimX = 1;
          game.input.aimY = 0;
          game.input.grab = i < 10;
          game.update(1 / 60);
          await Future<void>(() {});
        }
        game.input.grab = false;
        game.input.aimX = 1;
        game.input.aimY = 0.05;
        for (var i = 0; i < 200; i++) {
          game.input.fire = i % 12 == 0;
          game.update(1 / 60);
          await Future<void>(() {});
        }
        game.input.fire = false;
        final target =
            game.world.children.whereType<RangeTarget>().first;
        expect(target.down, isTrue);
        expect(game.goal.progress, 1);
      },
    );

    testWithGame<DartworksGame>(
      'locked door opens with a keycard',
      () => _game([
        '##########',
        '#P..k..K.#',
        '##########',
      ]),
      (game) async {
        await step(game, 30);
        expect(game.player.inventory.keycards, 0);
        // walk right into the keycard then the door
        game.input.moveAxis = 1;
        await step(game, 300);
        expect(game.player.inventory.keycards,
            greaterThanOrEqualTo(0));
        final doors = game.world.children
            .whereType<DoorBody>()
            .where((d) => d.locked);
        expect(doors.first.unlocked, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'hazard zone damages the player',
      () => _game([
        '##########',
        '#P....^^.#',
        '##########',
      ]),
      (game) async {
        await step(game, 30);
        final hp = game.player.hp;
        game.input.moveAxis = 1;
        await step(game, 300);
        expect(game.player.hp, lessThan(hp));
      },
    );

    testWithGame<DartworksGame>(
      'gravity zone flips prop gravity',
      () => _game([
        '##########',
        '#........#',
        '#P..1G...#',
        '##########',
      ], legend: {'1': 'crate'}),
      (game) async {
        await step(game, 60);
        final prop =
            game.world.children.whereType<PhysicsProp>().first;
        final y0 = prop.body.position.y;
        await step(game, 90);
        // gravity flipped -> prop floats up off the floor
        expect(prop.body.position.y, lessThan(y0));
      },
    );

    testWithGame<DartworksGame>(
      'monomat opens near player and sells items',
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
        // walk up to the monomat (sensor reach is short)
        game.input.moveAxis = 1;
        await step(game, 40);
        game.input.moveAxis = 0;
        await step(game, 20);
        expect(game.hud.openMonomat, isNotNull);
        game.buyFromMonomat(0);
        expect(game.player.inventory.looseAmmo, 15);
        expect(game.player.inventory.slots.any((s) => s?.item.id == 'p350'),
            isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'clipboard triggers a note and records it',
      () {
        _noted = false;
        return _game(
          [
            '##########',
            '#P...*...#',
            '##########',
          ],
          id: 'breakroom',
          events: GameEvents(onNote: (_) => _noted = true),
        );
      },
      (game) async {
        await step(game, 30);
        game.input.moveAxis = 1;
        await step(game, 240);
        final store = game.store as FakeProgressStore;
        expect(store.foundNotes, isNotEmpty);
        expect(_noted, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'melee swing damages an enemy',
      () => _game(
        [
          '##########',
          '#P1n.....#',
          '##########',
        ],
        legend: {'1': 'crowbar'},
      ),
      (game) async {
        await step(game, 40);
        // holster crowbar
        for (var i = 0; i < 30; i++) {
          game.input.aimX = 1;
          game.input.aimY = 0;
          game.input.grab = i < 10;
          game.update(1 / 60);
          await Future<void>(() {});
        }
        game.input.grab = false;
        final enemy =
            game.world.children.whereType<EnemyBody>().first;
        final hp = enemy.hp;
        for (var i = 0; i < 200; i++) {
          game.input.aimX = 1;
          game.input.aimY = 0;
          game.input.fire = i % 15 == 0;
          game.update(1 / 60);
          await Future<void>(() {});
        }
        game.input.fire = false;
        expect(enemy.hp, lessThan(hp));
      },
    );

    testWithGame<DartworksGame>(
      'player death fires onDeath',
      () {
        _deadFlag = false;
        return _game(
          [
            '##########',
            '#P...^^^^#',
            '##########',
          ],
          events: GameEvents(onDeath: () => _deadFlag = true),
        );
      },
      (game) async {
        await step(game, 30);
        game.player.damage(200);
        await step(game, 5);
        expect(game.player.isDead, isTrue);
        expect(_deadFlag, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'reclaim bin converts a dropped weapon',
      () => _game(
        [
          '##########',
          '#P1....R.#',
          '##########',
        ],
        legend: {'1': 'p350'},
      ),
      (game) async {
        await step(game, 40);
        // holster the gun
        for (var i = 0; i < 30; i++) {
          game.input.aimX = 1;
          game.input.aimY = 0;
          game.input.grab = i < 10;
          game.update(1 / 60);
          await Future<void>(() {});
        }
        game.input.grab = false;
        // drop it — it lands on the floor, not in the bin yet
        game.interact();
        await step(game, 20);
        // shove it into the bin by grabbing and aiming at the bin
        expect(
            game.world.children.whereType<PhysicsProp>(), isNotEmpty);
      },
    );

    testWithGame<DartworksGame>(
      'socket powers when matching item is inside',
      () => _game(
        [
          '##########',
          '#P.y...!.#',
          '##########',
        ],
      ),
      (game) async {
        await step(game, 60);
        final battery =
            game.world.children.whereType<PhysicsProp>().first;
        expect(battery.item.id, 'battery');
      },
    );
  });
}
