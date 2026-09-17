import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../data/items.dart';
import 'components/monomat.dart';
import 'systems/monomat_economy.dart';

/// Snapshot the HUD overlay renders each frame. The game mutates it;
/// widgets listen.
class HudState extends ChangeNotifier {
  double hp = 100;
  double maxHp = 100;
  int slotAmmo = 0;
  ItemDef? slotItem;
  int activeSlot = 0;
  ItemDef? slot0Item;
  ItemDef? slot1Item;
  int looseAmmo = 0;
  int keycards = 0;
  double slowCharge = 1;
  String objective = '';
  bool objectiveDone = false;
  bool slowmoActive = false;

  /// Set while the player stands at a monomat; cleared when they leave.
  MonomatZone? _openMonomat;
  MonomatZone? get openMonomat => _openMonomat;
  set openMonomat(MonomatZone? v) {
    if (v == _openMonomat) return;
    _openMonomat = v;
    _safeNotify();
  }

  String? _toast;
  double _toastTtl = 0;
  String? get toast => _toastTtl > 0 ? _toast : null;

  void showToast(String message, {double seconds = 2.6}) {
    _toast = message;
    _toastTtl = seconds;
    _safeNotify();
  }

  void tick(double dt) {
    if (_toastTtl > 0) {
      _toastTtl -= dt;
      if (_toastTtl <= 0) _safeNotify();
    }
  }

  void setObjective(String text, {required bool done}) {
    if (text == objective && done == objectiveDone) return;
    objective = text;
    objectiveDone = done;
    _safeNotify();
  }

  void refresh() => _safeNotify();

  /// GameWidget can drive update() from inside its own LayoutBuilder, so a
  /// plain notifyListeners() can land mid-build and trip markNeedsBuild.
  void _safeNotify() {
    SchedulerBinding? binding;
    try {
      binding = SchedulerBinding.instance;
    } catch (_) {}
    final phase = binding?.schedulerPhase;
    if (binding == null ||
        phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.transientCallbacks) {
      notifyListeners();
      return;
    }
    binding.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }
}

/// One row in the monomat popup.
class MonomatRow {
  const MonomatRow({required this.item, required this.price, required this.sold});
  final ItemDef item;
  final int price;
  final bool sold;
}

List<MonomatRow> monomatRows(MonomatStock stock) => [
      for (var i = 0; i < stock.offers.length; i++)
        if (stock.itemOf(i) != null)
          MonomatRow(
            item: stock.itemOf(i)!,
            price: stock.offers[i].price,
            sold: stock.isSold(i),
          ),
    ];
