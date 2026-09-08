import 'package:afyamsafiri_poe/features/risk_assessment/data/models/risk_level.dart';
import 'package:afyamsafiri_poe/features/traveller/data/models/traveller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/design_tokens.dart';
import '../../../../shared/providers/risk_provider.dart';
import '../../../../shared/providers/traveller_provider.dart';

class RiskDetailsScreen extends ConsumerWidget {
  final String bookingReference;

  const RiskDetailsScreen({super.key, required this.bookingReference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskAsync = ref.watch(riskAssessmentProvider(bookingReference));
    final travellerAsync = ref.watch(travellerByReferenceProvider(bookingReference));

    return Scaffold(
      appBar: AppBar(title: const Text('Risk Assessment Details')),
      body: riskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Could not load risk details.\n$err')),
        data: (result) {
          final screening = travellerAsync.value?.healthScreening;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _row(context, 'Matched Risk Factor', result.matchedCountry ?? 'None'),
                const Divider(height: AppSpacing.lg),
                _row(context, 'Country of Travel', result.matchedCountry ?? '—'),
                const Divider(height: AppSpacing.lg),
                _row(context, 'Current Risk Classification', result.level.label),
                const Divider(height: AppSpacing.lg),
                _row(
                  context,
                  'Screening Responses',
                  screening == null
                      ? '—'
                      : (screening.reportedSymptoms.isEmpty ? 'No symptoms reported' : screening.reportedSymptoms.join(', ')),
                ),
                const Divider(height: AppSpacing.lg),
                _row(context, 'Assessment Timestamp', DateFormat('d MMM yyyy, HH:mm').format(result.assessedAt)),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recommendation', style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 4),
                        Text(result.recommendation, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'This assessment is decision support only. The final entry decision belongs to the officer.',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

