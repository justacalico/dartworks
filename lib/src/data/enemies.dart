/// Enemy definitions mirroring the BONEWORKS roster.
enum EnemyBehavior {
  /// Walks toward the player and swings. Nullbodies, clones, zombish.
  meleeChaser,

  /// Leaps at the player's head. Crablets.
  jumper,

  /// Hovers and fires bolts. Omniprojectors.
  flyer,

  /// Stays back and hurls props. Zombish thrower.
  thrower,

  /// Fixed in place, fires on sight. Turret V4.
  turret,

  /// Boss: heavy melee plus a grabbable crown. King Ford.
  boss,
}

class EnemyDef {
  const EnemyDef({
    required this.id,
    required this.name,
    required this.behavior,
    required this.color,
    required this.hp,
    required this.speed,
    required this.damage,
    this.sizeX = 0.7,
    this.sizeY = 1.7,
    this.attackRange = 1.4,
    this.attackCooldown = 1.0,
    this.boltDamage = 0,
    this.boltSpeed = 0,
  });

  final String id;
  final String name;
  final EnemyBehavior behavior;

  /// ARGB int; converted to Color at render.
  final int color;

  final double hp;
  final double speed;
  final double damage;
  final double sizeX;
  final double sizeY;

  /// Distance at which melee attacks land / flyers start shooting.
  final double attackRange;
  final double attackCooldown;

  /// Ranged stats for flyers, throwers and turrets.
  final double boltDamage;
  final double boltSpeed;
}

EnemyDef? enemyById(String id) => kEnemies[id];

const Map<String, EnemyDef> kEnemies = {
  'nullbody': EnemyDef(
    id: 'nullbody', name: 'NULLBODY', behavior: EnemyBehavior.meleeChaser,
    color: 0xFFFF8C3B, hp: 30, speed: 2.4, damage: 8,
  ),
  'corrupted_nullbody': EnemyDef(
    id: 'corrupted_nullbody', name: 'CORRUPTED NULLBODY',
    behavior: EnemyBehavior.meleeChaser, color: 0xFF5B2BBF, hp: 60,
    speed: 1.9, damage: 14,
  ),
  'nullrat': EnemyDef(
    id: 'nullrat', name: 'NULLRAT', behavior: EnemyBehavior.meleeChaser,
    color: 0xFFFF8C3B, hp: 8, speed: 4.2, damage: 3, sizeX: 0.5,
    sizeY: 0.4, attackRange: 0.8, attackCooldown: 0.6,
  ),
  'crablet': EnemyDef(
    id: 'crablet', name: 'CRABLET', behavior: EnemyBehavior.jumper,
    color: 0xFFD8D4E8, hp: 15, speed: 3.0, damage: 6, sizeX: 0.5,
    sizeY: 0.45, attackRange: 1.0, attackCooldown: 1.4,
  ),
  'crablet_plus': EnemyDef(
    id: 'crablet_plus', name: 'CRABLET PLUS', behavior: EnemyBehavior.jumper,
    color: 0xFFB44DFF, hp: 35, speed: 3.4, damage: 12, sizeX: 0.7,
    sizeY: 0.6, attackRange: 1.2, attackCooldown: 1.2,
  ),
  'zombish': EnemyDef(
    id: 'zombish', name: 'ZOMBISH', behavior: EnemyBehavior.meleeChaser,
    color: 0xFF7CFF6B, hp: 40, speed: 1.5, damage: 12,
    attackCooldown: 1.3,
  ),
  'zombish_thrower': EnemyDef(
    id: 'zombish_thrower', name: 'ZOMBISH THROWER',
    behavior: EnemyBehavior.thrower, color: 0xFF9BCB3B, hp: 35,
    speed: 1.2, damage: 10, attackRange: 7.0, attackCooldown: 2.2,
    boltDamage: 8, boltSpeed: 9,
  ),
  'super_zombish': EnemyDef(
    id: 'super_zombish', name: 'SUPER ZOMBISH',
    behavior: EnemyBehavior.meleeChaser, color: 0xFF4D9B3B, hp: 80,
    speed: 1.7, damage: 20, sizeX: 0.9, sizeY: 2.0,
    attackCooldown: 1.6,
  ),
  'junkie_zombish': EnemyDef(
    id: 'junkie_zombish', name: 'JUNKIE ZOMBISH',
    behavior: EnemyBehavior.meleeChaser, color: 0xFFC9FF3B, hp: 30,
    speed: 3.6, damage: 8, attackRange: 1.2, attackCooldown: 0.7,
  ),
  'omniprojector': EnemyDef(
    id: 'omniprojector', name: 'OMNIPROJECTOR',
    behavior: EnemyBehavior.flyer, color: 0xFF4DE8FF, hp: 50, speed: 2.8,
    damage: 0, attackRange: 8.0, attackCooldown: 1.8, boltDamage: 10,
    boltSpeed: 14,
  ),
  'turret': EnemyDef(
    id: 'turret', name: 'TURRET V4', behavior: EnemyBehavior.turret,
    color: 0xFFFF4D5E, hp: 60, speed: 0, damage: 0, sizeX: 0.8,
    sizeY: 0.9, attackRange: 9.0, attackCooldown: 0.9, boltDamage: 8,
    boltSpeed: 18,
  ),
  'ford_clone': EnemyDef(
    id: 'ford_clone', name: 'FORD CLONE', behavior: EnemyBehavior.meleeChaser,
    color: 0xFFEDEBF5, hp: 40, speed: 2.6, damage: 10,
  ),
  'king_ford': EnemyDef(
    id: 'king_ford', name: 'KING FORD', behavior: EnemyBehavior.boss,
    color: 0xFFF2C230, hp: 300, speed: 2.8, damage: 25, sizeX: 0.9,
    sizeY: 2.0, attackRange: 1.8, attackCooldown: 1.2,
  ),
};
