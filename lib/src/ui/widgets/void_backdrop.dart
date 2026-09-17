import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';

/// Animated void-energy backdrop: drifting motes, nebula washes, scanlines
/// and a vignette. Pure function of [time] so goldens stay deterministic.
class VoidBackdrop extends StatefulWidget {
  const VoidBackdrop({super.key, this.seed = 7, this.child});

  final int seed;
  final Widget? child;

  @override
  State<VoidBackdrop> createState() => _VoidBackdropState();
}

class _VoidBackdropState extends State<VoidBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final VoidPainter _painter;

  @override
  void initState() {
    super.initState();
    _painter = VoidPainter(seed: widget.seed);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _painter..time = _controller.value * 60,
        child: SizedBox.expand(child: widget.child),
      ),
    );
  }
}

class VoidPainter extends CustomPainter {
  VoidPainter({int seed = 7}) : _motes = _spawnMotes(seed);

  double time = 0;

  final List<_Mote> _motes;

  static List<_Mote> _spawnMotes(int seed) {
    final rng = math.Random(seed);
    return List.generate(70, (_) {
      return _Mote(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        drift: 0.004 + rng.nextDouble() * 0.02,
        size: 0.6 + rng.nextDouble() * 1.8,
        hue: rng.nextDouble(),
        phase: rng.nextDouble() * math.pi * 2,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = DwColors.voidBlack);
    _paintNebula(canvas, size);
    _paintMotes(canvas, size);
    _paintScanlines(canvas, size);
    _paintVignette(canvas, size);
  }

  void _paintNebula(Canvas canvas, Size size) {
    final wobble = time * 0.15;
    final centers = [
      Offset(
        size.width * (0.22 + 0.04 * math.sin(wobble)),
        size.height * (0.18 + 0.05 * math.cos(wobble * 0.7)),
      ),
      Offset(
        size.width * (0.85 + 0.03 * math.cos(wobble * 0.8)),
        size.height * (0.9 + 0.04 * math.sin(wobble * 0.6)),
      ),
    ];
    final colors = [DwColors.voidDeep, const Color(0xFF143A4D)];
    final paint = Paint()..blendMode = BlendMode.plus;
    for (var i = 0; i < centers.length; i++) {
      paint.shader = RadialGradient(
        colors: [colors[i].withValues(alpha: 0.35), colors[i].withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: centers[i], radius: size.width * 0.45));
      canvas.drawRect(Offset.zero & size, paint);
    }
  }

  void _paintMotes(Canvas canvas, Size size) {
    final paint = Paint();
    for (final mote in _motes) {
      final y = (mote.y - time * mote.drift) % 1.0;
      final wobbleX = mote.x + 0.01 * math.sin(time * 0.8 + mote.phase);
      final alpha = 0.25 + 0.55 * (0.5 + 0.5 * math.sin(time * 1.6 + mote.phase));
      paint.color = Color.lerp(
        DwColors.voidPurple,
        DwColors.neonCyan,
        mote.hue,
      )!.withValues(alpha: alpha * 0.5);
      canvas.drawCircle(
        Offset(wobbleX * size.width, (y < 0 ? y + 1 : y) * size.height),
        mote.size,
        paint,
      );
    }
  }

  void _paintScanlines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.16)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _paintVignette(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.55),
        ],
        stops: const [0.55, 1],
      ).createShader(
        Rect.fromCircle(
          center: size.center(Offset.zero),
          radius: size.shortestSide * 0.95,
        ),
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(VoidPainter oldDelegate) => oldDelegate.time != time;
}

class _Mote {
  const _Mote({
    required this.x,
    required this.y,
    required this.drift,
    required this.size,
    required this.hue,
    required this.phase,
  });

  final double x;
  final double y;
  final double drift;
  final double size;
  final double hue;
  final double phase;
}
