import 'package:dartworks/src/data/items.dart';
import 'package:dartworks/src/data/level_data.dart';
import 'package:dartworks/src/game/components/enemy_body.dart';
import 'package:dartworks/src/game/components/physics_prop.dart';
import 'package:dartworks/src/game/components/player_body.dart';
import 'package:dartworks/src/game/dartworks_game.dart';
import 'package:dartworks/src/game/game_events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_store.dart';
import '../helpers/mini_level.dart';

LevelData _mini(List<String> layout,
        {LevelGoal goal = const LevelGoal(LevelGoalType.reachExit),
        Map<String, String> legend = const {},
        List<MonomatOffer> stock = const [],
        List<WaveSpec> waves = const []}) =>
    miniLevel(layout,
        goal: goal, legend: legend, stock: stock, waves: waves);

/// Step the game N frames, yielding each tick so deferred
/// component loads finish (world.add is FutureOr).
Future<void> step(DartworksGame game, int frames) async {
  for (var i = 0; i < frames; i++) {
    game.update(1 / 60);
    await Future<void>(() {});
  }
}

void main() {
  group('DartworksGame', () {
    testWithGame<DartworksGame>(
      'assembles a level: player, terrain, exit',
      () => DartworksGame(
        level: _mini([
          '##########',
          '#P......E#',
          '##########',
        ]),
        store: FakeProgressStore(),
        events: const GameEvents(),
      ),
      (game) async {
        expect(game.player, isA<PlayerBody>());
        expect(game.player.body.isValid, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'player falls to the floor and walks right',
      () => DartworksGame(
        level: _mini([
          '##########',
          '#P.......#',
          '#........#',
          '##########',
        ]),
        store: FakeProgressStore(),
        events: const GameEvents(),
      ),
      (game) async {
        await step(game, 90);
        final y = game.player.body.position.y;
        expect(y, greaterThan(4.0));
        expect(y, lessThan(6.0));

        final x0 = game.player.body.position.x;
        game.input.moveAxis = 1;
        await step(game, 60);
        expect(game.player.body.position.x, greaterThan(x0 + 1));
      },
    );

    testWithGame<DartworksGame>(
      'reaching the exit completes a reachExit level',
      () => DartworksGame(
        level: _mini([
          '##########',
          '#P......E#',
          '##########',
        ]),
        store: FakeProgressStore(),
        events: const GameEvents(),
      ),
      (game) async {
        game.input.moveAxis = 1;
        await step(game, 300);
        expect(game.goal.isComplete, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'gun slot fires bullets that damage enemies',
      () => DartworksGame(
        level: _mini([
          '############',
          '#P......n..#',
          '############',
        ]),
        store: FakeProgressStore(),
        events: const GameEvents(),
      ),
      (game) async {
        final enemy =
            game.world.children.whereType<EnemyBody>().first;
        enemy.player = game.player;
        game.input.aimX = 1;
        game.input.aimY = 0;
        game.player.inventory.store(kItems['p350']!);
        for (var i = 0; i < 300; i++) {
          game.input.fire = i % 12 == 0; // p350 is semi-auto: pulse it
          game.update(1 / 60);
          await Future<void>(() {});
          if (enemy.dead) break;
        }
        game.input.fire = false;
        expect(enemy.dead || enemy.hp < enemy.def.hp, isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'enemy contact damages the player',
      () => DartworksGame(
        level: _mini([
          '##########',
          '#P.n.....#',
          '##########',
        ]),
        store: FakeProgressStore(),
        events: const GameEvents(),
      ),
      (game) async {
        final enemy =
            game.world.children.whereType<EnemyBody>().first;
        enemy.player = game.player;
        final hp0 = game.player.hp;
        for (var i = 0; i < 300; i++) {
          game.update(1 / 60);
          await Future<void>(() {});
          if (game.player.hp < hp0) break;
        }
        expect(game.player.hp, lessThan(hp0));
      },
    );

    testWithGame<DartworksGame>(
      'waves spawn enemies for surviveRounds levels',
      () => DartworksGame(
        level: _mini(
          [
            '##########',
            '#P....X..#',
            '##########',
          ],
          goal: const LevelGoal(LevelGoalType.surviveRounds, count: 1),
          waves: const [WaveSpec({'nullrat': 2})],
        ),
        store: FakeProgressStore(),
        events: const GameEvents(),
      ),
      (game) async {
        await step(game, 240);
        expect(
            game.world.children.whereType<EnemyBody>().length,
            greaterThanOrEqualTo(1));
      },
    );

    testWithGame<DartworksGame>(
      'quest props survive floor contact, collect on player touch',
      () => DartworksGame(
        level: _mini(
          [
            '##########',
            '#P.....1.#',
            '##########',
          ],
          legend: {'1': 'module:museum_basement'},
        ),
        store: FakeProgressStore(),
        events: const GameEvents(),
      ),
      (game) async {
        await step(game, 90);
        // settled on the floor without self-collecting
        expect(game.world.children.whereType<PhysicsProp>().length, 1);
        final store = game.store as FakeProgressStore;
        expect(store.isLevelUnlocked('museum_basement'), isFalse);
        // walk into it
        game.input.moveAxis = 1;
        await step(game, 240);
        expect(store.isLevelUnlocked('museum_basement'), isTrue);
      },
    );

    testWithGame<DartworksGame>(
      'grabbing a gun prop holsters it into a slot',
      () => DartworksGame(
        level: _mini(
          [
            '##########',
            '#P1......#',
            '##########',
          ],
          legend: {'1': 'p350'},
        ),
        store: FakeProgressStore(),
        events: const GameEvents(),
      ),
      (game) async {
        await step(game, 60);
        game.input.aimX = 1;
        game.input.aimY = 0;
        // tap grab
        for (var i = 0; i < 30; i++) {
          game.input.grab = i < 10;
          game.update(1 / 60);
          await Future<void>(() {});
        }
        game.input.grab = false;
        expect(game.player.inventory.active?.item.id, 'p350');
      },
    );

    testWithGame<DartworksGame>(
      'legend items and boneboxes spawn props',
      () => DartworksGame(
        level: _mini(
          [
            '##########',
            '#P.1.b..o#',
            '##########',
          ],
          legend: {'1': 'crowbar'},
        ),
        store: FakeProgressStore(),
        events: const GameEvents(),
      ),
      (game) async {
        final props =
            game.world.children.whereType<PhysicsProp>().toList();
        expect(props.length, 3);
        expect(props.any((p) => p.item.id == 'crowbar'), isTrue);
        expect(props.any((p) => p.item.id == 'bonebox'), isTrue);
        expect(props.any((p) => p.item.id == 'barrel'), isTrue);
      },
    );
  });
}
