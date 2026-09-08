import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../core/utils/mask.dart';
import '../../../../shared/providers/traveller_provider.dart';

class TravellerRecordScreen extends ConsumerWidget {
  final String bookingReference;

  const TravellerRecordScreen({super.key, required this.bookingReference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final travellerAsync = ref.watch(travellerByReferenceProvider(bookingReference));

    return Scaffold(
      appBar: AppBar(title: const Text('Traveller Record')),
      body: travellerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text('Could not load traveller record.\n$err', textAlign: TextAlign.center),
          ),
        ),
        data: (traveller) => SafeArea(
          child: SingleChildScrollView(
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
                        Text(traveller.name, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: AppSpacing.sm),
                        _infoRow(context, 'Passport / ID', maskPassport(traveller.passportId)),
                        _infoRow(context, 'Nationality', traveller.nationality),
                        _infoRow(context, 'Booking Reference', traveller.bookingReference),
                        _infoRow(context, 'Arrival', DateFormat('d MMM yyyy, HH:mm').format(traveller.arrivalDateTime)),
                        _infoRow(context, 'Point of Entry', traveller.pointOfEntry),
                        _infoRow(context, 'Transport', traveller.transportReference),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _sectionCard(
                  context,
                  title: 'Travel History',
                  subtitle: '${traveller.travelHistory.length} countries in recent travel history',
                  onTap: () => context.push(AppRoutes.travelHistory, extra: bookingReference),
                ),
                const SizedBox(height: AppSpacing.sm),
                _sectionCard(
                  context,
                  title: 'Health Screening',
                  subtitle: traveller.healthScreening.reportedSymptoms.isEmpty
                      ? 'No symptoms reported'
                      : '${traveller.healthScreening.reportedSymptoms.length} symptom(s) reported',
                  onTap: () => context.push(AppRoutes.healthScreening, extra: bookingReference),
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: () => context.push(AppRoutes.riskAssessment, extra: bookingReference),
                  child: const Text('Continue to Risk Assessment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
      ),
    );
  }

  Widget _sectionCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.sm),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}