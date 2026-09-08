import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/design_tokens.dart';
import '../../../../shared/providers/traveller_provider.dart';

class HealthScreeningScreen extends ConsumerWidget {
  final String bookingReference;

  const HealthScreeningScreen({super.key, required this.bookingReference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final travellerAsync = ref.watch(travellerByReferenceProvider(bookingReference));

    return Scaffold(
      appBar: AppBar(title: const Text('Health Screening')),
      body: travellerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Could not load screening details.\n$err')),
        data: (traveller) {
          final screening = traveller.healthScreening;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Card(
                child: ListTile(
                  title: const Text('Vaccination Status'),
                  subtitle: Text(screening.vaccinationStatus),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: ListTile(
                  title: const Text('Reported Symptoms'),
                  subtitle: Text(
                    screening.reportedSymptoms.isEmpty
                        ? 'None reported'
                        : screening.reportedSymptoms.join(', '),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...screening.additionalAnswers.entries.map(
                    (e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Card(
                    child: ListTile(title: Text(e.key), subtitle: Text(e.value)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}