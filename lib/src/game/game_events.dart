import '../data/notes.dart';

/// Result handed to the UI when the level ends.
class LevelResult {
  const LevelResult({
    required this.levelId,
    required this.timeSeconds,
    required this.notesFound,
    required this.notesTotal,
    required this.won,
  });

  final String levelId;
  final double timeSeconds;
  final int notesFound;
  final int notesTotal;
  final bool won;
}

/// Everything the game can report back to the widget layer.
class GameEvents {
  const GameEvents({
    this.onComplete,
    this.onDeath,
    this.onNote,
    this.onUnlock,
    this.onToast,
  });

  /// Level finished through the exit. Progress is already saved.
  final void Function(LevelResult result)? onComplete;

  /// Player hp hit zero.
  final void Function()? onDeath;

  /// A clipboard was collected; body text for the popup.
  final void Function(NoteInfo note)? onNote;

  /// A sandbox module unlocked this level id.
  final void Function(String levelId)? onUnlock;

  /// Short status line for the HUD ticker.
  final void Function(String message)? onToast;
}
