import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'shared/providers/sync_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          ref.watch(autoSyncProvider); // keeps the connectivity listener alive
          return const AfyaMsafiriApp();
        },
      ),
    ),
  );
}