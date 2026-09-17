import 'package:flutter/material.dart';

import '../../theme.dart';

/// Angular terminal menu button with a hover/focus accent bar.
class MenuButton extends StatefulWidget {
  const MenuButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.subtitle,
    this.accent = DwColors.neonCyan,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? subtitle;
  final Color accent;
  final bool compact;

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _highlighted = false;

  bool get _enabled => widget.onPressed != null;

  void _setHighlighted(bool value) {
    if (value == _highlighted) return;
    setState(() => _highlighted = value);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _enabled ? widget.accent : DwColors.textFaint;
    final labelColor =
        _enabled ? DwColors.textPrimary : DwColors.textFaint;

    return FocusableActionDetector(
      onFocusChange: _setHighlighted,
      mouseCursor:
          _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: MouseRegion(
        onEnter: (_) => _setHighlighted(true),
        onExit: (_) => _setHighlighted(false),
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: Semantics(
            button: true,
            enabled: _enabled,
            label: widget.label,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                color: _highlighted
                    ? widget.accent.withValues(alpha: 0.10)
                    : DwColors.surface.withValues(alpha: 0.7),
                border: Border.all(
                  color: _highlighted ? widget.accent : DwColors.edge,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: widget.compact ? 8 : 14,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 4,
                    height: widget.compact ? 18 : 34,
                    color: _highlighted ? widget.accent : DwColors.edge,
                  ),
                  const SizedBox(width: 14),
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18, color: accent),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: (widget.compact ? DwText.h3 : DwText.button)
                              .copyWith(color: labelColor),
                        ),
                        if (widget.subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              widget.subtitle!,
                              style: DwText.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: _highlighted ? widget.accent : DwColors.textFaint,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
