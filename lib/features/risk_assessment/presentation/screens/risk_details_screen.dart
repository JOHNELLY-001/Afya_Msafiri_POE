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
import '../../../../shared/providers/traveller_provider.dart';
import '../widgets/risk_status_card.dart';

class RiskDetailsScreen extends ConsumerWidget {
  final String bookingReference;

  const RiskDetailsScreen({super.key, required this.bookingReference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskAsync = ref.watch(riskAssessmentProvider(bookingReference));
    final travellerAsync =
        ref.watch(travellerByReferenceProvider(bookingReference));
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AfyaAppBar(
        title: 'Risk Details',
        subtitle: 'Step 2 of 4 • ${AfyaAppBar.shortRef(bookingReference)}',
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step 2 of 4 • Risk assessment',
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.entryDecision,
                      extra: bookingReference),
                  child: const Text('Continue to Entry Decision'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: riskAsync.when(
        loading: () =>
            const AppLoadingState(message: 'Loading risk details…'),
        error: (err, _) => AppErrorState(
          message: '$err',
          onRetry: () =>
              ref.invalidate(riskAssessmentProvider(bookingReference)),
        ),
        data: (result) {
          final screening = travellerAsync.value?.healthScreening;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const FlowSteps(current: 2),
              const SizedBox(height: AppSpacing.md),
              RiskStatusCard(
                  level: result.level, explanation: result.explanation),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Factors'),
              _factorCard(
                context,
                icon: Icons.public_outlined,
                title: 'Travel history',
                value: result.countryMatch
                    ? '${result.matchedCountry} — flagged country'
                    : 'No flagged country in the last 21 days',
                tone: result.countryMatch
                    ? StatusTone.warning
                    : StatusTone.success,
              ),
              _factorCard(
                context,
                icon: Icons.monitor_heart_outlined,
                title: 'Symptoms',
                value: screening == null
                    ? '—'
                    : (screening.symptoms.isEmpty
                        ? 'No symptoms reported'
                        : '${screening.symptomCount} reported: ${screening.symptoms.join(', ')}'),
                tone: result.symptomCount >= 3
                    ? StatusTone.warning
                    : StatusTone.neutral,
              ),
              _factorCard(
                context,
                icon: Icons.person_search_outlined,
                title: 'Exposure',
                value: result.hasExposure
                    ? 'Exposure to a sick or deceased person reported'
                    : 'No exposure reported',
                tone: result.hasExposure
                    ? StatusTone.danger
                    : StatusTone.success,
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Recommendation'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.verified_outlined,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(result.recommendation,
                                style: text.titleSmall),
                            const SizedBox(height: 4),
                            Text(
                              'Assessed ${DateFormat('d MMM yyyy, HH:mm').format(result.assessedAt)}',
                              style: text.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'This assessment is decision support only. The final entry decision belongs to the officer.',
                style: text.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _factorCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required StatusTone tone,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.base),
          ),
          child: Icon(icon,
              color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(value),
        trailing: StatusChip(
          label: tone == StatusTone.success ? 'OK' : 'Flag',
          tone: tone,
        ),
      ),
    );
  }
}
