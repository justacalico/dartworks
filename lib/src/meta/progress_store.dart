import 'package:shared_preferences/shared_preferences.dart';

import '../data/catalog.dart';
import '../data/level_info.dart';

/// Tracks unlocks, completions, collected notes and reclaimed items.
/// Campaign levels unlock sequentially; sandbox levels unlock when their
/// module is reclaimed. `fantasy_arena` unlocks when the campaign is done.
abstract class ProgressStore {
  bool isLevelUnlocked(String levelId);
  bool isLevelComplete(String levelId);
  bool hasNote(String noteId);
  bool isReclaimed(String itemId);

  Set<String> get foundNotes;
  Set<String> get reclaimedItems;

  Future<void> unlockLevel(String levelId);
  Future<void> completeLevel(String levelId);
  Future<void> addNote(String noteId);
  Future<void> reclaimItem(String itemId);
  Future<void> reset();
}

class SharedPrefsProgressStore extends ProgressStore {
  SharedPrefsProgressStore(this._prefs);

  final SharedPreferences _prefs;

  static const _kUnlocked = 'dw.unlocked';
  static const _kCompleted = 'dw.completed';
  static const _kNotes = 'dw.notes';
  static const _kReclaimed = 'dw.reclaimed';

  Set<String> _read(String key) =>
      (_prefs.getStringList(key) ?? const <String>[]).toSet();

  Future<void> _write(String key, Set<String> values) =>
      _prefs.setStringList(key, values.toList()..sort());

  Set<String> get _unlocked => _read(_kUnlocked);
  Set<String> get _completed => _read(_kCompleted);

  @override
  bool isLevelUnlocked(String levelId) {
    final info = levelById(levelId);
    if (info == null) return false;
    if (info.kind == LevelKind.campaign) {
      if (info.order == 0) return true;
      final previous = campaignLevels[info.order - 1];
      return _completed.contains(previous.id);
    }
    if (levelId == 'fantasy_arena') {
      return campaignLevels.every((l) => _completed.contains(l.id));
    }
    return _unlocked.contains(levelId);
  }

  @override
  bool isLevelComplete(String levelId) => _completed.contains(levelId);

  @override
  bool hasNote(String noteId) => _read(_kNotes).contains(noteId);

  @override
  bool isReclaimed(String itemId) => _read(_kReclaimed).contains(itemId);

  @override
  Set<String> get foundNotes => _read(_kNotes);

  @override
  Set<String> get reclaimedItems => _read(_kReclaimed);

  @override
  Future<void> unlockLevel(String levelId) async {
    final set = _unlocked..add(levelId);
    await _write(_kUnlocked, set);
  }

  @override
  Future<void> completeLevel(String levelId) async {
    final set = _completed..add(levelId);
    await _write(_kCompleted, set);
  }

  @override
  Future<void> addNote(String noteId) async {
    final set = _read(_kNotes)..add(noteId);
    await _write(_kNotes, set);
  }

  @override
  Future<void> reclaimItem(String itemId) async {
    final set = _read(_kReclaimed)..add(itemId);
    await _write(_kReclaimed, set);
  }

  @override
  Future<void> reset() async {
    for (final key in [_kUnlocked, _kCompleted, _kNotes, _kReclaimed]) {
      await _prefs.remove(key);
    }
  }
}
