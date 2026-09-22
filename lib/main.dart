import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'main.reflectable.dart';

/// Launch goes straight into the app (splash route `/`) with no interim
/// loading page: D2Touch warms up in the background (see [AfyaMsafiriApp])
/// and the splash screen itself awaits/restores the session.
void main() {
  initializeReflectable();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: AfyaMsafiriApp(),
    ),
  );
}
