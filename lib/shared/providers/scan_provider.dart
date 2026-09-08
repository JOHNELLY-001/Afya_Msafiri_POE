import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/scanning/data/repositories/scan_repository.dart';

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepository();
});