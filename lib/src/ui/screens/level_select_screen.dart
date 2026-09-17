import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../data/catalog.dart';
import '../../data/level_info.dart';
import '../../meta/progress_store.dart';
import '../../theme.dart';
import '../widgets/neon_panel.dart';
import '../widgets/void_backdrop.dart';

/// Campaign + sandbox destination picker. Sandbox levels show their unlock
/// hint until their module has been reclaimed.
class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({
    super.key,
    this.startTab = LevelKind.campaign,
  });

  final LevelKind startTab;

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  late LevelKind _tab = widget.startTab;

  @override
  Widget build(BuildContext context) {
    final progress = AppScope.progressOf(context);
    final levels = _tab == LevelKind.campaign ? campaignLevels : sandboxLevels;

    return Scaffold(
      body: VoidBackdrop(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: DwColors.textDim),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text('DESTINATIONS // MYTHOS ACCESS',
                        style: DwText.h2),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                child: _TabToggle(
                  selected: _tab,
                  onChanged: (kind) => setState(() => _tab = kind),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 340,
                    mainAxisExtent: 132,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: levels.length,
                  itemBuilder: (context, i) => _LevelCard(
                    info: levels[i],
                    progress: progress,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabToggle extends StatelessWidget {
  const _TabToggle({required this.selected, required this.onChanged});

  final LevelKind selected;
  final ValueChanged<LevelKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final kind in LevelKind.values) ...[
          _TabChip(
            label: kind == LevelKind.campaign ? 'CAMPAIGN' : 'SANDBOX',
            selected: selected == kind,
            accent: kind == LevelKind.campaign
                ? DwColors.monogonYellow
                : DwColors.voidPurple,
            onTap: () => onChanged(kind),
          ),
          const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.14) : null,
          border: Border.all(
            color: selected ? accent : DwColors.edge,
          ),
        ),
        child: Text(
          label,
          style: DwText.h3.copyWith(
            color: selected ? accent : DwColors.textDim,
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.info, required this.progress});

  final LevelInfo info;
  final ProgressStore progress;

  void _open(BuildContext context) {
    if (!progress.isLevelUnlocked(info.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(info.unlockHint ?? 'LOCKED'),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    Navigator.of(context).pushNamed('/game?id=${info.id}');
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = progress.isLevelUnlocked(info.id);
    final cleared = progress.isLevelComplete(info.id);
    final accent = info.isSandbox ? DwColors.voidPurple : DwColors.monogonYellow;

    return GestureDetector(
      onTap: () => _open(context),
      child: NeonPanel(
        accent: unlocked ? accent : DwColors.textFaint,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  color: unlocked
                      ? accent.withValues(alpha: 0.16)
                      : DwColors.edge.withValues(alpha: 0.4),
                  child: Text(
                    info.isSandbox
                        ? 'SBX'
                        : info.order.toString().padLeft(2, '0'),
                    style: DwText.caption.copyWith(
                      color:
                          unlocked ? accent : DwColors.textFaint,
                    ),
                  ),
                ),
                const Spacer(),
                if (!unlocked)
                  const Icon(Icons.lock_outline,
                      size: 16, color: DwColors.textFaint)
                else if (cleared)
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: DwColors.toxicGreen),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              info.title,
              style: DwText.h3.copyWith(
                color: unlocked ? DwColors.textPrimary : DwColors.textFaint,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                unlocked
                    ? info.subtitle
                    : (info.unlockHint ?? 'Complete the campaign to unlock.'),
                style: DwText.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
