import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/providers/d2touch_provider.dart';
import '../shared/providers/sync_provider.dart';
import 'routes.dart';
import 'theme.dart';

class AfyaMsafiriApp extends ConsumerWidget {
  const AfyaMsafiriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Background-only: kick off D2Touch init + autosync without blocking
    // the UI. The splash screen awaits the session when it needs it.
    ref.watch(autoSyncProvider);
    ref.watch(d2TouchInstanceProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AfyaMsafiri Manager',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
