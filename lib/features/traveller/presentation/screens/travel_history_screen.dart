import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/design_tokens.dart';
import '../../../../shared/providers/traveller_provider.dart';

class TravelHistoryScreen extends ConsumerWidget {
  final String bookingReference;

  const TravelHistoryScreen({super.key, required this.bookingReference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final travellerAsync = ref.watch(travellerByReferenceProvider(bookingReference));

    return Scaffold(
      appBar: AppBar(title: const Text('Travel History')),
      body: travellerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Could not load travel history.\n$err')),
        data: (traveller) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: traveller.travelHistory.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final entry = traveller.travelHistory[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(entry.country, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: entry.period != null ? Text(entry.period!) : null,
              ),
            );
          },
        ),
      ),
    );
  }
}