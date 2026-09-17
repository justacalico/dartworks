import 'package:flutter/material.dart';

import '../../theme.dart';
import '../widgets/menu_button.dart';
import '../widgets/void_backdrop.dart';

/// MythOS terminal style landing screen.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VoidBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              const _Logo(),
              const SizedBox(height: 8),
              Text(
                'A 2D BONEWORKS DEMAKE // MYTHOS TERMINAL ACCESS',
                style: DwText.caption.copyWith(color: DwColors.textDim),
              ),
              const Spacer(flex: 2),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MenuButton(
                        label: 'CAMPAIGN',
                        subtitle: 'The story. All of it.',
                        icon: Icons.play_arrow,
                        accent: DwColors.monogonYellow,
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/levels'),
                      ),
                      const SizedBox(height: 12),
                      MenuButton(
                        label: 'SANDBOX',
                        subtitle: 'Unlocked by reclaiming modules',
                        icon: Icons.science_outlined,
                        accent: DwColors.voidPurple,
                        onPressed: () => Navigator.of(context)
                            .pushNamed('/levels?tab=sandbox'),
                      ),
                      const SizedBox(height: 12),
                      MenuButton(
                        label: 'MONOCHATS',
                        subtitle: 'Recovered clipboards and memos',
                        icon: Icons.content_paste,
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/notes'),
                      ),
                      const SizedBox(height: 12),
                      MenuButton(
                        label: 'SETTINGS',
                        subtitle: 'Controls, save data, about',
                        icon: Icons.tune,
                        accent: DwColors.textDim,
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/settings'),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    const text = 'DARTWORKS';
    return Stack(
      children: [
        Positioned(
          left: 3,
          top: 3,
          child: Text(
            text,
            style: DwText.logo.copyWith(
              color: DwColors.voidPurple.withValues(alpha: 0.6),
            ),
          ),
        ),
        Positioned(
          left: -3,
          top: -2,
          child: Text(
            text,
            style: DwText.logo.copyWith(
              color: DwColors.neonCyan.withValues(alpha: 0.4),
            ),
          ),
        ),
        const Text(text, style: DwText.logo),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Text(
            'UNOFFICIAL FAN PROJECT - NOT FOR PRODUCTION',
            style: DwText.caption.copyWith(color: DwColors.warnRed),
          ),
          const SizedBox(height: 4),
          const Text(
            'v1.0.0 // BONEWORKS and MythOS belong to Stress Level Zero',
            style: DwText.caption,
          ),
        ],
      ),
    );
  }
}
