import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../shared/providers/connectivity_provider.dart';
import '../../shared/providers/sync_provider.dart';

/// Shared AppBar for every screen from Dashboard onwards.
///
/// Guide compliance: Inter, white surface + Deep Slate title (dark variant is
/// scanner-only), outlined icons, Primary Blue active / Muted Gray inactive,
/// caption subtitle.
///
/// Standard features (opt-out per screen):
/// - [subtitle]: duty station / step / short booking ref under the title.
/// - Connectivity + pending-sync indicator (tap → Sync Center).
/// - Consistent outlined back/close leading via [showBack]/[leadingOverride].
/// - Per-screen [actions] appended after the sync indicator.
class AfyaAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final Widget? leadingOverride;
  final List<Widget>? actions;
  final bool showSyncStatus;
  final bool dark;

  const AfyaAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.leadingOverride,
    this.actions,
    this.showSyncStatus = true,
    this.dark = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// Short ref for subtitles: `TSFA20260914065665` → `TSFA…5665`.
  static String shortRef(String ref) {
    final v = ref.trim();
    if (v.length <= 10) return v;
    return '${v.substring(0, 4)}…${v.substring(v.length - 4)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final canPop = Navigator.of(context).canPop();

    Widget? leading;
    if (leadingOverride != null) {
      leading = leadingOverride;
    } else if (!showBack) {
      leading = null;
    } else if (canPop) {
      leading = IconButton(
        icon: const Icon(Icons.arrow_back_outlined),
        tooltip: 'Back',
        onPressed: () => context.pop(),
      );
    }

    final titleWidget = subtitle == null
        ? Text(title)
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title),
              Text(
                subtitle!,
                style: (text.labelSmall ?? const TextStyle(fontSize: 11))
                    .copyWith(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.70)
                      : colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );

    final trailing = <Widget>[
      if (showSyncStatus && !dark) _SyncStatusButton(),
      ...?actions,
    ];

    if (dark) {
      return AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: showBack,
        leading: leading,
        centerTitle: true,
        title: titleWidget,
        actions: trailing.isEmpty ? null : trailing,
      );
    }

    return AppBar(
      automaticallyImplyLeading: showBack,
      leading: leading,
      centerTitle: true,
      title: titleWidget,
      actions: trailing.isEmpty ? null : trailing,
    );
  }
}

/// Connectivity + pending-sync indicator used by [AfyaAppBar].
/// - Offline → `cloud_off_outlined` urgent red.
/// - Online + pending → `sync_outlined` amber with count badge.
/// - Online + clean → `cloud_done_outlined` success green.
/// Tap opens Sync Center (no-op when already there).
class _SyncStatusButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    final pending = ref.watch(pendingSyncCountProvider).value ?? 0;

    final (IconData icon, Color fg) = !isOnline
        ? (Icons.cloud_off_outlined, colors.error)
        : pending > 0
            ? (Icons.sync_outlined, const Color(0xFFD97706))
            : (Icons.cloud_done_outlined, const Color(0xFF22C55E));

    final location = GoRouterState.of(context).matchedLocation;
    final alreadyThere = location == AppRoutes.syncCenter;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(icon, color: fg),
          tooltip: !isOnline
              ? 'Offline — $pending pending'
              : pending > 0
                  ? '$pending pending sync'
                  : 'Up to date',
          onPressed: alreadyThere
              ? null
              : () => context.push(AppRoutes.syncCenter),
        ),
        if (pending > 0)
          Positioned(
            right: 6,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: fg,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                pending > 99 ? '99+' : '$pending',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
