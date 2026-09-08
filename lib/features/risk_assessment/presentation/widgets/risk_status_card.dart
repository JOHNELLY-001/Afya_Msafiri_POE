import 'package:flutter/material.dart';

import '../../../../app/design_tokens.dart';
import '../../data/models/risk_level.dart';

class RiskStatusCard extends StatelessWidget {
  final RiskLevel level;
  final String explanation;

  const RiskStatusCard({super.key, required this.level, required this.explanation});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final (Color color, IconData icon) = switch (level) {
      RiskLevel.low => (colors.secondary, Icons.check_circle_outline),
      RiskLevel.elevated => (colors.tertiary, Icons.warning_amber_outlined),
      RiskLevel.high => (colors.error, Icons.report_gmailerrorred_outlined),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Text(
                level.label,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(explanation, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}