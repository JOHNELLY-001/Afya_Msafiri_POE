import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/constants.dart';
import '../../../../app/design_tokens.dart';
import '../../../../shared/components/stat_card.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/providers/sync_provider.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../risk_assessment/data/repositories/risk_countries_repository.dart';
import '../../../synchronization/presentation/widgets/offline_banner.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final pendingCount = ref.watch(pendingSyncCountProvider).value ?? 0;
    final riskCountries =
        ref.watch(riskCountryNamesProvider).value ?? const <String>[];
    final riskCount = ref.watch(riskCountryNamesProvider).value?.length;
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AfyaAppBar(
        title: 'Dashboard',
        subtitle:
            'On duty at ${session.selectedPoe?.name ?? 'No station selected'}',
        showBack: false,
        // Sync-status icon is added by AfyaAppBar itself; profile menu
        // replaces the old standalone log-out button.
        actions: const [_ProfileMenu()],
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
                    // Officer identity header.
                    // Row(
                    //   children: [
                    //     InitialsAvatar(
                    //         name: session.officer?.name ?? '?', radius: 26),
                    //     const SizedBox(width: AppSpacing.md),
                    //     Expanded(
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             session.officer?.name ?? 'Officer',
                    //             style: text.headlineSmall,
                    //           ),
                    //           const SizedBox(height: 2),
                    //           Text(
                    //             session.officer?.role ??
                    //                 'Health Screening Officer',
                    //             style: text.bodyMedium,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: AppSpacing.md),
                    // Duty station strip.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: colors.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('On duty at',
                                    style: text.labelMedium),
                                const SizedBox(height: 2),
                                Text(
                                  [
                                    session.selectedPoe?.name ?? 'Not selected',
                                    if (session.selectedPoe?.borderType !=
                                        null)
                                      session.selectedPoe!.borderType!,
                                  ].join(' · '),
                                  style: text.titleMedium,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.pointOfEntry),
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const SectionHeader(title: 'Screening'),
                    // Hero scan action.
                    _ScanHero(
                      color: colors.primary,
                      onScanPressed: () => context.push(AppRoutes.scan),
                      // onManualPressed: () =>
                      //     context.push(AppRoutes.manualEntry),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const SectionHeader(title: 'Today at a glance'),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Pending Sync',
                            value: '$pendingCount',
                            icon: Icons.sync_outlined,
                            onTap: () =>
                                context.push(AppRoutes.syncCenter),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: StatCard(
                            title: 'Flagged Countries',
                            value: riskCount?.toString() ?? '…',
                            icon: Icons.flag_outlined,
                            onTap: () => _showFlaggedCountries(
                                context, riskCountries),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const SectionHeader(title: 'More'),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.cloud_upload_outlined,
                            label: 'Sync center',
                            onTap: () =>
                                context.push(AppRoutes.syncCenter),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.monitor_heart_outlined,
                            label: 'Diagnostics',
                            onTap: () =>
                                context.push(AppRoutes.syncDiagnostics),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanHero extends StatelessWidget {
  final Color color;
  final VoidCallback onScanPressed;
  // final VoidCallback onManualPressed;

  const _ScanHero({
    required this.color,
    required this.onScanPressed,
    // required this.onManualPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.75)],
        ),
        // Guide: hero banner uses radius-xl 28 + shadow-card.
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.qr_code_scanner_outlined,
              color: Colors.white, size: 40),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Scan Traveller QR',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Scan the traveller booking QR code to begin screening.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onScanPressed,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Open Scanner'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.primaryBtn),
                ),
              ),
            ),
          ),
          // const SizedBox(height: AppSpacing.sm),
          // SizedBox(
          //   width: double.infinity,
          //   child: TextButton(
          //     onPressed: onManualPressed,
          //     style: TextButton.styleFrom(foregroundColor: Colors.white),
          //     child: const Text('Or enter booking reference manually'),
          //   ),
          // ),
        ],
      ),
    );
  }
}

/// Profile avatar in the AppBar: taps open a small popup with the officer
/// identity header, a "View account settings" option and a "Log out" option.
class _ProfileMenu extends ConsumerWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return PopupMenuButton<String>(
      tooltip: 'Profile',
      offset: const Offset(0, 48),
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      icon: InitialsAvatar(
        name: session.officer?.name ?? '?',
        radius: 16,
      ),
      onSelected: (value) async {
        switch (value) {
          case 'settings':
            _showAccountSheet(context, ref);
            break;
          case 'logout':
            await ref.read(sessionProvider.notifier).logout();
            if (context.mounted) context.go(AppRoutes.login);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Row(
            children: [
              InitialsAvatar(
                name: session.officer?.name ?? '?',
                radius: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.officer?.name ?? 'Officer',
                      style: text.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      session.officer?.role ?? 'Health Screening Officer',
                      style: text.labelMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.person_outlined, color: colors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              const Text('View account settings'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_outlined, color: colors.error, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text('Log out', style: TextStyle(color: colors.error)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Account settings sheet: read-only officer + duty-station summary.
void _showAccountSheet(BuildContext context, WidgetRef ref) {
  final session = ref.read(sessionProvider);
  final text = Theme.of(context).textTheme;

  Widget row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: text.labelMedium),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: text.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.xl),
      ),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Account settings'),
            Row(
              children: [
                InitialsAvatar(
                  name: session.officer?.name ?? '?',
                  radius: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.officer?.name ?? 'Officer',
                        style: text.titleLarge,
                      ),
                      Text(
                        session.officer?.role ??
                            'Health Screening Officer',
                        style: text.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    row('Username',
                        session.officer?.username ?? '—'),
                    const Divider(height: AppSpacing.md),
                    row('Duty station',
                        session.selectedPoe?.name ?? 'Not selected'),
                    const Divider(height: AppSpacing.md),
                    row('App version', 'v${AppConstants.appVersion}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Actual flagged-country list behind the "Flagged Countries" stat card.
void _showFlaggedCountries(BuildContext context, List<String> countries) {
  final text = Theme.of(context).textTheme;
  final colors = Theme.of(context).colorScheme;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.xl),
      ),
    ),
    builder: (context) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Flagged countries'),
              Text(
                countries.isEmpty
                    ? 'No flagged countries loaded yet.'
                    : '${countries.length} ${countries.length == 1 ? 'country' : 'countries'} currently flagged — travellers from these countries raise the risk score.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: countries.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.lg),
                          child: Text(
                            'Pull down on this sheet to close, then check your connection and reopen the dashboard.',
                            style: text.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: countries.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  AppRadius.base),
                            ),
                            child: Icon(Icons.flag_outlined,
                                color: colors.error, size: 20),
                          ),
                          title: Text(countries[i],
                              style: text.titleMedium),
                          trailing: Text(
                            '${i + 1}',
                            style: text.labelMedium,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md, horizontal: AppSpacing.sm),
          child: Column(
            children: [
              Icon(icon,
                  color: Theme.of(context).colorScheme.primary, size: 26),
              const SizedBox(height: AppSpacing.xs),
              Text(label,
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
