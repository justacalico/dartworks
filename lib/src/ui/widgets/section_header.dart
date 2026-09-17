import 'package:flutter/material.dart';

import '../../theme.dart';

/// Uppercase mono label flanked by hairline rules.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.label, {super.key, this.color = DwColors.textDim});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: DwText.caption.copyWith(color: color)),
        const SizedBox(width: 12),
        const Expanded(child: Divider(height: 1, color: DwColors.edge)),
      ],
    );
  }
}
