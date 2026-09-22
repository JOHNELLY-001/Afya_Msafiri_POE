import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/design_tokens.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../widgets/scan_result_view.dart';

/// Shown when a booking code was already handled. Only states facts we
/// know (the reference itself) and routes to the live record — no
/// fabricated previous-decision details.
class AlreadyProcessedScreen extends StatelessWidget {
  final String bookingReference;

  const AlreadyProcessedScreen({super.key, required this.bookingReference});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AfyaAppBar(
        title: 'Already Processed',
        subtitle: AfyaAppBar.shortRef(bookingReference),
      ),
      body: ScanResultView(
        icon: Icons.history_outlined,
        iconBackground: AppStatus.infoBg,
        iconForeground: AppStatus.info,
        title: 'Traveller already processed',
        message:
            'This booking reference already has a screening record at a point of entry. Open the record to review it before taking further action.',
        bookingReference: bookingReference,
        primaryLabel: 'View Traveller Record',
        primaryIcon: Icons.person_search_outlined,
        onPrimary: () => context.push(
          AppRoutes.travellerRecord,
          extra: bookingReference,
        ),
        secondaryLabel: 'Scan Again',
        onSecondary: () => context.pop(),
      ),
    );
  }
}
