import 'level_info.dart';

/// The full level roster, mirroring the BONEWORKS campaign order and its
/// sandbox unlock chain. Every entry here has a matching layout in
/// `data/levels/`.
const List<LevelInfo> kCatalog = [
  // -- Campaign -----------------------------------------------------------
  LevelInfo(
    id: 'breakroom',
    title: 'BREAKROOM',
    subtitle: 'Sort the anomalous objects. Just another day at Monogon.',
    kind: LevelKind.campaign,
    order: 0,
  ),
  LevelInfo(
    id: 'museum',
    title: 'MUSEUM OF TECHNICAL DEMONSTRATION',
    subtitle: 'Orientation for new MythOS users. Mind the exhibits.',
    kind: LevelKind.campaign,
    order: 1,
  ),
  LevelInfo(
    id: 'streets',
    title: 'STREETS',
    subtitle: 'MythOS City in lockdown. The nullmen are awake.',
    kind: LevelKind.campaign,
    order: 2,
  ),
  LevelInfo(
    id: 'runoff',
    title: 'RUNOFF',
    subtitle: 'Drainage works beneath the city. Something shambles ahead.',
    kind: LevelKind.campaign,
    order: 3,
  ),
  LevelInfo(
    id: 'sewers',
    title: 'SEWERS',
    subtitle: 'Pitch dark maintenance tunnels. Bring a light.',
    kind: LevelKind.campaign,
    order: 4,
  ),
  LevelInfo(
    id: 'warehouse',
    title: 'WAREHOUSE 4B',
    subtitle: 'Shipping systems. The crablets got in.',
    kind: LevelKind.campaign,
    order: 5,
  ),
  LevelInfo(
    id: 'central_station',
    title: 'CENTRAL STATION',
    subtitle: 'Subway lines to the heart of the city.',
    kind: LevelKind.campaign,
    order: 6,
  ),
  LevelInfo(
    id: 'tower',
    title: 'TOWER',
    subtitle: 'Ascend the plazas. Zombish and Omnis war in the halls.',
    kind: LevelKind.campaign,
    order: 7,
  ),
  LevelInfo(
    id: 'time_tower',
    title: 'TIME TOWER',
    subtitle: 'Repair the System Clock. Break the world.',
    kind: LevelKind.campaign,
    order: 8,
  ),
  LevelInfo(
    id: 'dungeon',
    title: 'DUNGEON',
    subtitle: 'Fantasy Land gaol. The Fords are waiting.',
    kind: LevelKind.campaign,
    order: 9,
  ),
  LevelInfo(
    id: 'arena',
    title: 'ARENA',
    subtitle: 'Prove yourself. The King is watching.',
    kind: LevelKind.campaign,
    order: 10,
  ),
  LevelInfo(
    id: 'throne_room',
    title: 'THRONE ROOM',
    subtitle: 'Take the crown. Reach Chamber 02.',
    kind: LevelKind.campaign,
    order: 11,
  ),

  // -- Sandbox ------------------------------------------------------------
  LevelInfo(
    id: 'museum_basement',
    title: 'MUSEUM BASEMENT',
    subtitle: 'Grey chambers and gym shapes. Sandbox 101.',
    kind: LevelKind.sandbox,
    order: 0,
    unlockHint: 'Reclaim the module in the Museum reclamation exhibit.',
  ),
  LevelInfo(
    id: 'blankbox',
    title: 'BLANKBOX',
    subtitle: 'An empty chamber for pushing physics to its limit.',
    kind: LevelKind.sandbox,
    order: 1,
    unlockHint: 'Find the hidden room in the Museum. Push the wrong panel.',
  ),
  LevelInfo(
    id: 'redacted_chamber',
    title: '[REDACTED] CHAMBER',
    subtitle: 'Cut content. The bulkhead wants three targets down at once.',
    kind: LevelKind.sandbox,
    order: 2,
    unlockHint: 'Reclaim the [REDACTED] module in the Museum.',
  ),
  LevelInfo(
    id: 'handgun_range',
    title: 'HANDGUN RANGE',
    subtitle: 'Time trials and the P350. Beat the course.',
    kind: LevelKind.sandbox,
    order: 3,
    unlockHint: 'Reclaim the module inside the [REDACTED] Chamber.',
  ),
  LevelInfo(
    id: 'tuscany',
    title: 'TUSCANY',
    subtitle: 'A villa from another headset\'s demo reel.',
    kind: LevelKind.sandbox,
    order: 4,
    unlockHint: 'Finish the Handgun Range course and reclaim the module.',
  ),
  LevelInfo(
    id: 'zombie_warehouse',
    title: 'ZOMBIE WAREHOUSE',
    subtitle: 'Board the windows. Hold the line.',
    kind: LevelKind.sandbox,
    order: 5,
    unlockHint: 'A labelled locker in the main menu hides the module.',
  ),
  LevelInfo(
    id: 'fantasy_arena',
    title: 'FANTASY ARENA',
    subtitle: 'The pit, reopened for a new king.',
    kind: LevelKind.sandbox,
    order: 6,
    unlockHint: 'Complete the campaign.',
  ),
];

LevelInfo? levelById(String id) {
  for (final level in kCatalog) {
    if (level.id == id) return level;
  }
  return null;
}

List<LevelInfo> get campaignLevels =>
    kCatalog.where((l) => l.kind == LevelKind.campaign).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

List<LevelInfo> get sandboxLevels =>
    kCatalog.where((l) => l.kind == LevelKind.sandbox).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
