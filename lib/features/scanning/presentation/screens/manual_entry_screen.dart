import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/design_tokens.dart';
import '../../../../app/theme.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/page_hero.dart';
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
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _error = 'Enter the booking reference first.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final repository = ref.read(scanRepositoryProvider);
    final result = await repository.validate(value);

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result.status) {
      case ScanStatus.valid:
        context.push(AppRoutes.scanSuccess, extra: result.bookingReference);
        break;
      case ScanStatus.invalid:
        setState(() =>
            _error = 'No booking found for "$value". Check the reference — it starts with TSFA.');
        break;
      case ScanStatus.expired:
        context.push(AppRoutes.invalidQr, extra: 'expired');
        break;
      case ScanStatus.alreadyProcessed:
        context.push(
            AppRoutes.alreadyProcessed, extra: result.bookingReference);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AfyaAppBar(
        title: 'Enter Booking Reference',
        subtitle: 'Fallback • No camera needed',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHero(
                icon: Icons.confirmation_number_outlined,
                title: 'Can\'t scan the QR?',
                subtitle:
                    'Type the booking reference printed on the traveller\'s documents. References start with TSFA.',
                from: AppTheme.primary,
                to: AppTheme.primaryContainer,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _controller,
                label: 'Booking Reference',
                hint: 'e.g. TSFA20260914065665',
                prefixIcon: Icons.confirmation_number_outlined,
                errorText: _error,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _submit(),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              const Spacer(),
              AppButton(
                label: 'Retrieve Record',
                icon: Icons.person_search_outlined,
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Demo refs (mock mode): TSFA-LOW-TEST → low risk • '
                'TSFA-HIGH-TEST → high risk • any other TSFA… → elevated risk.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
