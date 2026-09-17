import 'package:dartworks/src/data/level_data.dart';

/// Tiny hand-authored level for tests: real palette, overridable
/// goal/legend/waves.
LevelData miniLevel(
  List<String> layout, {
  LevelGoal goal = const LevelGoal(LevelGoalType.reachExit),
  Map<String, String> legend = const {},
  Map<String, String> boneboxDrops = const {},
  List<MonomatOffer> stock = const [],
  List<WaveSpec> waves = const [],
  double darkness = 0,
  String id = 'test_mini',
}) =>
    LevelData(
      id: id,
      layout: layout,
      palette: LevelPalette(
          bgTop: 0xFF000000,
          bgBottom: 0xFF111111,
          block: 0xFF222222,
          blockEdge: 0xFF444444,
          accent: 0xFF4DE8FF,
          darkness: darkness),
      objective: 'test objective',
      goal: goal,
      itemLegend: legend,
      boneboxDrops: boneboxDrops,
      monomatStock: stock,
      waves: waves,
    );
