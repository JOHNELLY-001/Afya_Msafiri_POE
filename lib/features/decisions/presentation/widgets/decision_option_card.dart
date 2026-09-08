import 'package:flutter/material.dart';

import '../../../../app/design_tokens.dart';
import '../../data/models/decision_type.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isQuarantine = type == DecisionType.quarantined;
    final borderColor = selected ? (isQuarantine ? colors.error : colors.primary) : colors.outlineVariant;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: borderColor, width: selected ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(type.description, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? borderColor : colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}