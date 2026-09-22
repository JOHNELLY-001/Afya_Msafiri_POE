import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/flow_steps.dart';
import '../../../../core/widgets/page_hero.dart';
import '../../../../shared/providers/traveller_provider.dart';

/// 21-day country timeline: numbered nodes on a rail, newest first.
class TravelHistoryScreen extends ConsumerWidget {
  final String bookingReference;

  const TravelHistoryScreen({super.key, required this.bookingReference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final travellerAsync =
        ref.watch(travellerByReferenceProvider(bookingReference));

    return Scaffold(
      appBar: AfyaAppBar(
        title: 'Travel History',
        subtitle: 'Step 1 of 4 • ${AfyaAppBar.shortRef(bookingReference)}',
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
              Text('Step 1 of 4 • Traveller verification',
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.riskAssessment,
                      extra: bookingReference),
                  child: const Text('Continue to Risk Assessment'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: travellerAsync.when(
        loading: () =>
            const AppLoadingState(message: 'Loading travel history…'),
        error: (err, _) => AppErrorState(
          message: '$err',
          onRetry: () =>
              ref.invalidate(travellerByReferenceProvider(bookingReference)),
        ),
        data: (traveller) {
          final history = traveller.travelHistory;
          if (history.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.luggage_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: AppSpacing.sm),
                    Text('No countries recorded',
                        style:
                            Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('No countries recorded for the last 21 days.',
                        style:
                            Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: history.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    children: [
                      const FlowSteps(current: 1),
                      const SizedBox(height: AppSpacing.md),
                      PageHero(
                        icon: Icons.public_outlined,
                        title:
                            '${history.length} ${history.length == 1 ? 'country' : 'countries'} · 21 days',
                        subtitle:
                            'Newest first — flagged countries drive the risk score.',
                        from: AppTheme.primary,
                        to: AppTheme.secondary,
                      ),
                    ],
                  ),
                );
              }
              final entry = history[index - 1];
              final isLast = index == history.length;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$index',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin:
                                  const EdgeInsets.symmetric(vertical: 4),
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Card(
                        margin: EdgeInsets.only(
                            bottom: isLast ? 0 : AppSpacing.sm),
                        child: ListTile(
                          title: Text(
                            entry.country,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium,
                          ),
                          subtitle: entry.period != null
                              ? Text(entry.period!)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
