import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';

enum StatusTone { success, warning, danger, info, neutral }

/// Compact status pill (risk level, offline flag, sync state…).
/// Colors come from [AppStatus] so they stay legible in sunlight.
class StatusChip extends StatelessWidget {
  final String label;
  final StatusTone tone;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.icon,
  });

  (Color, Color) _colors(BuildContext context) {
    switch (tone) {
      case StatusTone.success:
        return (AppStatus.successBg, AppStatus.success);
      case StatusTone.warning:
        return (AppStatus.warningBg, AppStatus.warning);
      case StatusTone.danger:
        return (AppStatus.dangerBg, AppStatus.danger);
      case StatusTone.info:
        return (AppStatus.infoBg, AppStatus.info);
      case StatusTone.neutral:
        final scheme = Theme.of(context).colorScheme;
        return (scheme.surfaceContainerHighest, scheme.onSurfaceVariant);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
