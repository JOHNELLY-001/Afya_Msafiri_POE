import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../shared/providers/scan_provider.dart';
import '../../data/models/scan_result.dart';

class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    final repository = ref.read(scanRepositoryProvider);
    final result = await repository.validate(_controller.text);

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result.status) {
      case ScanStatus.valid:
        context.push(AppRoutes.scanSuccess, extra: result.bookingReference);
        break;
      case ScanStatus.invalid:
        setState(() => _error = 'Booking reference not recognized. Check and try again.');
        break;
      case ScanStatus.expired:
        context.push(AppRoutes.invalidQr, extra: 'expired');
        break;
      case ScanStatus.alreadyProcessed:
        context.push(AppRoutes.alreadyProcessed, extra: result.bookingReference);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Booking Reference')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the traveller\'s booking reference',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Use this if the QR code cannot be scanned.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _controller,
                label: 'Booking Reference',
                hint: 'e.g. AMS-2026-004821',
                prefixIcon: Icons.confirmation_number_outlined,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: 'Retrieve Record', loading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}