import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../core/widgets/page_hero.dart';
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
      appBar: AfyaAppBar(
        title: 'Data Synchronization',
        subtitle: isOnline ? 'Online • sync ready' : 'Offline • queued safely',
        showSyncStatus: false,
        actions: [
          IconButton(
            tooltip: 'Retry sync',
            icon: const Icon(Icons.refresh_outlined),
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
          IconButton(
            tooltip: 'Diagnostics',
            icon: const Icon(Icons.monitor_heart_outlined),
            onPressed: () => context.push(AppRoutes.syncDiagnostics),
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
                margin: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: PageHero(
                  icon: pending.isEmpty
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_upload_outlined,
                  title: isOnline
                      ? (pending.isEmpty
                          ? 'Up to date'
                          : '${pending.length} record(s) pending')
                      : 'Offline — will resume',
                  subtitle: isOnline
                      ? 'Pull to sync or tap refresh above.'
                      : 'Records are safe on device and sync automatically.',
                  from: AppTheme.primary,
                  to: AppTheme.secondary,
                ),
              ),
              Expanded(
                child: pending.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline),
                            const SizedBox(height: AppSpacing.sm),
                            Text('No pending synchronization',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium),
                            const SizedBox(height: 4),
                            Text(
                                'Completed screenings will queue here when offline.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium),
                          ],
                        ),
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
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                  child: OutlinedButton(
                    onPressed: () => ref.read(syncRepositoryProvider).retryFailed(),
                    child: const Text('Retry Failed Items'),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    pending.any((p) => p.syncError != null) ? 0 : AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.md),
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.syncDiagnostics),
                  icon: const Icon(Icons.monitor_heart_outlined),
                  label: const Text('View Sync Diagnostics'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}