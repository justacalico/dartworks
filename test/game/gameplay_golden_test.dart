import 'package:dartworks/src/data/level_data.dart';
import 'package:dartworks/src/data/levels/levels.dart';
import 'package:dartworks/src/game/components/bullet.dart';
import 'package:dartworks/src/game/components/enemy_body.dart';
import 'package:dartworks/src/game/components/monomat.dart';
import 'package:dartworks/src/game/dartworks_game.dart';
import 'package:dartworks/src/game/game_events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_store.dart';
import '../helpers/mini_level.dart';

void main() {
  testGolden(
    'gameplay frame renders terrain, entities and player',
    (game, tester) async {
      final g = game as DartworksGame;
      for (var i = 0; i < 80; i++) {
        g.update(1 / 60);
        await Future<void>(() {});
      }
    },
    game: DartworksGame(
      level: miniLevel(
        [
          '####################',
          '#..................#',
          '#P....1.......n...E#',
          '####################',
        ],
        legend: {'1': 'p350'},
      ),
      store: FakeProgressStore(),
      events: const GameEvents(),
    ),
    size: Vector2(960, 540),
    goldenFile: '../goldens/gameplay.png',
  );

  testGolden(
    'museum level renders campaign scenery',
    (game, tester) async {
      final g = game as DartworksGame;
      for (var i = 0; i < 80; i++) {
        g.update(1 / 60);
        await Future<void>(() {});
      }
    },
    game: DartworksGame(
      level: levelDataFor('museum')!,
      store: FakeProgressStore(),
      events: const GameEvents(),
    ),
    size: Vector2(960, 540),
    goldenFile: '../goldens/gameplay_museum.png',
  );

  testGolden(
    'darkness level renders flashlight cone',
    (game, tester) async {
      final g = game as DartworksGame;
      for (var i = 0; i < 80; i++) {
        g.update(1 / 60);
        await Future<void>(() {});
      }
    },
    game: DartworksGame(
      level: miniLevel(
        [
          '####################',
          '#..................#',
          '#P.................#',
          '####################',
        ],
        darkness: 0.85,
      ),
      store: FakeProgressStore(),
      events: const GameEvents(),
    ),
    size: Vector2(960, 540),
    goldenFile: '../goldens/gameplay_dark.png',
  );

  testGolden(
    'zone gallery renders every interactable type',
    (game, tester) async {
      final g = game as DartworksGame;
      for (var i = 0; i < 30; i++) {
        g.update(1 / 60);
        await Future<void>(() {});
      }
    },
    game: DartworksGame(
      level: miniLevel(
        [
          '####################',
          '#P.^..G..k.s.g.F...#',
          '#..A.R.!.0..m......#',
          '####################',
        ],
        stock: const [
          MonomatOffer('p350', 20),
          MonomatOffer('crowbar', 10),
        ],
      ),
      store: FakeProgressStore(),
      events: const GameEvents(),
    ),
    size: Vector2(960, 540),
    goldenFile: '../goldens/gameplay_zones.png',
  );

  testGolden(
    'combat fx render hurt door crack crown and sold stock',
    (game, tester) async {
      final g = game as DartworksGame;
      for (var i = 0; i < 30; i++) {
        g.update(1 / 60);
        await Future<void>(() {});
      }
      // push the hidden wall so the crack lines render
      g.input.moveAxis = 1;
      for (var i = 0; i < 60; i++) {
        g.update(1 / 60);
        await Future<void>(() {});
      }
      g.input.moveAxis = 0;
      final king = g.world.children
          .whereType<EnemyBody>()
          .firstWhere((e) => e.def.id == 'king_ford');
      king.crownTaken = true;
      final monomat =
          g.world.children.whereType<MonomatZone>().first;
      g.hud.openMonomat = monomat;
      g.buyFromMonomat(0);
      g.world.add(Bullet(
        spawn: g.player.body.position + Vector2(3.5, -1),
        dir: Vector2(1, 0),
        damage: 5,
        friendly: true,
      ));
      g.player.damage(15, from: g.player.body.position);
      for (var i = 0; i < 3; i++) {
        g.update(1 / 60);
        await Future<void>(() {});
      }
    },
    game: DartworksGame(
      level: miniLevel(
        [
          '####################',
          '#PH..B.m...........#',
          '####################',
        ],
        stock: const [MonomatOffer('crowbar', 5)],
        ammo: 30,
      ),
      store: FakeProgressStore(),
      events: const GameEvents(),
    ),
    size: Vector2(960, 540),
    goldenFile: '../goldens/gameplay_fx.png',
  );

  testGolden(
    'entity gallery renders enemies doors and platforms',
    (game, tester) async {
      final g = game as DartworksGame;
      for (var i = 0; i < 30; i++) {
        g.update(1 / 60);
        await Future<void>(() {});
      }
    },
    game: DartworksGame(
      level: miniLevel(
        [
          '####################',
          '#P.qQT.bt.B.DKH....#',
          '####################',
        ],
      ),
      store: FakeProgressStore(),
      events: const GameEvents(),
    ),
    size: Vector2(960, 540),
    goldenFile: '../goldens/gameplay_entities.png',
  );
}
