import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/design_tokens.dart';
import '../../../../app/routes.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../widgets/scan_result_view.dart';

/// Brief success confirmation before the record opens automatically.
class ScanSuccessScreen extends StatefulWidget {
  final String bookingReference;

  const ScanSuccessScreen({super.key, required this.bookingReference});

  @override
  State<ScanSuccessScreen> createState() => _ScanSuccessScreenState();
}

class _ScanSuccessScreenState extends State<ScanSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      context.go(AppRoutes.travellerRecord, extra: widget.bookingReference);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AfyaAppBar(
        title: 'Traveller Found',
        subtitle: AfyaAppBar.shortRef(widget.bookingReference),
      ),
      body: ScanResultView(
        icon: Icons.check_circle_outline,
        iconBackground: AppStatus.successBg,
        iconForeground: AppStatus.success,
        title: 'Traveller found',
        message: 'A matching booking record was found. Opening it now…',
        bookingReference: widget.bookingReference,
        primaryLabel: 'Open Record Now',
        primaryIcon: Icons.arrow_forward_outlined,
        onPrimary: () =>
            context.go(AppRoutes.travellerRecord, extra: widget.bookingReference),
        footer: const SizedBox(
          width: 180,
          child: LinearProgressIndicator(minHeight: 3),
        ),
      ),
    );
  }
}
