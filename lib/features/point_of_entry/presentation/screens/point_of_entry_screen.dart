import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/design_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/models/point_of_entry.dart';
import '../../../../shared/providers/session_provider.dart';
import '../widgets/poe_card.dart';

const _mockPoes = [
  PointOfEntry(code: 'JNIA', name: 'Julius Nyerere International Airport'),
  PointOfEntry(code: 'KIA', name: 'Kilimanjaro International Airport'),
  PointOfEntry(code: 'AAKIA', name: 'Abeid Amani Karume International Airport'),
];

class PointOfEntryScreen extends ConsumerStatefulWidget {
  const PointOfEntryScreen({super.key});

  @override
  ConsumerState<PointOfEntryScreen> createState() => _PointOfEntryScreenState();
}

class _PointOfEntryScreenState extends ConsumerState<PointOfEntryScreen> {
  PointOfEntry? _selected = _mockPoes.first;

  void _continue() {
    if (_selected == null) return;
    ref.read(sessionProvider.notifier).selectPointOfEntry(_selected!);
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POINT OF ENTRY'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text('Confirm duty station', style: Theme.of(context).textTheme.headlineMedium),
                // const SizedBox(height: AppSpacing.sm),
                // Text(
                //   'Select the point of entry where you are currently assigned.',
                //   style: Theme.of(context).textTheme.bodyMedium,
                // ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: _mockPoes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final poe = _mockPoes[index];
                    return PoeCard(
                      poe: poe,
                      selected: _selected?.code == poe.code,
                      onTap: () => setState(() => _selected = poe),
                    );
                  },
                ),
              ),
              AppButton(label: 'Confirm Duty Station', icon: Icons.check, onPressed: _continue),
            ],
          ),
        ),
      ),
    );
  }
}