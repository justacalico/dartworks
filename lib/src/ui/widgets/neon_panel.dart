import 'package:flutter/material.dart';

import '../../theme.dart';

/// Bordered Monogon terminal panel: sharp corners, accent corner ticks,
/// faint glow. Optional header row with a mono title.
class NeonPanel extends StatelessWidget {
  const NeonPanel({
    super.key,
    required this.child,
    this.title,
    this.accent = DwColors.neonCyan,
    this.padding = const EdgeInsets.all(16),
    this.fill = true,
  });

  final Widget child;
  final String? title;
  final Color accent;
  final EdgeInsetsGeometry padding;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CornerTicks(color: accent),
      child: Container(
        decoration: BoxDecoration(
          color: fill ? DwColors.surface.withValues(alpha: 0.88) : null,
          border: Border.all(color: DwColors.edge),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.10),
              blurRadius: 18,
              spreadRadius: -4,
            ),
          ],
        ),
        padding: padding,
        child: title == null
            ? child
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title!, style: DwText.caption.copyWith(color: accent)),
                  const SizedBox(height: 10),
                  child,
                ],
              ),
      ),
    );
  }
}

class _CornerTicks extends CustomPainter {
  const _CornerTicks({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const len = 10.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final corners = [
      (Offset.zero, const Offset(len, 0), const Offset(0, len)),
      (Offset(size.width, 0), const Offset(-len, 0), const Offset(0, len)),
      (Offset(0, size.height), const Offset(len, 0), const Offset(0, -len)),
      (
        Offset(size.width, size.height),
        const Offset(-len, 0),
        const Offset(0, -len),
      ),
    ];
    for (final (corner, dx, dy) in corners) {
      canvas
        ..drawLine(corner, corner + dx, paint)
        ..drawLine(corner, corner + dy, paint);
    }
  }

  @override
  bool shouldRepaint(_CornerTicks oldDelegate) => oldDelegate.color != color;
}
