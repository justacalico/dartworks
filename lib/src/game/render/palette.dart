import 'package:flutter/material.dart';

import '../../data/level_data.dart';

/// Resolves the framework-free ARGB ints in [LevelPalette] into Colors and
/// gives every level a derived look for terrain, glow and UI accents.
class DwPalette {
  const DwPalette(this.data);

  final LevelPalette data;

  Color get bgTop => Color(data.bgTop);
  Color get bgBottom => Color(data.bgBottom);
  Color get block => Color(data.block);
  Color get blockEdge => Color(data.blockEdge);
  Color get accent => Color(data.accent);
  double get darkness => data.darkness;

  bool get isLight =>
      bgTop.computeLuminance() > 0.5;

  /// Sky gradient for the level backdrop.
  LinearGradient get sky => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bgTop, bgBottom],
      );
}
