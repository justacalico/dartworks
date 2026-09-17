import 'package:flutter/material.dart';

import '../../data/notes.dart';
import '../../game/components/monomat.dart';
import '../../game/game_events.dart';
import '../../game/hud_state.dart';
import '../../theme.dart';
import '../widgets/neon_panel.dart';

/// Floating shop UI shown while standing at a monomat.
class MonomatPanel extends StatelessWidget {
  const MonomatPanel({
    super.key,
    required this.hud,
    required this.onBuy,
  });

  final HudState hud;
  final void Function(int index) onBuy;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: hud,
      builder: (context, _) {
        final m = hud.openMonomat;
        if (m == null) return const SizedBox.shrink();
        return _panel(m);
      },
    );
  }

  Widget _panel(MonomatZone m) {
    final rows = monomatRows(m.stock);
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 24),
        child: NeonPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MONOMAT', style: DwText.h3),
              Text('${hud.looseAmmo} ROUNDS ON HAND',
                  style: DwText.caption.copyWith(fontSize: 10)),
              const SizedBox(height: 10),
              for (var i = 0; i < rows.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(rows[i].item.name,
                            style: DwText.caption.copyWith(fontSize: 11)),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text('${rows[i].price}r',
                            style: DwText.caption.copyWith(
                                fontSize: 11,
                                color: DwColors.monogonYellow)),
                      ),
                      GestureDetector(
                        onTap: rows[i].sold ? null : () => onBuy(i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: rows[i].sold
                                    ? DwColors.textFaint
                                    : DwColors.neonCyan),
                          ),
                          child: Text(
                            rows[i].sold ? 'SOLD' : 'BUY',
                            style: DwText.caption.copyWith(
                                fontSize: 10,
                                color: rows[i].sold
                                    ? DwColors.textFaint
                                    : DwColors.neonCyan),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clipboard reading popup.
class NotePopup extends StatelessWidget {
  const NotePopup({super.key, required this.note, required this.onClose});

  final NoteInfo note;
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onClose,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: NeonPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CLIPBOARD RECOVERED',
                    style: DwText.caption
                        .copyWith(color: DwColors.monogonYellow)),
                const SizedBox(height: 6),
                Text(note.title, style: DwText.h3),
                Text('— ${note.author}',
                    style: DwText.caption.copyWith(fontSize: 10)),
                const SizedBox(height: 12),
                Text(note.body,
                    style: DwText.caption.copyWith(
                        fontSize: 12, height: 1.5)),
                const SizedBox(height: 14),
                Text('TAP TO FILE',
                    style: DwText.caption.copyWith(
                        fontSize: 10, color: DwColors.textFaint)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Esc menu.
class PauseMenu extends StatelessWidget {
  const PauseMenu(
      {super.key, required this.onResume, required this.onQuit});

  final void Function() onResume;
  final void Function() onQuit;

  @override
  Widget build(BuildContext context) {
    return _overlay(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('SIMULATION PAUSED', style: DwText.h2),
          const SizedBox(height: 24),
          _menuButton('RESUME', onResume),
          const SizedBox(height: 10),
          _menuButton('ABANDON RUN', onQuit),
        ],
      ),
    );
  }
}

/// Level-complete card.
class CompleteScreen extends StatelessWidget {
  const CompleteScreen(
      {super.key, required this.result, required this.onDone});

  final LevelResult result;
  final void Function() onDone;

  @override
  Widget build(BuildContext context) {
    final mins = result.timeSeconds ~/ 60;
    final secs = (result.timeSeconds % 60).toStringAsFixed(1);
    return _overlay(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('SIMULATION COMPLETE',
              style: DwText.h2.copyWith(color: DwColors.toxicGreen)),
          const SizedBox(height: 16),
          Text('TIME  ${mins}m ${secs}s', style: DwText.caption),
          Text(
              'NOTES  ${result.notesFound}/${result.notesTotal}',
              style: DwText.caption),
          const SizedBox(height: 24),
          _menuButton('CONTINUE', onDone),
        ],
      ),
    );
  }
}

/// Death card.
class DeathScreen extends StatelessWidget {
  const DeathScreen(
      {super.key, required this.onRetry, required this.onQuit});

  final void Function() onRetry;
  final void Function() onQuit;

  @override
  Widget build(BuildContext context) {
    return _overlay(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('CONSTRUCT TERMINATED',
              style: DwText.h2.copyWith(color: DwColors.warnRed)),
          const SizedBox(height: 8),
          Text('the simulation resets', style: DwText.caption),
          const SizedBox(height: 24),
          _menuButton('RE-ENTER', onRetry),
          const SizedBox(height: 10),
          _menuButton('ABANDON', onQuit),
        ],
      ),
    );
  }
}

Widget _overlay(Widget child) => Container(
      color: DwColors.voidBlack.withValues(alpha: 0.82),
      child: Center(child: child),
    );

Widget _menuButton(String label, void Function() onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: DwColors.neonCyan),
          color: DwColors.surface,
        ),
        child: Text(label, style: DwText.button),
      ),
    );
