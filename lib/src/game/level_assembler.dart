import 'package:flame_forge2d/flame_forge2d.dart';

import '../data/enemies.dart';
import '../data/items.dart';
import '../data/level_data.dart';
import '../data/notes.dart';
import 'components/door.dart';
import 'components/enemy_body.dart';
import 'components/level_backdrop.dart';
import 'components/monomat.dart';
import 'components/moving_platform.dart';
import 'components/physics_prop.dart';
import 'components/player_body.dart';
import 'components/target.dart';
import 'components/terrain_block.dart';
import 'components/zones.dart';
import 'render/palette.dart';
import 'systems/input_state.dart';
import 'systems/monomat_economy.dart';
import 'tile_map.dart';

/// Everything the assembler created, so the game can wire callbacks
/// without hunting the component tree.
class AssembledLevel {
  AssembledLevel({
    required this.player,
    required this.map,
    required this.palette,
  });

  final ParsedMap map;
  final DwPalette palette;
  final PlayerBody player;
  final enemies = <EnemyBody>[];
  final props = <PhysicsProp>[];
  final monomats = <MonomatZone>[];
  final doors = <DoorBody>[];
  final lockedDoors = <DoorBody>[];
  final targets = <RangeTarget>[];
  final zones = <DwZone>[];
  int notesTotal = 0;
}

Vector2 cellCenter(CellPos c) =>
    Vector2(c.x * kTile + kTile / 2, c.y * kTile + kTile / 2);

/// Spawn point with the body's feet resting on the cell's floor.
/// Centered spawns wedge tall bodies inside the tile below.
Vector2 feetAt(CellPos c, double halfHeight) => Vector2(
    c.x * kTile + kTile / 2, (c.y + 1) * kTile - halfHeight - 0.05);

/// Groups door cells sharing a column into vertical runs so a two-cell
/// `DD` column becomes one door.
List<({double x, double top, int height})> groupDoors(List<CellPos> cells) {
  final byColumn = <int, List<int>>{};
  for (final c in cells) {
    byColumn.putIfAbsent(c.x, () => []).add(c.y);
  }
  final out = <({double x, double top, int height})>[];
  for (final entry in byColumn.entries) {
    final ys = entry.value..sort();
    var start = ys.first;
    var prev = ys.first;
    for (var i = 1; i <= ys.length; i++) {
      if (i == ys.length || ys[i] != prev + 1) {
        out.add((
          x: entry.key * kTile + kTile / 2,
          top: start * kTile,
          height: ((prev - start + 1) * kTile).round(),
        ));
        if (i < ys.length) start = ys[i];
      }
      if (i < ys.length) prev = ys[i];
    }
  }
  return out;
}

/// Builds all terrain, zones and entities for [level] inside [world].
/// Gameplay callbacks are attached by the caller afterwards.
Future<AssembledLevel> assembleLevel({
  required Forge2DWorld world,
  required LevelData level,
  required InputState input,
}) async {
  final map = parseLevel(level);
  final palette = DwPalette(level.palette);
  final levelNotes =
      kNotes.where((n) => n.levelId == level.id).toList(growable: false);

  await world.add(LevelBackdrop(
    palette: palette,
    levelWidth: map.worldWidth,
    levelHeight: map.worldHeight,
    seed: level.id.hashCode,
  ));
  await world.add(TerrainBlock(rects: map.solids, palette: palette));
  await world.add(TerrainBlock(
      rects: map.thinPlatforms,
      palette: palette,
      kind: TerrainKind.platform));
  if (map.invisibleWalls.isNotEmpty) {
    await world.add(TerrainBlock(
        rects: map.invisibleWalls,
        palette: palette,
        kind: TerrainKind.invisible));
  }

  final player = PlayerBody(
      spawn: feetAt(map.playerSpawn, 0.78), input: input);
  await world.add(player);
  final result = AssembledLevel(player: player, map: map, palette: palette)
    ..notesTotal =
        levelNotes.length < map.clipboards.length
            ? levelNotes.length
            : map.clipboards.length;

  for (final run in groupDoors(map.doors)) {
    final door = DoorBody(
        x: run.x, top: run.top, height: run.height, locked: false)
      ..player = player;
    result.doors.add(door);
    await world.add(door);
  }
  for (final run in groupDoors(map.lockedDoors)) {
    final door = DoorBody(
        x: run.x, top: run.top, height: run.height, locked: true)
      ..player = player;
    result.lockedDoors.add(door);
    await world.add(door);
  }
  for (final cell in map.hiddenWalls) {
    await world.add(
        HiddenWall(x: cell.x * kTile, y: cell.y * kTile));
  }

  // Static pickups and zones.
  Future<void> zone(DwZone z) async {
    result.zones.add(z);
    await world.add(z);
  }

  for (final cell in map.exits) {
    await zone(ExitZone(center: cellCenter(cell)));
  }
  for (final cell in map.hazards) {
    await zone(HazardZone(center: cellCenter(cell) + Vector2(0, 0.5)));
  }
  for (final cell in map.gravityCells) {
    await zone(GravityZone(center: cellCenter(cell)));
  }
  for (final cell in map.keycards) {
    await zone(PickupZone(center: cellCenter(cell), kind: 'keycard'));
  }
  for (final cell in map.slowmos) {
    await zone(PickupZone(center: cellCenter(cell), kind: 'slowmo'));
  }
  for (final cell in map.gachapons) {
    await zone(PickupZone(center: cellCenter(cell), kind: 'gachapon'));
  }
  for (final cell in map.archiveBins) {
    await zone(BinZone(center: cellCenter(cell), isReclaim: false));
  }
  for (final cell in map.reclaimBins) {
    await zone(BinZone(center: cellCenter(cell), isReclaim: true));
  }
  for (final cell in map.batterySockets) {
    await zone(
        SocketZone(center: cellCenter(cell), acceptsItem: 'battery'));
  }
  for (final cell in map.coreSockets) {
    await zone(
        SocketZone(center: cellCenter(cell), acceptsItem: 'energy_core'));
  }
  for (final cell in map.targets) {
    final t = RangeTarget(center: cellCenter(cell));
    result.targets.add(t);
    await world.add(t);
  }
  for (final cell in map.monomats) {
    final m =
        MonomatZone(center: cellCenter(cell), stock: MonomatStock(level.monomatStock));
    result.monomats.add(m);
    await world.add(m);
  }
  for (final cell in map.elevators) {
    await world
        .add(MovingPlatform(center: cellCenter(cell), vertical: true));
  }
  for (final cell in map.movers) {
    await world
        .add(MovingPlatform(center: cellCenter(cell), vertical: false));
  }

  // Items.
  for (final spawn in map.itemSpawns) {
    final raw = spawn.itemId;
    if (raw.startsWith('module:')) {
      final p = PhysicsProp(
        item: kItems['module']!,
        spawn: cellCenter(spawn.cell),
        moduleTarget: raw.substring(7),
      );
      result.props.add(p);
      await world.add(p);
    } else if (raw == 'flashlight') {
      await zone(
          PickupZone(center: cellCenter(spawn.cell), kind: 'flashlight'));
    } else {
      final item = kItems[raw];
      if (item == null) continue;
      final p = PhysicsProp(item: item, spawn: cellCenter(spawn.cell));
      result.props.add(p);
      await world.add(p);
    }
  }
  for (final box in map.boneboxes) {
    final p = PhysicsProp(
      item: kItems['bonebox']!,
      spawn: cellCenter(box.cell),
      dropId: box.dropId,
      hp: 24,
    );
    result.props.add(p);
    await world.add(p);
  }
  for (final cell in map.batteries) {
    final p = PhysicsProp(
        item: kItems['battery']!, spawn: cellCenter(cell));
    result.props.add(p);
    await world.add(p);
  }
  for (final cell in map.energyCores) {
    final p = PhysicsProp(
        item: kItems['energy_core']!, spawn: cellCenter(cell));
    result.props.add(p);
    await world.add(p);
  }

  // Clipboards carry this level's notes in order.
  for (var i = 0; i < map.clipboards.length && i < levelNotes.length; i++) {
    final p = PhysicsProp(
      item: kItems['clipboard']!,
      spawn: cellCenter(map.clipboards[i]),
      noteId: levelNotes[i].id,
    );
    result.props.add(p);
    await world.add(p);
  }

  // Enemies; wave enemies spawn later from waveSpawns.
  for (final e in map.enemies) {
    final def = enemyById(e.enemyId)!;
    final enemy = EnemyBody(
      def: def,
      spawn: feetAt(e.cell, def.sizeY / 2),
    )..player = player;
    result.enemies.add(enemy);
    await world.add(enemy);
    if (e.enemyId == 'king_ford') {
      final crown = PhysicsProp(
        item: kItems['crown']!,
        spawn: cellCenter(e.cell) + Vector2(0, -1.4),
      );
      enemy.crown = crown;
      result.props.add(crown);
      await world.add(crown);
    }
  }

  return result;
}
