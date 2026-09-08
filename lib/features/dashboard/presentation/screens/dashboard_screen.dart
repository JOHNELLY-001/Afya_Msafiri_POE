import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/design_tokens.dart';
import '../../../../shared/components/stat_card.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../app/routes.dart';
import '../../../synchronization/presentation/widgets/offline_banner.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good morning', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(session.officer?.name ?? '—', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(session.officer?.role ?? '', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.lg),
                    _PoeStatus(poeName: session.selectedPoe?.name ?? 'Not selected'),
                    const SizedBox(height: AppSpacing.lg),
                    _ScanCard(
                      color: colors.primaryContainer,
                      onScanPressed: () => context.push(AppRoutes.scan),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Row(
                      children: [
                        Expanded(child: StatCard(title: 'Processed', value: '0', icon: Icons.people_outline)),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(child: StatCard(title: 'Pending Sync', value: '0', icon: Icons.sync)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          // Wired up as each destination feature is implemented.
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}

class _PoeStatus extends StatelessWidget {
  final String poeName;
  const _PoeStatus({required this.poeName});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(Icons.location_on, color: colors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Duty Station', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 3),
                  Text(poeName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: colors.secondary),
          ],
        ),
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final Color color;
  final VoidCallback onScanPressed;
  const _ScanCard({required this.color, required this.onScanPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.qr_code_scanner, color: Colors.white, size: 42),
          const SizedBox(height: AppSpacing.md),
          const Text('Scan Traveller QR', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'Scan the traveller booking QR code to begin screening.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onScanPressed,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Open Scanner'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: color),
            ),
          ),
        ],
      ),
    );
  }
}