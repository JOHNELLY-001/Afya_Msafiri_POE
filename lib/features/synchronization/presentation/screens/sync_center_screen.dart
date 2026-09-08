import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/design_tokens.dart';
import '../../../../shared/providers/connectivity_provider.dart';
import '../../../../shared/providers/sync_provider.dart';
import '../../data/local/app_database.dart';

class SyncCenterScreen extends ConsumerWidget {
  const SyncCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    final pendingAsync = ref.watch(syncRepositoryProvider).watchPending();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Synchronization'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isOnline
                ? () async {
              final (succeeded, failed) = await ref.read(syncRepositoryProvider).syncAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Synced $succeeded record(s), $failed failed.')),
                );
              }
            }
                : null,
          ),
        ],
      ),
      body: StreamBuilder<List<QueuedDecision>>(
        stream: pendingAsync,
        builder: (context, snapshot) {
          final pending = snapshot.data ?? [];

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                color: (isOnline ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error)
                    .withValues(alpha: 0.08),
                child: Text(
                  isOnline
                      ? (pending.isEmpty ? 'Up to date' : '${pending.length} record(s) pending')
                      : 'Offline — sync will resume automatically',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: pending.isEmpty
                    ? Center(
                  child: Text('No pending synchronization', style: Theme.of(context).textTheme.bodyMedium),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: pending.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = pending[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.bookingReference, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${item.decisionType.toUpperCase()} · ${DateFormat('d MMM, HH:mm').format(item.timestamp)}'
                              '${item.syncError != null ? '\nFailed: ${item.syncError}' : ''}',
                        ),
                        trailing: Text(item.syncError != null ? 'Failed' : 'Pending'),
                      ),
                    );
                  },
                ),
              ),
              if (pending.any((p) => p.syncError != null))
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: OutlinedButton(
                    onPressed: () => ref.read(syncRepositoryProvider).retryFailed(),
                    child: const Text('Retry Failed Items'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}