import '../../data/level_data.dart';

/// Tracks progress toward a level's goal. Pure state machine - the game
/// feeds it events (item sorted, core loaded, wave cleared, boss down)
/// and reads whether the exit may open.
class GoalTracker {
  GoalTracker(this.goal);

  final LevelGoal goal;

  int progress = 0;
  bool get isComplete => switch (goal.type) {
        LevelGoalType.reachExit => true,
        LevelGoalType.bossFight => progress >= 1,
        _ => progress >= goal.count,
      };

  /// Human-readable progress like `CORES 2/4`.
  String describe() => switch (goal.type) {
        LevelGoalType.reachExit => 'REACH THE EXIT',
        LevelGoalType.sortItems => 'ARCHIVED $progress/${goal.count}',
        LevelGoalType.clearEnemies =>
          'HOSTILES LEFT ${goal.count - progress}',
        LevelGoalType.surviveRounds => 'ROUND $progress/${goal.count}',
        LevelGoalType.timeTrial =>
          'TARGETS $progress/${goal.count}',
        LevelGoalType.repairCore => 'CORES $progress/${goal.count}',
        LevelGoalType.bossFight =>
          progress >= 1 ? 'KING DEFEATED' : 'DEFEAT THE KING',
      };

  void itemSorted() => progress++;
  void coreLoaded() => progress++;
  void targetHit() => progress++;
  void enemyKilled() => progress++;
  void waveCleared() => progress++;
  void bossDefeated() => progress = 1;
}
