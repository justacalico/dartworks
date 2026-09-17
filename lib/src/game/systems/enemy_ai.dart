import '../../data/enemies.dart';

/// Per-tick movement intent for an enemy, computed from the enemy's own
/// state and the player's position. Pure functions so behaviours are
/// fully unit-testable.
class EnemyIntent {
  const EnemyIntent({
    this.moveX = 0,
    this.moveY = 0,
    this.jump = false,
    this.attack = false,
    this.shoot = false,
  });

  final double moveX;
  final double moveY;
  final bool jump;
  final bool attack;
  final bool shoot;
}

/// [distX]/[distY] are the signed vector from enemy to player.
/// [cooldown] is seconds until the enemy may attack again.
/// [rng] supplies jitter for erratic types; pass a value in 0..1.
EnemyIntent decideIntent(
  EnemyDef def, {
  required double distX,
  required double distY,
  required double cooldown,
  double rng = 0.5,
}) {
  final dist = (distX.abs() + distY.abs());
  final ready = cooldown <= 0;

  return switch (def.behavior) {
    EnemyBehavior.meleeChaser => EnemyIntent(
        moveX: distX.sign,
        jump: distY < -1.5 && distX.abs() < 4,
        attack: ready && distX.abs() < def.attackRange && distY.abs() < 1.2,
      ),
    EnemyBehavior.jumper => EnemyIntent(
        moveX: distX.sign * 0.4,
        jump: ready && dist < 6,
        attack: ready && distX.abs() < def.attackRange && distY.abs() < 1.5,
      ),
    EnemyBehavior.flyer => EnemyIntent(
        // hold ~6u distance horizontally, match height loosely
        moveX: distX.abs() > 7 ? distX.sign : (distX.abs() < 5 ? -distX.sign : 0),
        moveY: distY.abs() > 1.5 ? distY.sign * 0.6 : 0,
        shoot: ready && dist < def.attackRange,
      ),
    EnemyBehavior.thrower => EnemyIntent(
        moveX: distX.abs() < 3 ? -distX.sign : 0,
        shoot: ready && dist < def.attackRange,
      ),
    EnemyBehavior.turret => EnemyIntent(
        shoot: ready && dist < def.attackRange && distY.abs() < 4,
      ),
    EnemyBehavior.boss => EnemyIntent(
        moveX: distX.sign,
        jump: distY < -2 && distX.abs() < 5,
        attack: ready && distX.abs() < def.attackRange && distY.abs() < 1.5,
      ),
  };
}
