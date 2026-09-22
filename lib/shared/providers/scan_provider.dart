import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/mediator_client.dart';
import '../../features/scanning/data/repositories/scan_repository.dart';

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepository(dio: ref.watch(mediatorClientProvider));
});
