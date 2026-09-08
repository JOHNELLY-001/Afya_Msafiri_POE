import 'package:afyamsafiri_poe/features/decisions/data/models/decision_type.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../data/models/decision.dart';

class DecisionRecordedScreen extends StatelessWidget {
  final Decision decision;

  const DecisionRecordedScreen({super.key, required this.decision});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Decision Recorded'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, size: 56, color: colors.secondary),
              const SizedBox(height: AppSpacing.md),
              Text('Decision Recorded', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Traveller has been ${decision.type.description.toLowerCase()}.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row(context, 'Decision', decision.type.label),
                      const Divider(height: AppSpacing.lg),
                      _row(context, 'Officer', decision.officerName),
                      const Divider(height: AppSpacing.lg),
                      _row(context, 'Point of Entry', decision.pointOfEntry),
                      const Divider(height: AppSpacing.lg),
                      _row(context, 'Date / Time', DateFormat('d MMM yyyy, HH:mm').format(decision.timestamp)),
                      const Divider(height: AppSpacing.lg),
                      _row(
                        context,
                        'Sync Status',
                        decision.synced ? 'Synced with AfyaMsafiri' : 'Saved securely on this device',
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: const Text('Return to Dashboard'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.scan),
                child: const Text('Scan Next Traveller'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}