import 'package:dartworks/src/data/enemies.dart';
import 'package:dartworks/src/data/items.dart';
import 'package:dartworks/src/data/level_data.dart';
import 'package:dartworks/src/game/systems/enemy_ai.dart';
import 'package:dartworks/src/game/systems/goal_tracker.dart';
import 'package:dartworks/src/game/systems/input_state.dart';
import 'package:dartworks/src/game/systems/inventory.dart';
import 'package:dartworks/src/game/systems/monomat_economy.dart';
import 'package:dartworks/src/game/systems/wave_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputState', () {
    test('edge flags clear as a batch', () {
      final input = InputState()
        ..jumpEdge = true
        ..interactEdge = true
        ..slot1 = true
        ..slot2 = true;
      input.clearEdges();
      expect(input.jumpEdge, isFalse);
      expect(input.interactEdge, isFalse);
      expect(input.slot1, isFalse);
      expect(input.slot2, isFalse);
    });
  });

  group('Inventory', () {
    final gun = kItems['p350']!;
    final melee = kItems['crowbar']!;

    test('stores into free slots then replaces active', () {
      final inv = Inventory();
      expect(inv.store(gun), isTrue);
      expect(inv.slots[0]?.item, gun);
      expect(inv.store(melee), isTrue);
      expect(inv.slots[1]?.item, melee);
      expect(inv.store(kItems['baton']!), isTrue);
      expect(inv.active?.item.id, 'baton');
    });

    test('quest items cannot be stored', () {
      final inv = Inventory();
      expect(inv.store(kItems['keycard']!), isFalse);
      expect(inv.store(kItems['module']!), isFalse);
    });

    test('slot selection clamps to range', () {
      final inv = Inventory();
      inv.select(1);
      expect(inv.activeSlot, 1);
      inv.select(9);
      expect(inv.activeSlot, 1);
      inv.select(-2);
      expect(inv.activeSlot, 1);
    });

    test('dropActive returns the item and clears the slot', () {
      final inv = Inventory()..store(gun);
      expect(inv.dropActive(), gun);
      expect(inv.active, isNull);
      expect(inv.dropActive(), isNull);
    });

    test('spendRounds only when the magazine covers it', () {
      final inv = Inventory()..store(gun);
      expect(inv.spendRounds(5), isTrue);
      expect(inv.active!.ammo, gun.magSize - 5);
      expect(inv.spendRounds(999), isFalse);
      expect(inv.spendRounds(0), isTrue);
    });

    test('salvage merges magazine into loose ammo', () {
      final inv = Inventory()..store(gun);
      inv.spendRounds(5);
      inv.salvageActive();
      expect(inv.looseAmmo, gun.magSize - 5);
      expect(inv.active, isNull);
    });
  });

  group('MonomatStock', () {
    final stock = MonomatStock(const [
      MonomatOffer('p350', 60),
      MonomatOffer('crowbar', 30),
    ]);

    test('buy succeeds once per item and checks funds', () {
      expect(stock.itemOf(0)?.id, 'p350');
      expect(stock.canAfford(0, 60), isTrue);
      expect(stock.buy(0, 59), isNull);
      expect(stock.buy(0, 60), 'p350');
      expect(stock.isSold(0), isTrue);
      expect(stock.buy(0, 999), isNull);
    });

    test('out-of-range indices return null', () {
      expect(stock.itemOf(-1), isNull);
      expect(stock.itemOf(9), isNull);
      expect(stock.buy(-1, 100), isNull);
      expect(stock.buy(9, 100), isNull);
    });
  });

  group('GoalTracker', () {
    test('reachExit is always open', () {
      final g = GoalTracker(
          const LevelGoal(LevelGoalType.reachExit));
      expect(g.isComplete, isTrue);
      expect(g.describe(), contains('EXIT'));
    });

    test('sortItems counts archive deposits', () {
      final g = GoalTracker(
          const LevelGoal(LevelGoalType.sortItems, count: 3));
      expect(g.isComplete, isFalse);
      g.itemSorted();
      g.itemSorted();
      g.itemSorted();
      expect(g.isComplete, isTrue);
      expect(g.describe(), 'ARCHIVED 3/3');
    });

    test('repairCore and surviveRounds track progress', () {
      final cores = GoalTracker(
          const LevelGoal(LevelGoalType.repairCore, count: 2));
      cores.coreLoaded();
      expect(cores.describe(), 'CORES 1/2');
      cores.coreLoaded();
      expect(cores.isComplete, isTrue);

      final waves = GoalTracker(
          const LevelGoal(LevelGoalType.surviveRounds, count: 3));
      waves.waveCleared();
      expect(waves.describe(), 'ROUND 1/3');
      expect(waves.isComplete, isFalse);
    });

    test('timeTrial and clearEnemies describe remaining work', () {
      final targets = GoalTracker(
          const LevelGoal(LevelGoalType.timeTrial, count: 4));
      targets.targetHit();
      expect(targets.describe(), 'TARGETS 1/4');

      final clear = GoalTracker(
          const LevelGoal(LevelGoalType.clearEnemies, count: 5));
      clear.enemyKilled();
      expect(clear.describe(), 'HOSTILES LEFT 4');
    });

    test('bossFight flips on bossDefeated', () {
      final g = GoalTracker(
          const LevelGoal(LevelGoalType.bossFight));
      expect(g.describe(), 'DEFEAT THE KING');
      g.bossDefeated();
      expect(g.isComplete, isTrue);
      expect(g.describe(), 'KING DEFEATED');
    });
  });

  group('decideIntent', () {
    EnemyDef def(String id) => kEnemies[id]!;

    test('melee chaser walks toward the player and attacks in range', () {
      final far = decideIntent(def('nullbody'),
          distX: 5, distY: 0, cooldown: 0);
      expect(far.moveX, 1);
      expect(far.attack, isFalse);

      final close = decideIntent(def('nullbody'),
          distX: -0.8, distY: 0, cooldown: 0);
      expect(close.moveX, -1);
      expect(close.attack, isTrue);

      final cooling = decideIntent(def('nullbody'),
          distX: -0.8, distY: 0, cooldown: 0.5);
      expect(cooling.attack, isFalse);
    });

    test('chaser hops when the player is above', () {
      final i = decideIntent(def('nullbody'),
          distX: 2, distY: -3, cooldown: 1);
      expect(i.jump, isTrue);
    });

    test('jumper leaps when close and ready', () {
      final i = decideIntent(def('crablet'),
          distX: 3, distY: 0, cooldown: 0);
      expect(i.jump, isTrue);
      final cooling = decideIntent(def('crablet'),
          distX: 3, distY: 0, cooldown: 0.4);
      expect(cooling.jump, isFalse);
    });

    test('flyer keeps range and shoots', () {
      final tooClose = decideIntent(def('omniprojector'),
          distX: 3, distY: 0, cooldown: 0);
      expect(tooClose.moveX, -1);
      final far = decideIntent(def('omniprojector'),
          distX: 9, distY: 0, cooldown: 0);
      expect(far.moveX, 1);
      final shoot = decideIntent(def('omniprojector'),
          distX: 6, distY: 0, cooldown: 0);
      expect(shoot.shoot, isTrue);
    });

    test('thrower backs off and lobs', () {
      final i = decideIntent(def('zombish_thrower'),
          distX: 2, distY: 0, cooldown: 0);
      expect(i.moveX, -1);
      expect(i.shoot, isTrue);
    });

    test('turret only shoots in range', () {
      final off = decideIntent(def('turret'),
          distX: 20, distY: 0, cooldown: 0);
      expect(off.shoot, isFalse);
      final on = decideIntent(def('turret'),
          distX: 5, distY: 1, cooldown: 0);
      expect(on.shoot, isTrue);
    });

    test('boss behaves like a heavy chaser', () {
      final i = decideIntent(def('king_ford'),
          distX: 1, distY: 0, cooldown: 0);
      expect(i.attack, isTrue);
      final far = decideIntent(def('king_ford'),
          distX: 4, distY: -3, cooldown: 0);
      expect(far.jump, isTrue);
    });
  });

  group('WaveManager', () {
    final waves = WaveManager(const [
      WaveSpec({'nullbody': 2}),
      WaveSpec({'crablet': 1, 'zombish': 1, 'ghost': 4}),
    ]);

    test('spawns each wave after the delay and counts down', () {
      expect(waves.update(1.0), isNull);
      final first = waves.update(1.5)!;
      expect(first.length, 2);
      expect(waves.alive, 2);
      expect(waves.update(9), isNull); // alive, no spawn
      waves.enemyDown();
      waves.enemyDown();
      final second = waves.update(3.5)!;
      expect(second.length, 2); // 'ghost' id is skipped
      waves.enemyDown();
      waves.enemyDown();
      expect(waves.update(4), isNull);
      expect(waves.finished, isTrue);
      expect(waves.allCleared, isTrue);
    });

    test('empty wave list finishes immediately', () {
      final w = WaveManager(const []);
      expect(w.update(9), isNull);
    });
  });
}
