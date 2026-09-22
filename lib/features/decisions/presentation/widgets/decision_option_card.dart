import 'package:flutter/material.dart';

import '../../../../app/design_tokens.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/models/decision_type.dart';

/// Selectable decision option with type icon and selected tint.
/// Quarantine reads consequential even before selection (red icon).
class DecisionOptionCard extends StatelessWidget {
  final DecisionType type;
  final bool selected;
  final VoidCallback onTap;

  const DecisionOptionCard({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  (IconData, Color, StatusTone) _style(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (type) {
      case DecisionType.cleared:
        return (Icons.check_circle_outline, AppStatus.success,
            StatusTone.success);
      case DecisionType.referred:
        return (Icons.medical_services_outlined, AppStatus.info,
            StatusTone.info);
      case DecisionType.quarantined:
        return (
          Icons.warning_amber_outlined,
          scheme.error,
          StatusTone.danger
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (icon, accent, _) = _style(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
            color: selected ? accent : colors.outlineVariant,
            width: selected ? 2 : 1),
      ),
      color: selected ? accent.withValues(alpha: 0.06) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.base),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style:
                          Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(type.description,
                        style:
                            Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? accent : colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
