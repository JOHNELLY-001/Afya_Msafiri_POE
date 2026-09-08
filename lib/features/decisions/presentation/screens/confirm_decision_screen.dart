import 'package:afyamsafiri_poe/features/risk_assessment/data/models/risk_level.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../shared/providers/risk_provider.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/providers/traveller_provider.dart';
import '../../../../shared/providers/decision_provider.dart';
import '../../data/models/decision.dart';
import '../../data/models/decision_type.dart';
import '../../../../shared/providers/connectivity_provider.dart';
import '../../../../shared/providers/sync_provider.dart';

typedef DecisionDraft = ({String bookingReference, DecisionType type});

class ConfirmDecisionScreen extends ConsumerStatefulWidget {
  final DecisionDraft draft;

  const ConfirmDecisionScreen({super.key, required this.draft});

  @override
  ConsumerState<ConfirmDecisionScreen> createState() => _ConfirmDecisionScreenState();
}

class _ConfirmDecisionScreenState extends ConsumerState<ConfirmDecisionScreen> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final session = ref.read(sessionProvider);
    final isOnline = await ref.read(connectivityServiceProvider).isOnline;

    final decision = Decision(
      bookingReference: widget.draft.bookingReference,
      type: widget.draft.type,
      notes: _notesController.text.trim(),
      officerName: session.officer?.name ?? 'Unknown Officer',
      pointOfEntry: session.selectedPoe?.name ?? 'Unknown Point of Entry',
      timestamp: DateTime.now(),
      synced: false,
    );

    if (!isOnline) {
      await ref.read(syncRepositoryProvider).enqueue(decision);
      if (!mounted) return;
      context.go(AppRoutes.decisionRecorded, extra: decision); // synced: false, shown as "saved on device"
      return;
    }

    await ref.read(decisionControllerProvider.notifier).submit(decision);

    if (!mounted) return;

    final result = ref.read(decisionControllerProvider);
    result.when(
      data: (d) {
        if (d != null) context.go(AppRoutes.decisionRecorded, extra: d);
      },
      loading: () {},
      error: (err, _) async {
        // Online submission failed mid-flight — fall back to the queue
        // rather than losing the officer's decision.
        await ref.read(syncRepositoryProvider).enqueue(decision);
        if (!mounted) return;
        context.go(AppRoutes.decisionRecorded, extra: decision);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final travellerAsync = ref.watch(travellerByReferenceProvider(widget.draft.bookingReference));
    final riskAsync = ref.watch(riskAssessmentProvider(widget.draft.bookingReference));
    final submission = ref.watch(decisionControllerProvider);

    final isQuarantine = widget.draft.type == DecisionType.quarantined;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Entry Decision')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      travellerAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (t) => _row(context, 'Traveller', t.name),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _row(context, 'Decision', widget.draft.type.description),
                      const SizedBox(height: AppSpacing.sm),
                      riskAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (r) => _row(context, 'Risk', r.level.label),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Officer Notes', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Add notes...'),
              ),
              if (isQuarantine) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.base),
                    border: Border.all(color: Theme.of(context).colorScheme.error),
                  ),
                  child: Text(
                    'Quarantine is a consequential action. Confirm this decision carefully.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: submission.isLoading ? null : () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: submission.isLoading ? null : _confirm,
                      style: isQuarantine
                          ? ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error)
                          : null,
                      child: submission.isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text('Confirm Decision'),
                    ),
                  ),
                ],
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
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}