import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/flow_steps.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../shared/providers/traveller_provider.dart';

class HealthScreeningScreen extends ConsumerWidget {
  final String bookingReference;

  const HealthScreeningScreen({super.key, required this.bookingReference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final travellerAsync =
        ref.watch(travellerByReferenceProvider(bookingReference));

    return Scaffold(
      appBar: AfyaAppBar(
        title: 'Health Screening',
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
            const AppLoadingState(message: 'Loading screening details…'),
        error: (err, _) => AppErrorState(
          message: '$err',
          onRetry: () =>
              ref.invalidate(travellerByReferenceProvider(bookingReference)),
        ),
        data: (traveller) {
          final screening = traveller.healthScreening;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const FlowSteps(current: 1),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Reported symptoms · last 21 days'),
              if (screening.symptoms.isEmpty)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline,
                        color: AppStatus.success),
                    title: Text('No symptoms reported'),
                    subtitle: Text(
                        'The traveller declared none of the 17 tracked symptoms.'),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: screening.symptoms
                          .map((s) => StatusChip(
                                label: s,
                                tone: StatusTone.warning,
                                icon: Icons.warning_amber_outlined,
                              ))
                          .toList(),
                    ),
                  ),
                ),
              if (screening.otherSymptoms != null &&
                  screening.otherSymptoms!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: ListTile(
                    title: const Text('Other symptoms'),
                    subtitle: Text(screening.otherSymptoms!),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Exposure · last 21 days'),
              _exposureRow(
                context,
                'Visited or resided in an outbreak area',
                'Ebola, Corona or Yellow fever area',
                screening.visitedOutbreakArea,
              ),
              _exposureRow(
                context,
                'Cared for a sick person',
                'With the symptoms above',
                screening.caredForSickPerson,
              ),
              _exposureRow(
                context,
                'Participated in a burial',
                'Of a deceased person',
                screening.participatedInBurial,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _exposureRow(
      BuildContext context, String title, String subtitle, bool value) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: StatusChip(
          label: value ? 'Yes' : 'No',
          tone: value ? StatusTone.danger : StatusTone.success,
        ),
      ),
    );
  }
}
