import '../../data/level_data.dart';
import '../../data/enemies.dart';

/// Tracks `surviveRounds` progress: which wave is active, which enemies
/// from it are still up, and when the next one spawns. Pure state —
/// the game calls [update] each tick and [enemyDown] on deaths.
class WaveManager {
  WaveManager(this.waves);

  final List<WaveSpec> waves;

  int currentWave = 0;
  int alive = 0;
  double spawnDelay = 2.0;
  bool finished = false;

  /// Enemies to spawn right now, or null if nothing due.
  List<String>? update(double dt) {
    if (finished || waves.isEmpty) return null;
    if (alive > 0) return null;
    spawnDelay -= dt;
    if (spawnDelay > 0) return null;
    if (currentWave >= waves.length) {
      finished = true;
      return null;
    }
    final spec = waves[currentWave];
    final ids = <String>[];
    spec.enemies.forEach((id, count) {
      if (kEnemies.containsKey(id)) {
        for (var i = 0; i < count; i++) {
          ids.add(id);
        }
      }
    });
    alive = ids.length;
    currentWave++;
    spawnDelay = 3.0;
    return ids;
  }

  void enemyDown() {
    if (alive > 0) alive--;
  }

  /// Whether the just-cleared wave was the last one.
  bool get allCleared => finished || (currentWave >= waves.length && alive <= 0);
}
