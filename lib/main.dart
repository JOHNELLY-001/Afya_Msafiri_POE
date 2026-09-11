import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'shared/providers/sync_provider.dart';
import 'shared/providers/d2touch_provider.dart';
import 'main.reflectable.dart';

void main() {
  initializeReflectable();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          ref.watch(autoSyncProvider);
          final init = ref.watch(d2TouchInstanceProvider);

          return init.when(
            loading: () => const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (e, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Text('Startup error: $e'),
                ),
              ),
            ),
            data: (_) => const AfyaMsafiriApp(),
          );
        },
      ),
    ),
  );
}