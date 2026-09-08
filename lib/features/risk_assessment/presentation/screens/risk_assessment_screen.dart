import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../shared/providers/risk_provider.dart';
import '../widgets/risk_status_card.dart';
import '../../../decisions/presentation/screens/entry_decision_screen.dart'; // for AppRoutes usage context only if needed

class RiskAssessmentScreen extends ConsumerWidget {
  final String bookingReference;

  const RiskAssessmentScreen({super.key, required this.bookingReference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskAsync = ref.watch(riskAssessmentProvider(bookingReference));

    return Scaffold(
      appBar: AppBar(title: const Text('Risk Assessment')),
      body: riskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Could not run risk assessment.\n$err')),
        data: (result) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RiskStatusCard(level: result.level, explanation: result.explanation),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Assessed ${DateFormat('d MMM yyyy, HH:mm').format(result.assessedAt)}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'This is system-based decision support, not a diagnosis. '
                      'The final entry decision belongs to the officer.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => context.push(AppRoutes.riskDetails, extra: bookingReference),
                  child: const Text('View Risk Details'),
                ),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton(
                  onPressed: () => context.push(AppRoutes.entryDecision, extra: bookingReference),
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