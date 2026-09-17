/// Item definitions for every prop, weapon and gadget in the game.
/// Stats tuned for the 2D sandbox; ids match save data keys.
enum ItemCategory { melee, gun, gadget, prop, quest }

class ItemDef {
  const ItemDef({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    this.damage = 0,
    this.fireRate = 0,
    this.magSize = 0,
    this.mass = 1,
    this.sizeX = 0.6,
    this.sizeY = 0.2,
    this.price = 0,
    this.knockback = 0,
  });

  final String id;
  final String name;
  final ItemCategory category;

  /// ARGB int to keep this file framework-free; converted to Color at render.
  final int color;

  /// Melee damage per hit, or bullet damage per shot.
  final double damage;

  /// Shots per second for guns; swings per second for melee.
  final double fireRate;

  /// Rounds per magazine. 0 = not applicable / infinite.
  final int magSize;

  /// Physics mass in kg-ish units.
  final double mass;
  final double sizeX;
  final double sizeY;

  /// Monomat price in rounds of ammunition.
  final int price;

  /// Impulse applied to whatever is hit.
  final double knockback;

  bool get isGun => category == ItemCategory.gun;
  bool get isMelee => category == ItemCategory.melee;
  bool get isWeapon => isGun || isMelee;
  bool get isHoldable =>
      category != ItemCategory.quest; // quest items grab automatically
}

ItemDef? itemById(String id) => kItems[id];

/// The full reclaimable arsenal, mirroring the BONEWORKS item roster.
const Map<String, ItemDef> kItems = {
  // -- Guns ---------------------------------------------------------------
  'p350': ItemDef(
    id: 'p350', name: 'P350', category: ItemCategory.gun, color: 0xFF4DE8FF,
    damage: 34, fireRate: 3, magSize: 15, mass: 1.2, price: 60,
  ),
  'm1911': ItemDef(
    id: 'm1911', name: '1911', category: ItemCategory.gun, color: 0xFF9B94B8,
    damage: 40, fireRate: 2.5, magSize: 8, mass: 1.1, price: 50,
  ),
  'eder22': ItemDef(
    id: 'eder22', name: 'EDER 22', category: ItemCategory.gun,
    color: 0xFFB44DFF, damage: 12, fireRate: 12, magSize: 24, mass: 1.4,
    price: 120,
  ),
  'uzi': ItemDef(
    id: 'uzi', name: 'UZI', category: ItemCategory.gun, color: 0xFFEDEBF5,
    damage: 10, fireRate: 14, magSize: 32, mass: 2.0, price: 140,
  ),
  'mp5': ItemDef(
    id: 'mp5', name: 'MP5', category: ItemCategory.gun, color: 0xFFEDEBF5,
    damage: 14, fireRate: 11, magSize: 30, mass: 2.6, price: 160,
  ),
  'mp5k': ItemDef(
    id: 'mp5k', name: 'MP5K', category: ItemCategory.gun, color: 0xFFEDEBF5,
    damage: 13, fireRate: 13, magSize: 25, mass: 2.2, price: 150,
  ),
  'm16': ItemDef(
    id: 'm16', name: 'M16', category: ItemCategory.gun, color: 0xFF7CFF6B,
    damage: 22, fireRate: 8, magSize: 30, mass: 3.4, price: 220,
  ),
  'mk18': ItemDef(
    id: 'mk18', name: 'MK18', category: ItemCategory.gun, color: 0xFF7CFF6B,
    damage: 24, fireRate: 9, magSize: 30, mass: 3.2, price: 240,
  ),
  'stapler': ItemDef(
    id: 'stapler', name: 'STAPLER', category: ItemCategory.gun,
    color: 0xFFF2C230, damage: 8, fireRate: 6, magSize: 40, mass: 0.6,
    price: 30,
  ),
  'nimbus_gun': ItemDef(
    id: 'nimbus_gun', name: 'NIMBUS GUN', category: ItemCategory.gun,
    color: 0xFF4DE8FF, damage: 5, fireRate: 4, magSize: 20, mass: 2.8,
    knockback: 26, price: 200,
  ),
  'balloon_gun': ItemDef(
    id: 'balloon_gun', name: 'BALLOON GUN', category: ItemCategory.gun,
    color: 0xFFFF4D5E, damage: 0, fireRate: 2, magSize: 12, mass: 1.8,
    knockback: -14, price: 180,
  ),
  'board_gun': ItemDef(
    id: 'board_gun', name: 'BOARD GUN', category: ItemCategory.gun,
    color: 0xFFC98A3D, damage: 6, fireRate: 4, magSize: 20, mass: 2.4,
    price: 0,
  ),
  'utility_gun': ItemDef(
    id: 'utility_gun', name: 'UTILITY GUN', category: ItemCategory.gadget,
    color: 0xFFB44DFF, mass: 2.0, knockback: 18, price: 0,
  ),
  'dev_manipulator': ItemDef(
    id: 'dev_manipulator', name: 'DEV MANIPULATOR',
    category: ItemCategory.gadget, color: 0xFF7CFF6B, mass: 1.5,
    knockback: 30,
  ),
  'gravity_staff': ItemDef(
    id: 'gravity_staff', name: 'GRAVITY STAFF', category: ItemCategory.melee,
    color: 0xFF7CFF6B, damage: 30, fireRate: 1.6, mass: 2.4, sizeX: 1.4,
    knockback: 22,
  ),

  // -- Melee --------------------------------------------------------------
  'crowbar': ItemDef(
    id: 'crowbar', name: 'CROWBAR', category: ItemCategory.melee,
    color: 0xFFFF4D5E, damage: 18, fireRate: 2.4, mass: 2.4, sizeX: 0.9,
  ),
  'baton': ItemDef(
    id: 'baton', name: 'BATON', category: ItemCategory.melee,
    color: 0xFF9B94B8, damage: 10, fireRate: 3.2, mass: 1.0, sizeX: 0.7,
  ),
  'frying_pan': ItemDef(
    id: 'frying_pan', name: 'FRYING PAN', category: ItemCategory.melee,
    color: 0xFF5E5878, damage: 8, fireRate: 3.0, mass: 1.4, sizeX: 0.7,
  ),
  'noodledog': ItemDef(
    id: 'noodledog', name: 'NOODLEDOG', category: ItemCategory.melee,
    color: 0xFFF2C230, damage: 4, fireRate: 4.0, mass: 0.5, sizeX: 0.8,
  ),
  'sledgehammer': ItemDef(
    id: 'sledgehammer', name: 'SLEDGEHAMMER', category: ItemCategory.melee,
    color: 0xFFC98A3D, damage: 40, fireRate: 1.1, mass: 6.0, sizeX: 1.1,
    knockback: 16,
  ),
  'combat_knife': ItemDef(
    id: 'combat_knife', name: 'COMBAT KNIFE', category: ItemCategory.melee,
    color: 0xFFEDEBF5, damage: 22, fireRate: 3.4, mass: 0.4, sizeX: 0.5,
  ),
  'cleaver': ItemDef(
    id: 'cleaver', name: 'CLEAVER', category: ItemCategory.melee,
    color: 0xFFEDEBF5, damage: 20, fireRate: 2.6, mass: 0.9, sizeX: 0.6,
  ),
  'knife': ItemDef(
    id: 'knife', name: 'KNIFE', category: ItemCategory.melee,
    color: 0xFF9B94B8, damage: 15, fireRate: 3.6, mass: 0.3, sizeX: 0.45,
  ),
  'machete': ItemDef(
    id: 'machete', name: 'MACHETE', category: ItemCategory.melee,
    color: 0xFF7CFF6B, damage: 26, fireRate: 2.4, mass: 1.2, sizeX: 0.9,
  ),
  'katana': ItemDef(
    id: 'katana', name: 'KATANA', category: ItemCategory.melee,
    color: 0xFF4DE8FF, damage: 35, fireRate: 2.6, mass: 1.1, sizeX: 1.1,
  ),
  'half_sword': ItemDef(
    id: 'half_sword', name: 'HALF SWORD', category: ItemCategory.melee,
    color: 0xFFEDEBF5, damage: 24, fireRate: 2.6, mass: 1.0, sizeX: 0.8,
  ),
  'bastard_sword': ItemDef(
    id: 'bastard_sword', name: 'BASTARD SWORD', category: ItemCategory.melee,
    color: 0xFFEDEBF5, damage: 38, fireRate: 1.7, mass: 2.2, sizeX: 1.3,
  ),
  'claymore': ItemDef(
    id: 'claymore', name: 'CLAYMORE', category: ItemCategory.melee,
    color: 0xFFB44DFF, damage: 45, fireRate: 1.3, mass: 2.8, sizeX: 1.5,
  ),
  'hatchet': ItemDef(
    id: 'hatchet', name: 'HATCHET', category: ItemCategory.melee,
    color: 0xFFC98A3D, damage: 20, fireRate: 2.6, mass: 1.1, sizeX: 0.6,
  ),
  'firefighter_axe': ItemDef(
    id: 'firefighter_axe', name: 'FIREFIGHTER AXE', category: ItemCategory.melee,
    color: 0xFFFF4D5E, damage: 28, fireRate: 1.9, mass: 2.6, sizeX: 1.0,
  ),
  'norse_axe': ItemDef(
    id: 'norse_axe', name: 'NORSE AXE', category: ItemCategory.melee,
    color: 0xFF9B94B8, damage: 30, fireRate: 1.8, mass: 2.4, sizeX: 1.0,
  ),
  'double_axe': ItemDef(
    id: 'double_axe', name: 'DOUBLE AXE', category: ItemCategory.melee,
    color: 0xFFB44DFF, damage: 36, fireRate: 1.5, mass: 3.0, sizeX: 1.2,
  ),
  'katar': ItemDef(
    id: 'katar', name: 'KATAR', category: ItemCategory.melee,
    color: 0xFFF2C230, damage: 18, fireRate: 3.2, mass: 0.6, sizeX: 0.5,
  ),
  'kunai': ItemDef(
    id: 'kunai', name: 'KUNAI', category: ItemCategory.melee,
    color: 0xFFEDEBF5, damage: 12, fireRate: 4.2, mass: 0.25, sizeX: 0.4,
  ),
  'spiked_club': ItemDef(
    id: 'spiked_club', name: 'SPIKED CLUB', category: ItemCategory.melee,
    color: 0xFFC98A3D, damage: 26, fireRate: 2.0, mass: 2.0, sizeX: 0.9,
  ),
  'polearm_spear': ItemDef(
    id: 'polearm_spear', name: 'POLEARM SPEAR', category: ItemCategory.melee,
    color: 0xFFEDEBF5, damage: 32, fireRate: 1.8, mass: 2.4, sizeX: 1.6,
  ),

  // -- Props --------------------------------------------------------------
  'crate': ItemDef(
    id: 'crate', name: 'CRATE', category: ItemCategory.prop,
    color: 0xFF8A6B40, mass: 4.0, sizeX: 0.9, sizeY: 0.9,
  ),
  'barrel': ItemDef(
    id: 'barrel', name: 'BARREL', category: ItemCategory.prop,
    color: 0xFF5B2BBF, mass: 5.0, sizeX: 0.7, sizeY: 1.0,
  ),
  'basketball': ItemDef(
    id: 'basketball', name: 'BASKETBALL', category: ItemCategory.prop,
    color: 0xFFC98A3D, mass: 0.6, sizeX: 0.5, sizeY: 0.5,
  ),
  'cinderblock': ItemDef(
    id: 'cinderblock', name: 'CINDERBLOCK', category: ItemCategory.prop,
    color: 0xFF9B94B8, mass: 8.0, sizeX: 0.7, sizeY: 0.4,
  ),
  'cardboard_box': ItemDef(
    id: 'cardboard_box', name: 'CARDBOARD BOX', category: ItemCategory.prop,
    color: 0xFFC98A3D, mass: 0.8, sizeX: 0.7, sizeY: 0.7,
  ),
  'monitor': ItemDef(
    id: 'monitor', name: 'MONITOR', category: ItemCategory.prop,
    color: 0xFF2E2840, mass: 3.0, sizeX: 0.7, sizeY: 0.5,
  ),
  'tray': ItemDef(
    id: 'tray', name: 'TRAY', category: ItemCategory.prop,
    color: 0xFF9B94B8, mass: 0.4, sizeX: 0.6, sizeY: 0.1,
  ),
  'takeaway_cup': ItemDef(
    id: 'takeaway_cup', name: 'TAKEAWAY CUP', category: ItemCategory.prop,
    color: 0xFFEDEBF5, mass: 0.1, sizeX: 0.2, sizeY: 0.3,
  ),
  'melon': ItemDef(
    id: 'melon', name: 'MELON BELLY', category: ItemCategory.prop,
    color: 0xFF7CFF6B, mass: 2.0, sizeX: 0.4, sizeY: 0.4,
  ),
  'plank': ItemDef(
    id: 'plank', name: 'PLANK', category: ItemCategory.prop,
    color: 0xFFC98A3D, mass: 1.5, sizeX: 1.2, sizeY: 0.12,
  ),
  'bonebox': ItemDef(
    id: 'bonebox', name: 'BONEBOX', category: ItemCategory.prop,
    color: 0xFFEDEBF5, mass: 1.6, sizeX: 0.7, sizeY: 0.7,
  ),
  'clipboard': ItemDef(
    id: 'clipboard', name: 'CLIPBOARD', category: ItemCategory.prop,
    color: 0xFFC98A3D, mass: 0.3, sizeX: 0.4, sizeY: 0.5,
  ),
  'flashlight': ItemDef(
    id: 'flashlight', name: 'FLASHLIGHT', category: ItemCategory.gadget,
    color: 0xFFF2C230, mass: 0.4, sizeX: 0.4, sizeY: 0.15,
  ),
  'gravity_cup': ItemDef(
    id: 'gravity_cup', name: 'GRAVITY CUP', category: ItemCategory.gadget,
    color: 0xFFB44DFF, mass: 0.5, sizeX: 0.3, sizeY: 0.3,
  ),
  'slow_time': ItemDef(
    id: 'slow_time', name: 'SLOW TIME DEVICE', category: ItemCategory.gadget,
    color: 0xFF4DE8FF, mass: 0.4, sizeX: 0.3, sizeY: 0.3,
  ),

  // -- Quest items --------------------------------------------------------
  'keycard': ItemDef(
    id: 'keycard', name: 'KEYCARD', category: ItemCategory.quest,
    color: 0xFFF2C230, mass: 0.1, sizeX: 0.3, sizeY: 0.2,
  ),
  'battery': ItemDef(
    id: 'battery', name: 'BATTERY', category: ItemCategory.quest,
    color: 0xFF7CFF6B, mass: 2.0, sizeX: 0.4, sizeY: 0.5,
  ),
  'energy_core': ItemDef(
    id: 'energy_core', name: 'ENERGY CORE', category: ItemCategory.quest,
    color: 0xFF4DE8FF, mass: 3.0, sizeX: 0.5, sizeY: 0.5,
  ),
  'gachapon': ItemDef(
    id: 'gachapon', name: 'GACHAPON', category: ItemCategory.quest,
    color: 0xFFB44DFF, mass: 0.5, sizeX: 0.4, sizeY: 0.4,
  ),
  'module': ItemDef(
    id: 'module', name: 'SANDBOX MODULE', category: ItemCategory.quest,
    color: 0xFFF2C230, mass: 0.8, sizeX: 0.5, sizeY: 0.4,
  ),
  'crown': ItemDef(
    id: 'crown', name: 'THE CROWN', category: ItemCategory.quest,
    color: 0xFFF2C230, mass: 0.6, sizeX: 0.4, sizeY: 0.3,
  ),
};
