/// Data-driven level format. Each level is an ASCII tile map plus a
/// palette, a goal, and per-level legends for item spawns and bonebox loot.
///
/// Tile legend
/// ===========
/// Terrain:
///   `#` solid block      `=` thin platform      `.` air
///   `I` invisible wall   `^` hazard (lava/etc)  `H` hidden pushable wall
///   `G` zero-gravity field cell
///
/// Entities:
///   `P` player spawn     `E` exit door          `B` King Ford
///   `n` nullbody         `N` corrupted nullbody `r` nullrat
///   `c` crablet          `C` crablet plus       `z` zombish
///   `Z` super zombish    `j` junkie zombish     `h` zombish thrower
///   `O` omniprojector    `t` turret             `f` ford clone
///
/// Interactables:
///   `x` crate            `o` barrel             `b` bonebox
///   `*` clipboard note   `m` monomat            `R` reclamation bin
///   `A` archive bin      `k` keycard            `K` locked door
///   `D` auto door        `M` module             `g` gachapon
///   `s` slow-time charge `q` elevator (vert)    `Q` platform (horiz)
///   `T` target           `!` battery socket     `y` battery
///   `e` energy core      `0` core socket        `F` flashlight pickup
///
/// Any character present in [LevelData.itemLegend] spawns that item as a
/// physics prop (weapons, gadgets, junk props). The pseudo-id
/// `module:<levelId>` spawns a sandbox module that unlocks that level.
library;

enum LevelGoalType {
  /// Reach the exit door.
  reachExit,

  /// Throw [count] marked props into the archive bin.
  sortItems,

  /// Eliminate every hostile in the level, then exit.
  clearEnemies,

  /// Survive [count] spawn waves, then exit.
  surviveRounds,

  /// Hit all [count] range targets, then exit.
  timeTrial,

  /// Load [count] energy cores into core sockets, then exit.
  repairCore,

  /// Defeat King Ford - or just steal his crown.
  bossFight,
}

class LevelGoal {
  const LevelGoal(this.type, {this.count = 0});

  final LevelGoalType type;
  final int count;
}

/// Per-level colour scheme (ARGB ints to keep data files framework-free).
class LevelPalette {
  const LevelPalette({
    required this.bgTop,
    required this.bgBottom,
    required this.block,
    required this.blockEdge,
    required this.accent,
    this.darkness = 0,
  });

  final int bgTop;
  final int bgBottom;
  final int block;
  final int blockEdge;
  final int accent;

  /// 0-1 darkness overlay; the player carries a light radius in dark maps.
  final double darkness;
}

/// What a monomat sells, in display order.
class MonomatOffer {
  const MonomatOffer(this.itemId, this.price);

  final String itemId;
  final int price;
}

/// Enemies spawned per wave in `surviveRounds` levels.
class WaveSpec {
  const WaveSpec(this.enemies);

  /// enemyId -> how many to spawn.
  final Map<String, int> enemies;
}

class LevelData {
  const LevelData({
    required this.id,
    required this.layout,
    required this.palette,
    required this.objective,
    this.goal = const LevelGoal(LevelGoalType.reachExit),
    this.itemLegend = const {},
    this.boneboxDrops = const {},
    this.monomatStock = const [],
    this.waves = const [],
    this.ammoStart = 0,
  });

  /// Matches [LevelInfo.id] in the catalog.
  final String id;
  final List<String> layout;
  final LevelPalette palette;

  /// One-line objective shown in the HUD.
  final String objective;
  final LevelGoal goal;

  /// tile char -> item id (or `module:<levelId>`), for loose item/weapon
  /// spawns.
  final Map<String, String> itemLegend;

  /// char -> item id (or `module:<levelId>`) dropped by the bonebox tile `b`.
  /// Bonebox chars may be `b` or any char mapped here.
  final Map<String, String> boneboxDrops;

  final List<MonomatOffer> monomatStock;
  final List<WaveSpec> waves;

  /// Rounds of loose ammunition the player starts with (monomat tender).
  final int ammoStart;

  int get width => layout.first.length;
  int get height => layout.length;
}
