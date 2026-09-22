import 'package:flutter/material.dart';

import '../../../../app/design_tokens.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/models/risk_level.dart';

/// Hero risk banner. Colors come from [AppStatus] (sunlight-legible),
/// not the generic color scheme.
class RiskStatusCard extends StatelessWidget {
  final RiskLevel level;
  final String explanation;

  const RiskStatusCard(
      {super.key, required this.level, required this.explanation});

  (Color, Color, IconData, StatusTone) get _style {
    switch (level) {
      case RiskLevel.low:
        return (AppStatus.successBg, AppStatus.success,
            Icons.check_circle_outline, StatusTone.success);
      case RiskLevel.elevated:
        return (AppStatus.warningBg, AppStatus.warning,
            Icons.warning_amber_outlined, StatusTone.warning);
      case RiskLevel.high:
        return (AppStatus.dangerBg, AppStatus.danger,
            Icons.report_outlined, StatusTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon, tone) = _style;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bg,
        // Guide: status / info cards use radius-lg 20.
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: fg, size: 30),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusChip(label: level.label, tone: tone, icon: icon),
                    const SizedBox(height: 4),
                    Text(
                      _headline,
                      style:
                          text.titleMedium?.copyWith(color: fg),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(explanation,
              style: text.bodyMedium?.copyWith(color: fg)),
        ],
      ),
    );
  }

  String get _headline {
    switch (level) {
      case RiskLevel.low:
        return 'Routine screening applies';
      case RiskLevel.elevated:
        return 'Needs officer review';
      case RiskLevel.high:
        return 'Needs immediate review';
    }
  }
}
