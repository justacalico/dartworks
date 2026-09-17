import '../../data/items.dart';
import '../../data/level_data.dart';

/// Monomat economy: items are priced in rounds of ammunition.
/// Pure logic - the Monomat component mirrors this state.
class MonomatStock {
  MonomatStock(List<MonomatOffer> offers)
      : offers = List.unmodifiable(offers);

  final List<MonomatOffer> offers;

  /// Item ids already dispensed. Monomats sell one of each.
  final Set<String> sold = {};

  ItemDef? itemOf(int index) =>
      index >= 0 && index < offers.length ? kItems[offers[index].itemId] : null;

  bool isSold(int index) => sold.contains(offers[index].itemId);

  bool canAfford(int index, int ammo) =>
      !isSold(index) && ammo >= offers[index].price;

  /// Attempts a purchase. Returns the bought item id or null.
  String? buy(int index, int ammo) {
    if (index < 0 || index >= offers.length || !canAfford(index, ammo)) {
      return null;
    }
    final offer = offers[index];
    sold.add(offer.itemId);
    return offer.itemId;
  }
}
