import 'package:afyamsafiri_poe/features/decisions/data/models/decision_type.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../core/widgets/flow_steps.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/models/decision.dart';

/// Receipt for a recorded decision: hero confirmation, decision chip,
/// sync state, and the two things an officer does next.
class DecisionRecordedScreen extends StatelessWidget {
  final Decision decision;

  const DecisionRecordedScreen({super.key, required this.decision});

  StatusTone _tone(DecisionType type) {
    switch (type) {
      case DecisionType.cleared:
        return StatusTone.success;
      case DecisionType.referred:
        return StatusTone.info;
      case DecisionType.quarantined:
        return StatusTone.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AfyaAppBar(
        title: 'Decision Recorded',
        subtitle:
            'Step 4 of 4 • Done • ${AfyaAppBar.shortRef(decision.bookingReference)}',
        showBack: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const FlowSteps(current: 4),
              const SizedBox(height: AppSpacing.md),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppStatus.success
                            .withValues(alpha: 0.30),
                        width: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppStatus.successBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppStatus.success
                              .withValues(alpha: 0.30),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_circle_outline,
                        color: AppStatus.success, size: 44),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              StatusChip(
                label: decision.type.label,
                tone: _tone(decision.type),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Traveller has been ${decision.type.description.toLowerCase()}.',
                style: text.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row(context, 'Booking', decision.bookingReference),
                      const Divider(height: AppSpacing.lg),
                      _row(context, 'Officer', decision.officerName),
                      const Divider(height: AppSpacing.lg),
                      _row(context, 'Point of Entry', decision.pointOfEntry),
                      const Divider(height: AppSpacing.lg),
                      _row(
                          context,
                          'Date / Time',
                          DateFormat('d MMM yyyy, HH:mm')
                              .format(decision.timestamp)),
                      const Divider(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sync Status',
                              style: text.labelMedium),
                          StatusChip(
                            label: decision.synced
                                ? 'Synced'
                                : 'Saved on device',
                            tone: decision.synced
                                ? StatusTone.success
                                : StatusTone.warning,
                            icon: decision.synced
                                ? Icons.cloud_done_outlined
                                : Icons.cloud_off_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.scan),
                child: const Text('Scan Next Traveller'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: const Text('Return to Dashboard'),
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
