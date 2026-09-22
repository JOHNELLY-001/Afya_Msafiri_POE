import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/flow_steps.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../shared/providers/risk_provider.dart';
import '../widgets/risk_status_card.dart';

class RiskAssessmentScreen extends ConsumerWidget {
  final String bookingReference;

  const RiskAssessmentScreen({super.key, required this.bookingReference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskAsync = ref.watch(riskAssessmentProvider(bookingReference));
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AfyaAppBar(
        title: 'Risk Assessment',
        subtitle: 'Step 2 of 4 • ${AfyaAppBar.shortRef(bookingReference)}',
      ),
      body: riskAsync.when(
        loading: () =>
            const AppLoadingState(message: 'Assessing risk factors…'),
        error: (err, _) => AppErrorState(
          message: '$err',
          onRetry: () =>
              ref.invalidate(riskAssessmentProvider(bookingReference)),
        ),
        data: (result) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FlowSteps(current: 2),
                const SizedBox(height: AppSpacing.md),
                RiskStatusCard(
                    level: result.level, explanation: result.explanation),
                const SizedBox(height: AppSpacing.md),
                // Factor summary chips.
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(
                      label: result.countryMatch
                          ? 'Flagged country: ${result.matchedCountry}'
                          : 'No flagged country',
                      tone: result.countryMatch
                          ? StatusTone.warning
                          : StatusTone.success,
                      icon: Icons.public_outlined,
                    ),
                    StatusChip(
                      label:
                          '${result.symptomCount} symptom${result.symptomCount == 1 ? '' : 's'}',
                      tone: result.symptomCount >= 3
                          ? StatusTone.warning
                          : StatusTone.neutral,
                      icon: Icons.monitor_heart_outlined,
                    ),
                    StatusChip(
                      label: result.hasExposure
                          ? 'Exposure reported'
                          : 'No exposure',
                      tone: result.hasExposure
                          ? StatusTone.danger
                          : StatusTone.success,
                      icon: Icons.person_search_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Assessed ${DateFormat('d MMM yyyy, HH:mm').format(result.assessedAt)}',
                  style: text.labelMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Note'),
                Text(
                  'System-based decision support, not a diagnosis. '
                  'The final entry decision belongs to the officer.',
                  style: text.bodyMedium,
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => context.push(AppRoutes.riskDetails,
                      extra: bookingReference),
                  child: const Text('View Risk Details'),
                ),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton(
                  onPressed: () => context.push(AppRoutes.entryDecision,
                      extra: bookingReference),
                  child: const Text('Continue to Entry Decision'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
