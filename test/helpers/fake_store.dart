import 'package:dartworks/src/meta/progress_store.dart';

/// In-memory save backend for engine tests.
class FakeProgressStore extends ProgressStore {
  final _unlocked = <String>{};
  final _completed = <String>{};
  final _notes = <String>{};
  final _reclaimed = <String>{};

  @override
  bool isLevelUnlocked(String levelId) =>
      _unlocked.contains(levelId) ||
      levelId == 'breakroom' ||
      _completed.contains(levelId);

  @override
  bool isLevelComplete(String levelId) => _completed.contains(levelId);

  @override
  bool hasNote(String noteId) => _notes.contains(noteId);

  @override
  bool isReclaimed(String itemId) => _reclaimed.contains(itemId);

  @override
  Set<String> get foundNotes => Set.of(_notes);

  @override
  Set<String> get reclaimedItems => Set.of(_reclaimed);

  @override
  Future<void> unlockLevel(String levelId) async => _unlocked.add(levelId);

  @override
  Future<void> completeLevel(String levelId) async =>
      _completed.add(levelId);

  @override
  Future<void> addNote(String noteId) async => _notes.add(noteId);

  @override
  Future<void> reclaimItem(String itemId) async =>
      _reclaimed.add(itemId);

  @override
  Future<void> reset() async {
    _unlocked.clear();
    _completed.clear();
    _notes.clear();
    _reclaimed.clear();
  }
}
