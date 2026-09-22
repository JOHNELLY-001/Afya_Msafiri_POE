import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../widgets/scan_result_view.dart';

class InvalidQrScreen extends StatelessWidget {
  final String? reason;

  const InvalidQrScreen({super.key, this.reason});

  @override
  Widget build(BuildContext context) {
    final expired = reason == 'expired';
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AfyaAppBar(
        title: expired ? 'Booking Expired' : 'QR Code Not Recognized',
        subtitle: expired ? 'Expired booking' : 'Unrecognized code',
      ),
      body: ScanResultView(
        icon: expired ? Icons.schedule_outlined : Icons.qr_code_2_outlined,
        iconBackground: expired ? AppStatus.warningBg : AppStatus.dangerBg,
        iconForeground: expired ? AppStatus.warning : AppStatus.danger,
        title: expired ? 'This booking has expired' : 'No matching record',
        message: expired
            ? 'This booking reference is no longer valid for entry. Ask the traveller to check their booking status.'
            : 'The code scanned is not a recognized AfyaMsafiri booking. Check the QR or enter the reference manually.',
        primaryLabel: 'Scan Again',
        primaryIcon: Icons.qr_code_scanner_outlined,
        onPrimary: () => context.pop(),
        secondaryLabel: 'Enter Booking Reference',
        onSecondary: () => context.push(AppRoutes.manualEntry),
        footer: expired
            ? null
            : Text(
                'Tip: AfyaMsafiri references start with TSFA.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
