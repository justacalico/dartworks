import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../theme.dart';
import '../widgets/menu_button.dart';
import '../widgets/neon_panel.dart';
import '../widgets/section_header.dart';
import '../widgets/void_backdrop.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _controls = <(String, String)>[
    ('A / D or arrows', 'Move'),
    ('W / Space', 'Jump'),
    ('S', 'Crouch'),
    ('Mouse', 'Aim'),
    ('Left click', 'Fire / swing'),
    ('E or right click', 'Grab / throw'),
    ('Q', 'Slow motion'),
    ('1 / 2', 'Inventory slots'),
    ('F', 'Interact'),
    ('Esc', 'Pause'),
  ];

  Future<void> _confirmReset(BuildContext context) async {
    final progress = AppScope.progressOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DwColors.surfaceHigh,
        title: const Text('WIPE SAVE DATA?', style: DwText.h3),
        content: const Text(
          'All unlocks, completions, reclaimed items and recovered '
          'monochats will be erased.',
          style: DwText.bodyDim,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL', style: DwText.button),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'WIPE',
              style: DwText.button.copyWith(color: DwColors.warnRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      await progress.reset();
      messenger.showSnackBar(
        const SnackBar(content: Text('Save data wiped.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VoidBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: DwColors.textDim),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text('SYSTEM CONFIGURATION', style: DwText.h2),
                ],
              ),
              const SizedBox(height: 20),
              const SectionHeader('CONTROL REFERENCE'),
              const SizedBox(height: 12),
              NeonPanel(
                title: 'DESKTOP / WEB',
                child: Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    for (final (input, action) in _controls)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 24, bottom: 6),
                            child: Text(input, style: DwText.body),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child:
                                Text(action, style: DwText.bodyDim),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const NeonPanel(
                title: 'TOUCH',
                child: Text(
                  'Left virtual stick moves, right half of the screen aims. '
                  'Cluster buttons handle jump, grab, fire and slow time.',
                  style: DwText.bodyDim,
                ),
              ),
              const SizedBox(height: 20),
              const SectionHeader('SAVE DATA'),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: MenuButton(
                  label: 'WIPE SAVE DATA',
                  subtitle: 'Erase all progress and recovered monochats',
                  icon: Icons.delete_forever,
                  accent: DwColors.warnRed,
                  onPressed: () => _confirmReset(context),
                ),
              ),
              const SizedBox(height: 20),
              const SectionHeader('ABOUT'),
              const SizedBox(height: 12),
              NeonPanel(
                title: 'DARTWORKS',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unofficial 2D fan demake of BONEWORKS (Stress Level '
                      'Zero, 2019). Not affiliated with or endorsed by SLZ. '
                      'Not for production use.',
                      style: DwText.bodyDim,
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: 'DARTWORKS',
                        applicationVersion: '1.0.0',
                      ),
                      child: Text(
                        'VIEW LICENSES',
                        style: DwText.button.copyWith(
                          color: DwColors.neonCyan,
                          fontSize: 13,
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
