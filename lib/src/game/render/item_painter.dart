import 'package:flutter/material.dart';

import '../../data/items.dart';

/// Procedural glyphs for every item. Drawn centered at origin inside a
/// [size]-wide box so props and HUD share one look.
void paintItem(Canvas canvas, ItemDef item, Size size) {
  final c = Color(item.color);
  final body = Paint()..color = c;
  final dark = Paint()..color = c.withValues(alpha: 0.45);
  final glow = Paint()
    ..color = c.withValues(alpha: 0.3)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.15);
  final w = size.width;
  final h = size.height;

  switch (item.category) {
    case ItemCategory.gun:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, h * 0.15, w * 0.7, h * 0.4), const Radius.circular(0.04)),
        glow,
      );
      // receiver + barrel + grip
      canvas.drawRect(Rect.fromLTWH(0, h * 0.2, w * 0.62, h * 0.34), body);
      canvas.drawRect(Rect.fromLTWH(w * 0.62, h * 0.26, w * 0.36, h * 0.14), dark);
      canvas.drawRect(Rect.fromLTWH(w * 0.14, h * 0.5, w * 0.16, h * 0.42), dark);
    case ItemCategory.melee:
      // blade + grip
      canvas.drawRect(
          Rect.fromLTWH(0, h * 0.38, w * 0.78, h * 0.24), body);
      canvas.drawRect(
          Rect.fromLTWH(w * 0.78, h * 0.42, w * 0.22, h * 0.16), dark);
      canvas.drawRect(
          Rect.fromLTWH(w * 0.1, h * 0.3, w * 0.5, h * 0.1), glow);
    case ItemCategory.gadget:
      canvas.drawRect(Rect.fromLTWH(w * 0.15, 0, w * 0.7, h), glow);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.6, h * 0.8),
            const Radius.circular(0.08)),
        body,
      );
      canvas.drawRect(
          Rect.fromLTWH(w * 0.35, h * 0.3, w * 0.3, h * 0.4), dark);
    case ItemCategory.prop:
      if (_round.contains(item.id)) {
        canvas.drawCircle(Offset(w / 2, h / 2), w / 2, glow);
        canvas.drawCircle(Offset(w / 2, h / 2), w / 2.3, body);
        canvas.drawArc(
          Rect.fromCircle(center: Offset(w / 2, h / 2), radius: w / 2.3),
          -0.6, 1.4, false, Paint()..color = dark.color..strokeWidth = 0.05..style = PaintingStyle.stroke,
        );
      } else {
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), glow);
        canvas.drawRect(Rect.fromLTWH(w * 0.06, h * 0.06, w * 0.88, h * 0.88), body);
        canvas.drawRect(Rect.fromLTWH(w * 0.42, h * 0.06, w * 0.16, h * 0.88), dark);
      }
    case ItemCategory.quest:
      _paintQuest(canvas, item, c, dark, glow, w, h);
  }
}

const _round = {'basketball', 'melon', 'gachapon', 'energy_core'};

void _paintQuest(Canvas canvas, ItemDef item, Color c, Paint dark,
    Paint glow, double w, double h) {
  final body = Paint()..color = c;
  switch (item.id) {
    case 'keycard':
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, h * 0.1, w, h * 0.8),
            const Radius.circular(0.05)),
        body,
      );
      canvas.drawRect(
          Rect.fromLTWH(w * 0.12, h * 0.3, w * 0.25, h * 0.3), dark);
    case 'battery':
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, h * 0.15, w * 0.6, h * 0.75),
            const Radius.circular(0.08)),
        body,
      );
      canvas.drawRect(Rect.fromLTWH(w * 0.35, 0, w * 0.3, h * 0.15), dark);
      canvas.drawRect(
          Rect.fromLTWH(w * 0.32, h * 0.35, w * 0.36, h * 0.3), dark);
    case 'energy_core':
      canvas.drawCircle(Offset(w / 2, h / 2), w / 2, glow);
      canvas.drawCircle(Offset(w / 2, h / 2), w / 2.6, body);
      canvas.drawCircle(Offset(w / 2, h / 2), w / 5, dark);
    case 'gachapon':
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, 0, w * 0.7, h),
            const Radius.circular(0.2)),
        glow,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, h * 0.08, w * 0.6, h * 0.84),
            const Radius.circular(0.18)),
        body,
      );
      canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.44, w * 0.6, h * 0.12), dark);
    case 'module':
      canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.05, w * 0.8, h * 0.9), glow);
      canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.1, w * 0.7, h * 0.8), body);
      for (var i = 0; i < 3; i++) {
        canvas.drawRect(
            Rect.fromLTWH(w * (0.25 + i * 0.2), h * 0.2, w * 0.08, h * 0.6),
            dark);
      }
    case 'crown':
      final path = Path()
        ..moveTo(w * 0.1, h * 0.85)
        ..lineTo(w * 0.1, h * 0.35)
        ..lineTo(w * 0.3, h * 0.6)
        ..lineTo(w * 0.5, h * 0.15)
        ..lineTo(w * 0.7, h * 0.6)
        ..lineTo(w * 0.9, h * 0.35)
        ..lineTo(w * 0.9, h * 0.85)
        ..close();
      canvas.drawPath(path, glow);
      canvas.drawPath(path, body);
      canvas.drawCircle(Offset(w * 0.5, h * 0.7), w * 0.08, dark);
    default:
      canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8), body);
  }
}
