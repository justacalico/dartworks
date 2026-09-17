import 'package:flutter/material.dart';

import '../../game/hud_state.dart';
import '../../theme.dart';

/// Status strip: health, slow-time, ammo, slots, objective ticker.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.hud});

  final HudState hud;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: hud,
      builder: (context, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Vitals(hud: hud),
                    const Spacer(),
                    _Objective(hud: hud),
                  ],
                ),
                const Spacer(),
                if (hud.toast != null)
                  Center(
                    child: Text(hud.toast!, style: DwText.caption),
                  ),
                const SizedBox(height: 8),
                _Slots(hud: hud),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Vitals extends StatelessWidget {
  const _Vitals({required this.hud});
  final HudState hud;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Bar(
          label: 'INTEGRITY',
          value: hud.hp / hud.maxHp,
          color: hud.hp > 30 ? DwColors.neonCyan : DwColors.warnRed,
          width: 170,
        ),
        const SizedBox(height: 6),
        _Bar(
          label: 'SLOW-TIME',
          value: hud.slowCharge,
          color:
              hud.slowmoActive ? DwColors.toxicGreen : DwColors.voidPurple,
          width: 170,
        ),
        if (hud.keycards > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('KEYCARD x${hud.keycards}',
                style: DwText.caption
                    .copyWith(color: DwColors.monogonYellow, fontSize: 10)),
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar(
      {required this.label,
      required this.value,
      required this.color,
      required this.width});
  final String label;
  final double value;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DwText.caption.copyWith(fontSize: 9)),
        const SizedBox(height: 2),
        Container(
          width: width,
          height: 8,
          decoration: BoxDecoration(
            border: Border.all(color: DwColors.edge),
            color: DwColors.surface,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: ColoredBox(color: color),
          ),
        ),
      ],
    );
  }
}

class _Objective extends StatelessWidget {
  const _Objective({required this.hud});
  final HudState hud;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DwColors.surface.withValues(alpha: 0.85),
        border: Border.all(
            color: hud.objectiveDone
                ? DwColors.toxicGreen
                : DwColors.edge),
      ),
      child: Text(
        hud.objectiveDone ? '${hud.objective} — EXIT OPEN' : hud.objective,
        style: DwText.caption.copyWith(
          color: hud.objectiveDone
              ? DwColors.toxicGreen
              : DwColors.textPrimary,
        ),
      ),
    );
  }
}

class _Slots extends StatelessWidget {
  const _Slots({required this.hud});
  final HudState hud;

  @override
  Widget build(BuildContext context) {
    Widget slot(int i, String? name, bool active) {
      return Container(
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: DwColors.surface.withValues(alpha: 0.85),
          border: Border.all(
              color: active ? DwColors.neonCyan : DwColors.edge,
              width: active ? 1.5 : 1),
        ),
        child: Text(
          name ?? (i == 0 ? '1 · EMPTY' : '2 · EMPTY'),
          style: DwText.caption.copyWith(
              color: active ? DwColors.neonCyan : DwColors.textDim),
        ),
      );
    }

    return Row(
      children: [
        slot(0, hud.slot0Item?.name, hud.activeSlot == 0),
        slot(1, hud.slot1Item?.name, hud.activeSlot == 1),
        const SizedBox(width: 8),
        if (hud.slotItem != null)
          Text(
            hud.slotItem!.isGun
                ? '${hud.slotAmmo} / ${hud.looseAmmo}'
                : '∞ / ${hud.looseAmmo}',
            style: DwText.h2.copyWith(fontSize: 18),
          ),
      ],
    );
  }
}
