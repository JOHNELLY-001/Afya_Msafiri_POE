import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../core/widgets/flow_steps.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
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
  ConsumerState<ConfirmDecisionScreen> createState() =>
      _ConfirmDecisionScreenState();
}

class _ConfirmDecisionScreenState extends ConsumerState<ConfirmDecisionScreen> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  StatusTone _decisionTone(DecisionType type) {
    switch (type) {
      case DecisionType.cleared:
        return StatusTone.success;
      case DecisionType.referred:
        return StatusTone.info;
      case DecisionType.quarantined:
        return StatusTone.danger;
    }
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
      context.go(AppRoutes.decisionRecorded,
          extra: decision); // synced: false, shown as "saved on device"
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
    final travellerAsync = ref.watch(
        travellerByReferenceProvider(widget.draft.bookingReference));
    final submission = ref.watch(decisionControllerProvider);
    final text = Theme.of(context).textTheme;

    final isQuarantine = widget.draft.type == DecisionType.quarantined;

    return Scaffold(
      appBar: AfyaAppBar(
        title: 'Confirm Decision',
        subtitle:
            'Step 3 of 4 • ${AfyaAppBar.shortRef(widget.draft.bookingReference)}',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FlowSteps(current: 3),
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(title: 'Summary'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      travellerAsync.maybeWhen(
                        data: (t) => _row(
                            context, 'Traveller', t.fullName),
                        orElse: () => _row(
                            context, 'Booking', widget.draft.bookingReference),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Decision',
                              style: text.labelMedium),
                          StatusChip(
                            label: widget.draft.type.label,
                            tone: _decisionTone(widget.draft.type),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _row(context, 'Station',
                          ref.watch(sessionProvider).selectedPoe?.name ?? '—'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Officer notes'),
              TextField(
                controller: _notesController,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText:
                      'Why this decision? e.g. symptoms observed, documents checked…',
                ),
              ),
              if (isQuarantine) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppStatus.dangerBg,
                    borderRadius: BorderRadius.circular(AppRadius.base),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_outlined,
                          color: AppStatus.danger),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Quarantine restricts movement. Double-check the risk factors before confirming.',
                          style: text.bodyMedium?.copyWith(
                            color: AppStatus.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: submission.isLoading
                          ? null
                          : () => context.pop(),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed:
                          submission.isLoading ? null : _confirm,
                      style: isQuarantine
                          ? ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.error)
                          : null,
                      child: submission.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
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
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
