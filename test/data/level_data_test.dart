import 'package:dartworks/src/data/catalog.dart';
import 'package:dartworks/src/data/enemies.dart';
import 'package:dartworks/src/data/items.dart';
import 'package:dartworks/src/data/level_data.dart';
import 'package:dartworks/src/data/levels/levels.dart';
import 'package:dartworks/src/data/notes.dart';
import 'package:flutter_test/flutter_test.dart';

const _enemyTiles = 'nNrcCzZjhOtfB';
const _terrainTiles = '#=.I^HG';
const _interactTiles = 'PExob*mRAkKDMgsqQT!ye0FX';

int _count(LevelData level, String ch) =>
    level.layout.fold(0, (n, row) => n + ch.allMatches(row).length);

void main() {
  group('level data integrity', () {
    test('every catalog level has data and vice versa', () {
      for (final info in kCatalog) {
        expect(kLevelData[info.id], isNotNull,
            reason: '${info.id} missing LevelData');
      }
      expect(kLevelData.keys.toSet(),
          kCatalog.map((l) => l.id).toSet());
    });

    test('layouts are rectangular with sealed borders', () {
      for (final level in kLevelData.values) {
        final width = level.width;
        for (var y = 0; y < level.height; y++) {
          expect(level.layout[y].length, width,
              reason: '${level.id} row $y ragged');
        }
        expect(level.layout.first, matches(RegExp('^#+\$')),
            reason: '${level.id} top row open');
        expect(level.layout.last, matches(RegExp('^#+\$')),
            reason: '${level.id} bottom row open');
        for (var y = 0; y < level.height; y++) {
          expect(level.layout[y][0], '#',
              reason: '${level.id} row $y open left');
          expect(level.layout[y][width - 1], '#',
              reason: '${level.id} row $y open right');
        }
      }
    });

    test('every tile char is known', () {
      for (final level in kLevelData.values) {
        final known =
            _terrainTiles + _interactTiles + _enemyTiles + '123456789'
                'wvuial' + ' ';
        for (var y = 0; y < level.height; y++) {
          for (final ch in level.layout[y].split('')) {
            final ok = known.contains(ch) ||
                level.itemLegend.containsKey(ch) ||
                level.boneboxDrops.containsKey(ch);
            expect(ok, isTrue,
                reason: '${level.id} has unknown tile "$ch"');
          }
        }
      }
    });

    test('exactly one player spawn and at least one exit', () {
      for (final level in kLevelData.values) {
        expect(_count(level, 'P'), 1, reason: level.id);
        expect(_count(level, 'E'), greaterThanOrEqualTo(1),
            reason: level.id);
      }
    });

    test('every clipboard has a note to show', () {
      for (final level in kLevelData.values) {
        final clipboards = _count(level, '*');
        if (clipboards == 0) continue;
        expect(notesForLevel(level.id).length, clipboards,
            reason:
                '${level.id}: $clipboards clipboards, '
                '${notesForLevel(level.id).length} notes');
      }
    });

    test('itemLegend and boneboxDrops resolve to real items/modules',
        () {
      for (final level in kLevelData.values) {
        for (final entry in [
          ...level.itemLegend.values,
          ...level.boneboxDrops.values
        ]) {
          if (entry.startsWith('module:')) {
            final target = entry.substring(7);
            expect(levelById(target), isNotNull,
                reason: '${level.id} module -> $target');
            expect(levelById(target)!.isSandbox, isTrue);
          } else {
            expect(kItems[entry], isNotNull,
                reason: '${level.id} spawns unknown item $entry');
          }
        }
      }
    });

    test('monomat stock resolves to real holdable items', () {
      for (final level in kLevelData.values) {
        for (final offer in level.monomatStock) {
          final item = kItems[offer.itemId];
          expect(item, isNotNull,
              reason: '${level.id} sells unknown ${offer.itemId}');
          expect(item!.isHoldable, isTrue);
          expect(offer.price, greaterThan(0));
        }
      }
    });

    test('wave specs reference real enemies', () {
      for (final level in kLevelData.values) {
        for (final wave in level.waves) {
          for (final entry in wave.enemies.entries) {
            expect(kEnemies[entry.key], isNotNull,
                reason: '${level.id} waves unknown ${entry.key}');
            expect(entry.value, greaterThan(0));
          }
        }
      }
    });
  });

  group('goal consistency', () {
    test('sortItems levels have an archive bin and loose props', () {
      for (final level in kLevelData.values) {
        if (level.goal.type != LevelGoalType.sortItems) continue;
        expect(_count(level, 'A'), greaterThanOrEqualTo(1),
            reason: level.id);
      }
    });

    test('timeTrial levels have enough targets', () {
      for (final level in kLevelData.values) {
        if (level.goal.type != LevelGoalType.timeTrial) continue;
        expect(_count(level, 'T'), level.goal.count, reason: level.id);
      }
    });

    test('repairCore levels have cores and sockets', () {
      for (final level in kLevelData.values) {
        if (level.goal.type != LevelGoalType.repairCore) continue;
        expect(_count(level, 'e'), greaterThanOrEqualTo(level.goal.count),
            reason: level.id);
        expect(_count(level, '0'), greaterThanOrEqualTo(level.goal.count),
            reason: level.id);
      }
    });

    test('surviveRounds levels have waves and spawn points', () {
      for (final level in kLevelData.values) {
        if (level.goal.type != LevelGoalType.surviveRounds) continue;
        expect(level.waves.length, level.goal.count, reason: level.id);
        expect(_count(level, 'X'), greaterThanOrEqualTo(2),
            reason: level.id);
      }
    });

    test('bossFight levels contain the king', () {
      for (final level in kLevelData.values) {
        if (level.goal.type != LevelGoalType.bossFight) continue;
        expect(_count(level, 'B'), greaterThanOrEqualTo(1),
            reason: level.id);
      }
    });
  });
}
