import 'package:dartworks/src/data/catalog.dart';
import 'package:dartworks/src/meta/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPrefsProgressStore> makeStore(
    [Map<String, Object> seed = const {}]) async {
  SharedPreferences.setMockInitialValues(seed);
  return SharedPrefsProgressStore(await SharedPreferences.getInstance());
}

void main() {
  group('campaign unlock rules', () {
    test('first level is always unlocked, rest are gated', () async {
      final store = await makeStore();
      expect(store.isLevelUnlocked('breakroom'), isTrue);
      expect(store.isLevelUnlocked('museum'), isFalse);
      expect(store.isLevelUnlocked('throne_room'), isFalse);
    });

    test('completing a level unlocks the next one', () async {
      final store = await makeStore();
      await store.completeLevel('breakroom');
      expect(store.isLevelComplete('breakroom'), isTrue);
      expect(store.isLevelUnlocked('museum'), isTrue);
      expect(store.isLevelUnlocked('streets'), isFalse);
    });

    test('unknown level ids are never unlocked', () async {
      final store = await makeStore();
      expect(store.isLevelUnlocked('nowhere'), isFalse);
    });
  });

  group('sandbox unlock rules', () {
    test('sandbox levels need their module reclaimed', () async {
      final store = await makeStore();
      expect(store.isLevelUnlocked('museum_basement'), isFalse);
      await store.unlockLevel('museum_basement');
      expect(store.isLevelUnlocked('museum_basement'), isTrue);
    });

    test('fantasy arena unlocks only when the campaign is done',
        () async {
      final store = await makeStore();
      expect(store.isLevelUnlocked('fantasy_arena'), isFalse);
      for (final level in campaignLevels) {
        await store.completeLevel(level.id);
      }
      expect(store.isLevelUnlocked('fantasy_arena'), isTrue);
    });
  });

  group('notes and reclaimed items', () {
    test('notes persist across store instances', () async {
      var store = await makeStore();
      await store.addNote('streets_2');
      expect(store.hasNote('streets_2'), isTrue);
      expect(store.foundNotes, contains('streets_2'));

      store = await makeStore({'dw.notes': ['streets_2']});
      expect(store.hasNote('streets_2'), isTrue);
    });

    test('reclaimed items round-trip', () async {
      final store = await makeStore();
      await store.reclaimItem('p350');
      expect(store.isReclaimed('p350'), isTrue);
      expect(store.reclaimedItems, contains('p350'));
    });
  });

  test('reset wipes everything', () async {
    final store = await makeStore();
    await store.completeLevel('breakroom');
    await store.unlockLevel('blankbox');
    await store.addNote('museum_1');
    await store.reclaimItem('crowbar');

    await store.reset();

    expect(store.isLevelComplete('breakroom'), isFalse);
    expect(store.isLevelUnlocked('blankbox'), isFalse);
    expect(store.hasNote('museum_1'), isFalse);
    expect(store.isReclaimed('crowbar'), isFalse);
    expect(store.isLevelUnlocked('breakroom'), isTrue);
  });
}
