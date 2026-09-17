import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../render/palette.dart';

/// Paints the level's sky gradient, distant structure hints, a faint
/// tile grid and scattered motes. Always behind the world.
class LevelBackdrop extends PositionComponent {
  LevelBackdrop({
    required this.palette,
    required double levelWidth,
    required double levelHeight,
    int seed = 11,
  })  : _motes = _genMotes(seed),
        super(
          size: Vector2(levelWidth, levelHeight),
          position: Vector2.zero(),
          priority: -100,
        );

  final DwPalette palette;
  final List<_Mote> _motes;

  static List<_Mote> _genMotes(int seed) {
    final rng = math.Random(seed);
    return List.generate(
        50,
        (_) => _Mote(
              x: rng.nextDouble(),
              y: rng.nextDouble(),
              size: 0.03 + rng.nextDouble() * 0.09,
              alpha: 0.15 + rng.nextDouble() * 0.5,
            ));
  }

  @override
  void render(Canvas canvas) {
    final rect = Offset.zero & size.toSize();
    canvas.drawRect(rect, Paint()..shader = palette.sky.createShader(rect));
    _paintStructures(canvas);
    _paintGrid(canvas);
    _paintMotes(canvas);
  }

  /// Distant slabs suggesting city blocks / castle walls behind the play
  /// field, drawn as darker vertical bars at varied depths.
  void _paintStructures(Canvas canvas) {
    if (palette.isLight) return;
    final rng = math.Random(4);
    final paint = Paint()
      ..color = palette.block.withValues(alpha: 0.25);
    for (var i = 0; i < 14; i++) {
      final w = 2 + rng.nextDouble() * 6;
      final h = size.y * (0.25 + rng.nextDouble() * 0.45);
      final x = rng.nextDouble() * size.x;
      canvas.drawRect(
        Rect.fromLTWH(x, size.y - h - 1, w, h),
        paint,
      );
    }
  }

  void _paintGrid(Canvas canvas) {
    final paint = Paint()
      ..color = (palette.isLight ? Colors.black26 : Colors.white10)
      ..strokeWidth = 0.02;
    for (var x = 0.0; x <= size.x; x += 4) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), paint);
    }
    for (var y = 0.0; y <= size.y; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), paint);
    }
  }

  void _paintMotes(Canvas canvas) {
    final paint = Paint()..color = palette.accent;
    for (final m in _motes) {
      paint.color =
          palette.accent.withValues(alpha: m.alpha * (palette.isLight ? 0.3 : 0.6));
      canvas.drawCircle(
        Offset(m.x * size.x, m.y * size.y),
        m.size,
        paint,
      );
    }
  }
}

class _Mote {
  const _Mote(
      {required this.x,
      required this.y,
      required this.size,
      required this.alpha});
  final double x;
  final double y;
  final double size;
  final double alpha;
}
