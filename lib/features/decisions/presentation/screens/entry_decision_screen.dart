import 'package:afyamsafiri_poe/features/risk_assessment/data/models/risk_level.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../shared/providers/risk_provider.dart';
import '../../../../shared/providers/traveller_provider.dart';
import '../../data/models/decision_type.dart';
import '../widgets/decision_option_card.dart';

class EntryDecisionScreen extends ConsumerStatefulWidget {
  final String bookingReference;

  const EntryDecisionScreen({super.key, required this.bookingReference});

  @override
  ConsumerState<EntryDecisionScreen> createState() => _EntryDecisionScreenState();
}

class _EntryDecisionScreenState extends ConsumerState<EntryDecisionScreen> {
  DecisionType? _selected;

  @override
  Widget build(BuildContext context) {
    final travellerAsync = ref.watch(travellerByReferenceProvider(widget.bookingReference));
    final riskAsync = ref.watch(riskAssessmentProvider(widget.bookingReference));

    return Scaffold(
      appBar: AppBar(title: const Text('Entry Decision')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              travellerAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (traveller) => Text(traveller.name, style: Theme.of(context).textTheme.headlineMedium),
              ),
              const SizedBox(height: 4),
              riskAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (risk) => Text(risk.level.label, style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: AppSpacing.lg),
              DecisionOptionCard(
                type: DecisionType.cleared,
                selected: _selected == DecisionType.cleared,
                onTap: () => setState(() => _selected = DecisionType.cleared),
              ),
              const SizedBox(height: AppSpacing.sm),
              DecisionOptionCard(
                type: DecisionType.referred,
                selected: _selected == DecisionType.referred,
                onTap: () => setState(() => _selected = DecisionType.referred),
              ),
              const SizedBox(height: AppSpacing.sm),
              DecisionOptionCard(
                type: DecisionType.quarantined,
                selected: _selected == DecisionType.quarantined,
                onTap: () => setState(() => _selected = DecisionType.quarantined),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => context.push(
                  AppRoutes.confirmDecision,
                  extra: (bookingReference: widget.bookingReference, type: _selected!),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}