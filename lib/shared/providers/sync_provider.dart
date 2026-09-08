import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/synchronization/data/repositories/sync_repository.dart';
import 'connectivity_provider.dart';
import 'database_provider.dart';
import 'decision_provider.dart';

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final decisionRepository = ref.watch(decisionRepositoryProvider);
  return SyncRepository(db, decisionRepository);
});

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(syncRepositoryProvider);
  return repository.watchPendingCount();
});

/// Watches connectivity and triggers an automatic sync attempt
/// whenever the device comes back online. Keep this alive for
/// the whole app session — wire it up once in main app scope.
final autoSyncProvider = Provider<void>((ref) {
  ref.listen(isOnlineProvider, (previous, next) {
    final wasOffline = previous?.value == false;
    final isNowOnline = next.value == true;

    if (wasOffline && isNowOnline) {
      ref.read(syncRepositoryProvider).syncAll();
    }
  });
});