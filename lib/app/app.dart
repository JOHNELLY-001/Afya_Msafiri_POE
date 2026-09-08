import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme.dart';

class AfyaMsafiriApp extends StatelessWidget {
  const AfyaMsafiriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AfyaMsafiri Manager',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}