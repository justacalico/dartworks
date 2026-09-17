import '../level_data.dart';
import 'arena.dart';
import 'blankbox.dart';
import 'breakroom.dart';
import 'central_station.dart';
import 'dungeon.dart';
import 'fantasy_arena.dart';
import 'handgun_range.dart';
import 'museum.dart';
import 'museum_basement.dart';
import 'redacted_chamber.dart';
import 'runoff.dart';
import 'sewers.dart';
import 'streets.dart';
import 'throne_room.dart';
import 'time_tower.dart';
import 'tower.dart';
import 'tuscany.dart';
import 'warehouse.dart';
import 'zombie_warehouse.dart';

/// All level data keyed by catalog id.
final Map<String, LevelData> kLevelData = {
  for (final level in [
    breakroom,
    museum,
    streets,
    runoff,
    sewers,
    warehouse,
    centralStation,
    tower,
    timeTower,
    dungeon,
    arena,
    throneRoom,
    museumBasement,
    blankbox,
    redactedChamber,
    handgunRange,
    tuscany,
    zombieWarehouse,
    fantasyArena,
  ])
    level.id: level,
};

LevelData? levelDataFor(String id) => kLevelData[id];
