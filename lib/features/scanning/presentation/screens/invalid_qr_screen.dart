import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';

class InvalidQrScreen extends StatelessWidget {
  final String? reason;

  const InvalidQrScreen({super.key, this.reason});

  @override
  Widget build(BuildContext context) {
    final expired = reason == 'expired';

    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Not Recognized')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, size: 56, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                expired ? 'This Booking Has Expired' : 'QR Code Not Recognized',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                expired
                    ? 'This booking reference is no longer valid for entry. Ask the traveller to check their booking status.'
                    : 'This could be due to an invalid booking reference, a connectivity issue, or no matching traveller record.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              AppButton(
                label: 'Scan Again',
                icon: Icons.qr_code_scanner,
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => context.push(AppRoutes.manualEntry),
                child: const Text('Enter Booking Reference'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}