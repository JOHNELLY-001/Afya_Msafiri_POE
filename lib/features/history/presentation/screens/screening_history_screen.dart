import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../shared/providers/sync_provider.dart';

/// History bottom-nav tab: every locally recorded screening decision,
/// newest first. Tapping an entry opens the standalone history-detail page
/// (read-only record view), NOT the live scanning-flow traveller screen.
class ScreeningHistoryScreen extends ConsumerWidget {
  const ScreeningHistoryScreen({super.key});

  StatusTone _toneFor(String decisionType) {
    switch (decisionType.toLowerCase()) {
      case 'cleared':
        return StatusTone.success;
      case 'referred':
        return StatusTone.info;
      case 'quarantined':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync =
        ref.watch(syncRepositoryProvider).watchAll();
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AfyaAppBar(
        title: 'History',
        subtitle: 'Completed screenings • newest first',
        showBack: false,
      ),
      body: StreamBuilder(
        stream: historyAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('No screenings yet', style: text.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Completed screenings will appear here.',
                      style: text.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    item.synced
                        ? Icons.check_circle_outline
                        : Icons.sync_outlined,
                    color: item.synced
                        ? AppStatus.success
                        : AppStatus.warning,
                  ),
                  title: Text(
                    item.bookingReference,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${item.decisionType.toUpperCase()} · ${DateFormat('d MMM, HH:mm').format(item.timestamp)}'
                    '${item.synced ? '' : ' · Pending sync'}',
                  ),
                  trailing: StatusChip(
                    label: item.decisionType,
                    tone: _toneFor(item.decisionType),
                  ),
                  onTap: () => context.push(
                    AppRoutes.historyDetail,
                    extra: item.bookingReference,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
