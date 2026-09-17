import 'package:flutter/material.dart';

import '../../game/systems/input_state.dart';
import '../../theme.dart';

/// Mobile control scheme: left stick moves, right side aims + fires,
/// edge buttons for jump / grab / slow-mo / interact / pause.
class TouchControls extends StatelessWidget {
  const TouchControls({super.key, required this.input, this.onPause});

  final InputState input;
  final VoidCallback? onPause;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                _TapButton(
                  label: 'II',
                  onTap: () => onPause?.call(),
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Stick(
                  onChanged: (dx, dy) {
                    input.moveAxis = dx;
                    input.crouch = dy > 0.6;
                    if (dy < -0.6 && !input.jump) {
                      input.jumpEdge = true;
                    }
                    input.jump = dy < -0.6;
                  },
                  onEnd: () {
                    input.moveAxis = 0;
                    input.jump = false;
                    input.crouch = false;
                  },
                ),
                const Spacer(),
                Column(
                  children: [
                    _HoldButton(
                      label: 'GRAB',
                      onDown: () => input.grab = true,
                      onUp: () => input.grab = false,
                    ),
                    const SizedBox(height: 10),
                    _TapButton(
                      label: 'USE',
                      onTap: () => input.interactEdge = true,
                    ),
                    const SizedBox(height: 10),
                    _HoldButton(
                      label: 'SLOW',
                      onDown: () => input.slowmo = true,
                      onUp: () => input.slowmo = false,
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                _AimStick(input: input),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stick extends StatefulWidget {
  const _Stick({required this.onChanged, required this.onEnd});
  final void Function(double dx, double dy) onChanged;
  final void Function() onEnd;

  @override
  State<_Stick> createState() => _StickState();
}

class _StickState extends State<_Stick> {
  Offset _knob = Offset.zero;

  void _update(Offset local, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    var delta = local - center;
    final max = size.width / 2 - 18;
    if (delta.distance > max) delta = delta / delta.distance * max;
    setState(() => _knob = delta);
    widget.onChanged(delta.dx / max, delta.dy / max);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size =
              Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            onPanUpdate: (d) => _update(d.localPosition, size),
            onPanEnd: (_) {
              setState(() => _knob = Offset.zero);
              widget.onEnd();
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DwColors.surface.withValues(alpha: 0.5),
                border: Border.all(color: DwColors.edge),
              ),
              child: Center(
                child: Transform.translate(
                  offset: _knob,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DwColors.neonCyan.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Right stick: drag to aim, held counts as firing.
class _AimStick extends StatefulWidget {
  const _AimStick({required this.input});
  final InputState input;

  @override
  State<_AimStick> createState() => _AimStickState();
}

class _AimStickState extends State<_AimStick> {
  Offset _knob = Offset.zero;

  void _update(Offset local, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    var delta = local - center;
    final max = size.width / 2 - 18;
    if (delta.distance > max) delta = delta / delta.distance * max;
    setState(() => _knob = delta);
    final nx = delta.dx / max;
    final ny = delta.dy / max;
    if (nx * nx + ny * ny > 0.05) {
      widget.input.aimX = nx;
      widget.input.aimY = ny;
    }
    widget.input.fire = delta.distance > max * 0.55;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size =
              Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            onPanUpdate: (d) => _update(d.localPosition, size),
            onPanStart: (d) => _update(d.localPosition, size),
            onPanEnd: (_) {
              setState(() => _knob = Offset.zero);
              widget.input.fire = false;
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DwColors.surface.withValues(alpha: 0.5),
                border:
                    Border.all(color: DwColors.voidPurple),
              ),
              child: Center(
                child: Transform.translate(
                  offset: _knob,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          DwColors.voidPurple.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HoldButton extends StatelessWidget {
  const _HoldButton(
      {required this.label, required this.onDown, required this.onUp});
  final String label;
  final void Function() onDown;
  final void Function() onUp;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: _buttonShell(label),
    );
  }
}

class _TapButton extends StatelessWidget {
  const _TapButton({required this.label, required this.onTap});
  final String label;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: _buttonShell(label));
  }
}

Widget _buttonShell(String label) => Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: DwColors.surface.withValues(alpha: 0.7),
        border: Border.all(color: DwColors.edge),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: DwText.caption.copyWith(fontSize: 11)),
    );
