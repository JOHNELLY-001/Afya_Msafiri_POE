import 'package:d2_touch/d2_touch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/dhis2_config.dart';

/// D2Touch is a singleton, created via the static async init() factory —
/// never via D2Touch(). Calling init() again later just returns the
/// same already-initialized instance, so this is safe to watch anywhere.
final d2TouchInstanceProvider = FutureProvider<D2Touch>((ref) async {
  return D2Touch.init(
    locale: 'en',
    databaseName: Dhis2Config.databaseName,
  );
});