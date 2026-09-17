import 'package:flutter/material.dart';

import '../../data/catalog.dart';
import '../../theme.dart';
import '../widgets/void_backdrop.dart';

/// Hosts the level simulation. The Forge2D stage mounts here once the
/// engine layer lands; until then it reports the pending patch.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.levelId});

  final String levelId;

  @override
  Widget build(BuildContext context) {
    final info = levelById(levelId);
    return Scaffold(
      body: VoidBackdrop(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  info?.title ?? 'UNKNOWN SECTOR',
                  style: DwText.h1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'SIMULATION OFFLINE - ENGINE PATCH PENDING',
                  style: DwText.caption.copyWith(color: DwColors.warnRed),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'RETURN TO TERMINAL',
                    style: DwText.button.copyWith(color: DwColors.neonCyan),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
