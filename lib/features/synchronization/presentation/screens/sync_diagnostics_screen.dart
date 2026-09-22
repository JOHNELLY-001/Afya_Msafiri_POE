import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../app/config.dart';
import '../../../../app/theme.dart';
import '../../../../core/widgets/page_hero.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../shared/providers/connectivity_provider.dart';
import '../../../../shared/providers/sync_provider.dart';

class SyncDiagnosticsScreen extends ConsumerWidget {
  const SyncDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    final pendingCount = ref.watch(pendingSyncCountProvider).value ?? 0;

    return Scaffold(
      appBar: AfyaAppBar(
        title: 'Sync Diagnostics',
        subtitle: isOnline ? 'Online • connection healthy' : 'Offline • on-device mode',
        actions: [
          IconButton(
            tooltip: 'Sync center',
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: () => context.push(AppRoutes.syncCenter),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          PageHero(
            icon: isOnline
                ? Icons.cloud_done_outlined
                : Icons.cloud_off_outlined,
            title: isOnline ? 'Online' : 'Offline',
            subtitle: isOnline
                ? 'Connection healthy — sync can run.'
                : 'Working offline — records stay on device.',
            from: AppTheme.primary,
            to: AppTheme.secondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Device state'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _row(context, 'Connectivity',
                      chip: StatusChip(
                        label: isOnline ? 'Online' : 'Offline',
                        tone: isOnline
                            ? StatusTone.success
                            : StatusTone.warning,
                        icon: isOnline
                            ? Icons.wifi_outlined
                            : Icons.wifi_off_outlined,
                      )),
                  const Divider(height: AppSpacing.lg),
                  _row(context, 'Pending Records',
                      chip: StatusChip(
                        label: '$pendingCount',
                        tone: pendingCount == 0
                            ? StatusTone.success
                            : StatusTone.warning,
                        icon: Icons.sync_outlined,
                      )),
                  const Divider(height: AppSpacing.lg),
                  _row(context, 'Data Mode',
                      chip: StatusChip(
                        label: AppConfig.useMockData
                            ? 'Mock (dev)'
                            : 'Live API',
                        tone: AppConfig.useMockData
                            ? StatusTone.neutral
                            : StatusTone.info,
                      )),
                  const Divider(height: AppSpacing.lg),
                  _row(context, 'App Version',
                      value: '1.1.0 build(1)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.syncCenter),
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Open Sync Center'),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label,
      {StatusChip? chip, String? value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        if (chip != null) chip,
        if (value != null)
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
