import '../data/level_data.dart';

/// A cell coordinate in tile space.
typedef CellPos = ({int x, int y});

/// World units per tile. Characters are ~1.6 units tall, so a tile must
/// be 2 units for one-tile corridors to fit them.
const kTile = 2.0;

/// A horizontal run of same-kind tiles, one cell tall.
typedef BlockRect = ({int x, int y, int w});

/// A spawnable enemy found in the map.
typedef EnemySpawn = ({CellPos cell, String enemyId});

/// An item spawn resolved through the level's item legend.
typedef ItemSpawn = ({CellPos cell, String itemId});

/// A bonebox plus the item it drops when broken.
typedef BoneboxSpawn = ({CellPos cell, String dropId});

/// Pure parser: turns a [LevelData] ASCII map into typed spawn lists.
/// Short rows are padded with solid wall on the right.
ParsedMap parseLevel(LevelData level) {
  final width =
      level.layout.fold<int>(0, (w, row) => row.length > w ? row.length : w);
  final height = level.layout.length;

  String at(int x, int y) {
    final row = level.layout[y];
    return x < row.length ? row[x] : '#';
  }

  final map = ParsedMap._(width, height);

  // Merge horizontal runs of solid / platform tiles into single bodies.
  void mergeRuns(int y, bool Function(String) test,
      List<BlockRect> into) {
    var start = -1;
    for (var x = 0; x <= width; x++) {
      final solid = x < width && test(at(x, y));
      if (solid && start < 0) start = x;
      if (!solid && start >= 0) {
        into.add((x: start, y: y, w: x - start));
        start = -1;
      }
    }
  }

  for (var y = 0; y < height; y++) {
    mergeRuns(y, (c) => c == '#', map.solids);
    mergeRuns(y, (c) => c == '=', map.thinPlatforms);
    mergeRuns(y, (c) => c == 'I', map.invisibleWalls);
  }

  const enemyTiles = {
    'n': 'nullbody',
    'N': 'corrupted_nullbody',
    'r': 'nullrat',
    'c': 'crablet',
    'C': 'crablet_plus',
    'z': 'zombish',
    'Z': 'super_zombish',
    'j': 'junkie_zombish',
    'h': 'zombish_thrower',
    'O': 'omniprojector',
    't': 'turret',
    'f': 'ford_clone',
    'B': 'king_ford',
  };

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final cell = (x: x, y: y);
      switch (at(x, y)) {
        case 'P':
          map.playerSpawn = cell;
        case 'E':
          map.exits.add(cell);
        case 'D':
          map.doors.add(cell);
        case 'K':
          map.lockedDoors.add(cell);
        case 'H':
          map.hiddenWalls.add(cell);
        case 'x':
          map.itemSpawns.add((cell: cell, itemId: 'crate'));
        case 'o':
          map.itemSpawns.add((cell: cell, itemId: 'barrel'));
        case '*':
          map.clipboards.add(cell);
        case 'm':
          map.monomats.add(cell);
        case 'A':
          map.archiveBins.add(cell);
        case 'R':
          map.reclaimBins.add(cell);
        case 'k':
          map.keycards.add(cell);
        case 'g':
          map.gachapons.add(cell);
        case 's':
          map.slowmos.add(cell);
        case 'y':
          map.batteries.add(cell);
        case '!':
          map.batterySockets.add(cell);
        case 'e':
          map.energyCores.add(cell);
        case '0':
          map.coreSockets.add(cell);
        case 'T':
          map.targets.add(cell);
        case 'G':
          map.gravityCells.add(cell);
        case '^':
          map.hazards.add(cell);
        case 'F':
          map.itemSpawns.add((cell: cell, itemId: 'flashlight'));
        case 'q':
          map.elevators.add(cell);
        case 'Q':
          map.movers.add(cell);
        case 'X':
          map.waveSpawns.add(cell);
        case 'b':
          map.boneboxes.add((cell: cell, dropId: 'gachapon'));
        default:
          final enemy = enemyTiles[at(x, y)];
          if (enemy != null) {
            map.enemies.add((cell: cell, enemyId: enemy));
          } else if (level.itemLegend.containsKey(at(x, y))) {
            map.itemSpawns.add(
                (cell: cell, itemId: level.itemLegend[at(x, y)]!));
          } else if (level.boneboxDrops.containsKey(at(x, y))) {
            map.boneboxes.add(
                (cell: cell, dropId: level.boneboxDrops[at(x, y)]!));
          }
      }
    }
  }
  return map;
}

/// The parsed contents of a level map.
class ParsedMap {
  ParsedMap._(this.width, this.height);

  final int width;
  final int height;

  double get worldWidth => width * kTile;
  double get worldHeight => height * kTile;

  final solids = <BlockRect>[];
  final thinPlatforms = <BlockRect>[];
  final invisibleWalls = <BlockRect>[];

  CellPos playerSpawn = (x: 2, y: 2);
  final exits = <CellPos>[];
  final doors = <CellPos>[];
  final lockedDoors = <CellPos>[];
  final hiddenWalls = <CellPos>[];

  final itemSpawns = <ItemSpawn>[];
  final boneboxes = <BoneboxSpawn>[];
  final enemies = <EnemySpawn>[];

  final clipboards = <CellPos>[];
  final monomats = <CellPos>[];
  final archiveBins = <CellPos>[];
  final reclaimBins = <CellPos>[];
  final keycards = <CellPos>[];
  final gachapons = <CellPos>[];
  final slowmos = <CellPos>[];
  final batteries = <CellPos>[];
  final batterySockets = <CellPos>[];
  final energyCores = <CellPos>[];
  final coreSockets = <CellPos>[];
  final targets = <CellPos>[];
  final gravityCells = <CellPos>[];
  final hazards = <CellPos>[];
  final elevators = <CellPos>[];
  final movers = <CellPos>[];
  final waveSpawns = <CellPos>[];
}
