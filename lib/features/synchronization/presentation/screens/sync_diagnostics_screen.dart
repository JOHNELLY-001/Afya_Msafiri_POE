import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/config.dart';
import '../../../../shared/providers/connectivity_provider.dart';
import '../../../../shared/providers/sync_provider.dart';

class SyncDiagnosticsScreen extends ConsumerWidget {
  const SyncDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    final pendingCount = ref.watch(pendingSyncCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Diagnostics')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _row(context, 'Connectivity', isOnline ? 'Online' : 'Offline'),
          const Divider(height: AppSpacing.lg),
          _row(context, 'Pending Records', '$pendingCount'),
          const Divider(height: AppSpacing.lg),
          _row(context, 'Data Mode', AppConfig.useMockData ? 'Mock Data (development)' : 'Live AfyaMsafiri API'),
          const Divider(height: AppSpacing.lg),
          // FutureBuilder<PackageInfo>(
          //   future: PackageInfo.fromPlatform(),
          //   builder: (context, snapshot) {
          //     final info = snapshot.data;
          //     return _row(context, 'App Version', info != null ? '${info.version} (${info.buildNumber})' : '—');
          //   },
          // ),
          _row(context, 'App Version', '1.1.0 build(1)'),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}