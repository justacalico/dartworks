import '../../data/items.dart';

/// A holstered weapon plus its remaining magazine.
class InventorySlot {
  InventorySlot(this.item, {int? ammo}) : ammo = ammo ?? item.magSize;

  final ItemDef item;
  int ammo;
}

/// Two weapon holsters plus loose ammunition (monomat tender).
class Inventory {
  final List<InventorySlot?> slots = [null, null];
  int activeSlot = 0;
  int looseAmmo = 0;
  int keycards = 0;

  InventorySlot? get active => slots[activeSlot];

  /// Stores an item in the first free slot, or the active one.
  /// Returns false if the item cannot be held.
  bool store(ItemDef item) {
    if (!item.isHoldable) return false;
    final index = slots[0] == null
        ? 0
        : slots[1] == null
            ? 1
            : activeSlot;
    slots[index] = InventorySlot(item);
    return true;
  }

  void select(int index) {
    if (index >= 0 && index < slots.length) activeSlot = index;
  }

  /// Drops the active slot's item, returning it for respawning.
  ItemDef? dropActive() {
    final item = slots[activeSlot]?.item;
    slots[activeSlot] = null;
    return item;
  }

  bool spendRounds(int n) {
    final slot = active;
    if (slot == null || slot.ammo < n) return false;
    slot.ammo -= n;
    return true;
  }

  /// Merges a spent weapon's magazine into loose ammo, e.g. when the
  /// physical gun is lost or holstered.
  void salvageActive() {
    final slot = slots[activeSlot];
    if (slot != null) looseAmmo += slot.ammo;
    slots[activeSlot] = null;
  }
}
