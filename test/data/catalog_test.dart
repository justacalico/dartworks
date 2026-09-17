import 'package:dartworks/src/data/catalog.dart';
import 'package:dartworks/src/data/level_info.dart';
import 'package:dartworks/src/data/notes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('level catalog', () {
    test('holds the full 12-level campaign in story order', () {
      final campaign = campaignLevels;
      expect(campaign, hasLength(12));
      expect(
        campaign.map((l) => l.id).toList(),
        [
          'breakroom',
          'museum',
          'streets',
          'runoff',
          'sewers',
          'warehouse',
          'central_station',
          'tower',
          'time_tower',
          'dungeon',
          'arena',
          'throne_room',
        ],
      );
    });

    test('holds all 7 sandbox levels with unlock hints', () {
      final sandbox = sandboxLevels;
      expect(sandbox, hasLength(7));
      for (final level in sandbox) {
        expect(level.unlockHint, isNotEmpty,
            reason: '${level.id} needs an unlock hint');
      }
      expect(
        sandbox.map((l) => l.id),
        containsAll([
          'museum_basement',
          'blankbox',
          'redacted_chamber',
          'handgun_range',
          'tuscany',
          'zombie_warehouse',
          'fantasy_arena',
        ]),
      );
    });

    test('ids are unique and orders are contiguous per kind', () {
      final ids = kCatalog.map((l) => l.id).toSet();
      expect(ids, hasLength(kCatalog.length));
      for (final kind in LevelKind.values) {
        final orders = kCatalog
            .where((l) => l.kind == kind)
            .map((l) => l.order)
            .toList()
          ..sort();
        expect(orders,
            List.generate(orders.length, (i) => i));
      }
    });

    test('levelById resolves ids and rejects unknowns', () {
      expect(levelById('museum')?.title,
          'MUSEUM OF TECHNICAL DEMONSTRATION');
      expect(levelById('fantasy_arena')?.isSandbox, isTrue);
      expect(levelById('not_a_level'), isNull);
    });
  });

  group('notes catalog', () {
    test('ids are unique', () {
      final ids = kNotes.map((n) => n.id).toSet();
      expect(ids, hasLength(kNotes.length));
    });

    test('every note points at a real level or the menu', () {
      for (final note in kNotes) {
        if (note.levelId == 'menu') continue;
        expect(levelById(note.levelId), isNotNull,
            reason: '${note.id} references ${note.levelId}');
      }
    });

    test('every campaign level has at least one note', () {
      for (final level in campaignLevels) {
        expect(notesForLevel(level.id), isNotEmpty,
            reason: '${level.id} has no clipboards');
      }
    });

    test('noteById resolves and rejects', () {
      expect(noteById('breakroom_1')?.author, 'MONOGON OPS');
      expect(noteById('bogus'), isNull);
    });
  });
}
