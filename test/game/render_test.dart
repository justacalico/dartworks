import 'dart:ui' as ui;

import 'package:dartworks/src/data/items.dart';
import 'package:dartworks/src/data/level_data.dart';
import 'package:dartworks/src/game/render/item_painter.dart';
import 'package:dartworks/src/game/render/palette.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('paintItem', () {
    test('every item paints without throwing', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      for (final item in kItems.values) {
        paintItem(canvas, item, const ui.Size(1, 1));
      }
      final picture = recorder.endRecording();
      final image = await picture.toImage(16, 16);
      expect(image.width, 16);
      image.dispose();
      picture.dispose();
    });
  });

  group('DwPalette', () {
    test('converts level palette ints to colors', () {
      const lp = LevelPalette(
        bgTop: 0xFF101020,
        bgBottom: 0xFF203040,
        block: 0xFF334455,
        blockEdge: 0xFF445566,
        accent: 0xFF4DE8FF,
        darkness: 0.5,
      );
      final p = DwPalette(lp);
      expect(p.bgTop.a * 255.0, 255);
      expect(p.blockEdge, isNotNull);
      expect(p.darkness, 0.5);
    });
  });
}
