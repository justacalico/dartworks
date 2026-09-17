import 'package:dartworks/src/data/level_data.dart';
import 'package:dartworks/src/data/levels/levels.dart';
import 'package:dartworks/src/game/level_assembler.dart';
import 'package:dartworks/src/game/tile_map.dart';
import 'package:flutter_test/flutter_test.dart';

LevelData _level(List<String> layout,
        {Map<String, String> legend = const {},
        Map<String, String> drops = const {}}) =>
    LevelData(
      id: 't',
      layout: layout,
      palette: const LevelPalette(
          bgTop: 0, bgBottom: 0, block: 0, blockEdge: 0, accent: 0),
      objective: 'x',
      itemLegend: legend,
      boneboxDrops: drops,
    );

void main() {
  group('parseLevel', () {
    test('merges horizontal solid runs', () {
      final map = parseLevel(_level([
        '#####',
        '#...#',
        '#####',
      ]));
      expect(map.solids.length, 4);
      expect(map.solids.first, (x: 0, y: 0, w: 5));
      expect(map.solids, contains((x: 0, y: 1, w: 1)));
      expect(map.solids, contains((x: 4, y: 1, w: 1)));
    });

    test('short rows pad with wall', () {
      final map = parseLevel(_level([
        '#####',
        '#..',
        '#####',
      ]));
      expect(map.width, 5);
      // missing cells read as '#' so the right wall merges
      expect(map.solids, contains((x: 3, y: 1, w: 2)));
    });

    test('finds player, exit and door cells', () {
      final map = parseLevel(_level([
        '######',
        '#P.D.E#',
        '######',
      ]));
      expect(map.playerSpawn, (x: 1, y: 1));
      expect(map.exits, [(x: 5, y: 1)]);
      expect(map.doors, [(x: 3, y: 1)]);
    });

    test('enemy tiles map to ids', () {
      final map = parseLevel(_level([
        '########',
        '#.n.c.B#',
        '########',
      ]));
      expect(
          map.enemies.map((e) => e.enemyId),
          ['nullbody', 'crablet', 'king_ford']);
    });

    test('item legend and module ids spawn props', () {
      final map = parseLevel(_level(
        ['#####', '#.1.2#', '#####'],
        legend: {'1': 'crowbar', '2': 'module:tuscany'},
      ));
      expect(map.itemSpawns.map((s) => s.itemId),
          ['crowbar', 'module:tuscany']);
    });

    test('bonebox tiles and drop legend', () {
      final map = parseLevel(_level(
        ['#####', '#.b.3#', '#####'],
        drops: {'3': 'p350'},
      ));
      expect(map.boneboxes.length, 2);
      expect(map.boneboxes[0].dropId, 'gachapon');
      expect(map.boneboxes[1].dropId, 'p350');
    });

    test('zone tiles sort into lists', () {
      final map = parseLevel(_level([
        '###########',
        '#.m.A.R.q#',
        '###########',
      ]));
      expect(map.monomats.length, 1);
      expect(map.archiveBins.length, 1);
      expect(map.reclaimBins.length, 1);
      expect(map.elevators.length, 1);
    });
  });

  group('groupDoors', () {
    test('vertical runs become single doors', () {
      final runs = groupDoors(
          [(x: 3, y: 5), (x: 3, y: 6), (x: 8, y: 2)]);
      expect(runs.length, 2);
      expect(runs, contains((x: 7.0, top: 10.0, height: 4)));
      expect(runs, contains((x: 17.0, top: 4.0, height: 2)));
    });

    test('gaps split a column into two doors', () {
      final runs = groupDoors(
          [(x: 3, y: 2), (x: 3, y: 3), (x: 3, y: 9)]);
      expect(runs.length, 2);
      expect(runs[0].height, 4);
      expect(runs[1].height, 2);
    });
  });

  group('all shipped levels parse', () {
    for (final level in kLevelData.values) {
      test('${level.id} parses with a player and goal path', () {
        final map = parseLevel(level);
        expect(map.width, greaterThan(10));
        expect(map.solids, isNotEmpty);
        expect(map.playerSpawn.x, greaterThanOrEqualTo(0));
        // every level needs an exit or a completable goal path
        final hasProgressPath = map.exits.isNotEmpty ||
            level.goal.type == LevelGoalType.bossFight;
        expect(hasProgressPath, isTrue,
            reason: '${level.id} has no exit');
      });
    }
  });
}
