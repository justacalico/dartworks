/// Static metadata for a single level, sourced from the BONEWORKS wiki.
/// Layouts and entity placement live in the per-level data files.
enum LevelKind { campaign, sandbox }

class LevelInfo {
  const LevelInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.order,
    this.unlockHint,
  });

  /// Stable id used in routes and save data, e.g. `time_tower`.
  final String id;
  final String title;
  final String subtitle;
  final LevelKind kind;

  /// Position within its kind. Campaign order follows the story.
  final int order;

  /// For sandbox levels, how the module is found. Null for campaign levels.
  final String? unlockHint;

  bool get isSandbox => kind == LevelKind.sandbox;
}
