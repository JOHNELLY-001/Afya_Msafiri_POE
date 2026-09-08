import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../shared/providers/connectivity_provider.dart';
import '../../../../shared/providers/sync_provider.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    final pendingCount = ref.watch(pendingSyncCountProvider).value ?? 0;

    if (isOnline && pendingCount == 0) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final color = isOnline ? colors.tertiary : colors.error;
    final label = isOnline
        ? '$pendingCount record${pendingCount == 1 ? '' : 's'} waiting to sync'
        : 'Offline — $pendingCount record${pendingCount == 1 ? '' : 's'} waiting to sync';

    return InkWell(
      onTap: () => context.push(AppRoutes.syncCenter),
      child: Container(
        width: double.infinity,
        color: color.withValues(alpha: 0.1),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
        child: Row(
          children: [
            Icon(isOnline ? Icons.sync : Icons.cloud_off, size: 16, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color))),
            Icon(Icons.chevron_right, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}