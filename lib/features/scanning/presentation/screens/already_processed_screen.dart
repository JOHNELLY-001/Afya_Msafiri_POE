import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';

class AlreadyProcessedScreen extends StatelessWidget {
  final String bookingReference;

  const AlreadyProcessedScreen({super.key, required this.bookingReference});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Traveller Already Processed')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 56, color: Theme.of(context).colorScheme.tertiary),
              const SizedBox(height: AppSpacing.md),
              Text('Traveller Already Processed', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This booking reference has already been recorded at a point of entry. Review the previous decision before taking further action.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row(context, 'Booking Reference', bookingReference),
                      const Divider(height: AppSpacing.lg),
                      _row(context, 'Previous Decision', 'Cleared'),
                      const Divider(height: AppSpacing.lg),
                      _row(context, 'Processed At', 'Julius Nyerere International Airport'),
                      const Divider(height: AppSpacing.lg),
                      _row(context, 'Date / Time', '24 Aug 2026, 09:14'),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Scan Again',
                icon: Icons.qr_code_scanner,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}