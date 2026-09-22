import 'package:afyamsafiri_poe/features/risk_assessment/data/models/risk_level.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../core/widgets/flow_steps.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../shared/providers/risk_provider.dart';
import '../../../../shared/providers/traveller_provider.dart';
import '../../data/models/decision_type.dart';
import '../widgets/decision_option_card.dart';

class EntryDecisionScreen extends ConsumerStatefulWidget {
  final String bookingReference;

  const EntryDecisionScreen({super.key, required this.bookingReference});

  @override
  ConsumerState<EntryDecisionScreen> createState() =>
      _EntryDecisionScreenState();
}

class _EntryDecisionScreenState extends ConsumerState<EntryDecisionScreen> {
  DecisionType? _selected;

  StatusTone _riskTone(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return StatusTone.success;
      case RiskLevel.elevated:
        return StatusTone.warning;
      case RiskLevel.high:
        return StatusTone.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final travellerAsync =
        ref.watch(travellerByReferenceProvider(widget.bookingReference));
    final riskAsync =
        ref.watch(riskAssessmentProvider(widget.bookingReference));

    return Scaffold(
      appBar: AfyaAppBar(
        title: 'Entry Decision',
        subtitle:
            'Step 3 of 4 • ${AfyaAppBar.shortRef(widget.bookingReference)}',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FlowSteps(current: 3),
              const SizedBox(height: AppSpacing.md),
              // Who + risk at a glance.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      travellerAsync.maybeWhen(
                        data: (t) => InitialsAvatar(
                            name: t.fullName, radius: 22),
                        orElse: () => InitialsAvatar(
                            name: '?', radius: 22),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            travellerAsync.maybeWhen(
                              data: (t) => Text(t.fullName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                              orElse: () => Text('Loading traveller…',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium),
                            ),
                            const SizedBox(height: 4),
                            riskAsync.maybeWhen(
                              data: (r) => StatusChip(
                                label: r.level.label,
                                tone: _riskTone(r.level),
                              ),
                              orElse: () => const StatusChip(
                                label: 'Assessing…',
                                tone: StatusTone.neutral,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Your decision'),
              DecisionOptionCard(
                type: DecisionType.cleared,
                selected: _selected == DecisionType.cleared,
                onTap: () =>
                    setState(() => _selected = DecisionType.cleared),
              ),
              const SizedBox(height: AppSpacing.sm),
              DecisionOptionCard(
                type: DecisionType.referred,
                selected: _selected == DecisionType.referred,
                onTap: () =>
                    setState(() => _selected = DecisionType.referred),
              ),
              const SizedBox(height: AppSpacing.sm),
              DecisionOptionCard(
                type: DecisionType.quarantined,
                selected: _selected == DecisionType.quarantined,
                onTap: () =>
                    setState(() => _selected = DecisionType.quarantined),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => context.push(
                          AppRoutes.confirmDecision,
                          extra: (
                            bookingReference: widget.bookingReference,
                            type: _selected!
                          ),
                        ),
                child: Text(_selected == null
                    ? 'Select a decision'
                    : 'Continue · ${_selected!.label}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
