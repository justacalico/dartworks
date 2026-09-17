import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../physics/body_defs.dart';
import '../render/palette.dart';
import '../tile_map.dart';

/// One static body holding every merged solid run (and separately the
/// thin platforms and invisible walls) for a level. Renders each rect
/// with a lit top edge in the level palette.
class TerrainBlock extends BodyComponent with GroundSurface {
  TerrainBlock({
    required this.rects,
    required this.palette,
    this.kind = TerrainKind.solid,
  });

  final List<BlockRect> rects;
  final DwPalette palette;
  final TerrainKind kind;

  @override
  Body createBody() {
    final body = world.createBody(staticBodyDef(0, 0, userData: this));
    for (final r in rects) {
      final isThin = kind == TerrainKind.platform;
      body.createShape(
        offsetBoxShape(
          r.w * kTile / 2,
          isThin ? 0.16 : kTile / 2,
          Vector2(r.x * kTile + r.w * kTile / 2,
              r.y * kTile + (isThin ? 0.84 : kTile / 2)),
        ),
        shapeDef(
          category: DwBits.terrain,
          friction: isThin ? 0.2 : 0.8,
          userData: this,
        ),
      );
    }
    return body;
  }

  @override
  void render(Canvas canvas) {
    if (kind == TerrainKind.invisible) return;
    final paint = Paint()..color = palette.block;
    final edge = Paint()..color = palette.blockEdge;
    for (final r in rects) {
      final rect = Rect.fromLTWH(
        r.x * kTile,
        r.y * kTile + (kind == TerrainKind.platform ? 0.68 : 0),
        r.w * kTile,
        kind == TerrainKind.platform ? 0.32 : kTile,
      );
      canvas.drawRect(rect, paint);
      canvas.drawRect(
        Rect.fromLTWH(rect.left, rect.top, rect.width, 0.06),
        edge,
      );
    }
  }
}

enum TerrainKind { solid, platform, invisible }
